struct PTM <: AbstractBasis
    model ::Array{Float64,3} # Dequantised array of RGB and coefficient values.
end

function PTM(
    A     ::Array{Float64,3}; # Array of quantised RGB and coefficient values.
    scale ::Vector{Float64},
    bias  ::Vector{Float64}
)::PTM
    dequantise!(A)
end
