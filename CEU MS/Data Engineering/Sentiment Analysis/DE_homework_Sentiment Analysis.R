install.packages('rvest')
install.packages('data.table')



library(rvest)
library(data.table)
library(jsonlite)
library(dplyr)
library(dataviewer)

library(ggplot2)
library(gridExtra)
library(cowplot)
library(data.table)
library(grid)
library(lspline)
library(gridExtra)
# install.packages("ggstatsplot")
library(ggstatsplot)
library(scales)
library(grid)
library(RColorBrewer)
library(httrr)
library(tidyverse)
library("aws.comprehend")


# geting started

my_dates <- as.Date(as.Date("2019-10-1"):as.Date("2019-10-30"), origin="1970-01-01")
stocks <- read_csv("stock_index.csv")

get_articles <- function(d){
  
  link <- "https://www.dawn.com/archive/"
  my_page <- paste0(link, d)
  
  t <- read_html(my_page)
#check if it has the data that we want
write_html(t, 't.html')

# get titles
my_titles <- 
  t %>%
  html_nodes('.story__link') %>%
  html_text() %>%  head(50)

my_links <- t %>% 
  html_nodes('.size-three.theme a') %>% 
  html_text() %>% head(50)
my_temp_list <- c()

my_summary <- 
  t %>%
  html_nodes('.story__excerpt')%>%
  html_text() %>% head(50)

my_summary <- strsplit(my_summary,'.', fixed = T)
my_summary1

for( i in 1:50){
  my_summary1[i] <- my_summary[[i]][1]
}
my_summary1
dawn_articles <- data.frame('Title'=my_titles, 'Genre'=my_links, 'Summary'=my_summary1, 'Date'=rep(d, 50))

dawn_articles <- dawn_articles %>% filter(Genre == 'Pakistan')
dawn_articles <- dawn_articles %>% head(10)
return(dawn_articles)
}


my_res <- lapply(my_dates, get_articles)
res_df <- rbindlist(my_res)

keyTable <- read.csv("accessKeys.csv", header = T) # accessKeys.csv == the CSV downloaded from AWS containing your Acces & Secret keys
AWS_ACCESS_KEY_ID <- as.character(keyTable$Access.key.ID)
AWS_SECRET_ACCESS_KEY <- as.character(keyTable$Secret.access.key)

#activate
Sys.setenv("AWS_ACCESS_KEY_ID" = AWS_ACCESS_KEY_ID,
           "AWS_SECRET_ACCESS_KEY" = AWS_SECRET_ACCESS_KEY,
           "AWS_DEFAULT_REGION" = "eu-west-1")

sent_array <- lapply(res_df$Summary, get_sentiment)
get_sentiment <- function(m){
  s_title <- detect_sentiment(m)
  # s_summary <- detect_sentiment(m$summary)
  
  list <- tibble('Pos'= mean(s_title$Positive, s_title$Positive), 'Neg'= mean(s_title$Negative, s_title$Negative), 'Neutral'= mean(s_title$Neutral, s_title$Neutral))
  return(list)
}


sent_array <- rbindlist(sent_array)
sent_array <- res_df %>% mutate(Positive = sent_array$Pos, Negative = sent_array$Neg, Neutral= sent_array$Neutral)
sent_array <- sent_array %>% group_by(Date) %>% summarise(Positive=mean(Positive)*100, Negative=mean(Negative)*100, Neutral=mean(Neutral)*100)
stk <- stocks %>% transmute(Date = DATE, Stock_Index= `DAILY HIGH`)
sent_array_stk <- left_join(sent_array, stk)


sent_array_stk <- na.omit(sent_array_stk)
model <- lm(Stock_Index ~ Positive, sent_array_stk)
view(sent_array_stk)
ggplot(sent_array_stk, aes(Positive, Stock_Index)) + geom_point(size = 2, color="Red") + geom_smooth(color = "Red", se = FALSE) +
  labs(title = "Stock Index vs Positive Sentiment", caption = "Data Points are Days", x = "Aggregated Mean of Positive Sentiment", y = "KSE 100 Index")

cor(sent_array_stk$Neutral, sent_array_stk$Stock_Index)
detect_sentiment("This is a test sentence in English")
