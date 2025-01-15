#Load required packages
library(dplyr)
library(tidyr)
library(tidyverse)
library(caret)
library(pROC)
library(ggplot2)
library(kernlab)
library(e1071)
library(ROSE)
library(rpart)


#Load prepared data
data <- read.csv("/Users/evan/prepared_zipcode_data.csv")

#Drop unneeded variables like year, major_city
data <- select(data, -one_of(c("ZIP", "GEOID", "NAME", "year", "major_city", "county", "state", "ZCTA5CE20", "INTPTLAT20", "INTPTLON20", "Rail_YN", "Stop_YN")))

#Set target variable to factor type
data$target <- as_factor(data$target)

#Bar plot showing target distribution in the dataset
ggplot(data, aes(x = target)) + 
  geom_bar() +
  xlab("Target Variable") +
  ylab("Count") +
  ggtitle("Distribution of Target Variable")


#####GLM Model Run Cross Validation#####
set.seed(123) # For reproducibility
control <- trainControl(method = "cv", number = 10)  # 10-fold cross-validation
#GLM for binary classification
model_cv <- train(target ~ ., data = data, method = "glm", family = "binomial", trControl = control)
print(model_cv)

#####Class Imbalance#####
#Create frequency table to look at distribution of target variable
frequency_table <- table(data$target)
print(frequency_table)
#Convert frequency to percentage
percentage_table <- prop.table(frequency_table) * 100
#View the table
percentage_table

#Over Sample Minority Class
data_balanced <- ovun.sample(target ~ ., data = data, method = "over", N = 625000)$data

#Check distribution
ggplot(data_balanced, aes(x = target)) + 
  geom_bar() +
  xlab("Target Variable") +
  ylab("Count") +
  ggtitle("Distribution of Target Variable")

#Create frequency table to look at distribution of target variable
frequency_table_2 <- table(data_balanced$target)
print(frequency_table_2)
#Convert frequency to percentage
percentage_table_2 <- prop.table(frequency_table_2) * 100
#View the table
percentage_table_2


#Re run model after Over Sampling Minority (1)
model_cv <- train(target ~ ., data = data_balanced, method = "glm", family = "binomial", trControl = control)
print(model_cv)


#####Split data into training and testing datasets#####
set.seed(123) #For reproducibility
# Create indices for the training set
train_indices <- createDataPartition(data_balanced$target, p = 0.70, list = FALSE)

#Split the data
train_data <- data_balanced[train_indices, ]
test_data <- data_balanced[-train_indices, ]
train_weights <- weights[train_indices]


#####GLM Model#####
model_glm <- glm(target ~ ., data = train_data, family = binomial())
summary(model_glm)
print(model_glm)

#Training Statistics
probabilities <- predict(model_glm, newdata = train_data, type = "response")
class_predictions <- ifelse(probabilities > 0.5, 1, 0)
#Confusion Matrix
conf_matrix <- table(Predicted = class_predictions, Actual = train_data$target)
print(conf_matrix)
# Accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
print(accuracy)
# Precision, Recall, and F1 Score (for binary classification)
precision <- conf_matrix[2,2] / sum(conf_matrix[2,])
print(precision)
recall <- conf_matrix[2,2] / sum(conf_matrix[,2])
print(recall)
f1_score <- 2 * (precision * recall) / (precision + recall)
print(f1_score)
roc_obj <- roc(response = train_data$target, predictor = probabilities)
auc(roc_obj)
plot(roc_obj)

#Test GLM Model
probabilities <- predict(model_glm, newdata = test_data, type = "response")
class_predictions <- ifelse(probabilities > 0.5, 1, 0)

#GLM Model Testing Data Statistics
#Confusion Matrix
conf_matrix <- table(Predicted = class_predictions, Actual = test_data$target)
print(conf_matrix)
# Accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
print(accuracy)
# Precision, Recall, and F1 Score (for binary classification)
precision <- conf_matrix[2,2] / sum(conf_matrix[2,])
print(precision)
recall <- conf_matrix[2,2] / sum(conf_matrix[,2])
print(recall)
f1_score <- 2 * (precision * recall) / (precision + recall)
print(f1_score)
roc_obj <- roc(response = test_data$target, predictor = probabilities)
auc(roc_obj)
plot(roc_obj)
