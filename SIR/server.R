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
    #paste0("R₀ = ", round(r0, 3))
    paste0("R0 = ", round(r0, 3))
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
    
    # Extract start and end points
    start_point <- data.frame(S = data$S[1], I = data$I[1])
    end_point <- data.frame(S = data$S[nrow(data)], I = data$I[nrow(data)])
    
    ggplot(data, aes(x = S, y = I)) +
      geom_path(color = "#A23B72", size = 1.2) +
      geom_point(data = start_point, aes(x = S, y = I), color = "green", size = 4, shape = 16) +
      geom_point(data = end_point, aes(x = S, y = I), color = "red", size = 4, shape = 16) +
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
