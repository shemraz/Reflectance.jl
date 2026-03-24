struct PTM{T} <: AbstractBasis{T,3}
    data::Array{T,3} # Dequantised array of RGB and coefficient values.
end

# Implement array-like behaviour.
Base.size(A::PTM) = size(A.data)
Base.getindex(A::PTM, I...) = getindex(A.data, I...)

"""
    PTM(A::Array{T,3}, metadata::JSON3.Object)::PTM{T} where T <: Real

Construct a polynomial texture map. Returns an N×H×W array, where:

    A[:, i, j] == [r, g, b, a₀, a₁, ..., a₅]

"""
function PTM(A::AbstractArray{T,3}, scale::Vector{Number}, bias::Vector{Number})::PTM{T} where T <: Real
    # Get scale and bias vectors from JSON metadata.
    # scale::Vector{T}, bias::Vector{T} = begin
    #     getproperty(metadata, :materials) |> first |> values
    # end
    dequantise!(A, scale, bias) # Dequantise coefficients before constructing PTM.
    return PTM{T}(A)
end

"""
    dequantise!(A::Array{T,3}, scale::Vector{T}, bias::Vector{T})::Array{T,3} where T <: Real

Dequantise coefficient values, whereby:

    ``A_{n,i,j} = scale_{n} * A_{n,i,j} + bias_{n}``

"""
function dequantise!(A::Array{T,3}, scale::Vector{T}, bias::Vector{T})::Array{T,3} where T <: Real
    # Iterate over first dimension of A.
    nplanes, _ = size(A)
    for i ∈ 1:nplanes
        A[i,:,:] .-= bias[i] # Subtract bias.
        A[i,:,:] .*= scale[i] # Multiply 2-D plane by corresponding scalar.
    end
    return A
end

dequantize!::Function = dequantise! # Alias for American-English spelling.

