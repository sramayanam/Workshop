predictvalues <- function(INID1, INID2, INDATE) {

    DemoData <- read.csv(file = "C:/Users/Public/Forecast/DemoData.csv", header = TRUE, row.names = NULL, encoding = "UTF-8", sep = ",", dec = ".", quote = "", comment.char = "")

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
    INPUTID1 <- INID1
    INPUTID2 <- INID2
    INPUTDATE <- INDATE
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


    # Date format clean-up
    data$time <- as.POSIXct(as.numeric(as.POSIXct(data$time, format = timeformat, tz = "UTC", origin = "1970-01-01"), tz = "UTC"), tz = "UTC", origin = "1970-01-01")

    # Helper functions extracting date-related information
    weeknum <- function(date) { date <- as.Date(date, format = timeformat); as.numeric(format(date, "%U")) }
    year <- function(date) { date <- as.Date(date, format = timeformat); as.numeric(format(date, "%Y")) }
    date.info <- function(df) { date <- df$time[1]; c(year(date), weeknum(date)) }


    # Forecasting Function

    arima.single.id <- function(data) {
        method.name <- "STL_ARIMA"

        # Train and test split
        data.length <- nrow(data)
        train.length <- data.length - horizon
        train <- data[1:train.length,]
        test <- data[(train.length + 1):data.length,]

        # Missing data: replace na with average
        train$obsval[is.na(train$obsval)] <- mean(train$obsval, na.rm = TRUE)

        # Build forecasting models
        train.ts <- ts(train$obsval, frequency = seasonality, start = date.info(train))
        train.model <- stlf(train.ts, h = horizon, method = "arima", s.window = "periodic")

        forecast.value <- train.model$mean
        forecast.lo95 <- train.model$lower[, 1]
        forecast.hi95 <- train.model$upper[, 1]

        output <- data.frame(time = test$time, cbind(forecast.value, forecast.lo95, forecast.hi95))
        colnames(output)[-1] <- paste(c("forecast", "lo95", "hi95"), method.name, sep = ".")
        
        return(output)

    }

    ##Final forecast values in clean format
    output <- filter(ddply(data, .(ID1, ID2), arima.single.id), as.Date(time, format = "%m/%d/%Y") == as.Date(INPUTDATE, format = "%m/%d/%Y"))

    #forecastedvalue <- filter(output, as.Date(time, format = "%m/%d/%Y") == as.Date("12/28/2013", format = "%m/%d/%Y"))
    return(output$forecast.STL_ARIMA)
}