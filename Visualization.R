# Install Packages
library("dplyr")
library("ggplot2")
library("tidyr")
library("tidyverse")

# Load prepared data
data <- read.csv("/Users/evan/prepared_zipcode_data.csv")
# Show summary statistics
summary(data)

# Find raw population values of Commuters per Zip Code
data$Public_Trans_Value <- (data$Total_Population_Est * data$Commuting_to_Work_Drive_Alone_Pct) / 100


# Aggregate for year over year percent change
aggregated_year_data <- data %>%
  group_by(year) %>%
  summarise(TotalPopPct = mean(Commuting_to_Work_Drive_Alone_Pct, na.rm = TRUE))


# Show line graph of YoY change
ggplot(aggregated_year_data, aes(x = year, y = TotalPopPct)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = unique(aggregated_year_data$year)) + #Show every year in graph
  theme_minimal() +
  labs(title = "Mean Year Over Year Percent of Population Commuting by Public Transportation (2013-2021)",
       x = "Year",
       y = "Percent of Total Population")


# See breakdown of Population Commuting by Public Trans by State
aggregated_state_data <- data %>%
  filter(state != "DC") %>%
  group_by(state, year) %>%
  summarise(TotalPop = mean((Commuting_to_Work_Public_Transportation_Pct), na.rm = TRUE)/8)

# Create Bar Graph to Visualize
ggplot(data = aggregated_state_data, aes(x = state, y = TotalPop, fill = as.factor(year))) +
  geom_bar(stat = "identity", position = "stack") +
  labs(title = "Average Percent of Population Commuting to Work by Public Transportation by State and Year",
       x = "State",
       y = "% of Pop. Commuting by Public Trans",
       fill = "Year") +
  theme_minimal()


# Let's take a deeper look at NY
# Create new df by filtering on Queens and Brooklyn Zip Codes
NYC_df <- data %>% 
  filter(state == "NY" & county == "New York County" | county == "Bronx County" | county == "Kings County" | county == "Queens County" | county == "Richmond County") %>%
  group_by(county, year) %>%
  summarise(TotalPop = mean(Commuting_to_Work_Public_Transportation_Pct, na.rm = TRUE))

ggplot(NYC_df, aes(x = year, y = TotalPop, group = county, color = county)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(breaks = unique(NYC_df$year)) + # Show every year in the graph
  theme_minimal() +
  labs(title = "Mean Year Over Year Percent of Population Commuting by Public Transportation for NYC (2013-2021)",
       x = "Year",
       y = "Percent of Total Population",
       color = "County")

# Add Age Distribution data
NYC_df_2 <- data %>% 
  filter(state == "NY" & county == "New York County" | county == "Bronx County" | county == "Kings County" | county == "Queens County" | county == "Richmond County") %>%
  group_by(county, year) %>%
  summarise(PctPopCommute = mean(Commuting_to_Work_Public_Transportation_Pct, na.rm = TRUE), Pct_Age_15_24 = mean(Age_15_19_Pct_of_Pop+Age_20_24_Pct_of_Pop), Pct_Age_25_44 = mean(Age_25_34_Pct_of_Pop+Age_35_44_Pct_of_Pop), Pct_Age_45_59 = mean(Age_45_54_Pct_of_Pop+Age_55_59_Pct_of_Pop), Pct_Age_60_74 = mean(Age_60_64_Pct_of_Pop+Age_65_74_Pct_of_Pop), Pct_Age_75_Up = mean(Age_75_84_Pct_of_Pop+Age_85_and_older_Pct_of_Pop))

p <- ggplot(data = NYC_df_2, aes(x = year, fill = as.factor(year))) + 
  # Add the stacked bar graph with fill mapped in aes for a legend
  geom_bar(aes(y = Pct_Age_15_24, fill = "15-24"), stat = "identity", alpha = 1) +
  geom_bar(aes(y = Pct_Age_25_44, fill = "25-44"), stat = "identity", alpha = 1, position = "stack") +
  geom_bar(aes(y = Pct_Age_45_59, fill = "45-59"), stat = "identity", alpha = 1, position = "stack") +
  geom_bar(aes(y = Pct_Age_60_74, fill = "60-74"), stat = "identity", alpha = 1, position = "stack") +
  geom_bar(aes(y = Pct_Age_75_Up, fill = "75+"), stat = "identity", alpha = 1, position = "stack") +
  # Add the line graph
  geom_line(aes(y = PctPopCommute, group = county, color = county)) +
  # Add the points
  geom_point(aes(y = PctPopCommute, group = county, color = county)) +
  scale_fill_manual(values = c("15-24" = "yellow", 
                               "25-44" = "red", 
                               "45-59" = "blue", 
                               "60-74" = "pink", 
                               "75+" = "orange"),
                    name = "Age Group") +
  scale_color_discrete(name = "County") + # If you have a variable 'county' for lines
  scale_x_continuous(breaks = unique(NYC_df_2$year)) + # Show every year in the graph
  # Labels and theme
  labs(x = "Year", 
       y = "Percentage", 
       title = "Year Over Year Trend in Percent of Population Commuting and Age Distribution for NYC",
       subtitle = "Stacked bar for age distribution and line for commuting trend") +
  theme_minimal()

print(p)

# Add Income Distribution data
# Add Age Distribution data
NYC_df_3 <- data %>% 
  filter(state == "NY" & county == "New York County" | county == "Bronx County" | county == "Kings County" | county == "Queens County" | county == "Richmond County") %>%
  group_by(county, year) %>%
  summarise(PctPopCommute = mean(Commuting_to_Work_Public_Transportation_Pct, na.rm = TRUE), Pct_Income_Less_Than_15k = mean(Family_Income_Less_Than_10k+Family_Income_10k_14999), Pct_Income_15k_35k = mean(Family_Income_15k_24999+Family_Income_25k_34999), Pct_Income_35k_75k = mean(Family_Income_35k_49999+Family_Income_50k_74999), Pct_Income_75k_150k = mean(Family_Income_75k_99999+Family_Income_100k_149999), Pct_Income_150k_Over = mean(Family_Income_150k_199999+Family_Income_Greater_Than_200k))

b <- ggplot(data = NYC_df_3, aes(x = year, fill = as.factor(year))) + 
  # Add the stacked bar graph with fill mapped in aes for a legend
  geom_bar(aes(y = Pct_Income_Less_Than_15k, fill = "<15K"), stat = "identity", alpha = 1) +
  geom_bar(aes(y = Pct_Income_15k_35k, fill = "15K-35K"), stat = "identity", alpha = 1, position = "stack") +
  geom_bar(aes(y = Pct_Income_35k_75k, fill = "35K-75K"), stat = "identity", alpha = 1, position = "stack") +
  geom_bar(aes(y = Pct_Income_75k_150k, fill = "75K-150K"), stat = "identity", alpha = 1, position = "stack") +
  geom_bar(aes(y = Pct_Income_150k_Over, fill = "150K+"), stat = "identity", alpha = 1, position = "stack") +
  # Add the line graph
  geom_line(aes(y = PctPopCommute, group = county, color = county)) +
  # Add the points
  geom_point(aes(y = PctPopCommute, group = county, color = county)) +
  scale_fill_manual(values = c("<15K" = "yellow", 
                               "15K-35K" = "red", 
                               "35K-75K" = "blue", 
                               "75K-150K" = "pink", 
                               "150K+" = "orange"),
                    name = "Age Group") +
  scale_color_discrete(name = "County") + # If you have a variable 'county' for lines
  scale_x_continuous(breaks = unique(NYC_df_2$year)) + # Show every year in the graph
  # Labels and theme
  labs(x = "Year", 
       y = "Percentage", 
       title = "Year Over Year Trend in Percent of Population Commuting and Age Distribution for NYC",
       subtitle = "Stacked bar for age distribution and line for commuting trend") +
  theme_minimal()

print(b)