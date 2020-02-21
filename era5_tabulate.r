
# This program converts the ERA5 monthly temperature data file
# from NetCDF to CSV. The ERA5 data is on a 0.25 degree grid.
# Because the grid spacing is so small, the resulting CSV file
# is very big. To make the data more manageable, I drop all
# grid points except for those that correspond with integer
# degree values. This reduces the data down to 1/16 of its
# original size. Using this approach, the resulting CSV
# file is about 500 megabytes. To further reduce its size,
# I've included parameters to restrict the range of years you
# which to examine. Also, if you wish, you can isolate a
# rectangular lat/lon area, dropping all grid points outside
# of that area.

# the data inputs needed to run this program can be download from here:
# https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-land-monthly-means?tab=form


Location_R_Code <- "D:/JPW/data_ERA5_Monthly"  # location of your R program

ERA5_Data <- "D:/JPW/data_ERA5_Monthly/data_era5_monthly_temperature.nc"

CSV_Output_File <<- "out_era5.csv"  # this output file is produced by this program

# Note that although I requested data back to 1981, I think the NetCDF file
# actually contains data back to 1979. This needs to be investigated further.
# Note also that the web page indicates that the NetCDF format for the ERA5 data
# is "experimental", suggesting, perhaps, that download errors are possible.
# Alternatively, one can use the GRIB file format, but I couldn't figure out
# how to deal with GRIB files using R.

Year_First <<- 1979 # the first year you wish to extract (no earlier than 1979)
Year_Last  <<- 1980 # the last year you wish to extract (no later than 2019)

Month_First <<- 1   # 1 = jan, 2 = feb, etc
Month_Last  <<- 12 

Extract_Rectangular_Area <<- TRUE  # false = entire planet, true = a particular area

UseOneDegreeSpacing <<- TRUE   #    set to TRUE if you want to drop all non-integer latitude
                               #    and longitude grid points. This reduces the data to 
                               #    1/16th its original size.

# use the min and max boundaries below to specify a rectangular area

Area_Lat_Min <<- 35  # degrees north
Area_Lat_Max <<- 45  # degrees north

Area_Lon_Min <<- 250  # degrees east
Area_Lon_Max <<- 270  # degrees east

cat("\014")

# you need the ncdf4 library, but you only need to install it once

#install.packages("ncdf4")  
#install.packages("matrixStats")

library("ncdf4")
library("matrixStats")

setwd(Location_R_Code)

source("era5_tabulate_support.r")

cat("\014")

Create_CSV_File(ERA5_Data)

print("Success! The CSV output file was generated. ")

print("Note that the data in the output file are expressed in degrees Celsius.")
