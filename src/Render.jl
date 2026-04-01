"""
    L(a::AbstractVector, u::AbstractFloat, v::AbstractFloat)::AbstractFloat

Precompute the terms of polynomial from specified light direction.
"""
function L(a::AbstractVector{Float64}, u::Float64, v::Float64)::Float64
    components = [1.0, v, u, u * v, v^2, u^2]
    return a .* components |> sum
end

function norm_vector(l::NTuple{3, AbstractFloat})::NTuple{3, AbstractFloat}
    magnitude = sqrt(sum(l .^ 2))
    return l ./ magnitude
end

function light(A::PTM, l::NTuple{3, <:Real})::Matrix{Float64}
    _, h, w = size(A)
    lᵤ, lᵥ, _ = norm_vector(l)

    # Initialise transformation matrix.
    T = Matrix{Float64}(undef, (h, w))

    # Loop over pixels
    for i in 1:h, j in 1:w
        T[i, j] = L(view(A.data, :, i, j), lᵤ, lᵥ)
    end

    return T
end
