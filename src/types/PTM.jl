using FixedPointNumbers

struct PTM <: AbstractBasis
    planes::Array{N0f8,3}
end

function PTM(planes::AbstractMatrix)::PTM
    A = cat(planes...; dims = 1)

end
