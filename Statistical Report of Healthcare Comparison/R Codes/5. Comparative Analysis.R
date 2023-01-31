library(tidyverse)
life_exp_CA <- read_csv('data_stat_analysis.csv')
View(life_exp_CA)

#Creating a column for the 2 groups
life_exp_CA <- life_exp_CA %>%
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
  ) %>% 
  mutate(country_group = if_else(Country %in% c('Australia','Canada',
                                                     'Denmark','Japan','Norway',
                                                     'United Kingdom'),
                                 'Developed',
                                 'African'))
glimpse(life_exp_CA)
View(life_exp_CA)

#T-test prerequisites
#Equal variance
bartlett.test(life_exp_CA$Life_expectancy ~ life_exp_CA$country_group)

#Normality first test
set.seed(42)
shapiro.test(life_exp_CA$Life_expectancy)

#Mann-Whitney Test
wilcox.test(life_exp_CA$Life_expectancy ~ life_exp_CA$country_group, data = life_exp_CA)


#T-test
t.test(life_exp_CA$Life_expectancy ~ life_exp_CA$country_group)

#paired T-test
t.test(life_exp_CA$Birthrate_per_1000, life_exp_CA$Deathrate_per_1000, paired=T)
summary(life_exp_CA)


