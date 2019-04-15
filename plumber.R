#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)

source("consume_tf_api.R")

#* @apiTitle Immunotherapy

#* Predict peptide class
#*
#* @param peptide Character vector with peptide, eg. "LLTDAQRIV" or `c("LLTDAQRIV", "LMAFYLYEV", "VMSPITLPT", "SLHLTNCFV", "RQFTCMIAV")`
#* @get /predict_peptide_class
function(peptide){
  solo_url <- "https://colorado.rstudio.com/rsc/content/2328/"
  predict_peptide_class(peptide = peptide, solo_url = solo_url)
}



# source("consume_tf_api.R")
# solo_url <- "https://colorado.rstudio.com/rsc/content/2328/"
# predict_peptide_class(peptide = "LLTDAQRIV", solo_url = solo_url)
