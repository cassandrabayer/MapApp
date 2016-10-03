server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    
    # select these
    if(input$county == "All Counties"){
      these <- (rents$price >= input$price[1] & rents$price <= input$price[2])
    }else{
      these <- (rents$price >= input$price[1] & rents$price <= input$price[2]) & 
        (rents$countyname == input$county)
    }
    
    # subset
    rents[these,]
  })
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    #colorNumeric(input$colors, rents$price)
    colorNumeric("RdYlBu", rents$price)
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(rents) %>% addTiles() %>%
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(radius = ~price/10, weight = 1, color = "#777777",
                 fillColor = ~pal(price), fillOpacity = 0.7, popup = ~paste(price)
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = rents)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    if (input$legend) {
      pal <- colorpal()
      proxy %>% addLegend(position = "bottomright",
                          pal = pal, values = ~price
      )
    }
  })
}

shinyApp(ui, server)
