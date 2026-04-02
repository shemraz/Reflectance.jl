using Reflectance
using Test
using ImageCore

intoindex = Int∘ceil
downscale(i) = intoindex(1//8 * i)

@testset "API" begin
    img, model = loaddir(PTM, "data/ptm"; scale = 1//8)

    @testset "Types" begin
        @test img isa Matrix{RGB{N0f8}}
        @test model isa PTM
        @test model.data isa Array{Float64, 3}
        @test PTM <: AbstractBasis
    end

    @testset "Methods" begin
        lvec = (rand(Float64, 2)..., rand(Float64, 1) * -1)
        T = light(model, lvec)
        @test T isa Matrix{Float64}
    end
end
