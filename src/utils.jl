
"""
    dequant(planes::Array{Float64,3}, materials::Dict{Symbol, Any})::Array{Float64,3}

Dequantise an array of coefficients.
"""
function dequant(planes::Array{Float64,3}, materials::Dict{Symbol,Vector{Float64}})::Array{Float64,3}
    scale = reshape(materials[:scale], (:, 1, 1))
    bias = reshape(materials[:bias], (:, 1, 1))
    return @. (planes - bias) * scale
end
