# Reflectance.jl

[![Build Status](https://github.com/shemraz/Reflectance.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/shemraz/Reflectance.jl/actions/workflows/CI.yml?query=branch%3Amaster)

Reflectance is a Julia package for loading, testing, and benchmarking [relightable images](https://doi.org/10.1145/3208806.3208820) captured using [Reflectance Transformation Imaging (RTI)](https://culturalheritageimaging.org/Technologies/RTI/) applications.

> [!IMPORTANT]
> **Project status:** Early development

## Overview

Reflectance.jl aims to bring relightable images into the Julia ecosystem! The package provides a simple and flexible API, designed to make evaluating and comparing the performance of different RTI bases quick and easy for large datasets. Reflectance.jl is designed to complement the brilliant [relight](https://github.com/cnr-isti-vclab/relight). To keep the API as simple as possible and completely non-destructive, exported methods only *read* relightable images into memory as a custom Julia type—Reflectance.jl does not support RTI compilation (`RelightLab` or `relight-cli` should be used for this). Currently, only the relight web format is supported for input data.

## Getting started

RTI bases are implemented as subtypes of `AbstractBasis`:

```
                         AbstractBasis                         
     ┌────────────┬────────────┴────────────┬────────────┐     
    PTM          HSH          RBF          BLN          YCC    

```

Bases behave like arrays and support Cartesian indexing:

```julia
	using Reflectance

	img, model = loaddir(PTM, "path/to/folder")

	model[1, :, :] |> typeof
```

```julia
	Matrix{Float64} (alias for Array{Float64, 2})
```

The following bases have been implemented (with more to come!):
- `PTM` or [Polynomial Texture Map](https://doi.org/10.1145/383259.383320). PTMs approximate the luminance of a surface by evaluating polynomial curve, defined by a series of per-pixel coefficients computed from a set of images under varying light directions.

## Roadmap
- [✓] Definition of core types for RTI bases.
- [/] Basis implementations:
	- [✓] PTM
	- [ ] HSH
	- [ ] RBF
	- [ ] BLN
	- [ ] YCC
- [✓] Basic rendering functionality.
- [✓] Simple image export.
- [ ] Benchmarking interface.
	- [ ] Loading reference images.
	- [ ] Evaluating luminance/chromaticity difference.
	- [ ] Use PCA to determine greatest error regions.
	- [ ] Benchmark results plotting.

## Credits

This project wouldn't be possible without the amazing work of the Visual Computing Lab at CNR-ISTI in creating [relight](https://github.com/cnr-isti-vclab/relight).
