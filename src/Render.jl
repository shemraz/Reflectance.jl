"""
    light(surface::Relightable{PTM}, direction::Tuple{Float64,Float64})

Simulate a texture map at the given incident light vector.
"""
function light(surface::AbstractBasis}, direction::Tuple{Float64,Float64})
    l(u, v, a) = a[1] * u^2 + a[2] * v^2 + a[3] * u * v + a[4] * u + a[5] * v + a[6]
    luma = @chain begin
        map(eachslice(surface.planes; dims=(2,3))) do plane
            l(direction..., plane)
        end
    end
    res = @chain begin
        mapslices(surface.rgb; dims=(2,3)) do channel
            clamp.(
                luma.*channel,
                0.0,
                1.0
            )
        end
    end
    return ImageCore.colorview(ImageCore.RGB, res)
end
