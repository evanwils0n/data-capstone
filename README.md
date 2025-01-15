# data-capstone

## Census Data Analysis for Rail Transportation Planning

### Project Objective

The primary objective of this project is to create a predictive model that will leverage census data and commuter rail transportation statistics to forecast commuter behavior.  This will allow for data-driven decisions to be made concerning transportation planning and the allocation of resources to better serve the public.  The main objectives will be to predict commuter trends by way of historic and current census data, develop insights that will optimize commuter experience, and make informed choices for resource allocation, infrastructure improvements, and any policy adjustments.

### Methodology & Data Sources

To obtain these objectives the project will employ a methodology that will gather a wide range of demographic and socioeconomic data from the US Census Bureau.  The data will be thoroughly cleaned and preprocessed to maintain integrity.  Key variables that influence commuter behavior, such as population density, income levels, employment data, and rail transportation factors, will be captured.  Using this data, machine learning and predictive modeling techniques can be applied to develop a robust predictive model.  This model will then be validated and interpreted so the outputs can be translated into insights.

* The data for the different machine learning models can be recreated by acquiring the data from the US Census Bureau using the tidycensus package in R.  The census_data.R file contains the steps to acquire the data.  Keep in mind, you will need to request an API key from the Census Bureau.
* GIS data is also necessary to perform the analysis.  The zipcode polygons (tl_2023_us_zcta520) are used to create the target variable by intersecting the rail lines & nodes with the zipcode polygons.  QGIS is used to perform this spatial analysis.  Two columns will be created from the intersections; Rail_YN and Stops_YN.  These fields will be boolean, 0 for False and 1 for True, values used to determine the boundaries that intersect with the rail lines and stops.  With the creation of these two columns, a target field can be also be created in R by assigned a 1 to all the rows where Rail_YN and Stops_YN equal 1.
* The other data source needed for this project is obtained by way of the US Bureau of Transportation Statistics.  The North American Rail Network Lines and Nodes files are available for download 'https://geodata.bts.gov/datasets/usdot::north-american-rail-network-lines/about' & 'https://geodata.bts.gov/datasets/usdot::north-american-rail-network-nodes/about'

### Predictive Models

#### Generalized Linear Model (GLM)
Much like a Linear Regression model, GLMs are used to understand the relationship between one or more independent variables and the target variable.  However, Linear Regression models assume that the dependent variable is continuous with a normal distribution in the dataset.  GLMs are not as restricted and can accommodate various types of target variables and relationships.  The advantage of using a GLM for this dataset is the binomial dependent variable and irregular distribution of the target variable.  This is available in the GLM_Model.R file.

#### Random Forest Model
Random Forest models are a type of ensemble learning technique.  The “forest” is a combination of multiple decision trees with each tree being built from a random sample of the training data.  For the purposes of this project, this model is very useful in dealing with noisy data.  Given the main data source has been from the U.S. Census Bureau, census data tends to be inherently noisy at lower geographic levels.  Aside from being less sensitive to noise in the data, a random forest model was decided upon after the overfitting experience during the training of the GLM model.  Random forests are able to improve generalization by averaging multiple decision trees.  This is available in the RandomForest_Model.ipynb.

#### Neural Network Model (NN)
Neural Network models, NN, are a type of machine learning model inspired by the structure and processing of the human brain.  A series of interconnected nodes, or neurons, are organized into layers.  An input layer receives an input signal, hidden layers that process this input, and an output layer to produce the final prediction.  These types of layers are especially useful for processing complex, non-linear relationships, which is why this type of model is being used.  Although the data has been adjusted to account for the imbalance in the distribution of the target variable, census data, particularly at lower geographic regions, such as block groups or tracts, tend to be noisy.  The intention is to utilize the reliability of neural network models to account for the imperfections in the data.  This is made available in the NN_Model.ipynb.

#### K-Nearest Neighbor (kNN)
The K-Nearest Neighbor model was attempted but never fully analyzed.  It was prepared, but still requires fine-tuning to improve F1-Score.
