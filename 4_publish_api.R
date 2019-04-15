library(rsconnect)


withr::with_dir("plumber", list.files())

withr::with_dir(
  "plumber",

  rsconnect::deployAPI(
    ".",
    server = "colorado.rstudio.com",
    # account = "{account}",  # <<- edit this line if necessary
    appTitle = "immunotherapy_api",
    forceUpdate = TRUE
  )
)
