
"""
    dequant(planes::Array{Float64,3}, materials::Dict{Symbol, Any})::Array{Float64,3}

Dequantise an array of coefficients.
"""
function dequant(planes::Array{Float64,3}, materials::Dict{Symbol, Any})::Array{Float64,3}
    scale, bias = (materials[:scale], materials[:bias])
    coeff(c, σ, β) = (c - β) * σ
    scale3 = reshape(scale, (:, 1, 1))
    bias3 = reshape(bias, (:, 1, 1))
    coeff.(planes, scale3, bias3)
end
