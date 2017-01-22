# chatr_background
library(jsonlite)

STORE_ID <- 'np94z'
chatrbase <- list()

# Gets a remote store and prints new messages to stdout pipe
bgGET <- function(store_id=STORE_ID) {
  stopifnot(nchar(store_id)>0)
  chatrpast <- chatrbase
  chatrbase <<- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  new_msgs <- setdiff(chatrbase, chatrpast)
  lapply(new_msgs, print)
}

# cron loop
while (T) {
  Sys.sleep(15)
  bgGET()
}