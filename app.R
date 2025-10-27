library(shiny)
library(deSolve)
library(ggplot2)
library(dplyr)

# Define UI
ui <- fluidPage(
  
  titlePanel("SIR Disease Model Simulator"),
  
  sidebarLayout(
    
    # Sidebar with input controls
    sidebarPanel(
      width = 3,
      
      h4("Initial Population Fractions"),
      helpText("Proportions must sum to 1"),
      
      sliderInput("S0", "Initial Susceptible (S₀):",
                  min = 0, max = 1, value = 0.999, step = 0.001),
      
      sliderInput("I0", "Initial Infected (I₀):",
                  min = 0, max = 1, value = 0.001, step = 0.0001),
      
      sliderInput("R0", "Initial Recovered (R₀):",
                  min = 0, max = 1, value = 0, step = 0.001),
      
      verbatimTextOutput("sum_check", placeholder = TRUE),
      
      hr(),
      
      h4("Disease Parameters"),
      
      sliderInput("beta", "Transmission Rate (β):",
                  min = 0.01, max = 1.0, value = 0.3, step = 0.01),
      
      sliderInput("gamma", "Recovery Rate (γ):",
                  min = 0.01, max = 0.5, value = 0.1, step = 0.01),
      
      verbatimTextOutput("R0_value"),
      
      hr(),
      
      h4("Simulation Parameters"),
      
      sliderInput("t_max", "Time Period (days):",
                  min = 50, max = 500, value = 200, step = 10),
      
      numericInput("dt", "Time Step:",
                   min = 0.01, max = 1, value = 0.1, step = 0.05)
    ),
    
    # Main panel with outputs
    mainPanel(
      width = 9,
      
      tabsetPanel(
        
        tabPanel("Time Series",
          h3("Population Fractions Over Time"),
          plotOutput("timeSeriesPlot", height = "500px"),
          helpText("Each compartment (S, I, R) is shown as a fraction of the total population.")
        ),
        
        tabPanel("Phase Plot",
          h3("S-I Phase Space Trajectory"),
          plotOutput("phasePlot", height = "500px"),
          helpText("The trajectory shows how the susceptible and infected fractions evolve together.")
        ),
        
        tabPanel("Statistics",
          h3("Epidemic Statistics"),
          fluidRow(
            column(6,
              h4("Key Metrics"),
              tableOutput("statistics_table")
            ),
            column(6,
              h4("Interpretation"),
              verbatimTextOutput("interpretation")
            )
          )
        ),
        
        tabPanel("Model Info",
          h3("Model Equations"),
          fluidRow(
            column(8,
              h4("Differential Equations"),
              div(style = "font-family: monospace; font-size: 14px;",
                "dS/dt = -β × S × I",
                br(),
                "dI/dt = β × S × I - γ × I",
                br(),
                "dR/dt = γ × I"
              ),
              br(),
              h4("Parameters"),
              tableOutput("param_table")
            ),
            column(4,
              h4("Notes"),
              helpText("S, I, R = fractions (proportions) of population"),
              helpText("S + I + R = 1 (conserved)"),
              helpText("β = transmission rate"),
              helpText("γ = recovery rate"),
              helpText("R₀ = β/γ = basic reproduction number")
            )
          )
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Check that initial conditions sum to 1
  output$sum_check <- renderText({
    total <- input$S0 + input$I0 + input$R0
    if (abs(total - 1) > 0.01) {
      paste0("⚠️ Sum = ", round(total, 3), " (should be 1)")
    } else {
      paste0("✓ Sum = ", round(total, 3))
    }
  })
  
  # Display R0 (R-naught)
  output$R0_value <- renderText({
    r0 <- input$beta / input$gamma
    paste0("R₀ = ", round(r0, 3))
  })
  
  # SIR Model Differential Equations
  sir_model <- function(t, state, parameters) {
    with(as.list(c(state, parameters)), {
      # S, I, R are fractions of population
      dS <- -beta * S * I
      dI <- beta * S * I - gamma * I
      dR <- gamma * I
      
      list(c(dS, dI, dR))
    })
  }
  
  # Run simulation
  simulation_data <- reactive({
    # Normalize initial conditions to sum to 1
    S0_norm <- input$S0
    I0_norm <- input$I0
    R0_norm <- input$R0
    total <- S0_norm + I0_norm + R0_norm
    
    if (abs(total - 1) > 0.01) {
      # Normalize
      S0_norm <- S0_norm / total
      I0_norm <- I0_norm / total
      R0_norm <- R0_norm / total
    }
    
    # Parameters
    parameters <- c(beta = input$beta, gamma = input$gamma)
    
    # Initial conditions
    initial_state <- c(S = S0_norm, I = I0_norm, R = R0_norm)
    
    # Time sequence
    times <- seq(0, input$t_max, by = input$dt)
    
    # Solve ODE
    out <- ode(y = initial_state, times = times, func = sir_model, parms = parameters)
    
    # Convert to data frame
    as.data.frame(out)
  })
  
  # Time series plot
  output$timeSeriesPlot <- renderPlot({
    data <- simulation_data()
    
    # Reshape data for plotting
    plot_data <- data %>%
      select(time, S, I, R) %>%
      tidyr::pivot_longer(cols = c(S, I, R), names_to = "Compartment", values_to = "Fraction")
    
    ggplot(plot_data, aes(x = time, y = Fraction, color = Compartment)) +
      geom_line(size = 1.2) +
      scale_color_manual(
        values = c("S" = "#2E86AB", "I" = "#A23B72", "R" = "#F18F01"),
        labels = c("S" = "Susceptible", "I" = "Infected", "R" = "Recovered")
      ) +
      labs(
        title = "Evolution of SIR Compartments",
        x = "Time (days)",
        y = "Fraction of Population",
        color = "Compartment"
      ) +
      ylim(0, 1) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        legend.position = "top",
        legend.text = element_text(size = 12),
        axis.text = element_text(size = 11),
        axis.title = element_text(size = 12)
      )
  })
  
  # Phase plot
  output$phasePlot <- renderPlot({
    data <- simulation_data()
    
    ggplot(data, aes(x = S, y = I)) +
      geom_path(color = "#A23B72", size = 1.2) +
      geom_point(aes(x = S[1], y = I[1]), color = "green", size = 3) +
      geom_point(aes(x = S[n()], y = I[n()]), color = "red", size = 3) +
      labs(
        title = "S-I Phase Space Trajectory",
        x = "Susceptible Fraction",
        y = "Infected Fraction",
        subtitle = "Green = start, Red = end"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 12),
        axis.text = element_text(size = 11),
        axis.title = element_text(size = 12)
      )
  })
  
  # Statistics table
  output$statistics_table <- renderTable({
    data <- simulation_data()
    
    # Calculate statistics
    peak_infected <- max(data$I)
    peak_time <- data$time[which.max(data$I)]
    final_recovered <- data$R[nrow(data)]
    final_susceptible <- data$S[nrow(data)]
    
    # Find when epidemic ends (I < threshold)
    threshold <- 0.001
    epidemic_data <- data[data$I >= threshold, ]
    if (nrow(epidemic_data) > 0) {
      epidemic_duration <- max(epidemic_data$time) - min(epidemic_data$time)
    } else {
      epidemic_duration <- 0
    }
    
    # Herd immunity threshold
    r0 <- input$beta / input$gamma
    herd_threshold <- ifelse(r0 > 1, 1 - 1/r0, NA)
    
    stats_df <- data.frame(
      Metric = c(
        "Peak Infected Fraction",
        "Time to Peak (days)",
        "Final Recovered Fraction",
        "Final Susceptible Fraction",
        "Epidemic Duration (days)",
        "Herd Immunity Threshold"
      ),
      Value = c(
        round(peak_infected, 4),
        round(peak_time, 1),
        round(final_recovered, 4),
        round(final_susceptible, 4),
        round(epidemic_duration, 1),
        ifelse(is.na(herd_threshold), "N/A (R₀ ≤ 1)", round(herd_threshold, 4))
      ),
      stringsAsFactors = FALSE
    )
    
    stats_df
  }, digits = 4)
  
  # Interpretation
  output$interpretation <- renderText({
    data <- simulation_data()
    r0 <- input$beta / input$gamma
    
    # Determine epidemic behavior
    peak_infected <- max(data$I)
    
    interpretation <- paste0(
      "R₀ = ", round(r0, 3), "\n\n"
    )
    
    if (r0 < 1) {
      interpretation <- paste0(interpretation, 
        "• R₀ < 1: Disease dies out\n",
        "• Outbreak will not spread\n",
        "• Initial cases will decline\n"
      )
    } else if (r0 == 1) {
      interpretation <- paste0(interpretation,
        "• R₀ = 1: Critical threshold\n",
        "• Epidemics are possible\n"
      )
    } else {
      interpretation <- paste0(interpretation,
        "• R₀ > 1: Epidemic will occur\n",
        "• ", round((1 - data$S[nrow(data)]) * 100, 1), "% of population infected\n",
        "• Peak infection: ", round(peak_infected * 100, 1), "%\n"
      )
    }
    
    interpretation
  })
  
  # Parameter table
  output$param_table <- renderTable({
    data.frame(
      Parameter = c("S₀", "I₀", "R₀", "β", "γ", "R₀ (beta/gamma)"),
      Value = c(
        input$S0,
        input$I0,
        input$R0,
        input$beta,
        input$gamma,
        round(input$beta / input$gamma, 3)
      )
    )
  }, digits = 4)
}

# Run the application
shinyApp(ui = ui, server = server)

