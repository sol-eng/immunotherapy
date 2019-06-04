library(httr)

predict_peptide <- function(peptide, solo_url = config::get("solo_url_plumber")){
  if (substring(solo_url, nchar(solo_url)) != "/") solo_url <- paste0(solo_url, "/")
  api_url <- paste0(solo_url, "/predict")

  r <- GET(api_url, query = list(peptide = peptide), encode = "json", content_type_json())
  if (httr::http_error(r)){
    cat(http_status(r))
    stop(http_status(r))
  }
  r %>%
    content() %>%
    as.data.frame()
}


predict_peptide(peptide = "LLTDAQRIV")
predict_peptide(c("LLTDAQRIV", "LMAFYLYEV", "VMSPITLPT", "SLHLTNCFV", "RQFTCMIAV"))
