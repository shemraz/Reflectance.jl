# bases/PTM.jl

## Basis type and constructor.
struct PTM <: AbstractBasis
    data::Array{Float64, 3} # Dequantised array of RGB and coefficient values.
end

"""
    PTM(A::Array{T,3}, material::Material)::PTM where T <: Real

Construct a polynomial texture map from a 3-dimensional array of **quantised** coefficients.

A `Material` containing scale and bias vectors must be provided to dequantise the
coefficients.

See also [`loaddir`](@loaddir), [`dequantise!`/`dequantize!`](@dequantise!).
"""
function PTM(A::Array{T, 3}, material::Material)::PTM where {T <: Real}
    # Dequantise coefficients before constructing PTM.
    dequantise!(
        A,
        @view(material.scale[4:end]),
        @view(material.bias[4:end])
    )
    return PTM(A)
end

"""
    PTM(A::Array{T,3})::PTM where T <: Real

Construct a polynomial texture map from a 3-dimensional array of **dequantised**
coefficients.

The array must be manually dequantised before construction.

See also [`dequantise!`/`dequantize!`](@dequantise!), [`loaddir`](@loaddir).
"""
function PTM(A::Array{T, 3})::PTM where {T <: Real}
    return PTM(A)
end

## Implements array-like behaviour.
Base.size(A::PTM) = size(A.data)
Base.getindex(A::PTM, I...) = getindex(A.data, I...)
### TODO: Add Base.show method.

## Render methods

"""
  weight(l::Vector{<:AbstractFloat})::Vector{Float64}  

Compute the light-dependent components for a PTM basis.
"""
function weight(l::Vector{<:AbstractFloat})::Vector{Float64}
    lᵤ, lᵥ, _ = l ./ norm(l)
    return Float64[1.0, lᵥ, lᵤ, lᵤ * lᵥ, lᵥ^2, lᵤ^2]
end

@doc raw"""
    weighted_sum(a::AbstractVector{Float64}, w::AbstractVector{Float64})::Float64

Perform a linear weighted summation of per-pixel coefficients. The general  
formulation for pixel *p* at the incident light vector *l* is:

```math
    p(x, y, l) = \sum_{k} a_{k}(x, y)w_{k}(l)
```
"""
function sum_weights(a::AbstractVector{Float64}, w::Vector{Float64})::Float64
    return a ⋅ w
end

function light(A::PTM, l::Vector{<:Real})::Matrix{Float64}
    # Compute light-dependent weights.
    weights = weight(l)

    # Initialise transformation matrix.
    _, height, width = size(A)
    T = Matrix{Float64}(undef, (height, width))

    # Loop over pixel coefficients
    for x in 1:height, y in 1:width
        a = view(A.data, :, x, y)
        w = weights
        T[x, y] = sum_weights(a, w)
    end

    return T
end
