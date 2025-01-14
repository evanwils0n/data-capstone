# Load required packages
library(rjson)
library(tidyverse)
library(tidycensus)
library(dplyr)
library(reprex)

# Set the API key
#census_api_key(api_key_data$apiKey, install = TRUE)z

acs_vars <- load_variables(2022, "acs5/profile", cache = TRUE)

View(acs_vars)


# Define the variables
variables = c(
              'DP02_0089P',   #Native Born
              'DP02_0094P',   #Foreign Born
              'DP03_0033P',   #Industry Agriculture
              'DP03_0034P',   #Industry Construction
              'DP03_0035P',   #Industry Manufacturing
              'DP03_0036P',   #Industry Wholesale Trade
              'DP03_0037P',   #Industry Retail Trade
              'DP03_0038P',   #Industry Transportation, Warehousing, Utilities
              'DP03_0039P',   #Industry Information
              'DP03_0040P',   #Industry Finance and Insurance, Real Estate/Rental/Leasing
              'DP03_0041P',   #Industry Professional, Scientific, and Management, and Administrative and Waste Management
              'DP03_0042P',   #Industry Educational, Health Care and Social Assistance
              'DP03_0043P',   #Industry Arts, Entertainment, and Recreation, and Accommodation and Food Services
              'DP03_0044P',   #Industry Other service, Except Public Administrative
              'DP03_0045P',   #Industry Public Administrative
              'DP02_0054P',   #Enrolled in Nursery School
              'DP02_0055P',   #Enrolled in Kindergarten
              'DP02_0056P',   #Enrolled in Elementary School
              'DP02_0057P',   #Enrolled in High School (9-12)
              'DP02_0058P',   #Enrolled in College or Graduate School
              #'DP03_0018',		#Commuting to Work Estimate
              'DP03_0018P',		#Commuting to Work Percent
              #'DP03_0019',		#Commuting to Work Drive Alone Estimate
              'DP03_0019P',		#Commuting to Work Drive Alone Percent
              #'DP03_0021',		#Commuting to Work Public Transportation Estimate
              'DP03_0021P',		#Commuting to Work Public Transportation Percent
              #'DP05_0001',		#Total Population Estimate
              'DP05_0001P',		#Total Population Percent
              #'DP05_0002',	  #Total Population Male Estimate
              'DP05_0002P',		#Total Population Male Percent
              #'DP05_0003',	  #Total Population Female Estimate
              'DP05_0003P',		#Total Population Female Percent
              'DP05_0008P',		#Age 15-19 Percent of Pop
              'DP05_0009P',		#Age 20-24 Percent of Pop
              'DP05_0010P',		#Age 25-34 Percent of Pop
              'DP05_0011P',		#Age 35-44 Percent of Pop
              'DP05_0012P',		#Age 45-54 Percent of Pop
              'DP05_0013P',		#Age 55-59 Percent of Pop
              'DP05_0014P',		#Age 60-64 Percent of Pop
              'DP05_0015P',		#Age 65-74 Percent of Pop
              'DP05_0016P',		#Age 75-84 Percent of Pop
              'DP05_0017P',		#Age 85 and older Percent of Pop
              'DP03_0076P',		#Family Income Less Than 10k
              'DP03_0077P',		#Family Income 10k-14999
              'DP03_0078P',		#Family Income 15k-24999
              'DP03_0079P',		#Family Income 25k-34999
              'DP03_0080P',		#Family Income 35k-49999
              'DP03_0081P',		#Family Income 50k-74999
              'DP03_0082P',		#Family Income 75k-99999
              'DP03_0083P',		#Family Income 100k-149999
              'DP03_0084P',		#Family Income 150k-199999
              'DP03_0085P'		#Family Income Greater Than 200k
)
# Define the years you want to loop through
years <- 2005:2022
survey <- ifelse(years < 2013, "acs1", "acs5")

# Create an empty data frame to store the results
population_data <- data.frame()

# Loop through the years
for (i in 1:length(years)) {
  year <- years[i]
  current_survey <- survey[i]
  
  # Use a tryCatch block to handle potential errors
  tryCatch({
    # Retrieve data for the current year and survey type
    acs_data <- get_acs(
      geography = "zcta",
      variables = variables,
      year = year,
      survey = current_survey,
      output = "wide"
    ) 
    
    # Add a "year" column
    acs_data$year <- year
    
    # Append the data for the current year to the results data frame
    population_data <- bind_rows(population_data, acs_data)
  }, error = function(e) {
    cat("Error for year", year, ":", conditionMessage(e), "\n")
    # You can handle the error as needed, e.g., continue the loop or take other actions
  })
}

# Print or save the results data frame
View(population_data)

# Rename the columns
population_data <- population_data %>% 
  rename(
    Native_Born = DP02_0089PE,
    Foreign_Born = DP02_0094PE,
    Industry_Agriculture = DP03_0033PE,
    Industry_Construction = DP03_0034PE,
    Industry_Manufacturing = DP03_0035PE,
    Industry_Wholesale_Trade = DP03_0036PE,
    Industry_Retail_Trade = DP03_0037PE,
    Industry_Trans_Warehousing_Utilities = DP03_0038PE,
    Industry_Information = DP03_0039PE,
    Industry_Finance_Insur_RealEstate_Rental_Leasing = DP03_0040PE,
    Industry_Prof_Sci_Management_Admin_Waste_Management = DP03_0041PE,
    Industry_Ed_Health_Care_and_Social_Assist = DP03_0042PE,
    Industry_Arts_Enter_Rec_Accom_Food_Services = DP03_0043PE,
    Industry_Other_Service_Except_Public_Admin = DP03_0044PE,
    Industry_Public_Admin = DP03_0045PE,
    Enrolled_in_Nursery_School = DP02_0054PE,
    Enrolled_in_Kindergarten = DP02_0055PE,
    Enrolled_in_Elementary_School = DP02_0056PE,
    Enrolled_in_High_School_9_12 = DP02_0057PE,
    Enrolled_in_College_or_Grad_School = DP02_0058PE,
    Commuting_to_Work_Est = DP03_0018PE,
    Commuting_to_Work_Drive_Alone_Pct = DP03_0019PE,
    Commuting_to_Work_Public_Transportation_Pct = DP03_0021PE,
    Total_Population_Est = DP05_0001PE,
    Total_Population_Male_Pct = DP05_0002PE,
    Total_Population_Female_Pct = DP05_0003PE,
    Age_15_19_Pct_of_Pop = DP05_0008PE,
    Age_20_24_Pct_of_Pop = DP05_0009PE,
    Age_25_34_Pct_of_Pop = DP05_0010PE,
    Age_35_44_Pct_of_Pop = DP05_0011PE,
    Age_45_54_Pct_of_Pop = DP05_0012PE,
    Age_55_59_Pct_of_Pop = DP05_0013PE,
    Age_60_64_Pct_of_Pop = DP05_0014PE,
    Age_65_74_Pct_of_Pop = DP05_0015PE,
    Age_75_84_Pct_of_Pop = DP05_0016PE,
    Age_85_and_older_Pct_of_Pop = DP05_0017PE,
    Family_Income_Less_Than_10k = DP03_0076PE,
    Family_Income_10k_14999 = DP03_0077PE,
    Family_Income_15k_24999 = DP03_0078PE,
    Family_Income_25k_34999 = DP03_0079PE,
    Family_Income_35k_49999 = DP03_0080PE,
    Family_Income_50k_74999 = DP03_0081PE,
    Family_Income_75k_99999 = DP03_0082PE,
    Family_Income_100k_149999 = DP03_0083PE,
    Family_Income_150k_199999 = DP03_0084PE,
    Family_Income_Greater_Than_200k = DP03_0085PE
  )

# View population_data
View(population_data)

# You can save the results as a CSV file if needed
write.csv(population_data, "acs_data_zipcode.csv", row.names = FALSE)
