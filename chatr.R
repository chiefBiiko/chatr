# chatr - console 2 console chat in R
library(sys)
library(jsonlite)
library(httr)
library(tools)

# Note:
#   If any stranger wants 2 run this, get ur own STORE_ID via a POST 2 http://api.myjson.com/bins.
#
# Data structures:
#   JSON object in remote store, named list in R
#
# Usage:
#   Get this repo on ur local machine
#   Update the NAME variable below with your name
#   setwd('PATH_2_chatr_DIRECTORY')
#   source('chatr.R')
#   chatrInit()  # start a background script that auto-pushes new msgs to your console
#   chatr('hi')  # send a msg to your peers via the remote store
#   chatrKill()  # stop background R process before exiting your R session!
#
# Help:
#   Running sys::exec_background('Rscript', path) like this requires that your system is configured
#   to run R scripts from the command prompt, i.e. on cmd prompt >>> Rscript urFunction.R
#   In case you cannot yet do so you need to append the path to the directory that contains
#   Rscript.exe (probly 'C:\Program Files\R\R-3.3.2\bin') to your systems environment variable 'Path':
#     right-click 'Computer', click 'Properties', then 'Advanced system settings',
#     then 'Environment Variables..', under 'System variables' select 'Path', click 'Edit',
#     append ';C:\Program Files\R\R-3.3.2\bin', click 'Ok'  # semicolon is separator

NAME <- 'biiko'  # 'balou', 'christian'
STORE_ID <- 'np94z'
INIT_MSG <- 'Do not rm(PID) from your global environment!\nand\nPlease run chatrKill() before exiting your R session!\nNow 2 the fun stuff..\nType chatr("ur_msg") in the console to send a message to your peers.'

message('Run chatrInit() to start chatting with your peers.')

# Initializes a chat
chatrInit <- function(name=NAME, store_id=STORE_ID, imsg=INIT_MSG) {
  stopifnot(nchar(name)>0, nchar(store_id)>0)
  message(imsg)
  cbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  cbase$hash[[tolower(name)]] <- T  # login
  if ((as.integer(Sys.time()) - as.integer(names(cbase$msgs)[length(cbase$msgs)])) > 86400) {  # 24h
    res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=list(hash=cbase$hash, msgs=list()), encode="json")
    if(httr::status_code(res)==200) message('Cleared old chat history and logged in.')
  } else {
    res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=cbase, encode="json")
    if(httr::status_code(res)==200) message('Logged in.')
  }
  PID <<- sys::exec_background('Rscript', 'chatr_background.R', T, T)
  message(paste0('Started background R process with PID ', PID))
  message(paste('Online:', paste0(names(which(unlist(cbase$hash))), collapse=', '), '\nRun chatr("ur_msg") 2 chat.'))
}

# Kills background R process and logs out
chatrKill <- function(pid=PID, name=NAME, store_id=STORE_ID) {
  tools::pskill(pid)
  message('Successfully killed background R process.')
  xbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  xbase$hash[[tolower(name)]] <- F  # logout
  res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=xbase, encode="json")
  if(httr::status_code(res)==200) message('Logged out.')
}

# Prepares and launches a PUT operation aka 'the chatting function'
chatr <- function(msg, name=NAME, store_id=STORE_ID) {
  stopifnot(typeof(msg)=='character', nchar(msg)>0)
  pbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))  # prep 4 safer put
  pbase$msgs[[as.character(as.integer(Sys.time()))]] <- paste(format(Sys.time(), tz = "UTC", "%d %b %H:%M"),
                                                         "UTC |", name, ':', msg)  # including timestamp
  res <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=pbase, encode="json")
  return(httr::status_code(res))
}
