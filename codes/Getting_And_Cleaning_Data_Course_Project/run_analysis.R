# John Hopkins Coursera Data Science Specialisation - Getting and Cleaning Data Project 
# Author: Harmilap Singh Dhaliwal

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# clear environment and console
rm(list = ls())
st <- Sys.time()
cat("\014")

# load required packages
require(data.table)
require(tidyverse)

# Data can be downloaded from the following link
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# read activity labels and features
activityLabels <- fread(file.path("data/UCI HAR Dataset/activity_labels.txt"), 
                        col.names = c("class", "activity"))

features <- fread(file.path("data/UCI HAR Dataset/features.txt"),
                  col.names = c("index", "features"))

# get only 'Mean' and 'Std' variables
featuresWanted <- grep("(mean|std)\\(\\)", features[,features])
featureNames <- grep("(mean|std)\\(\\)", features[,features], value = TRUE)
featureNames <- str_replace_all(featureNames, '[()]', '')

# read train dataset
train <- fread(file.path("data/UCI HAR Dataset/train/X_train.txt"))[,featuresWanted, with = FALSE]
setnames(train, colnames(train), featureNames)

trainActivities <- fread(file.path("data/UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path("data/UCI HAR Dataset/train/subject_train.txt"), col.names = c("Subject"))
train <- cbind(trainSubjects, trainActivities, train)

# read test datasets
test <- fread(file.path("data/UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
setnames(test, colnames(test), featureNames)

testActivities <- fread(file.path("data/UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path("data/UCI HAR Dataset/test/subject_test.txt"), col.names = c("Subject"))
test <- cbind(testSubjects, testActivities, test)

# combine train and test datasets
final_dt <- rbind(train, test)
# replace Activity Labels with Activity names
final_dt$Activity <- activityLabels[final_dt$Activity, "activity"]

# get the tidy data in the required format
tidyData <- final_dt %>%
    group_by(Subject, Activity) %>%
    summarise_all(mean) #summarise(across(everything(), mean))

write.table(tidyData, "codes/Getting_And_Cleaning_Data_Course_Project/tidyData.txt", row.names = FALSE)
write.csv(tidyData, "codes/Getting_And_Cleaning_Data_Course_Project/tidyData.csv", row.names = FALSE)

et <- Sys.time()
print(et - st)

rm(list = ls()[!(ls() %in% c("tidyData"))])
