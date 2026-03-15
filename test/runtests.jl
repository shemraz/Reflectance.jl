using Test
using Reflectance
using Glob

@testset "Performance" begin
    @showtime Reflectance.load(PTM, "ptm/")
    A = @showtime Reflectance.load_channels("ptm/plane_0.jpg")
    m = @showtime Reflectance.load_metadata("ptm/")
    @showtime glob("plane_*.jpg", "ptm/")
    @showtime PTM(A, m)
end

@testset "PTM" begin
    @time rl = Reflectance.load(PTM, "ptm/")
    @time metadata = Reflectance.load_metadata("ptm/")
    @test rl isa PTM
    @test typeof(rl) <: Basis
    @test size(rl) == (metadata.nplanes, metadata.height, metadata.width)
end


