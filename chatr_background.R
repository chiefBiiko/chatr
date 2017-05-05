# chatr_background

# sugar.R contains install statements for notification utilities
try(source('sugar.R'))

NAME <- 'Biiko'  # 'Balou', 'Christian'
STORE_ID <- 'np94z'
CHATRBASE <- list()  # persistent

# Gets a remote store and prints new messages to stdout pipe
bgGET <- function(name=NAME, store_id=STORE_ID) {
  stopifnot(nchar(name) > 0L, nchar(store_id) > 0L)
  chatrpast <- CHATRBASE
  CHATRBASE <<- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', 
                                          store_id))$msgs
  new_msgs <- setdiff(CHATRBASE, chatrpast)
  lapply(new_msgs, cat, sep='\n')
  if (length(new_msgs) > 0L &&  # and checking that at least 1 msg is not ur own
      !all(sapply(new_msgs, function(m) { 
        sub('^.+\\|\\s(\\S+)\\s.+$', '\\1', m, perl=TRUE) == name 
      }))) {
    try(notifier::notify(title='chatr', msg='New message'), silent=TRUE)
    try(beepr::beep(sample(c(2L, 10L), 1L)), silent=TRUE)
  }
}

# cron loop
repeat {
  Sys.sleep(10L)
  bgGET()
}