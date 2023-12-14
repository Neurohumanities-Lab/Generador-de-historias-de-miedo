library(shiny)
#pak::pak("rstudio/reticulate")
library(reticulate)
#library(shinyWidgets)
library(shinyjs)
library(openai)
library(magick)
library(deeplr)

#we will use two APIs: deepl for translation, and openAI for generative AI
DEEPL_KEY = "YOUR KEY"
Sys.setenv(
  OPENAI_API_KEY = 'YOUR KEY'
)

#install python libraries
py_install("openai")
py_install("gtts")

#call python script by means of reticulate
source_python("data/elogiosAI.py")

# Define UI for application that draws a histogram
ui <- fluidPage(#theme = shinytheme("journal"),
  
                tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}",
                           HTML("#ext-label.control-label{font-size: 11px;}"),
                           HTML("#rango-label.control-label{font-size: 11px;}"),
                           HTML("body {
                           background-color: #0e31a6;
                           color: white;
                                }"),
                           HTML(".well {
                                background-color: #0e31a6;")),

    # Application title
    titlePanel("😱 Generador de historias de miedo"),
    useShinyjs(), 
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
          textInput("escena", "Sugiere un lugar para una escena de miedo (p.e. 'la playa', 'un cine', etc)"),
          column(6,
          sliderInput("ext",
                      "Extensión de la escena:",
                      min = 80,
                      max = 260,
                      step = 60,
                      #ticks = FALSE,
                      value = 140),
          ),
          column(6,
          sliderInput("rango",
                      "Rango de miedo:",
                        min = 0,
                        max = 1,
                      #ticks = FALSE,
                      step = 0.33,
                        value = 0.33)
          ),
          actionButton("run", "generar"),
          hidden(
            actionButton("aumen", "aumentar miedo!")
          )
        ),

        # For the main panel
        mainPanel(
           htmlOutput("distPlot"),
           HTML("<br>"),
           imageOutput("myImage")
           #HTML("aquí imagen <img src='generatedImage$data$url' />")
        )
    )
)

# Define server logic
server <- function(input, output, session) {
  
  values <- reactiveValues()
  
  values$image <- image_blank(1200, 50, "#0e31a6")
  
  observeEvent (input$run, {
    myPrompt <- paste("Describe una escena siniestra, inquietante, estilo novela de terror, ambientada en", input$escena, sep = " ")
    tokens <- as.integer(input$ext)
    temp <- input$rango
    show("aumen")
    
    output$distPlot <- renderPrint({
      cat(py$get_response(myPrompt, tokens, temp), "...")
    })
    
    enTxt <- translate2(text = py$get_response(myPrompt, tokens, temp), 
               source_lang = "ES",
               target_lang = "EN",
               auth_key = DEEPL_KEY)
    
    generatedImage <- create_image(enTxt)
    download.file(generatedImage$data$url, paste0("data/image", ".jpg"), mode="wb")
    values$image <- image_convert(image_read("data/image.jpg", "jpg"))
  })
  
  
  output$myImage <- renderImage({
    
    tmpfile <- values$image %>%
      image_resize("500x500!") %>%
      image_write(tempfile(fileext='jpg'), format = 'jpg')
    
    # Return a list
    list(src = tmpfile, contentType = "image/jpeg")
    
  },
  deleteFile=TRUE)
  
  #create a counter for the Next buttton
  counter <- reactiveValues(countervalue = 0)
  
  observeEvent (input$aumen, {
    counter$countervalue <- counter$countervalue + 1
    if (counter$countervalue==1) {
      myPrompt <- paste("Describe una escena de mucho miedo, pavor, en el momento cumbre de intensidad de una novela de terror, que suceda en", input$escena, sep = " ")
      tokens <- as.integer(input$ext)
      if (input$rango<0.8){
      temp <- input$rango+0.2
      updateActionButton(session, "aumen", "Y al final...") }
      
      enTxt <- translate2(text = py$get_response(myPrompt, tokens, temp), 
                          source_lang = "ES",
                          target_lang = "EN",
                          auth_key = DEEPL_KEY)
      
      generatedImage <- create_image(enTxt)
      download.file(generatedImage$data$url, paste0("data/image", ".jpg"), mode="wb")
      values$image <- image_convert(image_read("data/image.jpg", "jpg"))
    }
    if (counter$countervalue>1){
      myPrompt <- paste("Describe el final de una historia de miedo que ha sucedido en", input$escena, sep = " ")
      tokens <- as.integer(80)
      temp <- 1
      
      enTxt <- translate2(text = py$get_response(myPrompt, tokens, temp), 
                          source_lang = "ES",
                          target_lang = "EN",
                          auth_key = DEEPL_KEY)
      
      generatedImage <- create_image(enTxt)
      download.file(generatedImage$data$url, paste0("data/image", ".jpg"), mode="wb")
      values$image <- image_convert(image_read("data/image.jpg", "jpg"))
    }
    
    output$distPlot <- renderPrint({
      cat(py$get_response(myPrompt, tokens, temp), "...")
    })
      
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
