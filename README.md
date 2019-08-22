# Typhoon
This repository contains the very WIP version of the Typhoon GPU-on-an-FPGA project by Finn Sinclair and Kuilin Li. This project seeks to implement a relatively performant, tile-based rasterization and GPU pipeline that is flexible enough to fit on a wide range of FPGA devices.

An extremely efficient and novel linked-list-based dynamic memory allocation system is used to store the transformed scene geometry data according to the adjustable screen binning regions.

A high precision depth buffer along with modular pixel shader cores allows for extremely high fidelity and high performance rendering with a very limited set of memory resources.

A custom SRAM-backed framebuffer and memory controller is included.

Please see the PDF paper for a full breakdown and analysis.
