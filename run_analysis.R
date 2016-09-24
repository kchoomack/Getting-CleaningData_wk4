library(dplyr)
library(data.table)
library(tidyr)

#set file path
fp <- "C:/Users/Kate/Rstuff/UCI HAR Dataset"

#read each file into a data table

#training data
subject_train <- tbl_df(read.table(file.path(fp, "train", "subject_train.txt")))
X_train <- tbl_df(read.table(file.path(fp, "train", "X_train.txt")))
y_train <- tbl_df(read.table(file.path(fp, "train", "y_train.txt")))

#test data
subject_test <- tbl_df(read.table(file.path(fp, "test", "subject_test.txt")))
X_test <- tbl_df(read.table(file.path(fp, "test", "X_test.txt")))
y_test <- tbl_df(read.table(file.path(fp, "test", "y_test.txt")))

#merge each corresponding data table
merged_subject <- rbind(subject_train, subject_test)
merged_X <- rbind(X_train, X_test)
merged_y <- rbind(y_train, y_test)

#Set variable names for subject and activity data
setnames(merged_subject, "V1", "Subject")
setnames(merged_y, "V1", "Activity_Number")

#set the colunm names for the activity labels
Activity_Labels <- tbl_df(read.table(file.path(fp, "activity_labels.txt")))
setnames(Activity_Labels, names(Activity_Labels), c("Activity_Number","Activity_Name"))

#extract lables fromt the features file to lable the activity data columns
Features <- tbl_df(read.table(file.path(fp, "features.txt")))
setnames(Features, names(Features), c("Feature_Number", "Feature_Name"))
colnames(merged_X) <- Features$Feature_Name

#merge all tables
mergedActSub <- cbind(merged_subject, merged_y)
merged_table <- cbind(mergedActSub, merged_X)

#filter rows with standard deviation and mean
Features_std_mean <- grep("mean\\(\\)|std\\(\\)",Features$Feature_Name,value=TRUE)
Features_std_mean <- union(c("Subject","Activity_Number"), Features_std_mean)
filtered_table <- subset(merged_table,select=Features_std_mean)

#add descriptive labels to the data table
filtered_table <- merge(Activity_Labels, filtered_table , by="Activity_Number", all.x=TRUE)
filtered_table$Activity_Name <- as.character(filtered_table$Activity_Name)

#create table with means sortd by Activity and Subject
aggregated_table <- aggregate(. ~ Subject - Activity_Name, data = filtered_table, mean)
final_table <- tbl_df(arrange(aggregated_table,Subject,Activity_Name))

#write final data table to file
write.table(final_table, "CleanData.txt", row.name=FALSE)












