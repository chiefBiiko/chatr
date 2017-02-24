# chatr - console 2 console chat in R
#
# Note:
#   If u r a stranger, get ur own STORE_ID via a POST 2 http://api.myjson.com/bins.
#
# Usage:
#   Get this repo on ur local machine
#   Update the NAME variable in chatr.R and chatr_background.R with ur name
#   setwd('PATH_2_chatr_DIRECTORY')  # u can change dir once u have run chatrInit()
#   source('chatr.R')
#   chatrInit()  # start a background script that auto-pushes new msgs 2 ur console
#   chatr('hi')  # send a msg 2 ur peers via the remote store
#   chatrKill()  # stop background R process before exiting ur R session!

lapply(list('devtools', 'sys', 'jsonlite', 'httr', 'tools'), function(p) {
  if (!p %in% .packages(T)) install.packages(p)
})

CHATR <- list()
CHATR$NAME <- 'Biiko'  # 'Balou', 'Christian'
CHATR$STORE_ID <- 'np94z'

message('Run chatrInit() 2 start chatting with your peers.')

# Initializes a chat
chatrInit <- function(name=CHATR$NAME, store_id=CHATR$STORE_ID) {
  stopifnot(nchar(name) > 0, nchar(store_id) > 0,
            'chatr.R' %in% list.files(), 'chatr_background.R' %in% list.files())
  message('Do not rm(CHATR, chatr...) from your global environment!\nand\nPlease run chatrKill() before exiting your R session!')
  cbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  cbase$hash[[tools::toTitleCase(name)]] <- T  # login
  cbase$msgs[[as.character(as.integer(Sys.time()))]] <- paste(format(Sys.time(), tz='UTC', '%d %b %H:%M'),
                                                              'UTC |', tools::toTitleCase(name), 'logged in.')
  if ((as.integer(Sys.time()) - as.integer(names(cbase$msgs)[length(cbase$msgs) - 1])) > 21600) {  # 6h
    cbase$msgs <- cbase$msgs[length(cbase$msgs)]
  }
  res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=cbase, encode='json')
  if (res$status_code == 200) message('Logged in.')
  CHATR$PID <<- sys::exec_background('Rscript', 'chatr_background.R', T, T)
  message(paste0('Started background R process with PID ', CHATR$PID))
  message(paste('Online:', paste0(names(which(unlist(cbase$hash))), collapse=', '), '\nRun chatr("ur msg") 2 chat.'))
}

# Kills background R process and logs out
chatrKill <- function(pid=CHATR$PID, name=CHATR$NAME, store_id=CHATR$STORE_ID) {
  tools::pskill(pid)
  message('Successfully killed background R process.')
  xbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  xbase$hash[[tools::toTitleCase(name)]] <- F  # logout
  xbase$msgs[[as.character(as.integer(Sys.time()))]] <- paste(format(Sys.time(), tz='UTC', '%d %b %H:%M'),
                                                              'UTC |', tools::toTitleCase(name), 'logged out.')
  res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=xbase, encode='json')
  if (res$status_code == 200) message('Logged out.')
}

# Prepares and launches a PUT operation aka 'the chatting function'
chatr <- function(msg, name=CHATR$NAME, store_id=CHATR$STORE_ID) {
  stopifnot(typeof(msg) == 'character', nchar(msg) > 0)
  pbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  pbase$msgs[[as.character(as.integer(Sys.time()))]] <- paste(format(Sys.time(), tz='UTC', '%d %b %H:%M'),
                                                              'UTC |', tools::toTitleCase(name), ':', msg)
  res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=pbase, encode='json')
  if (res$status_code != 200) message(res$status_code)
}