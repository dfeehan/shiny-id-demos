# Plan: SI Disease Model Shiny App

## Overview
Create an interactive Shiny application that visualizes the Susceptible-Infected (SI) epidemic model. This app will allow users to explore how different parameters affect disease spread through a population without recovery.

## SI Model Background

The SI model divides a population into two compartments:
- **S (Susceptible)**: Individuals who can be infected
- **I (Infected)**: Individuals currently infected (stay infected permanently)

This model is useful for modeling:
- Diseases with permanent infection (no recovery)
- Early stages of epidemics (before recovery becomes significant)
- Infections in closed populations where recovery takes very long
- Certain chronic diseases

### Mathematical Model

The SI model is defined by the following differential equations (in terms of population fractions):

- `dS/dt = -β × S × I`
- `dI/dt = β × S × I`

Where:
- S, I = fractions of the population in each compartment (S + I = 1)
- β (beta) = transmission rate (rate of infection per susceptible per infected)
- No recovery term (γ = 0)
- Final outcome: everyone becomes infected eventually if β > 0

Note: In the SI model, the epidemic does not burn out - everyone eventually gets infected (assuming no other interventions).

## App Structure

### Files to Create
1. `app.R` - Main Shiny application file (simplified from SIR version)
2. `README.md` - User documentation
3. `.gitignore` - Version control exclusions (can inherit from parent)

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
   - Note: No recovery rate needed (γ = 0 permanently)

3. **Simulation Parameters**
   - `t_max` (Time period): Slider, default 200 days, range 50-1000
   - `dt` (Time step): Numeric input, default 0.1 days

4. **Visualization Options**
   - Show annotations checkbox
   - Show grid checkbox
   - Color scheme selector

### Output (Main Panel)
1. **Tab 1: Time Series Plot**
   - Line plot showing S and I over time
   - Y-axis: Fraction (proportion) of population (0 to 1)
   - X-axis: Time (days)
   - Interactive tooltips on hover showing exact proportions
   - Option to download plot
   - Annotation showing when most infections occur

2. **Tab 2: Phase Plot**
   - S-I phase space trajectory
   - Shows how susceptible and infected fractions evolve together
   - Will show a simple curve from (S₀, I₀) to (0, 1)

3. **Tab 3: Statistics**
   - Final infected fraction (should be 1.0 or very close)
   - Time to 50% infected
   - Time to 90% infected
   - Time to 99% infected
   - Infection rate analysis

4. **Tab 4: Model Info**
   - Current parameter values
   - Model equations display
   - Comparison with SIR model

## Server Logic

### Key Functions

1. **SI Model Differential Equations**
```r
si_model <- function(t, state, parameters) {
  with(as.list(c(state, parameters)), {
    # S, I are fractions (proportions) of population
    dS <- -beta * S * I
    dI <- beta * S * I
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

3. **Statistics Calculation**
   - Final infected fraction: `I[nrow(results)]` (as proportion)
   - Time to 50% infected: Find where `I >= 0.5`
   - Time to 90% infected: Find where `I >= 0.9`
   - Time to 99% infected: Find where `I >= 0.99`
   - Maximum infection rate: `max(diff(I))` over time

4. **Visualization**
   - Use `ggplot2` for plots
   - Simpler than SIR (only 2 lines)
   - Ensure proper scaling and aesthetics
   - Add annotations for key time points

### Reactive Elements
- Recompute model when any parameter changes
- Dynamic display of infection milestones
- Cache results to avoid redundant calculations

## Implementation Steps

### Phase 1: Setup (20 min)
1. Create `app.R` file structure
2. Load required libraries (`shiny`, `deSolve`, `ggplot2`, `dplyr`, `tidyr`)
3. Set up basic UI layout with sidebar and main panel
4. Add basic input controls (simplified - no R compartment)

### Phase 2: Core Functionality (45 min)
1. Implement SI differential equation function
2. Create simulation function using `ode()` solver
3. Add reactive expression to run simulation
4. Create basic time series plot output (only S and I)

### Phase 3: Advanced Features (45 min)
1. Add all parameter input controls
2. Implement statistics calculations
3. Create multiple visualization tabs
4. Add phase plot functionality
5. Implement milestone displays

### Phase 4: Polish (30 min)
1. Improve UI aesthetics (CSS, themes)
2. Add informative tooltips
3. Error handling for edge cases
4. Add parameter validation
5. Create README documentation

### Phase 5: Testing (20 min)
1. Test with various parameter combinations
2. Verify numerical stability
3. Check edge cases (β = 0, β very large)
4. Test responsiveness of interactive elements

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
- β = 0 (no infection)
- Very high β values (rapid spread to everyone)
- Initial conditions where S₀ + I₀ ≠ 1 (not summing to unity)
- Ensure S, I stay within [0, 1] bounds at all times
- Negative values in calculations (prevent negative rates)
- Numerical instability for very small fractions
- Check conservation: S + I should remain approximately equal to 1

### Educational Enhancements
- Add tooltips explaining each parameter
- Include preset buttons (e.g., "Slow Spread", "Fast Spread")
- Add information panel explaining SI model concepts
- Explain why people eventually all get infected
- Compare SI vs SIR models
- Show when SI model is appropriate to use

## Differences from SIR Model

### Simpler Model
- Only 2 compartments (S and I) instead of 3 (S, I, and R)
- No recovery term (γ = 0)
- Everyone eventually becomes infected (assuming β > 0)
- No epidemic "burn out"

### UI Simplifications
- No R₀ display (not well-defined in SI model)
- No herd immunity threshold
- Simpler statistics
- Fewer controls (no gamma parameter)

### When to Use SI vs SIR
- **SI Model**: No recovery possible, permanent infection, early epidemic stages
- **SIR Model**: Recovery with immunity (or death), realistic long-term dynamics

## Future Enhancements (Optional)
1. Side-by-side comparison with SIR model
2. Ability to switch between SI and SIR models
3. Add death compartment (SIR → SIRD)
4. Age-structured compartments
5. Network-based spread
6. Export simulation data
7. Stochastic simulation option

## Success Criteria
- ✓ Smooth interaction with real-time updates
- ✓ Accurate SI model implementation
- ✓ Clear, informative visualizations
- ✓ Educational value for users
- ✓ No crashes or errors with valid inputs
- ✓ Responsive design
- ✓ Well-documented code
- ✓ Shows that eventually everyone gets infected

## Timeline Estimate
- **Total Development Time**: 2-3 hours
- **Phase 1**: 20 minutes
- **Phase 2**: 45 minutes
- **Phase 3**: 45 minutes
- **Phase 4**: 30 minutes
- **Phase 5**: 20 minutes

## Resources
- deSolve package documentation: https://cran.r-project.org/web/packages/deSolve/
- Shiny documentation: https://shiny.rstudio.com/
- SIR model literature (Kermack & McKendrick, 1927)
- Comparison of SI vs SIR models

## Key Insight
The SI model is mathematically simpler but biologically less realistic than the SIR model. It serves as a useful pedagogical tool and approximation for diseases without recovery. In the real world, most epidemics follow SIR or similar dynamics with recovery.

