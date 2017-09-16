# K means clustering

set.seed(42)

acciTrain <- acciPoints %>%
    select(
        -altitude,
        -name,
        -geometry
    )

accidentCluster <- kmeans(acciTrain, 10, nstart = 20)
accidentCluster

# table(acciTrain$directorate, accidentCluster$cluster)

accidentCluster$cluster <- as.factor(accidentCluster$cluster)
ggplot(acciTrain, aes(latitude, longitude, color = accidentCluster$cluster)) + geom_point()
