library(rgeos)
library(sp)
library(rgdal)

citibike <- read.csv("citibike.csv", stringsAsFactors = FALSE,
                     colClasses = c("start.station.latitude" = "numeric",
                                    "start.station.longitude" = "numeric"))
coords <- citibike[ , c(5, 6)]

### uncomment to download boro boundaries shapefile
# url <- "https://data.cityofnewyork.us/api/geospatial/tqmj-j8zm?method=export&format=Shapefile"
# file <- basename(url)
# download.file(url, file)
# unzip(file)

boros <- readOGR("geo_export_f087fc0a-ae33-4239-a07d-7a8512c44a26.shp",
                 "geo_export_f087fc0a-ae33-4239-a07d-7a8512c44a26")
boros <- spTransform(boros, CRS("+proj=longlat +ellps=WGS84 +no_defs"))

coordinates(coords) <- ~ start.station.longitude + start.station.latitude
proj4string(coords) <- proj4string(boros)

bike.points <- over(coords, boros)

citibike <- cbind(citibike, bike.points["boro_name"])

# write csv to folder specified with PUIDATA env variable
filepath <- Sys.getenv("PUIDATA")
write.csv(citibike, file =  paste0(filepath, "/citibike.csv"))

