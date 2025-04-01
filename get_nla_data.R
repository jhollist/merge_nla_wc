source("packages.R")

nla17_url <- "https://www.epa.gov/sites/default/files/2021-04/nla_2017_water_chemistry_chla-data.csv"
nla12_url <- "https://www.epa.gov/sites/default/files/2016-12/nla2012_waterchem_wide.csv"
nla12_site_url <- "https://www.epa.gov/sites/default/files/2016-12/nla2012_wide_siteinfo_08232016.csv"

nla17 <- read_csv(nla17_url, guess_max = 22873) |>
  rename_all(tolower) |>
  select(uid,site_id,date_col,visit_no,state,analyte,result) |>
  filter(analyte %in% c("NTL", "PTL", "TURB"))

nla12_wc <- read_csv(nla12_url) |>
  rename_all(tolower) |>
  select(uid, ntl_result, ptl_result, turb_result)

nla12_site <- read_csv(nla12_site_url) |>
  rename_all(tolower) |>
  select(uid, site_id, date_col, visit_no, state)

nla12 <- left_join(nla12_site, nla12_wc, by = c("uid" = "uid"))
nla12 <- na.omit(nla12)
nla12 <- pivot_longer(nla12,cols = ntl_result:turb_result,
                      names_to = "analyte", values_to = "result")

