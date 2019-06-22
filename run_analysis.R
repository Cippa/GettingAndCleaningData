#Cleaning the environment
rm(list = ls())
objects()
search()
intersect(objects(), search())

#Libraries used
library(tidyverse)

#Creating folders
if(!dir.exists("./data")){
        dir.create("./data")
}

if(!dir.exists("./outputs")){
        dir.create("./outputs")
}

if(!dir.exists("./scripts")){
        dir.create("./scripts")
}



#Download the dataset
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url = fileUrl, destfile = "./data/dataProject.zip", method = "curl")
#Unzip files in the "data" folder
unzip(zipfile = "./data/dataProject.zip", exdir = "./data")


##########Training and test sets################################################
#According to the "READM.txt" file of the dataset
#the file "train/X_train.txt" is the training set.

#Reading the training set
training <- read.table(file = "./data/UCI HAR Dataset/train/X_train.txt", header = FALSE)

#According to the "READM.txt" file of the dataset
#the file "test/X_test.txt" is the test set.

#Reading the test set
test <- read.table(file = "./data/UCI HAR Dataset/test/X_test.txt", header = FALSE)

#Merging training and test datasets into a unique one
wholeDataset <- bind_rows(training, test)

###########Features names#######################################################
#According to the "READM.txt" file of the dataset
#the file "features.txt" list all the features measured in the dataset.

#Reading the list of features measured
features <- read.table(file = "./data/UCI HAR Dataset/features.txt")

#Renaming the columns of the wholeDaset according to the features mesured
names(wholeDataset) <- features$V2

#Removing test, training and features datasets to maintain a clean envoronment
rm(test, training, features)

##########Activity labels#######################################################
#According to the "READM.txt" file of the dataset
#the file "train/y_train.txt" reports the training set labels.

#Reading the training set labels
trainingLabels <- read.table(file = "./data/UCI HAR Dataset/train/y_train.txt")

#According to the "READM.txt" file of the dataset
#the file "test/y_test.txt" reports the test set labels.

#Reading the test set labels
testLabels <- read.table(file = "./data/UCI HAR Dataset/test/y_test.txt")

#Merging trainingLabels and testLabels datasets into a unique one
wholeLabels <- bind_rows(trainingLabels, testLabels)

#Removing trainingLabels and testLabels to mantain a clean environment
rm(trainingLabels, testLabels)

#Renaming the column of the wholeLables dataset into "activity"
wholeLabels <- rename(wholeLabels, activity = V1)

#Adding the activity labels to the wholeDataset
wholeDataset <- bind_cols(wholeDataset, wholeLabels)

#Removing test, trainig and wholeLabels datasets to mantain a clean environment
rm(wholeLabels)

##########Subjects##############################################################
#According to the "READM.txt" file of the dataset
#the file "'train/subject_train.txt" reports the subjects that performed
#the training activities.

#Reading the subjects in the training set
trainingSubjects <- read.table(file = "./data/UCI HAR Dataset/train/subject_train.txt")

#According to the "READM.txt" file of the dataset
#the file "test/subject_test.txt" reports the subjects that performed
#the test acticities.

#Reading the subject in the test set
testSubjects <- read.table(file = "./data/UCI HAR Dataset/test/subject_test.txt")

#Merging trainingSubjectss and testSubjects datasets into a unique one
wholeSubjects <- bind_rows(trainingSubjects, testSubjects)

#Removing trainingSubjects and testSubjects to mantain a clean environment
rm(trainingSubjects, testSubjects)

#Renaming the column of the wholeSubjects dataset into "subject"
wholeSubjects <- rename(wholeSubjects, subject = V1)

#Adding the subjects to the wholeDataset
wholeDataset <- bind_cols(wholeSubjects, wholeDataset)

#Removing wholeSUbjects dataset to mantain a clean environment
rm(wholeSubjects)

##########Activity description##################################################
#According to the "READM.txt" file of the dataset
#the file "activity_labels.txt" reports the descriptive activity names linked
#to the activity labels of the dataset.

#Reading the activity_labels file
activityLabels <- read.table(file = "./data/UCI HAR Dataset/activity_labels.txt")

#Renaming the variables in activityLabels
activityLabels <- activityLabels %>%
        rename( activity = V1, activityDescription = V2)

#Merging wholeDataset with activityLables
wholeDataset <- left_join(x = wholeDataset, y = activityLabels, "activity")

#Removing activityLabels dataset to maintain a clean environment
rm(activityLabels)

##########Prepare tidy dataset##################################################
tidyDataSet <- wholeDataset %>%
        select(-activity) %>%
        group_by(activityDescription, subject) %>%
        summarise_all(mean)

##########Saving tidy dataset###################################################
write.table(x = tidyDataSet, file = "./outputs/tidyDataSet.txt", row.names = FALSE)

rm(wholeDataset, tidyDataSet)
