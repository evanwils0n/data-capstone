# Import Libraries
library("dplyr")
library("ggplot2")
library("tidyr")
library("zipcodeR") # Map zipcodes to CITY, STATE
                    #download_zip_data(force = FALSE)
library("sf")       # Spatial package

# Read in prepared data
# Census Data from census_data.R script
census_data <- read.csv('acs_data_zipcode.csv', header = TRUE, sep=",")

# Geospatially processed data exported from QGIS
# County Boundaries
#counties_intersect <- read.csv('ounties_enriched.csv', header = TRUE, sep= ",")

# Convert shapefile to csv with wkt
# Zip Code Boundaries
zipcode_shp <- st_read("tl_2023_us_zcta520")
# Add target variable where Rail_YN=1 AND Stop_YN=1
zipcode_shp$target <- ifelse(zipcode_shp$Rail_YN == 1 & zipcode_shp$Stop_YN == 1, 1, 0)


# Create wkt geometry
#zipcode_shp$wkt <- st_as_text(zipcode_shp$geometry)
# Set the geometry
#shp <- st_set_geometry(shp, NULL)
# Store copy
#write.csv(shp, "zipcode_boundaries.csv", row.names = FALSE)


# Find percentage of nulls for each column
null_percentages <- sapply(census_data, function(x) mean(is.na(x)) * 100)
View(null_percentages)
# Convert to dataframe
null_df <- data.frame(t(null_percentages))
View(null_df)

# Pivot for visualization
selected_columns <- null_df[, sapply(null_df, function(x) any(x > 20))]
long_data <- pivot_longer(selected_columns, cols = everything(), names_to = "column", values_to = "value")

# Bar Chart of Nulls per Column
ggplot(long_data, aes(x = column, y = value)) +
  geom_bar(stat = "identity")


# Add City and State names to zipcode data using zipcodeR
zip_code_lookup<-zip_code_db
census_data$ZIP <- substr(census_data$NAME, nchar(census_data$NAME) - 4, nchar(census_data$NAME))

enriched_zips <- merge(census_data, zip_code_lookup, by.x = "ZIP", by.y = "zipcode", all.x = TRUE)
View(enriched_zips)

# Remove rows pertaining to Puerto Rico (PR)
zips_final <- enriched_zips[enriched_zips$state != "PR", ]
View(zips_final)


# Join data frames keeping all the census_data and applying counties_intersect to all rows
merge_df <- merge(zips_final, zipcode_shp, by.x = "ZIP", by.y = "GEOID20", all.x = TRUE)
View(merge_df)

#Remove census margin of error columns
columns_to_remove <- grepl("PM$", names(merge_df))

#Create new data frame with removed margin of error columns
merge_df_2 <- merge_df[, !columns_to_remove]
View(merge_df_2)

#Remove the unneeded columns from the counties_intersect
merge_df_3 <- merge_df_2 %>% select(-c('zipcode_type', 'post_office_city', 'common_city_list', 'lat', 'lng', 'timezone', 'radius_in_miles', 'area_code_list', 'population', 'population_density', 'land_area_in_sqmi', 'water_area_in_sqmi', 'housing_units', 'occupied_housing_units', 'median_home_value', 'median_household_income', 'bounds_west', 'bounds_east', 'bounds_north', 'bounds_south', 'GEOIDFQ20', 'CLASSFP20', 'MTFCC20', 'FUNCSTAT20', 'ALAND20', 'AWATER20', 'geometry'))
View(merge_df_3)

#Find rows with NA values
rows_with_na_df <- merge_df_3 %>% filter_all(any_vars(is.na(.)))
View(rows_with_na_df)

#Update NA values in Age_85_and_older_Pct_of_Pop to 0
merge_df_3 <- merge_df_3 %>% mutate_if(is.numeric, ~replace(., is.na(.), 0))

#Find rows with NA values
rows_with_na_df <- merge_df_3 %>% filter_all(any_vars(is.na(.)))
View(rows_with_na_df)

#Remove NA rows
clean_df <- na.omit(merge_df_3)
View(clean_df)

#Export file to csv
write.csv(clean_df, 'prepared_zipcode_data.csv', row.names = FALSE)
