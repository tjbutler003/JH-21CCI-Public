# SCRIPT START ----
if(!require("pacman")) install.packages("pacman")
pacman::p_load("tidyverse", "sf", "mapview", "gridExtra", "survey")

load(".RData")
# -----------------



vbnCityData <- 
st_read("https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/1/query?outFields=*&where=1%3D1&f=geojson")

csaBoundaries <- 
st_read("https://services1.arcgis.com/UWYHeuuJISiGmgXx/arcgis/rest/services/Community_Statistical_Areas_(CSAs)__Reference_Boundaries_new/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")


View(vbnCityData)
mapview(vbnCityData)
mapview(csaBoundaries)
# INCLUDE IN QUARTO MARKDOWN - View of CSA and VBN points ----
mapview(csaBoundaries) + mapview(vbnCityData, cex = 2, col.regions = "red")
# ************************************************************
class(vbnCityData)

csaBoundariesIntersected <- csaBoundaries %>%
  mutate(vbns = 
            lengths(st_intersects(csaBoundaries, vbnCityData)),
         vbnsPerArea = vbns / Shape__Area * 1000000)


intersections <-
    lengths(st_intersects(csaBoundaries, vbnCityData))

mapview(csaBoundariesIntersected, zcol = "vbns")

vbnPerAreaMap <-
  ggplot() +
  geom_sf(data = csaBoundariesIntersected, aes(fill = vbnsPerArea)) +
  scale_fill_viridis_c() +
  theme_minimal() +
  labs(title = "VBN Units per CSA Area",
       fill = "VBNs per sq km")

vbnMap <-
  ggplot() +
  geom_sf(data = csaBoundariesIntersected, aes(fill = vbns)) +
  theme_minimal() +
  labs(title = "VBN Units in Baltimore City",
       fill = "VBN Units")

plot(csaBoundariesIntersected["vbnsPerArea"])

# INCLUDE IN QUARTO MARKDOWN - VBN's per CSA and VBN's per CSA area ----
gridExtra::grid.arrange(vbnPerAreaMap, vbnMap, ncol = 2)
# **********************************************************************


ggsave("vbn_per_area_map.png", 
        gridExtra::grid.arrange(vbnMap, vbnPerAreaMap, ncol = 2), 
        width = 16, height = 6)

# Read in 21CCI Vacant Building Sentiment data
load("BAS_data/baltimore-area-survey-2023.Rdata")
View(bas23)
load("BAS_data/baltimore-area-survey-2024.Rdata")
View(bas24)

# Neighborhood satisfaction: bas23_nhd_sat
# Neighborhood change: bas23_nhd_chg
# Neighbors do not share same values: bas23_nhd_cohes5

# BAS 24 Vacant building questions:
# bas24_nhd_pdvbldg
# bas24_nhd_pdvlot
# NOTE: NO VACANT LOT/BLDG QUESTIONS IN BAS23!!

# INCLUDE IN QUARTO MARKDOWN - BAS sentiment histogram ----
vac_lot <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvlot)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Lot Sentiment")

vac_bldg <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvbldg)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Bldg Sentiment")

gridExtra::grid.arrange(vac_lot, vac_bldg, ncol = 2)
# *********************************************************

# INCLUDE IN QUARTO MARKDOWN - CROSS TAB W/ DEMOGRAPHIC INFO ----
vac_lot_race <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvlot)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Lot Sentiment") + facet_wrap(~bas24_dem_raceeth4)

vac_bldg_race <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvbldg)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Bldg Sentiment") + facet_wrap(~bas24_dem_raceeth4)

vac_lot_sex <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvlot)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Lot Sentiment") + facet_wrap(~bas24_dem_gender)
  

vac_bldg_sex <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvbldg)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Bldg Sentiment") + facet_wrap(~bas24_dem_gender)


# ***************************************************************


# Recode vacant building/lot problem sentiment:
# 1 = 'Somewhat of a problem' or 'big problem'
# 0 = 'Not a problem at all' or 'Not much of a problem'

bas24 <-
mutate(bas24,
       vbldg_binary = 
        ifelse(bas24_nhd_pdvbldg %in% c("Somewhat of a problem","A big problem"),
          1, 0),
       vlot_binary =
        ifelse(bas24_nhd_pdvlot %in% c("Somewhat of a problem", "A big problem"),
        1, 0))

# Weight responses in order to show by CSA
bassvy <- svydesign(~1, weights = ~bas24_svy_fwgt, data = bas24)


save.image()
