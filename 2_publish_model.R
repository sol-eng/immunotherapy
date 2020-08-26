library(pins)
library(keras)

# Pin it on RStudio Connect
pins::board_register_rsconnect()
pins::pin(
  "saved_model",
  "peptide_model",
  "Peptide Prediction Model",
  "rsconnect",
  zip = TRUE
)

mod_pinned <- pins::pin_get("peptide_model")
utils::unzip(mod_pinned, exdir = fs::path_dir(mod_pinned))

mod <- keras::load_model_tf(file.path(fs::path_dir(mod_pinned), "saved_model"))
