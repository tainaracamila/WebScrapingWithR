#Web scraping with rvest

install.packages("rvest")
library(rvest)
library(stringr)
library(dplyr)
library(lubridate)
library(readr)

#Read web page
webpage <- read_html('https://www.nytimes.com/interactive/2017/06/23/opinion/trumps-lies.html')
webpage

#Extract records by the class name
records_full <- webpage %>% html_nodes('.short-desc')

#Clean records 
records <- vector("list", length = length(records_full))

for(i in seq_along(records_full)){
  date <- str_c(records_full[i] %>%
                  html_nodes('strong') %>%
                  html_text(trim = TRUE), ', 2017')
  
  lie <- str_sub(xml_contents(records_full[i])[2] %>% html_text(trim = TRUE), 2, -2)
  
  explanation <- str_sub(records_full[i] %>%
                           html_nodes('.short-truth') %>%
                           html_text(trim = TRUE), 2, -2)
  
  url <- records_full[i] %>% html_node('a') %>% html_attr('href')
  
  records[[i]] <- list(Date = date, Lie = lie, Explanation = explanation, Url = url)
}


#Build data frame
df <- bind_rows(records)
df

#Change type of Date
df$Date <- mdy(df$Date)
df

#Export to .csv
write_csv(df, 'trumps lies.csv')
