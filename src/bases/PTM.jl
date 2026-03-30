struct PTM <: AbstractBasis
    data::Array{Float64,3} # Dequantised array of RGB and coefficient values.
end

# Implement array-like behaviour.
Base.size(A::PTM) = size(A.data)
Base.getindex(A::PTM, I...) = getindex(A.data, I...)

function PTM(A::Array{T,3}, material::Material)::PTM where T <: Real
    # Get scale and bias vectors from JSON metadata.
    dequantise!(A, material.scale, material.bias) # Dequantise coefficients before constructing PTM.
    return PTM(A)
end

function dequantise!(A::Array{T,3}, scale::Vector{Float64}, bias::Vector{Float64})::Array{Float64,3} where T <: Real
    # Iterate over first dimension of A.
    nplanes, _ = size(A)
    for i ∈ 1:nplanes
        A[i,:,:] .-= bias[i+3] # Subtract bias.
        A[i,:,:] .*= scale[i+3] # Multiply 2-D plane by corresponding scalar.
    end
    return A
end

dequantize!::Function = dequantise! # Alias for American-English spelling.

