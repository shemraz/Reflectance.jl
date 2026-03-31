# Reflectance.jl

[![Build Status](https://github.com/shemraz/Reflectance.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/shemraz/Reflectance.jl/actions/workflows/CI.yml?query=branch%3Amaster)

Reflectance is a Julia package for loading, testing, and benchmarking [Relightable images](https://doi.org/10.1145/3208806.3208820)—also, *relightables*—captured by [Reflectance Transformation Imaging (RTI)](https://culturalheritageimaging.org/Technologies/RTI/) applications.

> [!IMPORTANT] Project status
> Early development

## Overview

Reflectance.jl aims to bring relightables into the Julia ecosystem! The package provides a simple and flexible API, designed to make evaluating and comparing the performance of different RTI bases quick and easy. Reflectance.jl is designed to complement the brilliant [relight](https://github.com/cnr-isti-vclab/relight). To keep the API as simple and non-destructive as possible, exported methods only *read* relightables into memory as a custom Julia type—they do not save or compile relightables (`RelightLab` or `relight-cli` should be used for this). Currently, only the relight web format is supported for input data.

The following bases have been implemented (with more to come!):
- `PTM` or [Polynomial Texture Map](https://doi.org/10.1145/383259.383320). PTMs approximate the luminance of a surface by evaluating polynomial curve, defined by a series of per-pixel coefficients computed from a set of images under varying light directions.

## Roadmap
- [✓] Definition of core types for relightable images.
- [✓]
- [x] Read PTMs in `relight` format.
- [x] Basic rendering functionality
- [ ] Other bases:
	- [ ] Radial basis functions
	- [ ] Bilinear
	- [ ] Hemispherical Harmonics
	- [ ] YCbCr
- [ ] Simple image export
- [ ] Normal map generation
