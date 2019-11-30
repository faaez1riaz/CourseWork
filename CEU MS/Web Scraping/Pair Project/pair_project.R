library(httr)
library(jsonlite)
library(rvest)
library(tidyverse)
library(data.table)

#We selected the bitfinex exchange for scraping
#define url
url <- 'https://api-pub.bitfinex.com/v2/tickers?symbols=ALL'

#Get the Json data
get_data <- function(url) {
  url <- 'https://api-pub.bitfinex.com/v2/tickers?symbols=ALL'

  my_ans <- GET(url, verbose(info = T))

  my_ans_data <- fromJSON(my_ans)
  # the data object will be return as a df. Some of the column will be also df

  coins <- data.frame(symbol = character(), current_price_usd=double(), daily_volume_traded=double(), daily_perc_change=double() , daily_hour_high=double(), daily_hour_low=double())
  
  
  for (i in 1:length(x)) {
    coins <- add_row(coins,symbol = x[[i]][1], current_price_usd = x[[i]][2],  daily_volume_traded= x[[i]][3], daily_perc_change = x[[i]][7], daily_hour_high = x[[i]][10], daily_hour_low = x[[i]][11])
  }
  
  return(coins)
}

#Clean the JSON Data
get_coin_data <- function(url){
  data <- get_data(url)
  data <- data %>% mutate(current_price_usd = as.double(current_price_usd), daily_volume_traded = as.double(daily_volume_traded), daily_perc_change = as.double(daily_perc_change)*100, daily_hour_high = as.double(daily_hour_high), daily_hour_low = as.double(daily_hour_low))
  return(data)
}

#Call function
coins_data <- get_coin_data(url)

#Save our file
saveRDS(coins_data, "coins_data.rds")
write_csv(coins_data, "coins_data.csv")

