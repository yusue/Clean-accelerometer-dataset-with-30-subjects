#download zipfile and unzip
rm(list=ls())
fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

setwd("/Users/yusue/Downloads")
if(!file.exists("runanalysis.zip")){
    download.file(fileURL, destfile = "runanalysis.zip", method = "curl")
}

zipF<- "/Users/yusue/Downloads/runanalysis.zip"
outDir<-"/Users/yusue/Downloads"
unzip(zipF,exdir=outDir)

#read txt files into R as data frame
xtest = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/test/X_test.txt", header = F, sep = "")
ytest = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/test/y_test.txt", header = F, sep = "")
subject_test = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/test/subject_test.txt", header = F, sep = "")

xtrain = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/train/X_train.txt", header = F, sep = "")
ytrain = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/train/y_train.txt", header = F, sep = "")
subject_train = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/train/subject_train.txt", header = F, sep = "")

activity_labels = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/activity_labels.txt", header = F, sep = "")

features = read.csv("/Users/yusue/Downloads/UCI HAR Dataset/features.txt", header = F, sep = "")

# Give dataframes variables accordingly
colnames(xtest) = features[,2]
colnames(xtrain) = features[,2]
colnames(ytest) = "activityId"
colnames(ytrain) = "activityId"
colnames(subject_test) = "subjectId"
colnames(subject_train) = "subjectId"
colnames(activity_labels) = c("activityId","activityname")

# Merges the training and the test sets to create one data set
testdf = cbind(subject_test, xtest, ytest)
traindf = cbind(subject_train, xtrain, ytrain)
totalset = rbind(traindf,testdf)

# Extracts only the measurements on the mean and standard deviation for each measurement
library(dplyr)
  
selected_cols = grep('mean|std', names(totalset), value = T)
selected_cols = c(selected_cols , 'activityId', "subjectId")

s_df = totalset[, selected_cols]
mergedata = merge(s_df, activity_labels, by = "activityId", all = T)

# Appropriately labels the data set with descriptive variable names
names(mergedata) = gsub("Acc", "Accelerometer", names(mergedata))
names(mergedata)<-gsub("Gyro", "Gyroscope", names(mergedata))
names(mergedata)<-gsub("BodyBody", "Body", names(mergedata))
names(mergedata)<-gsub("Mag", "Magnitude", names(mergedata))
names(mergedata)<-gsub("^t", "Time", names(mergedata))
names(mergedata)<-gsub("^f", "Frequency", names(mergedata))
names(mergedata)<-gsub("tBody", "TimeBody", names(mergedata))
names(mergedata)<-gsub("-mean()", "Mean", names(mergedata), ignore.case = TRUE)
names(mergedata)<-gsub("-std()", "STD", names(mergedata), ignore.case = TRUE)
names(mergedata)<-gsub("-freq()", "Frequency", names(mergedata), ignore.case = TRUE)
names(mergedata)<-gsub("angle", "Angle", names(mergedata))
names(mergedata)<-gsub("gravity", "Gravity", names(mergedata))

# generate a new tidy data set with the average of each variable for each activity and each subject
tidydata = aggregate(.~subjectId + activityId, mergedata,mean)
write.table(tidydata, file = "tidydata.txt", row.names = F)

# selectdf = select(subjectId, activityID, contains("mean"), contains("std"))