Create_CSV_File <- function(sFile)
{
  
  # 1440 longitude steps, where each step = 0.25 degrees
  # 721 latitude steps, where each step = 0.25 degrees
  # 493 time steps from 1979 to the present, where each step = 1 month
  
  nc <- nc_open(sFile)
  
  # print(nc) # uncomment this line if you want to see an overview of the file contents
  
  dname <- "t2m" # temperature at 2 meters above the earth's surface
  dlname <- ncatt_get( nc, dname, attname="long_name", verbose=FALSE )
  dlunits <- ncatt_get( nc, dname, attname="units", verbose=FALSE )
  fillvalue <- ncatt_get(nc, dname, "_FillValue")
  scale <- ncatt_get(nc, dname,"scale_factor")
  offset <- ncatt_get(nc,dname,"add_offset")

  fillvalue <- as.numeric(fillvalue)  # -32767
  scale <- as.numeric(scale)    # 0.001763198
  offset <- as.numeric(offset)  # 257.7037
  
  # get the dimensions of the data array  
  
  xlon <- ncvar_get(nc, "longitude")
  xlat <- ncvar_get(nc, "latitude")
  xver <- ncvar_get(nc, "expver")
  xtime <- ncvar_get(nc, "time")
  
  nlon <- dim(xlon)   #1440
  nlat<- dim(xlat)    #741
  nver<- dim(xver)    #2   version? 1, 5  
  ntime<- dim(xtime)  #492 months
  
  #print(nlon)
  #print(nlat)
  #print(nver)
  #print(ntime)
  
  # make grid of given longitude and latitude
  
  lonlat <- expand.grid(xlon, xlat)     
  lonlat <- data.frame(lonlat)
  
  names(lonlat)[1] <- "lon"
  names(lonlat)[2] <- "lat"
  
  #fetch the weather data 
  
  xOut <- 0
  
  for (yr in Year_First:Year_Last)
  {
    
    for (m in Month_First:Month_Last)
    {
    
      i = m + 12 * (yr - 1979)
    
      if (i > ntime) { break; }
    
      # progress upddate
      
      sY <- as.character(yr)
      sM <- as.character(m)
      sLabel <- paste("t", sY, "-", sM, sep = "")
      
      print(sLabel)
    
      # fetch the data
      
        #c(lon, lat, ver, time)
      myArray <- ncvar_get(nc, dname, start=c(1, 1, 1, i), count=c(-1, -1, 1, 1))
      
      # convert to data frame
      
      myVector <- as.vector(myArray) 
      myMatrix <- matrix(myVector, nrow = nlon * nlat, ncol = 1)
      myDF <- data.frame(myMatrix)

      # x <- colCounts(myMatrix, value = -32767)
    
      # adjust values using scale factor and offset;
      # however, I don't think we need to make this adjustment
      # because I think R implements the adjustment automatically
      
      # myDF <- myDF * scale
      # myDF <- myDF + offset
      
      # convert from Kelvin to Celsius
    
      myDF <- myDF - 273.15
      
      # insert column name for this month of data
      
      names(myDF)[1] <- sLabel
    
      # drop some lat/lon points, leaving us with with 1 degree spacing instead of 0.25 degrees
    
      myDF <- cbind(lonlat, myDF)
      
      if (UseOneDegreeSpacing == TRUE)
      {
        myDF <- myDF[ abs( myDF$lon - round(myDF$lon ) ) < 0.00000001,  ]
        myDF <- myDF[ abs( myDF$lat - round(myDF$lat ) ) < 0.00000001,  ]
        #myDF$xlon <- myDF$lon - floor(myDF$lon)
        #myDF$xlat <- myDF$lat - floor(myDF$lat)
        #myDF <- subset(myDF, xlon == .25 | xlon == 0.75)
        #myDF <- subset(myDF, xlat == .25 | xlat == 0.75)
        #myDF <- myDF[c("lon", "lat", sLabel)]
      }
      
      # drop lat/lon points that are outside of user-specified rectangle
      
      if (Extract_Rectangular_Area == TRUE)
      {
        myDF <- myDF[ myDF$lat >= Area_Lat_Min,  ]
        myDF <- myDF[ myDF$lat <= Area_Lat_Max,  ]
        myDF <- myDF[ myDF$lon >= Area_Lon_Min,  ]
        myDF <- myDF[ myDF$lon <= Area_Lon_Max,  ]
      }
    
      # add this month's data to output array
      
      if (yr == Year_First && m == Month_First )
      {
        xOut <- myDF 
      }
      else
      {
        myDF <- myDF[c(3)]
        xOut <- cbind(xOut, myDF)
      }
      
    }
    
  }
  
  nc_close(nc)
  
  #xOut <- round(xOut, 2)

  # output
  
  write.csv(xOut, file = CSV_Output_File, row.names = FALSE)

}  



round_df <- function(df, digits) 
{
  
  nums <- vapply(df, is.numeric, FUN.VALUE = logical(1))
  
  df[,nums] <- round(df[,nums], digits = digits)
  
  (df)
  
}

