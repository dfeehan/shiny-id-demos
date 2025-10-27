# Plan: SIS Disease Model Shiny App

## Overview
Create an interactive Shiny application that visualizes the Susceptible-Infected-Susceptible (SIS) epidemic model. This app will allow users to explore how different parameters affect disease spread through a population with recovery but no long-term immunity.

## SIS Model Background

The SIS model divides a population into two compartments:
- **S (Susceptible)**: Individuals who can be infected
- **I (Infected)**: Individuals currently infected and contagious
- **Recovery**: Individuals recover but immediately become susceptible again (no immunity)

This model is useful for modeling:
- Diseases with recovery but no long-term immunity
- Gonorrhea and other bacterial infections
- Common cold and other short-immunity diseases
- Endemic diseases that persist in a population
- Situations where reinfection is common

### Mathematical Model

The SIS model is defined by the following differential equations (in terms of population fractions):

- `dS/dt = -β × S × I + γ × I`
- `dI/dt = β × S × I - γ × I`

Where:
- S, I = fractions of the population in each compartment (S + I = 1)
- β (beta) = transmission rate (rate of infection per susceptible per infected)
- γ (gamma) = recovery rate
- R₀ = β/γ = basic reproduction number

Key insight: Unlike SIR model, the SIS model reaches an **endemic equilibrium** (disease persists at constant level) rather than burning out. The equilibrium is:
- If R₀ ≤ 1: Disease-free equilibrium (I* = 0)
- If R₀ > 1: Endemic equilibrium where I* = 1 - γ/β = 1 - 1/R₀

## App Structure

### Files to Create
1. `app.R` - Main Shiny application file
2. `README.md` - User documentation
3. `.gitignore` - Version control exclusions

## User Interface (UI)

### Layout
- **Sidebar Panel**: Input controls for model parameters
- **Main Panel**: Visualizations and results

### Input Controls (Sidebar)
1. **Population Parameters (Fractions)**
   - `S0` (Initial Susceptible fraction): Slider, default 0.99, range 0-1, step 0.001
   - `I0` (Initial Infected fraction): Slider, default 0.01, range 0-1, step 0.001
   - Validation: Ensure S₀ + I₀ = 1 (auto-adjust or warn)

2. **Disease Parameters**
   - `beta` (Transmission rate): Slider, default 0.3, range 0.01-1.0
   - `gamma` (Recovery rate): Slider, default 0.1, range 0.01-1.0
   - `R0` (R-naught): Dynamic display (β/γ) - read-only
   
3. **Simulation Parameters**
   - `t_max` (Time period): Slider, default 300 days, range 50-1000
   - `dt` (Time step): Numeric input, default 0.1 days

4. **Visualization Options**
   - Show endemic equilibrium line checkbox
   - Show phase plot checkbox
   - Color scheme selector

### Output (Main Panel)
1. **Tab 1: Time Series Plot**
   - Line plot showing S and I over time
   - Y-axis: Fraction (proportion) of population (0 to 1)
   - X-axis: Time (days)
   - Show equilibrium line if R₀ > 1
   - Interactive tooltips on hover showing exact proportions
   - Option to download plot

2. **Tab 2: Phase Plot**
   - S-I phase space trajectory
   - Shows how susceptible and infected fractions evolve together
   - Will approach endemic equilibrium
   - Add equilibrium point marker

3. **Tab 3: Statistics**
   - Equilibrium infected fraction (calculated as I* = 1 - 1/R₀ if R₀ > 1)
   - Current infected fraction (at end of simulation)
   - Time to reach 50% of equilibrium
   - Time to reach 90% of equilibrium
   - Peak infected fraction (if overshoots equilibrium)
   - Infection rate (dI/dt) analysis

4. **Tab 4: Model Info**
   - Current parameter values
   - R₀ value and interpretation
   - Model equations display
   - Equilibrium formula
   - Comparison with SIR and SI models

## Server Logic

### Key Functions

1. **SIS Model Differential Equations**
```r
sis_model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    # S, I are fractions (proportions) of population
    # People recover but immediately become susceptible again
    dS <- -beta * S * I + gamma * I
    dI <- beta * S * I - gamma * I
    list(c(dS, dI))
  })
}
```

2. **Simulation Function**
- Use `deSolve::ode()` to solve differential equations
- Initialize state with S₀, I₀ as fractions (proportions between 0 and 1)
- Ensure initial conditions sum to 1
- Returns data frame with time, S, I columns (all as fractions)
- Handle edge cases (prevent negative fractions, ensure S + I = 1)
- Normalize results if needed to maintain S + I = 1

3. **Equilibrium Calculation**
   - Calculate R₀ = β/γ
   - If R₀ ≤ 1: equilibrium is disease-free (I* = 0)
   - If R₀ > 1: endemic equilibrium where I* = 1 - γ/β = 1 - 1/R₀
   - Display equilibrium values

4. **Statistics Calculation**
   - Equilibrium infected fraction: `1 - 1/R₀` if R₀ > 1, else 0
   - Current infected fraction: `I[nrow(results)]`
   - Time to reach equilibrium (within threshold, e.g., ±5%)
   - Peak infected fraction: `max(I)` (as proportion)
   - Overshoot analysis (if I peaks then decreases to equilibrium)

5. **Visualization**
   - Use `ggplot2` for plots
   - Show only 2 lines (S and I)
   - Add horizontal line for endemic equilibrium
   - Ensure proper scaling and aesthetics

### Reactive Elements
- Recompute model when any parameter changes
- Update R₀ display dynamically
- Update equilibrium display dynamically
- Cache results to avoid redundant calculations

## Implementation Steps

### Phase 1: Setup (20 min)
1. Create `app.R` file structure
2. Load required libraries (`shiny`, `deSolve`, `ggplot2`, `dplyr`, `tidyr`)
3. Set up basic UI layout with sidebar and main panel
4. Add basic input controls (only S and I, no R)

### Phase 2: Core Functionality (45 min)
1. Implement SIS differential equation function
2. Create simulation function using `ode()` solver
3. Add reactive expression to run simulation
4. Create basic time series plot output (S and I only)
5. Add equilibrium line to plot

### Phase 3: Advanced Features (45 min)
1. Add all parameter input controls
2. Implement equilibrium calculation
3. Implement statistics calculations
4. Create multiple visualization tabs
5. Add phase plot functionality with equilibrium point
6. Implement R₀ dynamic display

### Phase 4: Polish (30 min)
1. Improve UI aesthetics (CSS, themes)
2. Add informative tooltips
3. Error handling for edge cases
4. Add parameter validation
5. Create README documentation

### Phase 5: Testing (20 min)
1. Test with various parameter combinations
2. Verify numerical stability
3. Check edge cases (R₀ < 1, R₀ ≈ 1, R₀ >> 1)
4. Verify equilibrium convergence
5. Test responsiveness of interactive elements

## Technical Considerations

### Required R Packages
- `shiny` - Web application framework
- `deSolve` - Differential equation solver
- `ggplot2` - Plotting
- `dplyr` - Data manipulation
- `tidyr` - Data reshaping (for plotting)

### Performance Optimization
- Use reactive caching for expensive computations
- Consider `bindCache()` for Shiny 1.6+
- Debounce rapid parameter changes

### Edge Cases to Handle
- R₀ < 1 (disease dies out, I → 0)
- R₀ = 1 (critical threshold)
- R₀ > 1 (endemic equilibrium)
- Very high R₀ values (rapid spread, high endemic level)
- Initial conditions where S₀ + I₀ ≠ 1 (not summing to unity)
- Ensure S, I stay within [0, 1] bounds at all times
- Negative values in calculations (prevent negative rates)
- Numerical instability for very small fractions
- Check conservation: S + I should remain approximately equal to 1

### Educational Enhancements
- Add tooltips explaining each parameter
- Include preset buttons (e.g., "Disease-Free", "Endemic", "High Prevalence")
- Add information panel explaining SIS model concepts
- Visualize equilibrium convergence
- Compare endemic vs epidemic dynamics
- Explain why disease persists instead of burning out
- Show relationship: I* = 1 - 1/R₀

## Differences from SIR and SI Models

### Comparison

| Feature | SI | SIS | SIR |
|---------|-----|-----|-----|
| Recovery | No | Yes | Yes |
| Immunity | No | No | Yes |
| Compartments | S, I | S, I | S, I, R |
| Final Outcome | Everyone infected | Endemic equilibrium | Epidemic burns out |
| R₀ Relevant | No | Yes | Yes |
| Use Case | Permanent infection | No immunity disease | Immunity after recovery |

### SIS Characteristics

#### Recovery But No Immunity
- Like SIR: has recovery parameter γ
- Like SI: no separate R compartment (recovered become susceptible)
- People cycle: S → I → S → I → ...

#### Endemic Equilibrium
- Unlike SIR: disease doesn't burn out
- Unlike SI: not everyone gets infected
- Reaches steady state: I* = 1 - 1/R₀
- Disease persists indefinitely at equilibrium level

#### Real-World Examples
- Gonorrhea (bacterial, treatable, no immunity)
- Common cold (many strains, short immunity)
- Certain parasitic infections
- Hospital-acquired infections
- Computer viruses without patching

## Future Enhancements (Optional)
1. Side-by-side comparison with SIR and SI models
2. SEIS model (with exposed/incubation period)
3. Age-structured compartments
4. Treatment campaigns
5. Seasonal variation in β
6. Stochastic simulation option
7. Export simulation data
8. Animation showing convergence to equilibrium

## Success Criteria
- ✓ Smooth interaction with real-time updates
- ✓ Accurate SIS model implementation
- ✓ Clear display of endemic equilibrium
- ✓ Clear, informative visualizations
- ✓ Educational value for users
- ✓ No crashes or errors with valid inputs
- ✓ Responsive design
- ✓ Well-documented code
- ✓ Shows equilibrium convergence

## Timeline Estimate
- **Total Development Time**: 2.5-3 hours
- **Phase 1**: 20 minutes
- **Phase 2**: 45 minutes
- **Phase 3**: 45 minutes
- **Phase 4**: 30 minutes
- **Phase 5**: 20 minutes

## Resources
- deSolve package documentation: https://cran.r-project.org/web/packages/deSolve/
- Shiny documentation: https://shiny.rstudio.com/
- SIR model literature (Kermack & McKendrick, 1927)
- Endemic disease modeling literature
- Comparison of SI, SIS, and SIR models

## Key Insights

### Mathematical Understanding
1. **Equilibrium**: Unlike SIR, SIS reaches endemic equilibrium instead of burning out
2. **Formula**: I* = 1 - γ/β = 1 - 1/R₀ when R₀ > 1
3. **Critical Threshold**: R₀ = 1 is critical (below: disease-free, above: endemic)
4. **Overshoot**: System can overshoot equilibrium before settling

### Pedagogical Value
- Demonstrates concept of endemic vs epidemic diseases
- Shows role of R₀ in endemic level
- Illustrates recovery without immunity
- Useful for understanding persistent infections
- Bridge between SI (no recovery) and SIR (recovery with immunity)

### Biological Interpretation
- I* increases with R₀ (higher transmission → higher endemic level)
- I* decreases with γ (faster recovery → lower endemic level)
- Total population cycles between S and I
- No individuals stay "recovered" permanently
- Disease persists indefinitely if R₀ > 1

