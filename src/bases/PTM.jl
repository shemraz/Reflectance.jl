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
