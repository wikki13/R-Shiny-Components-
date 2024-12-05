# server.R
library(shiny)
library(rmarkdown)
library(knitr)

server <- function(input, output, session) {
  
  calculate_bioage <- function(age,
                             gender,
                             smoking_status,
                             bmi,
                             waist_circumference) {
  # Placeholder: Replace with your actual model
  bioage <- age + (bmi * 0.1) + (ifelse(smoking_status == "Yes", 5, 0))
  return(bioage)
}
  
  observeEvent(input$calculate, {
    # Calculate bioage based on input data
    bioage <- calculate_bioage(
      age = input$age,
      gender = input$gender,
      smoking_status = ifelse(input$smoker, "Yes", "No"),
      bmi = input$bmi,
      waist_circumference = input$waist_circumference
    )
    
    # Display the result in a modal dialog
    showModal(
      modalDialog(
        title = tagList(h3(paste0(input$name, "'s BioAge"))),
        fluidRow(column(6, p("Chronological Age")), column(6, p("BioAge"))),
        fluidRow(
          column(6, p(input$age, style = "font-size: 24px; font-weight: bold;")),
          column(6, p(round(bioage, 2), style = "font-size: 24px; font-weight: bold;"))
        ),
        p(
          if (bioage <= input$age) {
            paste0("Congratulations, ", input$name, "! Your biological age is ", round(bioage, 2), 
                   " years old, which is equal to or less than your chronological age. This indicates a healthy lifestyle.")
          } else {
            paste0("Hi, ", input$name, ", your biological age is ", round(bioage, 2), 
                   " years old, which is higher than your chronological age. Consider adopting healthier lifestyle habits to improve your biological age.")
          }
        ),
        p("Complete report sent to your WhatsApp"),
        p("xxxxxxxx4321"),
        easyClose = TRUE
      )
    )
  })
  
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste("bioage_report_", Sys.Date(), ".html", sep = "")
    },
    content = function(file) {
      # Path to your R Markdown file
      src <- normalizePath('report.Rmd')  # Ensure the report.Rmd file exists in your working directory
      owd <- setwd(tempdir())  # Temporary directory
      on.exit(setwd(owd))  # Reset working directory after rendering
      file.copy(src, 'report.Rmd', overwrite = TRUE)  # Copy the .Rmd file to the temp directory
      
      # Render the Rmd file to HTML format
      out <- render('report.Rmd', output_format = "html_document", output_file = file)
      file.rename(out, file)  # Rename the output file to the desired file name
    }
  )
}
