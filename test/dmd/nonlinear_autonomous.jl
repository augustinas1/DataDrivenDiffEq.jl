@testset "Slow Manifold System" begin
  function slow_manifold(du, u, p, t)
    du[1] = p[1]*u[1]
    du[2] = p[2]*(u[2]-u[1]^2)
  end

  u0 = [3.0; -2.0]
  tspan = (0.0, 5.0)
  p = [-0.8; -0.7]

  problem = ODEProblem(slow_manifold, u0, tspan, p)
  solution = solve(problem, Tsit5(), saveat = 0.01)


  prob = ContinuousDataDrivenProblem(solution)

  @variables u[1:2]
  Ψ = Basis([u; u[1]^2], u)
  for alg in [DMDPINV(); DMDSVD(); TOTALDMD()]
    res = solve(prob, Ψ, alg, digits = 1)
    b = result(res)
    m = metrics(res)
    @test isapprox(eigvals(b), [2*p[1]; p[1]; p[2]], atol = 1e-1)
    @test m.Error/size(solution, 2) < 1e-1

    _prob = ODEProblem((args...)->b(args...), u0, tspan, parameters(res))
    _sol = solve(_prob, Tsit5(), saveat = solution.t)
    @test norm(solution - _sol)/size(solution, 2) < 1e-1
  end
end

@testset "Slow Manifold Discrete System" begin
  function slow_manifold(du, u, p, t)
    du[1] = p[1]*u[1]
    du[2] = p[2]*u[2]+(p[1]^2 - p[2])*u[1]^2
  end

  u0 = [3.0; -2.0]
  tspan = (0.0, 10.0)
  p = [-0.8; -0.7]

  problem = DiscreteProblem(slow_manifold, u0, tspan, p)
  solution = solve(problem, FunctionMap())

  ddprob = DiscreteDataDrivenProblem(solution)

  @variables u[1:2]

  Ψ = Basis([u[1]; u[1]^2; u[2]-u[1]^2], u)

  for alg in [DMDPINV(); DMDSVD(); TOTALDMD()]
    res = solve(ddprob, Ψ, alg, digits = 1)
    b = result(res)
    m = metrics(res)
    @test isapprox(eigvals(b), [p[1]; p[2]; p[1]^2], atol = 1e-1)
    @test m.Error/size(solution, 2) < 1e-1
  end
end
