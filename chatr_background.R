# chatr_background

# 4 R & notifications c: github.com/gaborcsardi/notifier
if (paste0(Sys.info()[1:2], collapse='') == 'Windows7' && !file.exists('notifu/notifu.exe')) {
  message('Installing notifu.')  # if u r !using windows 7 check notifier repo 4 requirements
  temp <- tempfile()
  download.file('https://www.paralint.com/projects/notifu/dl/notifu-1.6.zip', temp)
  unzip(temp, exdir='notifu')
  unlink(temp)
}
if (!'notifier' %in% installed.packages()) source('https://install-github.me/gaborcsardi/notifier')
if (!'beepr' %in% installed.packages()) devtools::install_github('rasmusab/beepr') 

library(jsonlite)
library(notifier)
library(beepr)

NAME = 'Biiko'
STORE_ID <- 'np94z'
chatrbase <- list()

# Gets a remote store and prints new messages to stdout pipe
bgGET <- function(name=NAME, store_id=STORE_ID) {
  stopifnot(nchar(store_id) > 0)
  chatrpast <- chatrbase
  chatrbase <<- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))$msgs
  new_msgs <- setdiff(chatrbase, chatrpast)
  lapply(new_msgs, cat, sep='\n')
  if (length(new_msgs) > 0 &&  # and checking that at least 1 msg is not ur own
      !all(sapply(new_msgs, function(m) { sub('^.+\\|\\s(\\S+)\\s.+$', '\\1', m) == name }))) {
    try(notifier::notify(title='chatr', msg='New message'), T)
    try(beepr::beep(sample(c(2, 10), 1)), T)
  }
}

# cron loop
while (T) {
  Sys.sleep(10)
  bgGET()
}