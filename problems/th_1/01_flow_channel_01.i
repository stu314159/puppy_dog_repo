T_in = 300. # K
m_dot_in = 1e-1 # kg/s
press = 100e3 # Pa

[GlobalParams] # I assume all of these names are arbitrary? - no they are not.
  initial_p = ${press}
  initial_vel = 0.0001 # why not based on mass flow rate, density, and cross-sectional area?
  initial_T = ${T_in}
  gravity_vector = '0 0 0' # no gravity

  rdg_slope_reconstruction = minmod
  scaling_factor_1phase = '1 1e-2 1e-4'
  closures = thm_closures
  fp = he # fluid properties?
[]

[FluidProperties]
  [he]  # can this be replaced with a HeliumFluidProperties object?
    #type = HeliumFluidProperties # nope.  This didn't work.
    type = IdealGasFluidProperties
    molar_mass = 4e-3 # (kg/mol)
    gamma = 1.67 # unitless
    #k = 0.2556 # W/(m-K)
    k = 0.156027   # my value from EasyProp
    mu = 1.99365e-5 # my value from EasyProp
    #mu = 3.22639e-5 # (Pa-s)
  []
[]

[Closures]
  [thm_closures]
    type = Closures1PhaseTHM
  []
[]

[Components]
  [inlet]
    type = InletMassFlowRateTemperature1Phase
    input = 'core_chan:in'
    m_dot = ${m_dot_in}
    T = ${T_in}
  []

  [core_chan]
    type = FlowChannel1Phase
    position = '0 0 0'
    orientation = '0 0 1'
    length = 1
    n_elems = 25
    A = 7.2548e-3
    D_h = 7.0636e-2
  []

  [outlet]
    type = Outlet1Phase
    input = 'core_chan:out'
    p = ${press}
  []
[]

[Postprocessors]
  [core_p_in]
    type = SideAverageValue
    boundary = core_chan:in
    variable = p
  []

  [core_p_out]
    type = SideAverageValue
    boundary = core_chan:out
    variable = p
  []

  [core_delta_p]
    type = ParsedPostprocessor
    pp_names = 'core_p_in core_p_out'
    function = 'core_p_in - core_p_out'
  []
[]

[Preconditioning]
  [pc]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  line_search = basic

  start_time = 0
  end_time = 1000
  dt = 10

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  nl_max_its = 25



[]

[Outputs]
  #exodus = true
  #execute_on = 'timestep_end'
  [exodus]
    type = Exodus
    execute_on = 'initial final'
  []

  [console]
    type = Console
    max_rows = 1
    outlier_variable_norms = false
  []
  [csv]
    type = CSV  
    execute_on = timestep_end
  []
  print_linear_residuals = false
[]

