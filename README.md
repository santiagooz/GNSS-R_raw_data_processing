# CYGNSS GNSS-R Raw Intermediate Frequency Data Processing

Set of Matlab scripts to process CYGNSS Level 1 Raw Intermediate Frequency 
Data Records.

## Description

Processing of the binay data in the registers to obatin a time series of 
delay Doppler maps (DDMs). Also, it plots the ground tracks of the 
reflections and their estimated SNR. The input files are the CYGNSS Level 1
Raw Intermediate Frequency Data Record, that contains the samples of the 
signal to process, and the CYGNSS Level 1 Science Data Record netCDF file 
from the same date and CYGNSS satellite as the Raw IF record file.
Both type of registers are available to the public: 
https://podaac.jpl.nasa.gov/CYGNSS?tab=mission-objectives&sections=about%2Bdata.
The netCDF file contains the DDMs processed on board during that day, as 
well as relevant information for processing and geolocation of the 
reflections. The important variables values during the time of the Raw IF 
record (reported in its metadata) is read from the netCDF file and used 
during the calculation of the DDMs.

The processing parameters are completely configurable, such as coherent and
non-coherent integration time, delay and Doppler resolution, etc.

### Executing program

If processing a new register (or using the script for the first time) 
follow these steps to prepare the data files:
* First, store both the Raw If binary file and the Level 1 Science Data 
Record netCDF file in the same directory.
* Edit config.m with the appropiate files directory in the variable folder_path.
* Edit case_selector.m to add a new case with the corresponding file names,
preferred channel to process and DDM identification number as reported in 
the netCDF file. Read case_selector.m comments for more details in the case
definition.

DDM Processing
* Edit config.m to set the desired processing parameters. The configurable 
parameters are the total processing time, coherent and non-coherent 
integration time, decimation ratio which determines the delay resolution, 
and the resolution, maximum value and optional central offset for the 
Doppler bins. These are defined in the "Input parameters" section of the 
script.
* Set plot_tracks flag to 1 to plot the ground tracks of the 4 DDMs 
processed on board while reading the netCDF file before processing the 
binary data.
* After configuration, run the script main.m. It will calculate the DDMs 
during the processing time and plot the results.

DDM coarse delay tracking
* After processing a data register for the first you may encounter that the
DDMs are moving in the delay dimension during the processing time. This 
residual error in the delay tracking can be estimated and saved using the 
script coarse_delay_tracking.m after finishing running main.m. The stored 
.mat file with the delay estimation will be used if kept in the file 
directory to compensate for this shifting while processing this same 
register in future occasions.