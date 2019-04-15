library(httr)
library(PepTools)
library(magrittr)

predict_peptide_class <- function(peptide, solo_url = "https://colorado.rstudio.com/rsc/content/2328/"){
  if (substring(solo_url, nchar(solo_url)) >= "/") solo_url <- paste0(solo_url, "/")
  api_url <- paste0(solo_url, "serving_default/predict")

  peptide_classes <- c("NB", "WB", "SB")
  x_val <-
    peptide %>%
    pep_encode() %>%
    reticulate::array_reshape(c(nrow(.), 9*20))

  body <- list(instances = list(
    x_val
  ))

  POST(api_url, body = body, encode = "json", content_type_json()) %>%
    content() %>%
    jsonlite::fromJSON() %>%
    extract2("predictions") %>%
    as.array() %>%
    .[1, , ] %>%
    as.data.frame() %>%
    set_colnames(peptide_classes) %>%
    set_rownames(peptide)
}



# test_dat <- c("LLTDAQRIV", "LMAFYLYEV", "VMSPITLPT", "SLHLTNCFV", "RQFTCMIAV",
#               "HQRLAPTMP", "FMNGHTHIA", "KINPYFSGA", "WLLIFHHCP", "NIWLAIIEL"
# )
#
# predict_peptide_class(test_dat)


