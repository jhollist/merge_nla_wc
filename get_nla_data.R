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

nla17 <- nla17 |>
  mutate(source = "NLA 2017",
         analyte = tolower(analyte),
         result = as.numeric(result),
         date_col = dmy(date_col))
nla12 <- nla12 |>
  mutate(source = "NLA 2012",
         analyte = str_replace(analyte, "_result", ""),
         date_col = mdy(date_col))

nla_both <- bind_rows(nla17, nla12)

ggplot(nla_both, aes(x = date_col, y = result, color = analyte)) +
  geom_point() +
  facet_wrap(source~., scales = "free")

year_analyte_summary <- nla_both |>
  group_by(source, analyte) |>
  summarize(mean = mean(result, na.rm = TRUE),
            sd = sd(result, na.rm = TRUE),
            n = n()) |>
  ungroup()

knitr::kable(year_analyte_summary)

write_csv(nla_both, "nla_both.csv")
write.csv(nla_both, "nla_both_base.csv")

