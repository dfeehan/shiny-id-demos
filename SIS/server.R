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
  
  # Display R0 (R-naught)
  output$R0_value <- renderText({
    r0 <- input$beta / input$gamma
    paste0("R₀ = ", round(r0, 3))
  })
  
  # Display equilibrium
  output$equilibrium_display <- renderText({
    r0 <- input$beta / input$gamma
    if (r0 <= 1) {
      "Equilibrium: Disease-Free (I* = 0)"
    } else {
      i_star <- 1 - 1/r0
      paste0("Equilibrium: I* = ", round(i_star, 4))
    }
  })
  
  # SIS Model Differential Equations
  sis_model <- function(t, state, parameters) {
    with(as.list(c(state, parameters)), {
      # S, I are fractions of population
      # People recover but immediately become susceptible again
      dS <- -beta * S * I + gamma * I
      dI <- beta * S * I - gamma * I
      
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
    parameters <- c(beta = input$beta, gamma = input$gamma)
    
    # Initial conditions
    initial_state <- c(S = S0_norm, I = I0_norm)
    
    # Time sequence
    times <- seq(0, input$t_max, by = input$dt)
    
    # Solve ODE
    out <- ode(y = initial_state, times = times, func = sis_model, parms = parameters)
    
    # Convert to data frame
    as.data.frame(out)
  })
  
  # Time series plot
  output$timeSeriesPlot <- renderPlot({
    data <- simulation_data()
    
    # Calculate equilibrium
    r0 <- input$beta / input$gamma
    i_equilibrium <- ifelse(r0 > 1, 1 - 1/r0, 0)
    
    # Reshape data for plotting
    plot_data <- data %>%
      select(time, S, I) %>%
      tidyr::pivot_longer(cols = c(S, I), names_to = "Compartment", values_to = "Fraction")
    
    p <- ggplot(plot_data, aes(x = time, y = Fraction, color = Compartment)) +
      geom_line(size = 1.2) +
      scale_color_manual(
        values = c("S" = "#2E86AB", "I" = "#A23B72"),
        labels = c("S" = "Susceptible", "I" = "Infected")
      ) +
      labs(
        title = "Evolution of SIS Compartments",
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
    
    # Add equilibrium line if R0 > 1 and checkbox is checked
    if (r0 > 1 && input$show_equilibrium) {
      p <- p + geom_hline(yintercept = i_equilibrium, linetype = "dashed", color = "#A23B72", size = 1) +
        annotate("text", x = max(data$time) * 0.9, y = i_equilibrium + 0.03, 
                 label = paste0("Equilibrium: ", round(i_equilibrium, 3)), 
                 color = "#A23B72", fontface = "bold", size = 4)
    }
    
    p
  })
  
  # Phase plot
  output$phasePlot <- renderPlot({
    data <- simulation_data()
    
    # Calculate equilibrium
    r0 <- input$beta / input$gamma
    i_equilibrium <- ifelse(r0 > 1, 1 - 1/r0, 0)
    s_equilibrium <- ifelse(r0 > 1, 1/r0, 1)
    
    # Extract start and end points
    start_point <- data.frame(S = data$S[1], I = data$I[1])
    end_point <- data.frame(S = data$S[nrow(data)], I = data$I[nrow(data)])
    equilibrium_point <- data.frame(S = s_equilibrium, I = i_equilibrium)
    
    ggplot(data, aes(x = S, y = I)) +
      geom_path(color = "#A23B72", size = 1.2) +
      geom_point(data = start_point, aes(x = S, y = I), color = "green", size = 4, shape = 16) +
      geom_point(data = end_point, aes(x = S, y = I), color = "red", size = 4, shape = 16) +
      geom_point(data = equilibrium_point, aes(x = S, y = I), color = "orange", size = 5, shape = 18) +
      labs(
        title = "S-I Phase Space Trajectory",
        x = "Susceptible Fraction",
        y = "Infected Fraction",
        subtitle = "Green = start, Red = end, Orange = equilibrium"
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
    r0 <- input$beta / input$gamma
    
    # Calculate equilibrium
    i_equilibrium <- ifelse(r0 > 1, 1 - 1/r0, 0)
    s_equilibrium <- ifelse(r0 > 1, 1/r0, 1)
    
    # Calculate statistics
    final_infected <- data$I[nrow(data)]
    final_susceptible <- data$S[nrow(data)]
    peak_infected <- max(data$I)
    
    # Find time to reach equilibrium (within 5%)
    time_to_eq <- NA
    if (r0 > 1) {
      threshold <- abs(data$I - i_equilibrium) <= 0.05 * i_equilibrium
      if (any(threshold)) {
        time_to_eq <- data$time[min(which(threshold))]
      }
    }
    
    # Find if overshoots equilibrium
    overshoot <- peak_infected > i_equilibrium
    
    stats_df <- data.frame(
      Metric = c(
        "R₀",
        "Equilibrium Infected Fraction",
        "Current Infected Fraction",
        "Final Susceptible Fraction",
        "Peak Infected Fraction",
        "Time to Equilibrium (days)",
        "Overshoot Occurs"
      ),
      Value = c(
        round(r0, 3),
        round(i_equilibrium, 4),
        round(final_infected, 4),
        round(final_susceptible, 4),
        round(peak_infected, 4),
        ifelse(is.na(time_to_eq), "Not reached", round(time_to_eq, 1)),
        ifelse(overshoot, "Yes", "No")
      ),
      stringsAsFactors = FALSE
    )
    
    stats_df
  }, digits = 4)
  
  # Interpretation
  output$interpretation <- renderText({
    data <- simulation_data()
    r0 <- input$beta / input$gamma
    i_equilibrium <- ifelse(r0 > 1, 1 - 1/r0, 0)
    final_infected <- data$I[nrow(data)]
    
    interpretation <- paste0(
      "SIS Model Analysis\n\n"
    )
    
    if (r0 <= 1) {
      interpretation <- paste0(interpretation,
        "• R₀ ≤ 1: Disease-free equilibrium\n",
        "• Disease will die out\n",
        "• Final infected: ", round(final_infected * 100, 1), "%\n"
      )
    } else {
      interpretation <- paste0(interpretation,
        "• R₀ > 1: Endemic equilibrium\n",
        "• Disease persists indefinitely\n",
        "• Equilibrium level: ", round(i_equilibrium * 100, 1), "%\n",
        "• Current level: ", round(final_infected * 100, 1), "%\n\n"
      )
      
      # Convergence assessment
      if (abs(final_infected - i_equilibrium) < 0.02) {
        interpretation <- paste0(interpretation,
          "✓ Has converged to equilibrium\n"
        )
      } else if (final_infected > i_equilibrium) {
        interpretation <- paste0(interpretation,
          "⊘ Still converging (above equilibrium)\n"
        )
      } else {
        interpretation <- paste0(interpretation,
          "⊘ Still converging (below equilibrium)\n"
        )
      }
      
      interpretation <- paste0(interpretation,
        "\nThis model assumes:\n",
        "• Recovery with no immunity\n",
        "• People cycle S → I → S\n",
        "• Disease persists at endemic level"
      )
    }
    
    interpretation
  })
  
  # Parameter table
  output$param_table <- renderTable({
    r0 <- input$beta / input$gamma
    data.frame(
      Parameter = c("S₀", "I₀", "β", "γ", "R₀ (beta/gamma)", "Equilibrium I*"),
      Value = c(
        input$S0,
        input$I0,
        input$beta,
        input$gamma,
        round(r0, 3),
        ifelse(r0 > 1, round(1 - 1/r0, 4), "0 (disease-free)")
      )
    )
  }, digits = 4)
}
