if(!require("pacman")) install.packages("pacman")
pacman::p_load("tidyverse", "sf", "mapview")

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
