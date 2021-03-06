#Creating Story Graph from knoweldge base and querying it
setwd("/local/home/paramita/Projects/emofiel/")
library(igraph)
library(stringr)
library(dplyr)
library(tidytext)
library("tm")
library("SnowballC")
#library("wordcloud")
library("RColorBrewer")
kb = read.csv("storygraph_v1.csv")  # read csv file
character_list = read.csv("character_list.csv",header = TRUE)
#Preprocessing
#Cleaning Actions and Objects column
preProcess <- function(data){
  data <-  gsub('\\[', '', data)
  data <-  gsub('\\]', '', data)
  data <-  gsub("\\'", '', data)
  data <-  gsub("\\,", '', data)
  data <-  gsub("\\- |\\-| ", ' ', data)
  data <- sub("^$", "NA", data)
  return(data)
}

kb$Subject.Characters <- preProcess(kb$Subject.Characters)
kb$Actions.with.Subject.Charcater <- preProcess(kb$Actions.with.Subject.Charcater)
kb$Object.Characters <- preProcess(kb$Object.Characters)
kb$Objects.and.Actions <- preProcess(kb$Objects.and.Actions)

#Removing those rows in which subject and object both are NA
kb <- subset(kb, !(grepl("NA",kb[[2]]) & grepl("NA",kb[[4]])))

#Defining Event
event = list()
event_sentences = list()
j=0 #Event Index
for(i in 1:length(kb$Sentence)){
  #print(i)
 if(length(event) == 0){
   currentObject <- strsplit(
     (kb$Object.Characters[1])," ")
   # currentObject<- currentObject[[1:length(strsplit((kb$Object.Characters[k])," ")[1])]]
   
   currentSubject <-   strsplit(
     (kb$Subject.Characters[1])," ")
    event[1] <- 1
    print("Event Initialised")
    j=1 #j is the event id
    previous_event_characters <- c(currentSubject,currentObject)
    
  }
  else{
    
    #Search in previous event
    length_Last_Event = length(event[[j]])
    #Storing the sentence id from the last event
    temp <- event[[j]]
    #print(c("temp =", temp))
    
    
  # for(k in 1:length_Last_Event){
     pronounList <- c("he","He","She","she","it","It","They","they","We","we","I","You","you","him","Him","Her","her","Them","them","Us","us","Me","me")
    #New Algo for Scene Segmentation
      currentObject <- unique(strsplit(kb$Object.Characters[i]," ")[[1:length(strsplit(kb$Object.Characters[i]," ")[1])]])
     # currentObject<- currentObject[[1:length(strsplit((kb$Object.Characters[k])," ")[1])]]
     
      currentSubject <-   unique(strsplit(kb$Subject.Characters[i]," ")[[1:length(strsplit(kb$Subject.Characters[i]," ")[1])]])
      #currentSubject<- currentSubject[[1:length(strsplit((kb$Subject.Characters[k])," ")[1])]]
    print(i)
       print("Previous Event")
     print(previous_event_characters)
     print("Current Subject")
     print(currentSubject)
     print("Current Object")
    print(currentObject)
    #  if((length(Reduce(intersect,list(currentObject,previous_event_characters)))==0) & (length(currentObject)>0)){
    if(((length(intersect(strsplit(unlist(currentObject)," "),strsplit(unlist(previous_event_characters)," ")))==0) &
       (length(intersect(strsplit(unlist(currentSubject)," "),strsplit(unlist(previous_event_characters)," ")))==0))){
       #A new event defined
       j = j+1 #Increasing the event id
       event[[j]] <- i
       #print("LALA")
       print("New eventCC")
       previous_event_characters <- c(currentSubject,currentObject)
     }
     else{
       if(length(intersect(strsplit(unlist(currentObject)," "),strsplit(unlist(previous_event_characters)," ")))==0){
         if(length(setdiff(currentObject,pronounList))==0){
           event[[j]] <- c(event[[j]],i)
           print("Same Event")
           previous_event_characters <- c(previous_event_characters,currentSubject,currentObject)
         }
         else{
         j = j+1 #Increasing the event id
         event[[j]] <- i
         #print("LALA")
         print("New eventCC")
         previous_event_characters <- c(currentSubject,currentObject)}
       }
       else{
          event[[j]] <- c(event[[j]],i)
          print("Same Event")
          previous_event_characters <- c(previous_event_characters,currentSubject,currentObject)
        }
       }
    } 
    }
   #################################################################################
  #    previous_event_characters <- 
  #    unique(
  #      c(previous_event_characters,
  #          strsplit(
  #              (kb$Subject.Characters[temp[[k]]])," ")
  #                [[1:length(strsplit((kb$Subject.Characters[temp[[k]]])," ")[1])]],
   #                                strsplit(
    #                                 (kb$Object.Characters[temp[[k]]])," ")
     #                                   [[1:length(strsplit((kb$Object.Characters[temp[[k]]])," ")[1])]]))
   #}
    
    #Removing the pronouns
    #previous_event_characters <- previous_event_characters[-which(previous_event_characters%in%pronounList)]
    #a[-which(a %in% c("lala", "caca"))]
  #  current_sentence_characters <- unique(c(strsplit(kb$Subject.Characters[i]," ")[[1:length(strsplit(kb$Subject.Characters[i]," ")[1])]],
   #                                         strsplit(kb$Object.Characters[i]," ")[[1:length(strsplit(kb$Object.Characters[i]," ")[1])]]))
    #print(c("previous_event_characters = ",previous_event_characters))
    #print(c("current_sentence_characters = ",current_sentence_characters))
    #Checking if there is any common character between the two events
    #  if(length(setdiff(current_sentence_characters,previous_event_characters))<(length(current_sentence_characters))){
        #Checking for only match being NA
      #  if(length(setdiff(current_sentence_characters,previous_event_characters))==(length(current_sentence_characters))-1 
       #     & ('NA' %in% previous_event_characters) & ('NA' %in% current_sentence_characters)){
         # if(length(event[[j]])==2 | length(event[[j]])==1){
            #The sentence belongs to the last event
          #  event[[j]] <- c(event[[j]],i)
           # print("Same Event")}
         # else{
          #A new event defined
      #    j = j+1 #Increasing the event id
       #   event[j] <- i
        #  print("New event")
        #}
    #    else{
        #The sentence belongs to the last event
     #       event[[j]] <- c(event[[j]],i)
      #      print("Same Event")
       #         }
          #}
     # else{
      #  if((length(setdiff(current_sentence_characters,pronounList))==0)){
       #   event[[j]] <- c(event[[j]],i)
        #  print("Same Event")
        #}
        #else if( grepl("^[[:upper:]]+$", setdiff(current_sentence_characters,pronounList))){
         # event[[j]] <- c(event[[j]],i)
          #print("Same Event")
        #}
        #If only pronoun in current event characters
       # if(length(event[[j]])==2 | length(event[[j]])==1){
          #The sentence belongs to the last event
        #  event[[j]] <- c(event[[j]],i)
         # print("Same Event")}
        #  else{
          #A new event defined
         # j = j+1 #Increasing the event id
          #event[[j]] <- i
          #print("New event")}
      #}
   #}
#print(" ")  

######################################################################################################
print(c("There are total ", j, "events identified."))

#Write these event sentences in a csv
anger = 1:length(event) #Will be addressed in next function
anticipation=1:length(event)
disgust=1:length(event)
fear=1:length(event)
joy=1:length(event)
sadness=1:length(event)
surprise=1:length(event)
trust=1:length(event)
paragraph = 1:length(event)
sentence_id = 1:length(event)
nrc_sentiment = 1:length(event)
no_of_interactions = 1:length(event)
Valence =  1:length(event)
Arousal =  1:length(event)
Dominance =  1:length(event)
export = data.frame(paragraph,nrc_sentiment,no_of_interactions,sentence_id,joy,anticipation,surprise,trust,anger,sadness,disgust,fear,Valence, Arousal, Dominance)

for(i in 1:length(event)){
  export$paragraph[i] = ""
  export$sentence_id[i] =""
  for(j in 1:length(event[[i]])){
  export$paragraph[i] = paste(export$paragraph[i],kb$Sentence[event[[i]][j]], sep = " ")
  export$sentence_id[i] = paste(export$sentence_id[i], event[[i]][j], sep = " ")
  }  
}
#write.csv(export$paragraph, file= "event_distribution.csv", row.names = FALSE)

#Emotion Labelling per event based on the sentences per event

library(syuzhet)
for(i in 1:length(event)){
  print(i)
my_example_text <- export$paragraph[i]
s_v <- get_sentences(export$paragraph[i])
syuzhet_vector <- get_sentiment(s_v, method="syuzhet")
bing_vector <- get_sentiment(s_v, method="bing")
afinn_vector <- get_sentiment(s_v, method="afinn")
nrc_vector <- get_sentiment(s_v, method="nrc")
#Because the different methods use different scales, it may be more useful to compare them 
#using R’s built in sign function. The sign function converts all positive number to 1, all
#negative numbers to -1 and all zeros remain 0.
rbind(
  sign(head(syuzhet_vector)),
  sign(head(bing_vector)),
  sign(head(afinn_vector)),
  sign(head(nrc_vector))
)
#Summing the values in order to get a measure of the overall emotional valence in the text

#Sentiment Plotting
s_v_sentiment <- get_sentiment(s_v)
#Plotting valence for each individual event separately
#plot(
#  s_v_sentiment, 
#  type="l", 
#  main=c("Event ", i ," Plot Trajectory"), 
#  xlab = "Narrative Time", 
#  ylab= "Emotional Valence"
#)

#Plotting valence for each individual event on one plot

if(i==1){
  plot(s_v_sentiment,type="l",col="red",main=c("Valence along entire story"), 
       xlab = "Narrative Time", 
       ylab= "Emotional Valence")}

else if(i>1 & i<=(floor(length(event)/3))){
  lines(s_v_sentiment,col="red")
  }
else if((i>=((floor(length(event)/3)+1))) & (i<=(floor(length(event)*2/3)))){
  lines(s_v_sentiment,col="green")}
else
  lines(s_v_sentiment,col="blue")
#Emotion Labelling
nrc_data <- get_nrc_sentiment(s_v)
#Which sentences give anger
#angry_items <- which(nrc_data$anger > 0)
#s_v[angry_items]
#Which sentences give joy
#joy_items <- which(nrc_data$joy > 0)
#s_v[joy_items]

#Viewing all emotions and its values in a event
pander::pandoc.table(nrc_data[, 1:8], split.table = Inf)

#Plotting all emotions bar-plot per event
#barplot(
#  sort(colSums(prop.table(nrc_data[, 1:8]))), 
#  horiz = TRUE, 
#  cex.names = 0.7, 
#  las = 1, 
#  main = c("Emotions in Event", i) , xlab="Percentage"
#)

export$anger[i] <- colSums(prop.table(nrc_data[, 1:8]))[1]
export$anticipation[i] <- colSums(prop.table(nrc_data[, 1:8]))[2]
export$disgust[i] <- colSums(prop.table(nrc_data[, 1:8]))[3]
export$fear[i] <- colSums(prop.table(nrc_data[, 1:8]))[4]
export$joy[i] <- colSums(prop.table(nrc_data[, 1:8]))[5]
export$sadness[i] <- colSums(prop.table(nrc_data[, 1:8]))[6]
export$surprise[i] <- colSums(prop.table(nrc_data[, 1:8]))[7]
export$trust[i] <- colSums(prop.table(nrc_data[, 1:8]))[8]

if(length(get_sentiment(get_sentences(export$paragraph[i])))>1)
  export$nrc_sentiment[i] = mean(get_sentiment(get_sentences(export$paragraph[i])))
else
  export$nrc_sentiment[i] =  get_sentiment(get_sentences(export$paragraph[i]))
export$no_of_interactions[i] = length(get_sentiment(get_sentences(export$paragraph[i])))
#Calculating the Valence, Arousal and Dominance.
fileConn<-file("input.txt")
writeLines(export$paragraph[i], fileConn)
system("java -jar //local/home/paramita/Projects/emofiel//JEmAS-v0.2-beta.jar /local/home/paramita/Projects/emofiel//input.txt > output.csv", intern=TRUE)
close(fileConn)
temp_kb <- read.csv("output.csv")
temp_kb <- read.csv("output.csv", sep = "\t")
export$Valence[i] = temp_kb$Valence[1]
export$Arousal[i] = temp_kb$Arousal[1]
export$Dominance[i] = temp_kb$Dominance[1]
}
#Plotting along the storyline
plot(export$nrc_sentiment,xlab = "Event Indexes", ylab = "Emotion Valence", main = "Emotion valence along different events throughout the story ",type = "l")

write.csv(export, file= "event_distribution_1.csv", row.names = FALSE)

fileConn<-file("events.txt")
writeLines(as.character(event), fileConn)
close(fileConn)



















