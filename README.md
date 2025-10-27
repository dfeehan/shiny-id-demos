# SIR Disease Model Simulator

An interactive Shiny application that visualizes the Susceptible-Infected-Recovered (SIR) epidemic model, allowing users to explore how different parameters affect disease spread through a population.

## Overview

The SIR model is a classic epidemiological model that divides a population into three compartments:
- **S (Susceptible)**: Individuals who can be infected
- **I (Infected)**: Individuals currently infected and contagious
- **R (Recovered)**: Individuals who have recovered and gained immunity

## Model Details

The app uses a **fraction-based parameterization**, where all population compartments are represented as proportions (0 to 1) rather than absolute counts. This makes the model scale-independent and applicable to populations of any size.

### Differential Equations

- `dS/dt = -β × S × I`
- `dI/dt = β × S × I - γ × I`
- `dR/dt = γ × I`

Where:
- S, I, R are fractions of the population (S + I + R = 1)
- β (beta) = transmission rate
- γ (gamma) = recovery rate
- R₀ = β/γ = basic reproduction number

## Features

- **Interactive Controls**: Adjust all model parameters in real-time
- **Time Series Plot**: Visualize how each compartment evolves over time
- **Phase Plot**: Explore the S-I trajectory in phase space
- **Statistics**: View key epidemic metrics including peak infections and herd immunity threshold
- **Model Info**: Access equations and parameter documentation

## Installation

1. Ensure you have R (version 4.0 or higher) installed
2. Install required packages:

```r
install.packages(c("shiny", "deSolve", "ggplot2", "dplyr", "tidyr"))
```

## Running the App

Option 1: Run directly in R
```r
shiny::runApp("app.R")
```

Option 2: Run in RStudio
- Open `app.R` in RStudio
- Click the "Run App" button

## Usage

### Setting Initial Conditions

- Adjust `S₀`, `I₀`, and `R₀` sliders to set initial population fractions
- The app will warn if these don't sum to 1.0
- Valid starting conditions automatically normalize to sum to unity

### Adjusting Disease Parameters

- **β (Transmission Rate)**: Controls how quickly susceptible individuals become infected
- **γ (Recovery Rate)**: Controls how quickly infected individuals recover
- **R₀**: Automatically calculated as β/γ

### Interpreting Results

- **R₀ < 1**: Disease dies out, no epidemic
- **R₀ = 1**: Critical threshold
- **R₀ > 1**: Epidemic will occur

The herd immunity threshold is 1 - 1/R₀ (the fraction that must be immune to stop transmission).

## Example Scenarios

### COVID-19-like
- β = 0.3, γ = 0.1 (R₀ ≈ 3)
- Initial: S₀ = 0.99, I₀ = 0.01, R₀ = 0

### Seasonal Flu-like
- β = 0.2, γ = 0.15 (R₀ ≈ 1.3)
- Initial: S₀ = 0.98, I₀ = 0.02, R₀ = 0

### High Transmissibility
- β = 0.6, γ = 0.1 (R₀ ≈ 6)
- Initial: S₀ = 0.999, I₀ = 0.001, R₀ = 0

## Outputs

The app provides four main views:

1. **Time Series**: Plot showing S, I, R over time
2. **Phase Plot**: S-I trajectory showing epidemic dynamics
3. **Statistics**: Peak infections, duration, final outcomes, herd immunity threshold
4. **Model Info**: Current parameters and model equations

## Technical Details

- **Solver**: Uses `deSolve::ode()` for numerical integration
- **Visualization**: Built with `ggplot2`
- **Interactive**: Real-time updates using Shiny reactives
- **Validation**: Automatic normalization of initial conditions

## Future Enhancements

Potential additions:
- SIRS model (waning immunity)
- SEIR model (with exposed/incubation period)
- Multiple scenarios comparison
- Stochastic simulation option
- Age-structured compartments
- Export simulation data

## References

- Kermack, W. O., & McKendrick, A. G. (1927). A contribution to the mathematical theory of epidemics. *Proceedings of the Royal Society of London*, 115(772), 700-721.

## License

This project is provided as-is for educational and research purposes.

