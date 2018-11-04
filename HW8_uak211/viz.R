library(tidyverse)
library(ggplot2)
library(rgdal)
library(sp)

# borough boundaries
# uncomment if downloading shapefile for first time
# download.file("https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nybb_18c.zip",
              #destfile = "boro.zip")
# unzip("boro.zip")

boros <- readOGR("nybb_18c/nybb.shp", "nybb") %>%
   spTransform(., CRS("+proj=longlat +ellps=WGS84 +no_defs")) %>%
   fortify(boros, region = "BoroName") %>%
   select(c(1, 2, 3, 6, 7))

# voter list munge to output no-party registration proportion of all registrations
voters <- read.csv("allNYCvoters102018.csv", stringsAsFactors = FALSE,
                   na.strings = c("NA", "", " ", NA))

voters.clean <- voters %>%
   mutate(boro = as.character(factor(V22, levels = c(3, 24, 31, 41, 43),
                           labels = c("Bronx", "Brooklyn", "Manhattan", "Queens", "Staten Island"))),
          reg.year = substr(V36, 1, 4)) %>%
   select(boro, party = V20, status = V40, reg.year) %>%
   group_by(boro, reg.year) %>%
   mutate(total.boro.reg = n()) %>%
   ungroup() %>%
   filter(reg.year >= 2008, party == "BLK") %>%
   group_by(boro, reg.year) %>%
   mutate(boro.noparty.reg = n(),
          pct.noparty = round((boro.noparty.reg / total.boro.reg * 100), 2)) %>%
   unique() %>%
   ungroup() %>%
   select(c(1, 4, 7))

# joining boro boundaries and party data
boro.plot <- merge(boros, voters.clean, by.x = "id", by.y = "boro")

# small multiples (over last 10 years) of boro proportions using ggplot
p <- ggplot(data = boro.plot, aes(x = long, y = lat, group = group))
p + geom_polygon(aes(fill = pct.noparty), show.legend = TRUE) +
   facet_wrap(~ reg.year) +
   theme_void() +
   scale_fill_gradient(low = "#ddeaee", high = "#2b4b56") +
   labs(title = "percent of new nyc voters not designating a party affiliation")



