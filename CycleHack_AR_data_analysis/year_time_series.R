# Year time series
require("reshape")
require("rjson")
require("ade4")
require("data.table")
require("dummies")

# selecting data for year comparison
temp <- acciPoints
    
# one-hot-encoding the year to have the years as seprate columns
temp <- dummy.data.frame(temp, names = c("year"), sep="_")

# assigining the count to each year
temp <- temp %>%
    mutate(
        y2008 = if_else(year_2008 == 1, count, as.integer(0)),
        y2009 = if_else(year_2009 == 1, count, as.integer(0)),
        y2010 = if_else(year_2010 == 1, count, as.integer(0)),
        y2011 = if_else(year_2011 == 1, count, as.integer(0)),
        y2012 = if_else(year_2012 == 1, count, as.integer(0)),
        y2013 = if_else(year_2013 == 1, count, as.integer(0)),
        y2014 = if_else(year_2014 == 1, count, as.integer(0)),
        y2015 = if_else(year_2015 == 1, count, as.integer(0)),
        y2016 = if_else(year_2016 == 1, count, as.integer(0))
    ) %>%
    select(
        -count,
        -year_2008,
        -year_2009,
        -year_2010,
        -year_2011,
        -year_2012,
        -year_2013,
        -year_2014,
        -year_2015,
        -year_2016
    )

temp <- acciPoints %>%
    select(
        street,
        directorate,
        year,
        count
    )
temp1 <- reshape(temp, idvar = c("street", "directorate"), timevar = "year", sep = "_", direction = "wide")

temp1[is.na(temp1)] <- 0

colnames(temp1) <- c("street", "directorate", 
                     "y2008", 
                     "y2009",
                     "y2010",
                     "y2011",
                     "y2012",
                     "y2013",
                     "y2014",
                     "y2015",
                     "y2016"
                     )


# y2010 + y2011+ y2012 + y2013 + y2014 + y2015 + y2016 

# generate json and save to working directory
x <- toJSON(unname(split(temp1, 1:nrow(temp1))))

sink("years_overview.json")
cat(x)
sink()
