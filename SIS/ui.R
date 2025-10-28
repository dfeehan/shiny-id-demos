# Check and install required packages if needed
packages <- c("shiny", "deSolve", "ggplot2", "dplyr", "tidyr")
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Define UI
ui <- fluidPage(
  
  titlePanel("SIS Model"),
  
  sidebarLayout(
    
    # Sidebar with input controls
    sidebarPanel(
      width = 3,
      
      h4("Initial Population Fractions"),
      helpText("Proportions must sum to 1"),
      
      sliderInput("S0", "Initial Susceptible (S₀):",
                  min = 0, max = 1, value = 0.99, step = 0.001),
      
      sliderInput("I0", "Initial Infected (I₀):",
                  min = 0, max = 1, value = 0.01, step = 0.001),
      
      #verbatimTextOutput("sum_check", placeholder = TRUE),
      
      hr(),
      
      h4("Disease Parameters"),
      
      sliderInput("beta", "Transmission Rate (β):",
                  min = 0.01, max = 1.0, value = 0.3, step = 0.01),
      
      sliderInput("gamma", "Recovery Rate (γ):",
                  min = 0.01, max = 1.0, value = 0.1, step = 0.01),
      
      verbatimTextOutput("R0_value"),
      
      verbatimTextOutput("equilibrium_display", placeholder = TRUE),
      
      hr(),
      
      h4("Simulation Parameters"),
      
      sliderInput("t_max", "Time Period (days):",
                  min = 50, max = 1000, value = 300, step = 10),
      
      numericInput("dt", "Time Step:",
                   min = 0.01, max = 1, value = 0.1, step = 0.05),
      
      hr(),
      
      h4("Display Options"),
      
      checkboxInput("show_equilibrium", "Show equilibrium line", value = FALSE)
    ),
    
    # Main panel with outputs
    mainPanel(
      width = 9,
      
      tabsetPanel(
        
        tabPanel("Time Series",
          h3("Population Fractions Over Time"),
          plotOutput("timeSeriesPlot", height = "500px"),
          helpText("Each compartment (S, I) is shown as a fraction of the total population.")
        ),
        
        tabPanel("Phase Plot",
          h3("S-I Phase Space Trajectory"),
          plotOutput("phasePlot", height = "500px"),
          helpText("The trajectory shows how the susceptible and infected fractions evolve together toward the endemic equilibrium.")
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
                "dS/dt = -β × S × I + γ × I",
                br(),
                "dI/dt = β × S × I - γ × I"
              ),
              br(),
              h4("Equilibrium"),
              div(style = "font-family: monospace; font-size: 14px;",
                "If R₀ > 1: I* = 1 - γ/β = 1 - 1/R₀",
                br(),
                "If R₀ ≤ 1: Disease-free (I* = 0)"
              ),
              br(),
              h4("Parameters"),
              tableOutput("param_table")
            ),
            column(4,
              h4("Notes"),
              helpText("S, I = fractions (proportions) of population"),
              helpText("S + I = 1 (conserved)"),
              helpText("β = transmission rate"),
              helpText("γ = recovery rate"),
              helpText("R₀ = β/γ"),
              helpText("People cycle S → I → S")
            )
          )
        )
      )
    )
  )
)
