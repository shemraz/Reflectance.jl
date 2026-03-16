"""
    L(a::AbstractVector, u::Float64, v::Float64)::Float64

Precompute the terms of polynomial from specified light direction.
"""
function L(a::AbstractVector, u::Float64, v::Float64)::Float64
    components = [1.0, v, u, u*v, v^2, u^2]
    a .* components |> sum
end

function norm_vector(l::NTuple{3,Float64})
    magnitude = sqrt(sum(l.^2))
    l ./ magnitude
end

@doc raw"""
    render(A::PTM, l::NTuple{3, Float64})

Render an image by computing the per-pixel luminance ``L`` at light direction ``l``:

``L(l_u, l_v) = a_0 l_u^2 + a_1 l_v^2 + a_2 l_u l_v + a_3 l_u + a_4 l_v + a_5``

where ``l_u`` and ``l_v`` are components of the noramlised light vector ``l``,
and ``a_0, \dots, a_5`` are the per-pixel coefficients.
"""
function render(A::PTM, l::NTuple{3, Float64})
    # Separate channels and coefficients for convenience.
    n, h, w = size(A)
    channels = view(A, 1:3, :, :)
    coeffs = view(A, 4:n, :, :)

    # Initialise array
    img = Array{Float64, 3}(undef, (3, h, w))
    lᵤ, lᵥ, _ = norm_vector(l)
    # Loop over pixels
    for i ∈ 1:h, j ∈ 1:w
        img[:, i, j] .= L(coeffs[:, i, j], lᵤ, lᵥ) .* channels[:, i, j]
    end
    return reinterpret(reshape, RGB{Float64}, img)
end

