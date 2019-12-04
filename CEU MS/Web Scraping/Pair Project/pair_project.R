library(httr)
library(jsonlite)
library(rvest)
library(tidyverse)
library(pbapply)

############################

t <- read_html('https://csimarket.com/markets/Stocks.php')

q <- t %>% 
      html_nodes('.linkt')%>%
      html_text()
q

# get the json of it. 
json_data <- 
  fromJSON(
     q <- t %>% 
      html_nodes('.linkt')%>%
      html_attr('href')
  )
view(list_of_companies)


#### Get a list of all companies on the website
list_of_companies <- fromJSON("https://csimarket.com/_jquery_autocomplete_stock.php?q=s&limit=10")

#Functio to Clean Company Name
clean_names <- function(str) {
  substr(str, 1, regexpr("<", str) - 2)
}

clean_codes <- function(str) {
  substring(str, regexpr("=", str) + 1)
}

#Apply for each name in our dataframe
list_of_names <- sapply(list_of_companies[[2]], clean_names)
list_of_names <- rbind_list(list_of_names)
list_of_companies <- list_of_companies %>% mutate(name=list_of_names)

#Get stocks data for a single company
get_company_data <- function(code) {
  url <- paste0("https://csimarket.com/scripts/amstock/technicals_data_compare_priceag_java.php?code=", code)
  stock_prices <- fromJSON(url)
  out <- tryCatch(
    {stock_prices <- stock_prices %>% mutate("Company Code" = code)
    }, error= function(cond) {
      error_mes <- paste0("No Data for: ",code)
      # print(error_mes)
      return(NA)
    }
  )
  return(stock_prices)
}

#Run to get for all companies
all_companies_data <- pblapply(list_of_companies[[1]], get_company_data)
all_companies_data <- rbind_list(all_companies_data)
view(output_data)
#Join with list of companies to include company names in our data as well
output_data <- left_join(all_companies_data, list_of_companies, by = c("Company Code" = "value"))

#renaming columns according to our data
output_data <- output_data %>% rename("Date" = category, "Stock Price"=price, "Company Name"=name)

#saving our data
write_csv(output_data, "stocks_data.csv")
saveRDS(output_data, "stocks_data.rds")


##########################
pages <- c(1:29)

get_list_of_companies <- function(pagenum) {
  link <- paste0("https://csimarket.com/markets/Stocks.php?days=yday&pageA=", pagenum, "1#tablecomp2")
  t <- read_html(link)
  
  links <- t %>% 
        html_nodes('.linktm')%>%
        html_attr('href')
  
  names <- t %>% 
        html_nodes('.linktm')%>%
        html_text()
  
  codes <- lapply(links, clean_codes)
  codes <- unlist(codes)
  
  return(data.frame(value=codes, name=names))
}

list_of_companies2 <- lapply(pages, get_list_of_companies)
list_of_companies2 <- rbind_list(list_of_companies2)


get_info <- function(code) {
  my_url <- paste0("https://csimarket.com/stocks/at_glance.php?code=", code)


  t <- read_html(my_url)
  
  title <- t %>% 
        html_nodes('.Naziv') %>%
        html_text()
  
  q <- t %>% 
        html_nodes('table.comgl') %>%
        html_table(fill=TRUE)
    
  q1 <- t %>% 
        html_nodes('a:nth-child(2)') %>%
        html_text()
  
  sector <- trimws(substring(q1[[1]], regexpr(".", q1[[1]]) + 1))
  
  industry <- trimws(substring(q1[[2]], regexpr(".", q1[[2]]) + 1))
  
  df <- data.frame("Company Name"=title, "Sector" = sector, "Industry"= industry, "Market Capitalization"=q[[1]][[2]][1], 
                   "Shares"=q[[1]][[2]][2],
                   "Employees"=q[[1]][[2]][3],
                   "Revenues"= q[[1]][[2]][4],
                   "Net Income"= q[[1]][[2]][5],
                   "Cash Flow"= q[[1]][[2]][6],
                   "Shares"=q[[1]][[2]][7])
  
  return(df)
}


all_companies_data2 <- pblapply(list_of_companies2[[1]], get_info)
all_companies_data2 <- rbind_list(all_companies_data2)
view(all_companies_data2)

## ANALYSIS

library(tidyr)
library(ggplot2)
library(tidyverse)


#Histogram of number of companies in each sector:
b <- ggplot(data = scraped_data) + 
  geom_bar(mapping = aes(x = Sector), col="red", alpha = .2)
b +
  coord_flip() +
  labs(x = "Number of companies", y = "Sector")



#removing the commas from Market Capitalization numbers
scraped_data$Market.Capitalization <- as.numeric(gsub(",","",scraped_data$Market.Capitalization))
scraped_data

#plotting sum of Market Capitalization per sector 
mc <- scraped_data %>%
  group_by(Sector) %>%
  summarise('marketcap' = sum(Market.Capitalization))

view(mc)
c <- ggplot(data = mc, mapping = aes(x = marketcap, y = Sector)) +
  geom_point(colour = "blue", size = 2) +
  theme_bw()

c
