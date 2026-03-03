using Reflectance
using Test

@testset "reading relight format" begin
    rl = loaddir("relight-ptm/", PTM)    
    v = (0.0, 1.0)
    res = light(rl, v)
    # Dimensions are (n_planes, height, width)
    coeff_n, coeff_h, coeff_w = size(rl.planes)
    rgb_n, rgb_h, rgb_w = size(rl.rgb)
    @test rl.spec.height == coeff_h == rgb_h
    @test rl.spec.width == coeff_w == rgb_w
    @test rl.spec.nplanes == coeff_n + rgb_n
    @test size(res) == (rgb_h, rgb_w)
end
