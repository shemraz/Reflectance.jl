"""
    simulate(surface::Relightable{PTM}, direction::Tuple{Float64,Float64})::Matrix{Float64}

Simulate a texture map at the given incident light vector.
"""
function simulate(surface::Relightable{PTM}, direction::Tuple{Float64,Float64})::Matrix{Float64}
    l(u, v, a) = a[1] * u^2 + a[2] * v^2 + a[3] * u * v + a[4] * u + a[5] * v + a[6]
    luma = @> surface.planes begin
        mapslices(_; dims=(1)) do plane
            l(direction..., plane)
        end
        dropdims(_; dims=1)
    end
    res = @> begin
        map(eachslice(surface.base)) do channel
            clamp.(
                luma.*channel,
                0.0,
                1.0
            )
        end
        stack(_; dims=1)
    end
end
