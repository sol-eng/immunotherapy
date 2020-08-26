library(httr)
library(purrr)

predict_peptide <- function(peptide,
                            solo_url = config::get("solo_url_plumber"))
{
  if (substring(solo_url, nchar(solo_url)) != "/") {
    solo_url <- paste0(solo_url, "/")
  }

  if(length(peptide > 1)) {
    peptide <- paste(peptide, collapse = ",")
  }

  api_url <- paste0(solo_url, "predict")

  r <- GET(
    api_url,
    query = list(peptide = peptide),
    encode = "json", content_type_json()
  )
  stop_for_status(r)
  rc <- content(r)

  rc %>% map_dfr(
    ~as.data.frame(., stringsAsFactors = FALSE)
  )
}

# Test it

predict_peptide(peptide = "LLTDAQRIV")
predict_peptide("LLTDAQRIV, LMAFYLYEV, VMSPITLPT, SLHLTNCFV, RQFTCMIAV")
predict_peptide(c("LLTDAQRIV", "LMAFYLYEV", "VMSPITLPT", "SLHLTNCFV", "RQFTCMIAV"))

