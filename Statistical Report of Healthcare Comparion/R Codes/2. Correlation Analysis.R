library(corrplot)

data_1 <- read_csv('data_stat_analysis.csv')

#rename the columns
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

#To get  only the indicators
indicators <- colnames(data_1[,-c(1,2)])

#First, calculate the correlation coefficient
round(cor(data_1[indicators]), 3)

#comprehensive correlation significance
corr.test(data_1[indicators], use='complete')

#Next, plot the correlation matrix
cor_matrix <- cor(data_1[indicators])
corrplot(cor_matrix)
