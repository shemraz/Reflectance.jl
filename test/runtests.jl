using Test
using Reflectance

@testset "reading relight format" begin
    rl = Reflectance.load(PTM, "ptm/")
    @test rl isa PTM
    @test typeof(rl) <: AbstractBasis
end
