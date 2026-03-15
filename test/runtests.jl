using Test
using Reflectance
using Glob
using BenchmarkTools

data = "data/ptm"
ptm9 = Reflectance.load(PTM, data)
metadata = Reflectance.load_metadata(data)
m_size = (metadata.nplanes, metadata.height, metadata.width)
n_jpegs = length(glob("plane_*.jpg", data))

@testset "Metadata" begin
    @test metadata.nplanes ==  n_jpegs * 3
end

@testset "Basis interface" begin
    @test ptm9 isa PTM
    @test typeof(ptm9) <: Basis
    @test size(ptm9) == m_size
end

@testset "Performance" begin
    @btime Reflectance.load(PTM, data) samples=5
    @btime Reflectance.getplanes(glob("plane_*.jpg", data), m_size) samples=5
    @btime Reflectance.load_channels!("$data/plane_0.jpg", Array{Float64,3}(undef, (3, m_size[2], m_size[3])))
end
