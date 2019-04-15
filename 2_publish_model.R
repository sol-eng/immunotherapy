library(rsconnect)

rsconnect::deployTFModel(
  "saved_models",
  server = "colorado.rstudio.com",
  # account = "{account}",  # <<- edit this line if necessary
  appTitle = "immunotherapy",
  forceUpdate = TRUE
)
