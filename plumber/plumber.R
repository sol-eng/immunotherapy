#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(config)

source("3_consume_tf_api.R")

#* @apiTitle Immunotherapy

#* Predict peptide class
#* @param peptide Character vector with a single peptide, eg. `"LLTDAQRIV"` or comma separated, e.g. `"LLTDAQRIV, LMAFYLYEV, VMSPITLPT, SLHLTNCFV, RQFTCMIAV"`
#* @get /predict
function(peptide, solo_url){
  if (missing(solo_url) || is.null(solo_url)) {
    solo_url <- config::get("solo_url_tensorflow") # TensorFlow API
  }

  # split on commas and remove white space
  peptide <- trimws(strsplit(peptide, ",")[[1]])

  predict_peptide_class_fun(peptide = peptide, solo_url = solo_url)
}



# source("consume_tf_api.R")
# solo_url <- "https://colorado.rstudio.com/rsc/content/2328/"
# predict_peptide_class(peptide = "LLTDAQRIV", solo_url = solo_url)
