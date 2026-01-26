# SCRIPT START ----
if(!require("pacman")) install.packages("pacman")
pacman::p_load("tidyverse", "sf", "mapview", "gridExtra", "survey", "devtools",
               "ggmosaic")
#devtools::install_github("haleyjeppson/ggmosaic")

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
load("BAS_data/baltimore-area-survey-2025.Rdata")
View(bas25)

# Neighborhood satisfaction: bas23_nhd_sat
# Neighborhood change: bas23_nhd_chg
# Neighbors do not share same values: bas23_nhd_cohes5




# INCLUDE IN QUARTO MARKDOWN - BAS sentiment histogram ----
vac_lot24 <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvlot)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Lot Sentiment") + ylim(c(0,1000))

vac_bldg24 <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvbldg)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Bldg Sentiment") + ylim(c(0,1000))

vac_bldg25 <- ggplot(data = bas25, mapping = aes(x = bas25_nhd_pbvbld)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 25 Vac Bldg Sentiment") + ylim(c(0,1000))

gridExtra::grid.arrange(vac_lot24, vac_bldg24, vac_bldg25, ncol = 3)
# *********************************************************

# INCLUDE IN QUARTO MARKDOWN - CROSS TAB W/ DEMOGRAPHIC INFO ----
vac_lot_race24 <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvlot)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Lot Sentiment") + facet_wrap(~bas24_dem_raceeth4)

vac_bldg_race24 <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvbldg)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Bldg Sentiment") + facet_wrap(~bas24_dem_raceeth4)

vac_bldg_race25 <- ggplot(data = bas25, mapping = aes(x = bas25_nhd_pbvbld)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 25 Vac Bldg Sentiment") + facet_wrap(~bas25_dem_raceeth4)

vac_lot_sex24 <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvlot)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Lot Sentiment") + facet_wrap(~bas24_dem_gender)
  

vac_bldg_sex24 <- ggplot(data = bas24, mapping = aes(x = bas24_nhd_pdvbldg)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 24 Vac Bldg Sentiment") + facet_wrap(~bas24_dem_gender)

vac_bldg_sex25 <- ggplot(data = bas25, mapping = aes(x = bas25_nhd_pbvbld)) + 
  geom_bar() + theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  labs(x="BAS 25 Vac Bldg Sentiment") + facet_wrap(~bas25_dem_gender)

# ***************************************************************



# BAS 24 ----
# BAS 24 Vacant building questions:
# nhd_pdvbldg
# nhd_pdvlot
# *********************************
# BAS 24 other Q's:
# nhd_walksafe - feel safe walking after dark
# nhd_sat - neighborhood satisfaction


# BAS 25 ----
# BAS 25 Q's to include:
# nhd_sat - neighborhood satisfactions
# nhd_safe - neighborhood safety
# nhd_sat - Neighborhood satisfaction
# nhd_newres - Neighborhood is welcoming
# nhd_walksafe - Feel safe walking after dark
# nhd_wratt - Worry about being attacked
# nhd_wrbkhm - Worry about break-in at home
# nhd_pbdrugs - Drug use in neighborhood
# nhd_pbod - Drug overdoses
# nhd_pbdsale - Drug sales

# VACANTS Q'S ***
# nhd_pbvbld - Vacant buildings in neighborhood
# con_pbvbld - Vacant buildings in jurisdiction (City or county)
# ***************

# INCLUDE IN QUARTO MARKDOWN - Association between Vacant Building and other
# neighborhood indicators
table(bas24$bas24_nhd_walksafe, bas24$bas24_nhd_pdvbldg)
bas24_vac_blg_vs_walksafe <- bas24 %>% 
  select(bas24_nhd_pdvbldg, bas24_nhd_walksafe) %>% 
  group_by(bas24_nhd_pdvbldg) %>% 
  count(bas24_nhd_walksafe)

# Grouped bar plot
ggplot(data = bas24_vac_blg_vs_walksafe, 
       aes(x = bas24_nhd_pdvbldg, y = n, fill = bas24_nhd_walksafe)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  ylab("Frequency") + xlab("Vacant Building Sentiment") + 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.8)) + 
  ggtitle("Bar chart of safe walking sentiment by vacant building sentiment")

# Mosaic plot - relative frequencies by vacant building sentiment
ggplot(data = bas24) +
  ggmosaic::geom_mosaic(aes(x = product(bas24_nhd_pdvbldg), 
                            fill = bas24_nhd_walksafe)) + 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.8))
# **************************************************************************















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
bassvy24 <- svydesign(~1, weights = ~bas24_svy_fwgt, data = bas24)


save.image()
