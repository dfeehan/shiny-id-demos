# Plan: SIR Disease Model Shiny App

## Overview
Create an interactive Shiny application that visualizes the Susceptible-Infected-Recovered (SIR) epidemic model. This app will allow users to explore how different parameters affect disease spread through a population.

## SIR Model Background

The SIR model divides a population into three compartments:
- **S (Susceptible)**: Individuals who can be infected
- **I (Infected)**: Individuals currently infected and contagious
- **R (Recovered)**: Individuals who have recovered and gained immunity

### Mathematical Model

The SIR model is defined by the following differential equations:

- `dS/dt = -β × S × I / N`
- `dI/dt = β × S × I / N - γ × I`
- `dR/dt = γ × I`

Where:
- β (beta) = transmission rate (rate of infection)
- γ (gamma) = recovery rate
- N = total population (S + I + R, constant)
- R₀ (R-naught) = β/γ = basic reproduction number

## App Structure

### Files to Create
1. `app.R` - Main Shiny application file (or separate `ui.R` and `server.R`)
2. `README.md` - User documentation
3. `.gitignore` - Version control exclusions

## User Interface (UI)

### Layout
- **Sidebar Panel**: Input controls for model parameters
- **Main Panel**: Visualizations and results

### Input Controls (Sidebar)
1. **Population Parameters**
   - `N` (Total population): Slider, default 10,000, range 100-1,000,000
   - `S0` (Initial Susceptible): Slider, default 9,990
   - `I0` (Initial Infected): Slider, default 10
   - `R0` (Initial Recovered): Slider, default 0 (or calculated)

2. **Disease Parameters**
   - `beta` (Transmission rate): Slider, default 0.3, range 0.01-1.0
   - `gamma` (Recovery rate): Slider, default 0.1, range 0.01-0.5
   - `R0` (R-naught): Dynamic display (β/γ) - read-only
   
3. **Simulation Parameters**
   - `t_max` (Time period): Slider, default 200 days, range 50-500
   - `dt` (Time step): Numeric input, default 0.1 days

4. **Visualization Options**
   - Show individual compartments checkbox
   - Show phase plot checkbox
   - Color scheme selector

### Output (Main Panel)
1. **Tab 1: Time Series Plot**
   - Line plot showing S, I, R over time
   - Y-axis: Number of people
   - X-axis: Time (days)
   - Interactive tooltips on hover
   - Option to download plot

2. **Tab 2: Phase Plot**
   - S-I phase space trajectory
   - Shows how susceptible and infected populations relate
   - Useful for understanding epidemic dynamics

3. **Tab 3: Statistics**
   - Peak infected count
   - Time to peak
   - Final recovered count
   - Epidemic duration (when I < threshold)
   - Total cases (peak infected + final recovered)

4. **Tab 4: Model Parameters Summary**
   - Current parameter values
   - R₀ value and interpretation
   - Model equations display

## Server Logic

### Key Functions

1. **SIR Model Differential Equations**
```r
sir_model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I / N
    dI <- beta * S * I / N - gamma * I
    dR <- gamma * I
    list(c(dS, dI, dR))
  })
}
```

2. **Simulation Function**
- Use `deSolve::ode()` to solve differential equations
- Returns data frame with time, S, I, R columns
- Handle edge cases (prevent negative populations)

3. **Statistics Calculation**
- Peak infected: `max(I)`
- Time to peak: `which.max(I)`
- Final recovered: `R[nrow(results)]`
- Epidemic duration: Find where `I < 1`

4. **Visualization**
- Use `ggplot2` for plots
- Consider `plotly` for interactivity
- Ensure proper scaling and aesthetics

### Reactive Elements
- Recompute model when any parameter changes
- Update R₀ display dynamically
- Cache results to avoid redundant calculations

## Implementation Steps

### Phase 1: Setup (30 min)
1. Create `app.R` file structure
2. Load required libraries (`shiny`, `deSolve`, `ggplot2`, `dplyr`)
3. Set up basic UI layout with sidebar and main panel
4. Add basic input controls

### Phase 2: Core Functionality (1 hour)
1. Implement SIR differential equation function
2. Create simulation function using `ode()` solver
3. Add reactive expression to run simulation
4. Create basic time series plot output

### Phase 3: Advanced Features (1 hour)
1. Add all parameter input controls
2. Implement statistics calculations
3. Create multiple visualization tabs
4. Add phase plot functionality
5. Implement R₀ dynamic display

### Phase 4: Polish (30 min)
1. Improve UI aesthetics (CSS, themes)
2. Add informative tooltips
3. Error handling for edge cases
4. Add parameter validation
5. Create README documentation

### Phase 5: Testing (30 min)
1. Test with various parameter combinations
2. Verify numerical stability
3. Check edge cases (R₀ < 1, R₀ >> 1)
4. Test responsiveness of interactive elements

## Technical Considerations

### Required R Packages
- `shiny` - Web application framework
- `deSolve` - Differential equation solver
- `ggplot2` - Plotting
- `dplyr` - Data manipulation
- `plotly` - Optional, for interactive plots

### Performance Optimization
- Use reactive caching for expensive computations
- Consider `bindCache()` for Shiny 1.6+
- Debounce rapid parameter changes

### Edge Cases to Handle
- R₀ < 1 (disease dies out quickly)
- Very high R₀ values (rapid spread)
- Initial conditions where S₀ + I₀ + R₀ ≠ N
- Negative values in calculations
- Division by zero scenarios

### Educational Enhancements
- Add tooltips explaining each parameter
- Include "Classic Epidemics" preset buttons (e.g., COVID-19, Flu)
- Add information panel explaining SIR model concepts
- Consider including herd immunity threshold visualization

## Future Enhancements (Optional)
1. SIRS model (waning immunity)
2. SEIR model (with exposed/incubation period)
3. Age-structured compartments
4. Vaccination campaigns
5. Multiple disease strains
6. Comparison between different scenarios
7. Export simulation data
8. Stochastic simulation option

## Success Criteria
- ✓ Smooth interaction with real-time updates
- ✓ Accurate SIR model implementation
- ✓ Clear, informative visualizations
- ✓ Educational value for users
- ✓ No crashes or errors with valid inputs
- ✓ Responsive design
- ✓ Well-documented code

## Timeline Estimate
- **Total Development Time**: 3-4 hours
- **Phase 1**: 30 minutes
- **Phase 2**: 1 hour
- **Phase 3**: 1 hour
- **Phase 4**: 30 minutes
- **Phase 5**: 30 minutes

## Resources
- deSolve package documentation: https://cran.r-project.org/web/packages/deSolve/
- Shiny documentation: https://shiny.rstudio.com/
- SIR model literature (Kermack & McKendrick, 1927)

