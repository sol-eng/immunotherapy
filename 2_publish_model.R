library(rsconnect)

rsconnect::deployTFModel(
  modelDir = "saved_models",
  # server = "{server}",     # <<- edit this line if necessary
  # account = "{account}",   # <<- edit this line if necessary
  appTitle = "immunotherapy",
  forceUpdate = TRUE
)
