using DataDrivenDiffEq
using DataDrivenDiffEq.Optimize
using ModelingToolkit

using LinearAlgebra
using SafeTestsets
using Random

@info "Loading OrdinaryDiffEq"
using OrdinaryDiffEq

using Test
@info "Finished loading packages"

const GROUP = get(ENV, "GROUP", "All")

@time begin
    if GROUP == "All" || GROUP == "DataDrivenDiffEq" || GROUP == "Standard"
        @testset "Basis" begin include("./basis/basis.jl") end
        @testset "Basis Generators" begin include("./basis/generators.jl") end
        @testset "DataDrivenProblem" begin include("./problem.jl") end

        @testset "Sparse Identification" begin
            @testset "Pendulum" begin include("./sindy/pendulum.jl") end
            @testset "Michaelis Menten" begin include("./sindy/michaelis_menten.jl") end
            @testset "Cartpole" begin include("./sindy/cartpole.jl") end
        end

        @testset "Koopman" begin
            @testset "Linear Autonomous" begin include("./dmd/linear_autonomous.jl") end
            @testset "Linear Forced" begin include("./dmd/linear_forced.jl") end
            @testset "Nonlinear Autonomous" begin include("./dmd/nonlinear_autonomous.jl") end
            @testset "Nonlinear Forced" begin include("./dmd/nonlinear_forced.jl") end
        end

        include("./utils.jl")
    end

    if GROUP == "All" || GROUP == "Optional"

        @info "Loading Flux"
        using Flux
        @info "Loading Symbolic Regression"
        using SymbolicRegression

        @testset "Symbolic Regression" begin
            @testset "OccamNet" begin include("./symbolic_regression/occamnet.jl") end
            @testset "SymbolicRegression" begin include("./symbolic_regression/symbolic_regression.jl") end
        end
    end

    # These are excluded right now, until the deps are figured out
    #if GROUP == "Integration" || GROUP == "All"
    #    @safetestset "Partial Lotka Volterra Discovery " begin include("./applications/partial_lotka_volterra.jl") end
    #end
end
