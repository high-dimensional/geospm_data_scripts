# Data Scripts for GeoSPM

This repository is an addendum to the [main GeoSPM code](https://github.com/high-dimensional/geospm). It holds additional shell scripts and MATLAB code for running the synthetic data experiments [described in the preprint paper](http://arxiv.org/abs/2204.02354).

## Installation

1. Copy the root directory of this repository to your MATLAB directory. We assume it is named `geospm_data_scripts`.

2. Make sure that the following directories are on your MATLAB path in the order shown, so that `geospm_data_scripts` appears before `geospm` and `spm12` (`[...]` stands for the path on your machine where the MATLAB directory is located)

    ```
    [...]/MATLAB/geospm_data_scripts:
    [...]/MATLAB/geospm:
    [...]/MATLAB/spm12:
    ```
  To configure your MATLAB path, you can click on the "Set Path" button on the "Home" toolstrip.

3. Quit MATLAB.

6. In a Bash shell window type and run:

   ```
   cd [...]/geospm_data_scripts/run_all.sh
   ```

   which will run all synthetic experiments reported in the paper. It is recommended to run this on a machine with at least 128GB of main memory and 10 processor cores. To only run a specific experiment, make sure all other experiments in the run_all.sh script are commented out.
