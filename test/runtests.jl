using Reflectance
using Test
using ImageCore

@testset verbose = true "API" begin
    img, model = loaddir(PTM, "data/ptm"; scale = 1 // 8)
    data = Reflectance.Metadata("data/ptm/info.json")
    properties = Symbol[
        :width,
        :height,
        :format,
        :type,
        :colorspace,
        :nplanes,
        :quality,
        :materials,
    ]
    @testset verbose = true "Types" begin
        @testset "PTM" begin
            intoindex = Int ∘ ceil
            downscale(i::Int)::Int = intoindex(1 // 8 * i)

            @test img isa Matrix{RGB{Float64}}
            @test model isa PTM
            @test model.data isa Array{Float64, 3}
            @test PTM <: AbstractBasis
            @test size(model)[1] == (data.nplanes - 3)
            @test map(downscale, (data.height, data.width)) == size(img) == size(model)[2:end]
        end

        @testset "Metadata" begin
            @test data isa Reflectance.Metadata

            @testset for p in properties
                hasproperty(data, p)
            end

            @testset "Materials" begin
                @test data.materials isa Vector{Reflectance.Material}
                @test length(data.materials) == 1

                material = data.materials[1]

                @test hasproperty(material, :scale) && material.scale isa Vector{Float64}
                @test hasproperty(material, :bias) && material.bias isa Vector{Float64}
                @test length(material.scale) == length(material.bias) == data.nplanes
                @test first(material.scale, 3) == repeat([1.0], 3)
                @test first(material.bias, 3) == repeat([0.0], 3)
            end
        end
    end

    @testset "Methods" begin
        lvec = (rand(Float64, 2)..., -1 * rand(Float64, 1)...)
        T = light(model, lvec)
        @test T isa Matrix{Float64}
        @test size(T) == size(img)
        result = T .* img |> clamp01!
        @test result isa Matrix{RGB{Float64}}
        @test img isa Matrix{RGB{Float64}}
        @test size(result) == size(img) == size(T)
        @test (maximum ∘ channelview)(result) <= 1.0
        @test (minimum ∘ channelview)(result) >= 0.0
    end
end
