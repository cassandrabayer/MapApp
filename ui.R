
# Load libraries ------------
library(RColorBrewer)
library(tidyr)
library(leaflet)
library(rgeos)
library(sp)



# Some data input and cleaning -------------
rents <- read.csv("rents_cat.csv")

map <-leaflet(data = rents) %>% addTiles() %>%
  addCircles(popup = ~neighborhood)
map


# Set up some useful variables
# neighborhood_names <- names(table(rents$neighborhood))
county_names <- c("All Counties", names(table(rents$countyname)))


ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  titlePanel("Rental Prices by County in the Bay Area"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                sliderInput("price", "Price", min(rents$price), max(10000),
                            value = range(rents$price), step = 500
                ),
                #selectInput("neighborhood", "Neighborhoods",
                #            neighborhood_names
                selectInput("county", "County",
                            county_names
                ),
                checkboxInput("legend", "Show legend", TRUE)
  )
)