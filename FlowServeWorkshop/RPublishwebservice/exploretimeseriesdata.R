DemoData <- read.csv(file = "C:/Users/srram/Desktop/DemoData.csv", header = TRUE, row.names = NULL, encoding = "UTF-8", sep = ",", dec = ".", quote = "", comment.char = "")

library(forecast)
library(dplyr)
library(plyr)
library(ggplot2)

min.length <- 104
value.threshold <- 20
test.length <- 8
horizon <- test.length
seasonality <- 52
observation.freq <- "week"
timeformat <- "%m/%d/%Y"
INPUTID1 <- 1
INPUTID2 <- 2
data <- filter(DemoData, ID1 == INPUTID1 & ID2 == INPUTID2)

# apply business rules
businessrule <- function(data) {
  tsvalues <- data$obsval
  
  # Select Eligible Time Series:
  # Rule 1: if a time series has no more than <min.length> non-NA values, discard
  if (sum(!is.na(tsvalues)) < min.length) return(c(judge = 1))
  
  # Rule 2: if a time series has any sales quantity <= value.threshold , discard
  if (length(tsvalues[tsvalues > value.threshold]) != length(tsvalues)) return(c(judge = 2))
  
  return(c(judge = 0))
}

judge.all <- ddply(data, .(ID1, ID2), businessrule)
judge.good <- judge.all[judge.all$judge == 0, c("ID1", "ID2")]
data.good <- join(data, judge.good, by = c("ID1", "ID2"), type = "inner")
data <- data.good
data$time <- as.Date(data$obsdttm, format = "%m/%d/%Y")

min.time <- min(data$time)
max.time <- max(data$time)
unique.time <- seq(from = min.time, to = max.time, by = "week")

# For every (ID1, ID2) pair, create (ID1, ID2, time) combination 
unique.ID12 <- unique(data[, 1:2])
comb.ID1 <- rep(unique.ID12$ID1, each = length(unique.time))
comb.ID2 <- rep(unique.ID12$ID2, each = length(unique.time))
comb.time <- rep(unique.time, times = dim(unique.ID12)[1])
comb <- data.frame(ID1 = comb.ID1, ID2 = comb.ID2, time = comb.time)

# Join the combination with original data
data <- join(comb, data, by = c("ID1", "ID2", "time"), type = "left")

# apply business rules
businessrule <- function(data) {
  # Train and test split
  data.length <- dim(data)[1]
  #test.length <- 52
  train.length <- data.length - test.length
  
  tsvalues <- data$obsval
  
  # Select Eligible Time Series based on training and testing principals:
  # Rule 3: if the last 6 values in trainning set are all NA, discard
  if (sum(is.na(tsvalues[(train.length - 5):train.length])) == 6) return(c(judge = 3))
  
  # Rule 4: if test data has more than a half NA, discard
  if (test.length > 0 && sum(is.na(tsvalues[(train.length + 1):data.length])) > test.length / 2) return(c(judge = 4))
  
  return(c(judge = 0))
}
judge.all <- ddply(data, .(ID1, ID2), businessrule)
judge.good <- judge.all[judge.all$judge == 0, c("ID1", "ID2")]
data.good <- join(data, judge.good, by = c("ID1", "ID2"), type = "inner")
data <- data.good


data$time <- as.POSIXct(as.numeric(as.POSIXct(data$time, format = timeformat, tz = "UTC", origin = "1970-01-01"), tz = "UTC"), tz = "UTC", origin = "1970-01-01")



weeknum <- function(date) { date <- as.Date(date, format = timeformat); as.numeric(format(date, "%U")) }
year <- function(date) { date <- as.Date(date, format = timeformat); as.numeric(format(date, "%Y")) }
date.info <- function(df) { date <- df$time[1]; c(year(date), weeknum(date)) }


# Train and test split
data.length <- nrow(data)


# Missing data: replace na with average
data$obsval[is.na(data$obsval)] <- mean(data$obsval, na.rm = TRUE)

ggplot(data, aes(x = time)) + geom_line(aes(y = obsval), color = "black") + facet_grid(ID1~ID2)
library(zoo)
acf(my.ts)
pacf(my.ts)

# Build forecasting models
my.ts <- ts(data$obsval, frequency = seasonality, start = date.info(data))

myarimamodel <- auto.arima(my.ts)
tsdiag(myarimamodel)
plot(forecast(myarimamodel, h = 5))
