# File:

# run_analysis.R

# Overview:

# Here we are using data collected from the accelerometers from the Samsung Galaxy S2 smartphone,
# in order to manipulate data with the result of producing clean data set. The main goal is to make
# tidy data, named "tidy_data.txt".

library(dplyr)

# Step 0.1 - Getting the data

# download zip file with the needed data, if you previously haven't downloaded it

zipURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!file.exists(zipFile)) {
        download.file(zipURL, zipFile, mode = "wb")
}

# unzip zip file with the data

dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
        unzip(zipFile)
}

## Step 0.2 - Reading the data

# reading training data

train_Subjects <- read.table(file.path(dataPath, "train", "subject_train.txt"))
train_Values <- read.table(file.path(dataPath, "train", "X_train.txt"))
train_Activity <- read.table(file.path(dataPath, "train", "y_train.txt"))

# reading test data

test_Subjects <- read.table(file.path(dataPath, "test", "subject_test.txt"))
test_Values <- read.table(file.path(dataPath, "test", "X_test.txt"))
test_Activity <- read.table(file.path(dataPath, "test", "y_test.txt"))

# reading features

features <- read.table(file.path(dataPath, "features.txt"), as.is = TRUE)

# reading activity labels

activities <- read.table(file.path(dataPath, "activity_labels.txt"))
colnames(activities) <- c("activity_ID", "activity_Label")

## Step 1.0 - Merging the training and the test sets to create one unique data set

# merging individual data tables to make a single data table

human_Activity <- rbind(
        cbind(train_Subjects, train_Values, train_Activity),
        cbind(test_Subjects, test_Values, test_Activity)
)

# removing individual data tables in order to save memory

rm(train_Subjects, train_Values, train_Activity, test_Subjects, test_Values, test_Activity)

# assigning column names

colnames(human_Activity) <- c("subject", features[, 2], "activity")

## Step 2.0 - Extracting only the measurements on the mean and standard deviation for each measurement

# determining columns of data set to be kept based on a column name

columns_to_kepp <- grepl("subject|activity|mean|std", colnames(human_Activity))

# keeping data in these columns only

human_Activity <- human_Activity[, columns_to_kepp]

## Step 3.0 - Using descriptive activity names to name the activities in the data set

# replacing activity values with named factor levels

human_Activity$activity <- factor(human_Activity$activity, levels = activities[, 1], labels = activities[, 2])

## Step 4.0 - Labeling the data set with descriptive variable names

# extracting column names

human_Activity_columns <- colnames(human_Activity)

# removing special characters

human_Activity_columns <- gsub("[\\(\\)-]", "", human_Activity_columns)

# expanding abbreviations  and cleaning up names

human_Activity_columns <- gsub("^f", "frequency_Domain", human_Activity_columns)
human_Activity_columns <- gsub("^t", "time_Domain", human_Activity_columns)
human_Activity_columns <- gsub("Acc", "Accelerometer", human_Activity_columns)
human_Activity_columns <- gsub("Gyro", "Gyroscope", human_Activity_columns)
human_Activity_columns <- gsub("Mah", "Magnitude", human_Activity_columns)
human_Activity_columns <- gsub("Freq", "Frequency", human_Activity_columns)
human_Activity_columns <- gsub("mean", "Mean", human_Activity_columns)
human_Activity_columns <- gsub("std", "standard_Deviation", human_Activity_columns)

# correcting typo

human_Activity_columns <- gsub("BodyBody", "Body", human_Activity_columns)

# using the new labels as column names

colnames(human_Activity) <- human_Activity_columns

## Step 5.0 - Creating a second, independent tidy set with the average of each variable
##            for each activity and each subject

# group by subject and activity and summarise using mean

human_Activity_means <- human_Activity %>%
        group_by(subject, activity) %>%
        summarise_each(funs(mean))

# outputing file "tidy_data.txt"

write.table(human_Activity_means, "tidy_data.txt", row.names = FALSE, quote = FALSE)