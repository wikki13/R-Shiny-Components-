#Server.R
library(shiny)
library(rmarkdown)
library(knitr)
library(tinytex)

# Function: Biological Age Calculation
calculate_bioage <- function(age, gender, smoking_status, bmi, waist_circumference) {
  bioage <- age + (bmi * 0.1) + (ifelse(smoking_status == "Yes", 5, 0))
  return(bioage)
}

# Function: Validate User Inputs
validate_inputs <- function(input) {
  validate(
    need(input$age > 0, "Age must be positive"),
    need(input$bmi > 0, "BMI must be positive"),
    need(input$waist_circumference > 0, "Waist circumference must be positive")
  )
}

# Function: Show Modal Dialog starting 
show_bioage_modal <- function(name, age, bioage) {
  # Determine the message based on BioAge vs Chronological Age.
  message <- if (bioage < age) {
    paste0(
      name, ", your BioAge is ", round(bioage, 2), 
      " years, which is lower than your Chronological Age. Great job maintaining healthy habits!"
    )
  } else if (bioage > age) {
    paste0(
      name, ", your BioAge is ", round(bioage, 2), 
      " years, which is higher than your Chronological Age. Consider focusing on healthier lifestyle choices."
    )
  } else {
    paste0(
      name, ", your BioAge matches your Chronological Age, indicating balanced health markers."
    )
  }
  
  # Modal dialogue starting
  showModal(
    modalDialog(
      title = div(tagList(h3(paste0(name, "'s BioAge"))),class="custom-popup-title"),
      div(
        style = "text-align: center; margin-top: 20px;",
        fluidRow(
          column(5, div(
            p("Chronological Age", style = "font-weight: bold; font-size: 16px;"),
            p(paste(age, "years"), style = "font-size: 24px; font-weight: bold; color: #4CAF50;")
          )),
          column(2, div(
            p("→", style = "font-size: 32px; font-weight: bold; color: #888; margin-top: 25px;")
          )),
          column(5, div(
            p("BioAge", style = "font-weight: bold; font-size: 16px;"),
            p(paste(round(bioage, 2), "years"), style = "font-size: 24px; font-weight: bold; color: #2196F3;")
          ))
        )
      ),
      div(
        style = "text-align: center; margin-top: 20px;",
        p(message, style = "font-size: 16px; font-weight: bold;")
      ),
      div(
        class = "custom-popup-border",
        p("Complete report sent to your WhatsApp", style = "font-size: 14px;"),
        p("xxxxxxxx4321", style = "font-size: 14px; color: #888;")
      ),
      easyClose = TRUE
    )
  )
}


# Pdf report generation block
generate_report <- function(params, output_file) {
  src <- normalizePath('report.Rmd')  # Ensure 'report.Rmd' exists in your project directory
  
  # Copy Rmd file to a temporary directory ( using tinytex not LaTex) which is lite weight.
  owd <- setwd(tempdir())
  on.exit(setwd(owd))
  
  file.copy(src, 'report.Rmd', overwrite = TRUE)
  
  # Render the report with the provided parameters in the form entries
  rmarkdown::render(
    input = 'report.Rmd',
    output_file = output_file,
    output_format = 'pdf_document',
    envir = new.env(parent = globalenv())  # Use a new environment to avoid conflicts
  )
}

# Server Logic
server <- function(input, output, session) {
  observeEvent(input$calculate, {
    validate_inputs(input)
    
    bioage <- calculate_bioage(
      age = input$age,
      gender = input$gender,
      smoking_status = ifelse(input$smoker, "Yes", "No"),
      bmi = input$bmi,
      waist_circumference = input$waist_circumference
    )
    
    # Pass required arguments explicitly
    show_bioage_modal(
      name = input$name,
      age = input$age,
      bioage = bioage
    )
  })
  
  output$downloadReport <- downloadHandler(
    filename = function() {
      paste("bioage_report_", Sys.Date(), ".pdf", sep = "")
    },
    content = function(file) {
      tryCatch({
        generate_report(
          params = list(
            name = input$name,
            age = input$age,
            bioage = calculate_bioage(
              age = input$age,
              gender = input$gender,
              smoking_status = ifelse(input$smoker, "Yes", "No"),
              bmi = input$bmi,
              waist_circumference = input$waist_circumference
            )
          ),
          output_file = file
        )
      }, error = function(e) {
        showModal(modalDialog(
          title = "Error",
          paste("Failed to generate the report:", e$message),
          easyClose = TRUE
        ))
      })
    }
  )
}
