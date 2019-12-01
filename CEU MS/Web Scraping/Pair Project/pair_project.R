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
write_csv(output_data, "stocks_data.csv")
saveRDS(output_data, "stocks_data.csv")



