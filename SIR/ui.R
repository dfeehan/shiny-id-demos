# Check and install required packages if needed
packages <- c("shiny", "deSolve", "ggplot2", "dplyr")
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Define UI
ui <- fluidPage(
  
  titlePanel("SIR Model"),
  
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
      
      #verbatimTextOutput("sum_check", placeholder = TRUE),
      
      hr(),
      
      h4("Disease Parameters"),
      
      sliderInput("beta", "Transmission Rate (β):",
                  min = 0.01, max = 1.0, value = 0.3, step = 0.01),
      
      sliderInput("gamma", "Recovery Rate (γ):",
                  min = 0.01, max = 1.0, value = 0.1, step = 0.01),
      
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
