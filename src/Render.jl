"""
    L(a::AbstractVector, u::AbstractFloat, v::AbstractFloat)::AbstractFloat

Precompute the terms of polynomial from specified light direction.
"""
function L(a::Vector{T}, u::T, v::T)::T where T <: Real
    components = T[1.0, v, u, u*v, v^2, u^2]
    a .* components |> sum
end

function norm_vector(l::NTuple{3,AbstractFloat})::NTuple{3,AbstractFloat}
    magnitude = sqrt(sum(l.^2))
    l ./ magnitude
end

"""
    render(A::PTM{T}, l::NTuple{3, AbstractFloat})::AbstractArray{T} where T <: Real

Render an image by computing the per-pixel luminance ``L`` at light direction ``l``:

``L(l_u, l_v) = a_0 l_u^2 + a_1 l_v^2 + a_2 l_u l_v + a_3 l_u + a_4 l_v + a_5``

where ``l_u`` and ``l_v`` are components of the noramlised light vector ``l``,
and ``a_0, \\dots, a_5`` are the per-pixel coefficients.
"""
function render(A::PTM{T}, l::NTuple{3, T})::AbstractArray{T} where T <: Real
    # Separate channels and coefficients for convenience.
    n, h, w = size(A)
    bands = view(A, 1:3, :, :)
    coeffs = view(A, 4:n, :, :)

    # Initialise array as RGB channels.
    img = Array{T, 3}(undef, (3, h, w))
    lᵤ, lᵥ, _ = norm_vector(l)

    # Loop over pixels
    for i ∈ 1:h, j ∈ 1:w
        img[:, i, j] = L(coeffs[:, i, j], lᵤ, lᵥ) * bands[:, i, j]
    end
    return img
end
