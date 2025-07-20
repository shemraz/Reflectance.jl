function simulate(texture::Array{Float64,3}, direction::Tuple{Float64,Float64})::Matrix{Float64}
    l(u, v, a) = a[1] * u^2 + a[2] * v^2 + a[3] * u * v + a[4] * u + a[5] * v + a[6]
    @> texture begin
        mapslices(_; dims=(1)) do texel
            l(direction..., texel)
        end
        dropdims(_; dims=1)
    end
end
