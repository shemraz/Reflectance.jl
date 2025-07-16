module Reflectance

using Chain
using Base.Iterators

function readptm(
    filename ::AbstractString
)
    @chain eachline(filename) begin
        (first(_, 6), collect(drop(_, 6)))
    end
end

end
