@doc raw"""
    weighted_sum(a::AbstractVector{Float64}, w::AbstractVector{Float64})::Float64

Perform a linear weighted summation of per-pixel coefficients. The general  
formulation for pixel *p* at the incident light vector *l* is:

```math
    p(x, y, l) = \sum_{k} a_{k}(x, y)w_{k}(l)
```
"""
function weighted_sum(a::AbstractVector{Float64}, w::AbstractVector{Float64})::Float64
    return a ⋅ w
end

function norm_vector(l::NTuple{3, AbstractFloat})::NTuple{3, AbstractFloat}
    magnitude = sqrt(sum(l .^ 2))
    return l ./ magnitude
end

function light(A::PTM, l::NTuple{3, <:Real})::Matrix{Float64}
    _, height, width = size(A)
    u, v, _ = norm_vector(l)

    # Compute light-dependent weights.
    ϕ(lᵤ, lᵥ) = [1.0, lᵥ, lᵤ, lᵤ * lᵥ, lᵥ^2, lᵤ^2]

    # Initialise transformation matrix.
    T = Matrix{Float64}(undef, (height, width))

    # Loop over pixel coefficients
    for x in 1:height, y in 1:width
        T[x, y] = weighted_sum(view(A.data, :, x, y), ϕ(u,v))
    end

    return T
end
