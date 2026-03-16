struct PTM{T} <: Basis{T,3}
    data::Array{Float64,3} # Dequantised array of RGB and coefficient values.
end

# Implement array-like behaviour.
Base.size(A::PTM) = size(A.data)
Base.getindex(A::PTM, I...) = getindex(A.data, I...)

"""
    PTM(
        A::Array{Float64,3},
        metadata::JSON3.Object
    )

Construct a polynomial texture map. Returns an N×H×W array, where:

    A[:, i, j] == [r, g, b, a₀, a₁, ..., a₅]

"""
function PTM(
    A::Array{Float64,3}, # Array of normalised RGB and coefficient values.
    metadata::JSON3.Object
)
    # Get scale and bias vectors from JSON metadata.
    scale::Vector{Float64}, bias::Vector{Float64} = @chain metadata begin
        getproperty(:materials)
        first
        values
    end
    dequantise!(A, scale, bias) # Dequantise coefficients before constructing PTM.
    return PTM{Float64}(A)
end

"""
    dequantise!(A::Array{Float64,3}, scale::Vector{Float64}, bias::Vector{Float64})::Array{Float64,3}

Dequantise coefficient values, whereby:

    Aₙ,ᵢ,ⱼ = scaleₙ * Aₙ,ᵢ,ⱼ + biasₙ

"""
function dequantise!(A::Array{Float64,3}, scale::Vector{Float64}, bias::Vector{Float64})::Array{Float64,3}
    # Iterate over first dimension of A.
    nplanes, _ = size(A)
    for i ∈ 1:nplanes
        A[i,:,:] *= scale[i] # Multiply 2-D plane by corresponding scalar.
        A[i,:,:] .+= bias[i]
    end
    return A
end

dequantize!::Function = dequantise! # Alias for American-English spelling.
