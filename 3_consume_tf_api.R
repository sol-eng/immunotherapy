library(httr)
library(PepTools)
library(magrittr)
library(reticulate)

predict_peptide_class <- function(peptide, solo_url = "https://colorado.rstudio.com/rsc/content/2328/"){
  if (substring(solo_url, nchar(solo_url)) >= "/") solo_url <- paste0(solo_url, "/")
  api_url <- paste0(solo_url, "serving_default/predict")

  peptide_classes <- c("NB", "WB", "SB")
  x_val <-
    peptide %>%
    pep_encode() %>%
    array_reshape(dim = c(nrow(.), 9*20))

  body <- list(instances = list(
    x_val
  ))

  r <- POST(api_url, body = body, encode = "json", content_type_json())

  if (httr::http_error(r)) http_status(r)

  a <-
    r %>%
    content() %>%
    jsonlite::fromJSON() %>%
    extract2("predictions") %>%
    .[1, , ] %>%
    as.matrix()

  if (ncol(a) == 1) a <- t(a)

  a %>%
    as.data.frame() %>%
    set_colnames(peptide_classes) %>%
    set_rownames(peptide)
}



# test_dat <- c("LLTDAQRIV", "LMAFYLYEV", "VMSPITLPT", "SLHLTNCFV", "RQFTCMIAV",
#               "HQRLAPTMP", "FMNGHTHIA", "KINPYFSGA", "WLLIFHHCP", "NIWLAIIEL"
# )
#
# predict_peptide_class(test_dat)
# predict_peptide_class(test_dat[1:2])
# predict_peptide_class(test_dat[1])



