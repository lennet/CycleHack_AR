# K means clustering
require("cluster")
require("fpc")

set.seed(42)

#### data exploration ####
summary(acciPoints)
# missing values exist in oneway_ratio, feature_length and ride_length

# looking at oneway_ratio
hist(acciPoints$oneway_ratio)

summary(acciPoints$oneway_ratio)
# oneway_ratio has high freq at 0 and 1
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
# 0.000   0.000   0.021   0.282   0.575   1.000   21221 

table(is.na(acciPoints$oneway_ratio))
# FALSE  TRUE 
# 13478 21221 
# there are more missing values than exiting ones

hist(acciPoints$feature_length)

summary(acciPoints$feature_length)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#    0     601    1137    1931    2216   29796   21221

table(is.na(acciPoints$feature_length))
# FALSE  TRUE 
# 13478 21221 
# same picutre as with oneway_ratio

hist(acciPoints$ride_length)

summary(acciPoints$ride_length)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#    0    1075    1995    2945    3481   36911   21221 

table(is.na(acciPoints$feature_length))
# FALSE  TRUE 
# 13478 21221 
# same picutre as with oneway_ratio

median(acciPoints$lng[is.na(acciPoints$ride_length) == TRUE])

#### Data preprocessing ####
# imputing missing values with means
# in oneway_ratio, feature_length and ride_length
acciMisMean <- acciPoints %>%
    select(
        -street,
        -year,
        -features
    ) %>%
    mutate(
        oneway_ratio = ifelse(
            is.na(oneway_ratio) == TRUE, 
            mean(oneway_ratio, na.rm = TRUE),
            oneway_ratio
        ),
        feature_length = ifelse(
            is.na(oneway_ratio) == TRUE, 
            mean(oneway_ratio, na.rm = TRUE),
            oneway_ratio
        ),
        ride_length = ifelse(
            is.na(ride_length) == TRUE, 
            mean(ride_length, na.rm = TRUE),
            ride_length
        )
    )

##### preparation ####
# estimating the right number of clusters
# y<-as.matrix(sapply(x, as.numeric))

gap <- clusGap(acciMisMean, FUN = kmeans, K.max = 2, B = 10)
with(gap, maxSE(Tab[,"gap"], Tab[,"SE.sim"], method="firstSEmax"))


#### model training ####
acciTrain <- acciPoints2016 %>%
    select(
        -street,
        -features
    )
str(acciTrain)
accidentCluster <- kmeans(acciTrain, 5, nstart = 10)
accidentCluster

##### Model evaluation ####
# table(acciTrain$directorate, accidentCluster$cluster)
accidentCluster$cluster <- as.factor(accidentCluster$cluster)
ggplot(acciTrain, aes(lat, lng, color = accidentCluster$cluster)) + geom_point()

