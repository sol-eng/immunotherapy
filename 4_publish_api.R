library(rsconnect)

# Since the API is defined by `plumber/plumber.R`, i.e. inside a subfolder,
# first copy the `config.yml` to the `plumber` folder
fs::file_copy("config.yml", "plumber/config.yml", overwrite = TRUE)

withr::with_dir(
  "plumber",

  rsconnect::deployAPI(
    ".",
    # server = "{server}",     # <<- edit this line if necessary
    # account = "{account}",   # <<- edit this line if necessary
    appTitle = "immunotherapy_api",
    forceUpdate = TRUE
  )
)
