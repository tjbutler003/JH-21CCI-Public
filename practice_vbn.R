if(!require("pacman")) install.packages("pacman")
pacman::p_load("tidyverse", "sf", "mapview", "gridExtra")

vbnCityData <- 
st_read("https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/1/query?outFields=*&where=1%3D1&f=geojson")

csaBoundaries <- 
st_read("https://services1.arcgis.com/UWYHeuuJISiGmgXx/arcgis/rest/services/Community_Statistical_Areas_(CSAs)__Reference_Boundaries_new/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")


View(vbnCityData)
mapview(vbnCityData)
mapview(csaBoundaries)
mapview(csaBoundaries) + mapview(vbnCityData, cex = 2, col.regions = "red")
class(vbnCityData)

vbnPerCsa <- st_intersects(csaBoundaries, vbnCityData)
mapView(vbnPerCsa)

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

gridExtra::grid.arrange(vbnPerAreaMap, vbnMap, ncol = 2)

ggsave("vbn_per_area_map.png", 
        gridExtra::grid.arrange(vbnMap, vbnPerAreaMap, ncol = 2), 
        width = 16, height = 6)

# Read in 21CCI Vacant Building Sentiment data
