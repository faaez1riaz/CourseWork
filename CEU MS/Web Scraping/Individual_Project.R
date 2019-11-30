
#load packages
library(rvest)
library(data.table)
library(jsonlite)
library(dplyr)


library(ggplot2)
library(gridExtra)
library(tibble)
library(data.table)
library(grid)
library(gridExtra)
# install.packages("ggstatsplot")
library(httr)

# geting started

######################################################################


get_articles <- function(d, search_term){
  link <- "https://weaintgotnohistory.sbnation.com/search?page="
  my_page <- paste0(link, d, "&q=", search_term)
  
  t <- read_html(my_page)
  
#check if it has the data that we want
  write_html(t, 't.html')
  
  # get titles
  my_titles <- 
    t %>%
    html_nodes('.c-entry-box--compact__title a') %>%
    html_text()
  
  my_authors <- t %>% 
    html_nodes('a:nth-child(1) .c-byline__author-name') %>% 
    html_text()
  
  my_summary <- 
    t %>%
    html_nodes('.c-entry-box--compact__dek')%>%
    html_text()
  
  my_dates <- 
    t %>%
    html_nodes('.c-byline__item .c-byline__item')%>%
    html_text()
  my_dates <- trimws(my_dates)
  # 
  # print(my_titles)
  # print(my_authors)
  # print(my_summary)
  # print(my_dates)
  

  articles <- data.frame('Title'=my_titles, 'Authors'=my_authors, 'Summary'=my_summary, 'Date'=my_dates)
  return(articles)
}

get_data <- function(n, s) {
  pages <- c(1:n)
  my_res <- lapply(pages, get_articles, search_term=s)
  res_df <- rbindlist(my_res)
  view(res_df)
}

get_data(4, "Mourinho")
