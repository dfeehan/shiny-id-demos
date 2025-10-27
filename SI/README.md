# SI Disease Model Simulator

An interactive Shiny application that visualizes the Susceptible-Infected (SI) epidemic model, allowing users to explore disease spread in a simplified scenario without recovery.

## Overview

The SI model is a simplified epidemiological model that divides a population into two compartments:
- **S (Susceptible)**: Individuals who can be infected
- **I (Infected)**: Individuals currently infected (stay infected permanently)

## Model Details

The app uses a **fraction-based parameterization**, where all population compartments are represented as proportions (0 to 1) rather than absolute counts. This makes the model scale-independent and applicable to populations of any size.

### Differential Equations

- `dS/dt = -β × S × I`
- `dI/dt = β × S × I`

Where:
- S, I are fractions of the population (S + I = 1)
- β (beta) = transmission rate
- No recovery term (γ = 0 permanently)

Key insight: In the SI model, **everyone eventually gets infected** if β > 0, since there is no recovery and no immunity.

## When to Use SI vs SIR

### Use SI Model for:
- Diseases with permanent infection (no recovery)
- Early stages of epidemics (before recovery becomes significant)
- Certain chronic diseases
- Infections in closed populations with very slow recovery
- Pedagogical purposes (simpler model to learn)

### Use SIR Model for:
- Diseases with recovery and immunity
- Realistic long-term epidemic dynamics
- Modeling actual outbreaks where people recover
- Planning vaccination campaigns

## Features

- **Interactive Controls**: Adjust all model parameters in real-time
- **Time Series Plot**: Visualize how S and I evolve over time
- **Phase Plot**: Explore the S-I trajectory in phase space
- **Statistics**: View infection milestones (50%, 90%, 99% infected)
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
shiny::runApp("SI/app.R")
```

Option 2: Run in RStudio
- Open `SI/app.R` in RStudio
- Click the "Run App" button

## Usage

### Setting Initial Conditions

- Adjust `S₀` and `I₀` sliders to set initial population fractions
- The app will warn if these don't sum to 1.0
- Valid starting conditions automatically normalize to sum to unity

### Adjusting Disease Parameters

- **β (Transmission Rate)**: Controls how quickly susceptible individuals become infected
- Higher β = faster spread to everyone
- Lower β = slower spread but still leads to everyone infected eventually

### Interpreting Results

- **Everyone eventually gets infected** in the SI model (assuming β > 0)
- The only question is: how fast?
- Phase plot will show trajectory from (S₀, I₀) toward (0, 1)
- Statistics show time to reach different infection milestones

## Example Scenarios

### Slow Spread
- β = 0.1
- Initial: S₀ = 0.99, I₀ = 0.01
- Takes longer but everyone still gets infected

### Fast Spread  
- β = 0.6
- Initial: S₀ = 0.99, I₀ = 0.01
- Rapid infection of nearly the entire population

### Extremely Fast Spread
- β = 1.0
- Initial: S₀ = 0.99, I₀ = 0.01
- Very rapid infection of everyone

## Outputs

The app provides four main views:

1. **Time Series**: Plot showing S and I over time (no R compartment)
2. **Phase Plot**: S-I trajectory showing progression toward (0, 1)
3. **Statistics**: Infection milestones, final infected fraction, max infection rate
4. **Model Info**: Current parameters and model equations

## Key Differences from SIR Model

### Simplifications
- Only 2 compartments (S and I) instead of 3 (S, I, and R)
- No recovery term (γ = 0)
- No R₀ parameter (not well-defined in SI model)
- Simpler statistics (no herd immunity threshold)

### Mathematical Simplicity
- Only one parameter: β (transmission rate)
- Final outcome is deterministic: everyone becomes infected
- Phase plot shows simple curve from (S₀, I₀) to (0, 1)

### Biological Reality
- Less realistic than SIR for most diseases
- Useful for permanent infections or early epidemic stages
- Good pedagogical tool for understanding epidemic basics

## Technical Details

- **Solver**: Uses `deSolve::ode()` for numerical integration
- **Visualization**: Built with `ggplot2`
- **Interactive**: Real-time updates using Shiny reactives
- **Validation**: Automatic normalization of initial conditions

## Limitations

The SI model assumes:
- No recovery from infection
- No immunity
- Everyone eventually gets infected
- No demographic processes (births, deaths)
- Homogeneous mixing (everyone equally likely to contact anyone)

These assumptions may not hold for real epidemics, making the SI model more appropriate for:
- Permanent infections
- Early epidemic modeling
- Educational purposes
- Mathematical simplicity

## Comparison: SI vs SIR

| Feature | SI Model | SIR Model |
|---------|----------|-----------|
| Compartments | S, I | S, I, R |
| Recovery | No (γ = 0) | Yes (γ > 0) |
| Parameters | β only | β and γ |
| Final Outcome | Everyone infected | Epidemic burns out |
| Complexity | Simple | Moderate |
| Realism | Low | High |
| Use Case | Permanent infections | Most real epidemics |

## Future Enhancements

Potential additions:
- Side-by-side comparison with SIR model
- Ability to switch between SI and SIR modes
- SIS model (infection without immunity)
- SIRD model (with death compartment)
- Age-structured compartments
- Network-based spread
- Export simulation data

## References

- Kermack, W. O., & McKendrick, A. G. (1927). A contribution to the mathematical theory of epidemics. *Proceedings of the Royal Society of London*, 115(772), 700-721.
- Mathematical Biology textbooks for compartmental epidemic models

## License

This project is provided as-is for educational and research purposes.

