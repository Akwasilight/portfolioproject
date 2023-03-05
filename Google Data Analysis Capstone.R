## Google Data Analysis Capstone : Case Study 1, Cyclistic Bike Share

##Obectives 
# 1)  How Does a Bike-Share Navigate Speedy Success?
# 2) how casual riders and annual members use Cyclistic bikes differently
# 3) How can Cyclistic use digital media to influence casual riders to become members?

## key Detail
#Casual riders <-  single or full day riders  purchasers 
# Cyclistic Member <- Annual purchasers 

# Suggestion
#.Cyclistic’s finance analysts have concluded that 
#annual members are much more profitable than casual riders.



## libraries needed for that work 
library(tidyverse)


##l Reading data

setwd("C:/Users/hp/OneDrive/Desktop/Data/cyclistic data")
df1<-read_csv("202004-divvy-tripdata.csv")
df2<-read_csv("202005-divvy-tripdata.csv")
df3<-read_csv("202006-divvy-tripdata.csv")
df4<-read_csv("202007-divvy-tripdata.csv")
df5<-read_csv("202008-divvy-tripdata.csv")
df6<-read_csv("202009-divvy-tripdata.csv")
df7<-read_csv("202010-divvy-tripdata.csv")
df8<-read_csv("202011-divvy-tripdata.csv")
df9<-read_csv("202012-divvy-tripdata.csv")
df10<-read_csv("202101-divvy-tripdata.csv")
df11<-read_csv("202102-divvy-tripdata.csv")
df12<-read_csv("202103-divvy-tripdata.csv")
## Combindind  all 12 dataset
bike<-rbind(df1,df2,df3,df4,df5,df6,df7,df8,df9,df10,df11,df12)

## Checking Data
dim(bike)
names(bike)
str(bike)


# Data Cleaning

## Selecting Specific columns 
df_bike <- bike%>%
  select("member_casual","rideable_type","started_at", "ended_at","start_station_name",
         "end_station_name")

## checking Data
head(df_bike)
sapply(df_bike, typeof)
glimpse(df_bike)



## Checking and removing NA values
anyNA(df_bike)
map(df_bike, ~sum(is.na(.))) ## checking na in all columns 

df_bike<-drop_na(df_bike) ## drop all NA

#difference in end and start time in seconds 
df_bike<-df_bike%>%
  mutate(compare= (df_bike$ended_at-df_bike$started_at))

#correcting negative values 
df_bike<-df_bike%>%
  mutate(time_difference= ifelse(compare< 0 ,-1*compare, compare))
min(df_bike$time_difference)

## separating year month and days
df_bike$st_year<-format(as.Date(df_bike$started_at),"%y") ## to years
df_bike$week_days<-weekdays(df_bike$started_at) # to days of the week
df_bike$st_Month<-month(df_bike$started_at,label = TRUE) ##change date format



## ANalysis  

members_count<-df_bike%>%
  count(member_casual)%>%  
  mutate(per=n/sum(n),        
         per_label= paste0(round(per*100),"%")) 
view(members_count)


ggplot(data=members_count,aes(x=reorder(member_casual, per), y=per))+
  geom_bar(stat = "identity",fill="grey",color="black")+
  geom_text(aes(label=per_label),vjust=231)+
  geom_text(aes(label=n,vjust=12))+
  labs(x="Riders and Members", y= "percentage count",
       title="Count of Casual and Annual Members")+
  scale_y_continuous(labels = scales::percent)+theme_bw()

#The bike share navigate  has more annual members purschase than casual riders 

## count of casual_member by ride type
cmr<-df_bike%>%
  count(member_casual,rideable_type)%>%
  group_by(member_casual)%>%
  mutate(per=n/sum(n),        
         per_label= paste0(round(per*100),"%")) 
view(cmr)


###  ploting multiple bar 
ggplot(cmr,aes(x=rideable_type, y=n, fill=member_casual))+ 
  geom_bar(stat="identity",position = "dodge")+
  labs(x="Ride types",y="Total count of ride",
       title =" most perfered Ride Type ", fill="Type of Membership")

## Docked bike is the most used bike by both casual riders and annual members 

###### count number of annual members by week days

mem_days<-df_bike%>%
  filter(member_casual=="member")

mem_days<-mem_days%>%
  count(member_casual,week_days)

mem_days$week_days<-ordered(mem_days$week_days,
levels=c("Sunday","Monday","Tuesday",
         "Wednesday","Thursday","Friday","Saturday"))
  

ggplot(data=mem_days,aes(x=week_days,y=n))+
  geom_point(color="blue")+
  labs(title = "Ride usage on Week_day by Annual Members ",y="count",x="Week_days")
##the use of bike by annual member is more on Wednesday Thursday 
## Friday and Saturday


###### count number of casual by week days
casu_days<-df_bike%>%
  filter(member_casual=="casual")

casu_days<-casu_days%>%
  count(member_casual,week_days)

casu_days$week_days<-ordered(casu_days$week_days,
levels=c("Sunday","Monday","Tuesday",
         "Wednesday","Thursday","Friday","Saturday"))


ggplot(data=casu_days,aes(x=week_days,y=n))+
  geom_point(color="red")+
  labs(title = "Ride usage on Week_day by Causual Riders ",y="count",x="Week_days")

## The use of bike share by casual riders is high on weekend which is 
##Saturday and Sundays 

#### ride service per month
cmm<-df_bike%>%
  count(st_Month,member_casual)

ggplot(cmm,aes(x=st_Month, y=n, fill=member_casual))+ 
  geom_bar(stat="identity" ,position = "dodge") +
  labs(x="Months of the year",y="Count of Rides",title="Riders Per Month",
       fill="Type of Membership")
## On any giving month there are more annual member compare to casual riders 


### use of  Ride by Month
cmm<-df_bike%>%
  count(st_Month,member_casual)

ggplot(cmm,aes(x=st_Month, y=n, fill=member_casual))+ 
  geom_bar(stat="identity" ,position = "dodge") +
  labs(x="Months of the year",y="Count of Rides",title="Riders Per Month",
       fill="Type of Membership")



###  time tables
usage<-df_bike%>%
  select(member_casual,time_difference)

### mean and max and min  of annual member 
mem_time<-usage %>%
  filter(member_casual=="member")%>%
  summarise(mem_mean_= mean(time_difference)/60, 
            mem_max= max(time_difference)/60,mem_min=min(time_difference),n = n())

##annual member  on average spend 19.7 minutes riding or keeping the bike with
# the highest recorded minutes of 58720  minimum of 0 minutes 
##

#### mean and max of casual rider 
casu_time<-usage %>%
  filter(member_casual=="casual")%>%
  summarise(casu_mean_= mean(time_difference)/60, 
            casu_max= max(time_difference)/60, casu_min=min(time_difference),n = n())

##annual member  on average spend 46.5 minutes riding or keeping the bike with
# the highest recorded minutes of 55684  minimum of 0 minutes 


### Conclusion
# 1) The bike-share navigate Speedy Success may dependend on annual members as 
# said by Cyclistic’s finance analysts since there 60% of the customers purchases
#are annual riders and make use of the service more offend 


#2i) Casusal Riders mostly make use of the bike
# -share sercie on weekend whiles Annaul members make use of the use of the serivce
 #in some working days and weekends. 



# 2ii) Casual members ride for an average of 46.5 minutes,
#while Annual members cycle for an average of 19.7 minutes.

#2iii) In every giving month there are more Annual members purchases  than Casual
 # riders 


## demonstrating that Casual riders utilize the bike for leisure or as a source
# of pleasure while Annual members use the bike for activities related to their jobs



#3) Increase the price of single-ride and full-day passes during peak hours  
 # e.g. during the summer and weekends.













