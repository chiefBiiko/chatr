# chatr - console 2 console chat in R
library(sys)
library(jsonlite)
library(httr)
library(tools)

# Note:
#   If any stranger should want 2 run this, get ur own store and STORE_ID via a POST 2 http://api.myjson.com/bins.
#   Running sys::exec_background('Rscript', path) like this requires that your system is configured
#   to run R scripts from the command prompt, i.e. on cmd prompt >>> Rscript urFunction.R
#   In case you cannot yet do so you need to append the path to the directory that contains
#   Rscript.exe (probly 'C:\Program Files\R\R-3.3.2\bin') to your systems environment variable 'Path':
#     right-click 'Computer', click 'Properties', then 'Advanced system settings',
#     then 'Environment Variables..', under 'System variables' select 'Path', click 'Edit',
#     append ';C:\Program Files\R\R-3.3.2\bin', click 'Ok'  # semicolon is separator
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

NAME = 'Biiko'
STORE_ID <- 'np94z'
INIT_MSG <- 'Do not rm(pid) from your global environment!\nand\nPlease run chatrKill() before exiting your R session!\nNow 2 the fun stuff..\nType chatr("ur_msg") in the console to send a message to your peer.'

message('Run chatrInit() to start chatting with your peers.')

# Initializes a chat
# TODO: store and on init print login info about peers in another store '1h2msv'
chatrInit <- function(store_id=STORE_ID) {
  message(INIT_MSG)
  cbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))
  if ((as.integer(Sys.time()) - as.integer(names(cbase)[length(cbase)])) > 86400) {
    httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=list(), encode="json")
    message('Cleared old chat history.')
  }  # cleared store if the last chat msg was older than 24 hours
  pid <<- sys::exec_background('Rscript', 'chatr_background.R', T, T)
  message(paste0('Started background R process with PID ', pid))
}

# Kills background R process
chatrKill <- function() {
  tools::pskill(pid)
  message('Successfully killed background R process.')
}

# Prepares and launches a PUT operation aka 'the chatting function'
chatr <- function(msg, name=NAME, store_id=STORE_ID) {
  stopifnot(typeof(msg)=='character', nchar(msg)>0, nchar(name)>0, nchar(store_id)>0)
  pbase <- jsonlite::fromJSON(paste0('http://api.myjson.com/bins/', store_id))  # prep 4 safer put
  pbase[[as.character(as.integer(Sys.time()))]] <- paste(format(Sys.time(), tz = "UTC", "%d %b %H:%M"),
                                                         "UTC |", name, ':', msg)  # including timestamp
  response <- httr::PUT(paste0('http://api.myjson.com/bins/', store_id), body=pbase, encode="json")
  return(httr::status_code(response))
}
