library(httr)
library(PepTools)
library(magrittr)
library(reticulate)

predict_peptide_class_fun <- function(peptide, solo_url = "https://colorado.rstudio.com/rsc/content/2328/"){

  if (substring(solo_url, nchar(solo_url)) != "/") solo_url <- paste0(solo_url, "/")
  api_url <- paste0(solo_url, "serving_default/predict")

  peptide_classes <- c("NB", "WB", "SB")

  # transform input into flattened array
  x_val <-
    peptide %>%
    pep_encode() %>%
    array_reshape(dim = c(nrow(.), 9*20))

  # construct http body
  body <- list(instances = list(
    x_val
  ))

  # make http request
  r <- POST(api_url, body = body, encode = "json", content_type_json())

  # check for errors
  if (httr::http_error(r)){
    cat(http_status(r))
    stop(http_status(r))
  }

  # extract prediction and transform to a matrix
  a <-
    r %>%
    content() %>%
    jsonlite::fromJSON() %>%
    extract2("predictions") %>%
    .[1, , ] %>%
    as.matrix()

  # transpose if necessary
  if (ncol(a) == 1) a <- t(a)

  # convert to a data frame and column names
  d <-
    a %>%
    as.data.frame() %>%
    set_colnames(peptide_classes)

  # column bind with original request
  cbind(
    data.frame(
      peptide = peptide,
      stringsAsFactors = FALSE
    ),
    d
  )
}



test_dat <- c("LLTDAQRIV", "LMAFYLYEV", "VMSPITLPT", "SLHLTNCFV", "RQFTCMIAV",
              "HQRLAPTMP", "FMNGHTHIA", "KINPYFSGA", "WLLIFHHCP", "NIWLAIIEL"
)

predict_peptide_class_fun(test_dat)
predict_peptide_class_fun(test_dat[1:2])
predict_peptide_class_fun(test_dat[1])



