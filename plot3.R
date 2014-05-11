## Clear the env I've been playing in and collect garbage - can remove from final code
rm(list=ls())
gc()

## Stick some header in here and comments
library(data.table)

## Create a connection
PowerFile <- "C:/Users/bernie/Data Exploration/Assignment 1/household_power_consumption.txt"
SmallPowerFile <- "C:/Users/bernie/Data Exploration/Assignment 1/household_power_consumption_Feb_2007.txt"
conRead <- file(PowerFile, "r", blocking = TRUE)
conWrite <- file(SmallPowerFile, "w", blocking = TRUE)

# Read in the file line by line and just take the ones needed
#take the header
this_line <- readLines(conRead,1)
this_line <- gsub("Date;Time","date;time",this_line)
writeLines(this_line, con = conWrite, sep = "\n")

#assume data is sorted 
foundMonthYear <- FALSE
while (foundMonthYear == FALSE | substr(this_line,2,8)=="/2/2007")
  { 
  #avoid regex for speed and use first condition to reject most lines quickly
  if(substr(this_line,2,4)=="/2/" & (substr(this_line,1,8)=="1/2/2007" | substr(this_line,1,8)=="2/2/2007"))
    {
      foundMonthYear <- TRUE
      this_line   <- gsub("2/","02/",this_line)
      this_line   <- gsub("1/","01/",this_line)
      this_line   <- paste(substr(this_line,7,10),"-",substr(this_line,4,5),"-",substr(this_line,1,2),"", substr(this_line,11,nchar(this_line)),sep="") 
      writeLines(this_line, con = conWrite)#, sep = "\n")
    }
  this_line <- readLines(conRead,1)
  }

#read the data in, close connections and remove working file
power_data <- data.table(read.csv(SmallPowerFile, sep=';',stringsAsFactor=FALSE))
close(conRead);close(conWrite)
file.remove(SmallPowerFile)

#sort datetime data
power_data[,datetime:=as.POSIXct(paste(power_data$date,power_data$time))]

#write chart to PNG
png(file="C:/Users/bernie/Data Exploration/Assignment 1/plot3.png",width=480,height=480,res=72)
#par(cex=72/120)
with(power_data,plot(datetime,Sub_metering_1,type='l',xlab="",ylab="Energy sub metering"))
with(power_data,lines(datetime,Sub_metering_2,col='red'))
with(power_data,lines(datetime,Sub_metering_3,col='blue'))
with(power_data,legend("topright",lty=1,col=c("black","red","blue"),legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3")))
dev.off()