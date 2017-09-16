# Year time series
require("reshape")

unique(acciPoints$year)

temp <- acciPoints %>% 
    select(
        -oneway_ratio, 
        -feature_length, 
        -ride_length, 
        -feature_count,
        -features
        )
    

md <- reshape::melt(temp, id = c("street", "directorate", "year", "lat", "lng"))
ct <- reshape::cast(md, street + directorate + lat + lng ~ variable + year)

