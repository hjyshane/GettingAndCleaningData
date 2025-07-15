library(data.table)
library(dplyr)
library(tidr)

# Load the datasets
test <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE, sep = "")
train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE, sep = "")
test_label <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE, sep = "")
train_label <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE, sep = "")
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE, sep = "")
train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE, sep = "")
features <- read.table("./UCI HAR Dataset/features.txt", header = FALSE, sep = "")
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = FALSE, sep = "")

# COLUMN NAMES  
colnames(test) <- features$V2
colnames(train) <- features$V2
colnames(test_label) <- "activity"
colnames(train_label) <- "activity"
colnames(test_subject) <- "subject"
colnames(train_subject) <- "subject"

train$subject <- train_subject$subject
test$subject <- test_subject$subject
train$activity <- train_label$activity
test$activity <- test_label$activity

# Merge the datasets
combined <- bind_rows(train, test)

activity_labels <- setNames(activity_labels$V2, activity_labels$V1)
combined$activity <- activity_labels[combined$activity]

# Extract mean and standard deviation measurements
mean_std_features <- grep("mean\\(\\)|std\\(\\)", features$V2)
combined <- combined %>%
  select(subject, activity, all_of(features$V2[mean_std_features]))

# Create a tidy dataset with the average of each variable for each activity and subject
tidy_data <- combined %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), mean), .groups = 'drop')

# Write the tidy dataset to a text file
write.table(tidy_data, "tidy_data.txt", row.names = FALSE, sep = "\t", quote = FALSE)
