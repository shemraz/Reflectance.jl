# Reflectance

[![Build Status](https://github.com/shemraz/Reflectance.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/shemraz/Reflectance.jl/actions/workflows/CI.yml?query=branch%3Amaster)

Reflectance is a Julia package for loading and testing [Relightable images](https://doi.org/10.1145/3208806.3208820). The package provides a toolset for evaluating the performance of different bases used in Reflectance Transformation Imaging (RTI).

## Overview

[Polynomial Texture Mapping](https://doi.org/10.1145/383259.383320) (PTM) is a mathematical basis used to create relightable images. A PTM approximates the appearance of a surface using data from a set of images under varying light directions.

 Reflectance.jl aims to make relightable images accessible within the Julia ecosystem for the purpose of testing and comparing various RTI bases.

## Roadmap

> [!IMPORTANT] Project status
> Early development

- [x] Read legacy `.ptm` format.
- [x] Read PTMs in `relight` format.
- [x] Basic rendering functionality
- [ ] Other bases:
	- [ ] Radial basis functions
	- [ ] Bilinear
	- [ ] Hemispherical Harmonics
	- [ ] YCbCr
- [ ] Simple image export
- [ ] Normal map generation
