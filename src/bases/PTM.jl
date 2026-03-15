struct PTM <: Basis{Float64,3}
    data::Array{Float64,3} # Dequantised array of RGB and coefficient values.
end

Base.size(A::PTM) = size(A.data)
Base.getindex(A::PTM, I...) = getindex(A.data, I...)

function PTM(
    A::Array{Float64,3}, # Array of quantised RGB and coefficient values.
    metadata::JSON3.Object
)
    scale::Vector{Float64}, bias::Vector{Float64} = @chain metadata begin
        getproperty(:materials)
        first
        values
    end
    dequantise!(A, scale, bias)
    return PTM(A)
end

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
