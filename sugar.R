# chatr notifications sugar
# 4 R & notifications c: github.com/gaborcsardi/notifier

# installing notifu
if (paste0(Sys.info()[1:2], collapse='') == 'Windows7' && !file.exists('notifu/notifu.exe')) {
  message('Installing notifu...')  # if u r !using windows 7 check notifier repo 4 requirements
  download.file('https://www.paralint.com/projects/notifu/dl/notifu-1.6.zip', 
                temp <- tempfile())
  unzip(temp, exdir='notifu')
  unlink(temp)
}

# installing notifier
if (!'notifier' %in% .packages(TRUE)) {
  message('Installing notifier...')
  source('https://install-github.me/gaborcsardi/notifier')
}

# installing beepr
if (!'beepr' %in% .packages(TRUE)) {
  message('Installing beepr...')
  devtools::install_github('rasmusab/beepr')
}