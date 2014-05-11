## Clear the env I've been playing in and collect garbage - can remove from final code
rm(list=ls())
gc()

## Stick some header in here and comments
library(data.table)

## Create a connection
PowerFile <- "C:/Users/bernie/Data Exploration/Assignment 1/household_power_consumption.txt"
SmallPowerFile <- "C:/Users/bernie/Data Exploration/Assignment 1/household_power_consumption_Feb_2007.txt"
conRead <- file(PowerFile, "r", blocking = FALSE)
conWrite <- file(SmallPowerFile, "w", blocking = FALSE)

# Read in the file line by line and just take the ones needed
#take the header
this_line <- readLines(conRead,1); writeLines(this_line, con = conWrite, sep = "\n")
#assume data is sorted 
foundMonthYear <- FALSE
while (foundMonthYear == FALSE | substr(this_line,2,8)=="/2/2007")
  { 
  #avoid regex for speed and use first condition to reject most lines quickly
  if(substr(this_line,2,4)=="/2/" & (substr(this_line,1,8)=="1/2/2007" | substr(this_line,1,8)=="2/2/2007"))
    {
      foundMonthYear <- TRUE
      this_line <- gsub("2/","02/",this_line)
      this_line <- gsub("1/","01/",this_line)
      writeLines(this_line, con = conWrite, sep = "\n")
    }
  this_line <- readLines(conRead,1)
  }

#read the data in, close connections and remove working file
power_data <- data.table(read.csv(SmallPowerFile,sep=';',stringsAsFactor=FALSE))
close(conRead);close(conWrite)
file.remove(SmallPowerFile)

#sort datetime data
power_data[,datetime:=paste(Date,Time)][,Time:=NULL][,Date:=NULL]

#write chart to PNG
png(file="C:/Users/bernie/Data Exploration/Assignment 1/plot1.png",width=480,height=480,res=72)
hist(power_data$Global_active_power,n=15,col='red',main=paste("Global Active Power"),xlab="Global Active Power (kilowatts)")
dev.off()