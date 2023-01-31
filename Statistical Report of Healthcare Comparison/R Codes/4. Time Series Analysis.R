library(tidyverse)
library(tseries)
library(TTR)
library(xts)
library(forecast)

life_exp <- read_csv('life_expectancy.csv')
head(life_exp)

spec(life_exp)

#To select the columns required
life_exp <- life_exp[, c(3,5)]
life_exp <- life_exp %>% 
  rename("life_expectancy" = "Life expectancy at birth, total (years) [SP.DYN.LE00.IN]")
tail(life_exp)

#convert the life_expectancy column to numeric data type
life_exp <-
  life_exp %>% 
  mutate_at("life_expectancy", as.numeric) %>% 
  na.omit()

#Time Series Object
date <- seq(from = as.Date('1960/1/1'),
           to = as.Date('2020/1/1'),
           by = 'years')
life_exp.xts <- xts(life_exp$life_expectancy, date)

head(life_exp.xts)


#plotting the time series
#GGPlot
autoplot(life_exp.xts) +
  geom_line(colour='red')+
  labs(x='Years', y='Life Expectancy', 
       title='Time Series Plot')+
  theme(plot.title = element_text(hjust = 0.5))



#Forecasting with ARIMA
#differencing to make the data stationary
ndiffs(life_exp.xts)
life_exp_diff <- diff(life_exp.xts, differences = 2)
autoplot(life_exp_diff)

#formal test for stationarity
adf.test(na.omit(life_exp_diff))

#plots to get the correlogram and partial correlogram of the series
autoplot(Acf(life_exp_diff))
autoplot(Pacf(life_exp_diff))

#select p and q automatically
data_fitted <- auto.arima(life_exp.xts)

#Testing Goodness of fit
checkresiduals(data_fitted)

#forecast
autoplot(forecast(data_fitted, 10)) +
  labs(x='Year', y='Life Expectancy')

forecast_life_exp <- forecast(data_fitted, 10)

#forecast error
acf(forecast_life_exp$residuals, lag.max=20)
Box.test(forecast_life_exp$residuals, lag=20, type="Ljung-Box")

autoplot(forecast_life_exp$residuals)

##Using the Simple Exponential Smoothing
autoplot(life_exp.xts)
life_exp_ESforecast <- HoltWinters(life_exp.xts, beta=F, gamma=F)

plot(life_exp_ESforecast)

#forecasting with ES
life_exp_ESforecast2 <- forecast(life_exp_ESforecast, h=10)
life_exp_ESforecast2
autoplot(life_exp_ESforecast2)
