##LIBRARIES
#For descriptive
library(tidyverse)
library(dplyr)
library(mice)
library(psych)
library(modeest)

#For Correlation
library(corrplot)
#-----------------------------------------


##CODES

data_1 <- read_csv('data_stat_analysis.csv')

data_1 %>% head()
View(data_1)
glimpse(data_1)

#To change the column names
data_1 <- data_1 %>% 
  rename("Country" = "Country Name",
         "Year" = "Time",
         "Birthrate_per_1000" = "Birthrate, crude (per 1,000 people)",
         "Deathrate_per_1000" = "Death rate, crude (per 1,000 people)]",
         "govt_health_exp_GDP" = "Domestic general government health expenditure (% of GDP)",
         "ext_govt_exp_Health" = "External health expenditure (% of current health expenditure)",
         "Life_expectancy"="Life expectancy at birth, total (years)",
         "mortality_rate_female_per_1000"="Mortality rate, adult, female (per 1,000 female adults)",
         "mortality_rate_male_per_1000"="Mortality rate, adult, male (per 1,000 male adults)",
         "mortality_rate_infant_per_1000"="Mortality rate, infant (per 1,000 live births)",
         "infant_deaths"="Number of infant deaths",
         "maternal_deaths"="Number of maternal deaths",
         "population_growth"="Population growth (annual %)",
         "population"="Population, total"
         )


col_list <- list(colnames(data_1))
col_list

colSums(is.na(data_1))

md.pattern(data_1, rotate.names=T) #To visualize the missing values

#To get  only the indicators
indicators <- colnames(data_1[,-c(1,2)])

indicator_data <- data_1[indicators]

#To get a quick statistical summary of the data
describe(data_1[indicators])


#To get the descriptive stats by country
country_des <- function(x) sapply(x, describe)
by(data_1[indicators], data_1$Country, country_des)


#since describe doesn't calculate 'mode', To get the mode by country
modefunc <- function(x){
  if (length(mfv(x)) != 1){
    return (NA)
  }else{
    return(mfv(x))
  }
}
country_mode <- function(y) sapply(y, modefunc)
by(data_1[indicators], data_1$Country, country_mode)

#___________________________________________________________
#CORRELATION
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

