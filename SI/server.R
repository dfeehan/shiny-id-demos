# Define server logic
server <- function(input, output, session) {
  
  # Check that initial conditions sum to 1
  output$sum_check <- renderText({
    total <- input$S0 + input$I0
    if (abs(total - 1) > 0.01) {
      paste0("⚠️ Sum = ", round(total, 3), " (should be 1)")
    } else {
      paste0("✓ Sum = ", round(total, 3))
    }
  })
  
  # SI Model Differential Equations
  si_model <- function(t, state, parameters) {
    with(as.list(c(state, parameters)), {
      # S, I are fractions of population
      dS <- -beta * S * I
      dI <- beta * S * I
      
      list(c(dS, dI))
    })
  }
  
  # Run simulation
  simulation_data <- reactive({
    # Normalize initial conditions to sum to 1
    S0_norm <- input$S0
    I0_norm <- input$I0
    total <- S0_norm + I0_norm
    
    if (abs(total - 1) > 0.01) {
      # Normalize
      S0_norm <- S0_norm / total
      I0_norm <- I0_norm / total
    }
    
    # Parameters
    parameters <- c(beta = input$beta)
    
    # Initial conditions
    initial_state <- c(S = S0_norm, I = I0_norm)
    
    # Time sequence
    times <- seq(0, input$t_max, by = input$dt)
    
    # Solve ODE
    out <- ode(y = initial_state, times = times, func = si_model, parms = parameters)
    
    # Convert to data frame
    as.data.frame(out)
  })
  
  # Time series plot
  output$timeSeriesPlot <- renderPlot({
    data <- simulation_data()
    
    # Reshape data for plotting
    plot_data <- data %>%
      select(time, S, I) %>%
      tidyr::pivot_longer(cols = c(S, I), names_to = "Compartment", values_to = "Fraction")
    
    ggplot(plot_data, aes(x = time, y = Fraction, color = Compartment)) +
      geom_line(size = 1.2) +
      scale_color_manual(
        values = c("S" = "#2E86AB", "I" = "#A23B72"),
        labels = c("S" = "Susceptible", "I" = "Infected")
      ) +
      labs(
        title = "Evolution of SI Compartments",
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
    final_infected <- data$I[nrow(data)]
    final_susceptible <- data$S[nrow(data)]
    
    # Find infection milestones
    time_50 <- NA
    time_90 <- NA
    time_99 <- NA
    
    if (any(data$I >= 0.5)) {
      time_50 <- data$time[min(which(data$I >= 0.5))]
    }
    if (any(data$I >= 0.9)) {
      time_90 <- data$time[min(which(data$I >= 0.9))]
    }
    if (any(data$I >= 0.99)) {
      time_99 <- data$time[min(which(data$I >= 0.99))]
    }
    
    # Calculate maximum infection rate
    infection_rates <- diff(data$I) / diff(data$time)
    max_rate <- max(infection_rates)
    max_rate_time <- data$time[which.max(infection_rates)]
    
    stats_df <- data.frame(
      Metric = c(
        "Final Infected Fraction",
        "Final Susceptible Fraction",
        "Time to 50% Infected (days)",
        "Time to 90% Infected (days)",
        "Time to 99% Infected (days)",
        "Max Infection Rate (1/day)"
      ),
      Value = c(
        round(final_infected, 4),
        round(final_susceptible, 4),
        ifelse(is.na(time_50), "Not reached", round(time_50, 1)),
        ifelse(is.na(time_90), "Not reached", round(time_90, 1)),
        ifelse(is.na(time_99), "Not reached", round(time_99, 1)),
        round(max_rate, 4)
      ),
      stringsAsFactors = FALSE
    )
    
    stats_df
  }, digits = 4)
  
  # Interpretation
  output$interpretation <- renderText({
    data <- simulation_data()
    
    final_infected <- data$I[nrow(data)]
    
    interpretation <- paste0(
      "SI Model Analysis\n\n"
    )
    
    interpretation <- paste0(interpretation,
      "• Everyone eventually gets infected\n",
      "• Final infected fraction: ", round(final_infected * 100, 1), "%\n",
      "• No recovery means S → 0 over time\n\n"
    )
    
    if (final_infected > 0.99) {
      interpretation <- paste0(interpretation,
        "✓ Nearly everyone is infected (>99%)\n"
      )
    } else if (final_infected > 0.9) {
      interpretation <- paste0(interpretation,
        "⊖ Most people are infected (>90%)\n"
      )
    } else {
      interpretation <- paste0(interpretation,
        "⊘ Infection rate is slow\n",
        "   Simulation may need more time\n"
      )
    }
    
    interpretation <- paste0(interpretation,
      "\nThis model assumes:\n",
      "• No recovery (permanent infection)\n",
      "• No immunity\n",
      "• Eventually everyone gets infected"
    )
    
    interpretation
  })
  
  # Parameter table
  output$param_table <- renderTable({
    data.frame(
      Parameter = c("S₀", "I₀", "β"),
      Value = c(
        input$S0,
        input$I0,
        input$beta
      )
    )
  }, digits = 4)
}
