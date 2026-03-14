using Test
using Reflectance

@testset "Performance" begin
    @time Reflectance.load(PTM, "ptm/")
end

@testset "PTM" begin
    @time rl = Reflectance.load(PTM, "ptm/")
    @time metadata = Reflectance.load_metadata("ptm/")
    @test rl isa PTM
    @test typeof(rl) <: Basis
    @test size(rl) == (metadata.nplanes, metadata.height, metadata.width)
end


