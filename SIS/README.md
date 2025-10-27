# SIS Disease Model Simulator

An interactive Shiny application that visualizes the Susceptible-Infected-Susceptible (SIS) epidemic model, allowing users to explore disease spread with recovery but no long-term immunity.

## Overview

The SIS model divides a population into two compartments:
- **S (Susceptible)**: Individuals who can be infected
- **I (Infected)**: Individuals currently infected and contagious
- **Recovery**: Individuals recover but immediately become susceptible again (no immunity)

## Model Details

The app uses a **fraction-based parameterization**, where all population compartments are represented as proportions (0 to 1) rather than absolute counts. This makes the model scale-independent and applicable to populations of any size.

### Differential Equations

- `dS/dt = -β × S × I + γ × I`
- `dI/dt = β × S × I - γ × I`

Where:
- S, I are fractions of the population (S + I = 1)
- β (beta) = transmission rate
- γ (gamma) = recovery rate
- R₀ = β/γ = basic reproduction number

### Key Insight: Endemic Equilibrium

Unlike the SIR model (which burns out) or the SI model (where everyone gets infected), the SIS model reaches an **endemic equilibrium** - the disease persists indefinitely at a constant level.

- If R₀ ≤ 1: Disease-free equilibrium (I* = 0) - disease dies out
- If R₀ > 1: Endemic equilibrium where I* = 1 - γ/β = 1 - 1/R₀

The higher R₀, the higher the endemic infected fraction.

## Features

- **Interactive Controls**: Adjust all model parameters in real-time
- **Time Series Plot**: Visualize how S and I evolve over time with equilibrium line
- **Phase Plot**: Explore the S-I trajectory converging to endemic equilibrium
- **Statistics**: View equilibrium level, convergence time, overshoot analysis
- **Model Info**: Access equations, equilibrium formulas, and parameter documentation

## Installation

1. Ensure you have R (version 4.0 or higher) installed
2. Install required packages:

```r
install.packages(c("shiny", "deSolve", "ggplot2", "dplyr", "tidyr"))
```

## Running the App

Option 1: Run directly in R
```r
shiny::runApp("SIS/app.R")
```

Option 2: Run in RStudio
- Open `SIS/app.R` in RStudio
- Click the "Run App" button

## Usage

### Setting Initial Conditions

- Adjust `S₀` and `I₀` sliders to set initial population fractions
- The app will warn if these don't sum to 1.0
- Valid starting conditions automatically normalize to sum to unity

### Adjusting Disease Parameters

- **β (Transmission Rate)**: Controls how quickly susceptible individuals become infected
- **γ (Recovery Rate)**: Controls how quickly infected individuals recover
- **R₀ = β/γ**: Automatically calculated and displayed
- **Equilibrium**: Shown in real-time based on R₀

### Interpreting Results

- **R₀ ≤ 1**: Disease-free equilibrium - all infections eventually clear
- **R₀ > 1**: Endemic equilibrium - disease persists at level I* = 1 - 1/R₀
- The system will converge to equilibrium (may overshoot first)
- Higher R₀ = higher endemic infected fraction

## Example Scenarios

### Low R₀ (Disease-Free)
- β = 0.1, γ = 0.2 (R₀ = 0.5)
- Disease dies out completely
- Final: I = 0

### Moderate R₀ (Endemic)
- β = 0.3, γ = 0.15 (R₀ = 2.0)
- Equilibrium: I* = 0.5 (50% infected long-term)
- Disease persists at moderate level

### High R₀ (High Prevalence)
- β = 0.6, γ = 0.1 (R₀ = 6.0)
- Equilibrium: I* = 0.833 (83.3% infected long-term)
- High endemic level

## Outputs

The app provides four main views:

1. **Time Series**: Plot showing S and I over time with equilibrium line
2. **Phase Plot**: S-I trajectory converging to equilibrium point
3. **Statistics**: Equilibrium level, convergence metrics, overshoot analysis
4. **Model Info**: Current parameters, equilibrium formulas, equations

## Key Differences from SI and SIR Models

| Feature | SI | SIS | SIR |
|---------|-----|-----|-----|
| Compartments | S, I | S, I | S, I, R |
| Recovery | No (γ = 0) | Yes (γ > 0) | Yes (γ > 0) |
| Immunity | No | No | Yes |
| Parameters | β only | β, γ | β, γ |
| Final Outcome | Everyone infected | Endemic equilibrium | Epidemic burns out |
| R₀ Relevant | No | Yes | Yes |
| Use Case | Permanent infection | No immunity disease | Immunity after recovery |

## Real-World Applications

The SIS model is appropriate for:
- **Gonorrhea**: Bacterial infection, treatable with antibiotics, but no long-term immunity
- **Common cold**: Many strains, short-term immunity, reinfection common
- **Hospital-acquired infections**: Persistent in hospital environments
- **Computer viruses**: Without patching, systems cycle between susceptible and infected
- **Parasitic infections**: Without immunity, repeated infections occur

## Biological Interpretation

### Endemic Equilibrium
- Disease persists indefinitely at constant level
- Balance between new infections (β × S × I) and recoveries (γ × I)
- Not everyone gets infected (unlike SI)
- Disease doesn't burn out (unlike SIR)

### People Cycle
- S → I → S → I → S → ...
- No R compartment (recovered immediately become susceptible)
- Population constantly cycling between S and I
- At equilibrium: S* = 1/R₀, I* = 1 - 1/R₀

### Role of R₀
- R₀ determines endemic level, not just epidemic growth
- R₀ > 1: disease persists (higher R₀ → higher endemic level)
- R₀ ≤ 1: disease dies out
- Different from SIR where R₀ determines epidemic size before burn-out

## Mathematical Details

### Equilibrium Calculation

At equilibrium: dI/dt = 0

This gives:
- β × S × I - γ × I = 0
- I × (β × S - γ) = 0
- If I > 0: β × S = γ
- S = γ/β = 1/R₀
- I = 1 - S = 1 - γ/β = 1 - 1/R₀

### Convergence Behavior

- System may overshoot equilibrium before settling
- Final trajectory is spiral convergence to equilibrium
- Convergence time depends on parameters
- Initial conditions don't affect equilibrium level (only path)

## Technical Details

- **Solver**: Uses `deSolve::ode()` for numerical integration
- **Visualization**: Built with `ggplot2`
- **Interactive**: Real-time updates using Shiny reactives
- **Validation**: Automatic normalization of initial conditions
- **Equilibrium**: Calculated and displayed dynamically

## Limitations

The SIS model assumes:
- No immunity after recovery
- Homogeneous mixing
- No demographic processes (births, deaths)
- No external factors (vaccination, treatment programs)
- No age structure
- Constant parameters (no seasonal variation)

## Comparison: Three Models

### SI Model (No Recovery)
- Everyone eventually infected
- β is only parameter
- Useful for permanent infections

### SIS Model (Recovery, No Immunity) ← This App
- Endemic equilibrium
- β and γ parameters
- Useful for diseases with reinfection

### SIR Model (Recovery with Immunity)
- Epidemic burns out
- β and γ parameters
- Useful for most real epidemics

## Future Enhancements

Potential additions:
- Side-by-side comparison with SI and SIR models
- SEIS model (with exposed/incubation period)
- Treatment campaigns (temporarily changing γ)
- Seasonal variation in β
- Age-structured compartments
- Stochastic simulation option
- Export simulation data
- Animation showing convergence

## References

- Kermack, W. O., & McKendrick, A. G. (1927). A contribution to the mathematical theory of epidemics. *Proceedings of the Royal Society of London*, 115(772), 700-721.
- Endemic disease modeling literature
- Mathematical Epidemiology textbooks

## License

This project is provided as-is for educational and research purposes.

