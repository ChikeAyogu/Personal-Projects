library(car)
library(caret)
library(corrplot)
library(MASS)
library(writexl)

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

indicators <- colnames(data_1[,-c(1,2)])

indicator_data <- data_1[indicators]

#grouping the dataset by country and reducing by mean
country_mean <-
   data_1 %>%
  dplyr::select(-Year) %>%
   group_by(Country) %>%
   summarise_all(mean)
View(country_mean) 

lr_indicators <- colnames(indicator_data[,c(1,3,8,11,5)])
lr_indicator_data <- indicator_data[lr_indicators]

#scatterplot matrix
scatterplotMatrix(indicator_data[lr_indicators],
                  smooth = F,
                  main = 'Scatterplot Matrix of Selected Indicators')

#Linear regression
#testing variables to see the best R^2 resulting variable combination

model1_lin <- lm(Life_expectancy ~ Birthrate_per_1000+govt_health_exp_GDP, data=indicator_data[lr_indicators])
summary(model1_lin)

model2_lin <- lm(Life_expectancy ~ Birthrate_per_1000+govt_health_exp_GDP+mortality_rate_infant_per_1000, data=indicator_data[lr_indicators])
summary(model2_lin)

model3_lin <- lm(Life_expectancy ~ Birthrate_per_1000+govt_health_exp_GDP+
                   mortality_rate_infant_per_1000+
                   population_growth, data=indicator_data[lr_indicators])
summary(model3_lin)

model4_lin <- lm(Life_expectancy ~ Birthrate_per_1000+
                   mortality_rate_infant_per_1000+
                   population_growth, data=indicator_data[lr_indicators])
summary(model4_lin)

#Using The Robust Regression
model_robust <- rlm(Life_expectancy ~ Birthrate_per_1000+
                     mortality_rate_infant_per_1000+
                     population_growth, data=indicator_data[lr_indicators])
summary(model_robust)

#checking residual independence
plot(model4_lin, 1)

#checking residual normality
plot(model4_lin, 2)

#checking homoscedasticity
plot(model4_lin, 3)

#check for multicoliinearity
vif(model4_lin)

##LOGISTIC REGRESSION
#Select Denmark data
den_cam_data <- data_1[data_1$Country %in% c('Denmark','Cameroon'),]
View(den_cam_data) 

#remove country and year in the data
den_cam_data <- den_cam_data[,-c(1,2)]
den_cam_data

#convert the life expectancy column to binary
den_cam_data <- den_cam_data %>% 
  mutate(Life_expectancy_bin = if_else(Life_expectancy > 63.75, 1, 0))
den_cam_data <- den_cam_data[,-c(5)]
  
View(den_cam_data)

write_xlsx(den_cam_data,"C:\\Users\\C\\Downloads\\denmarCam.xlsx")


#to standardize the data
scaled_1 <- scale(den_cam_data[, -c(12)])
scaled_data <- cbind(scaled_1, den_cam_data[, c(12)])

#Finding the right IVs
model1_logistic <- glm(Life_expectancy_bin ~ Birthrate_per_1000+
                         +govt_health_exp_GDP,data = scaled_data, family = "binomial")
summary(model1_logistic)

#Step Regression
model_step <- lm(Life_expectancy ~ ., data=indicator_data)
step(model_step, direction = 'backward')
model_step_Final <- MASS::stepAIC(model_step, direction = 'backward', trace=F)
summary(model_step_Final)
