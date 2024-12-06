# ui.R
library(shiny)

ui <- fluidPage(
  titlePanel("BioAge Calculator"),
  sidebarLayout(
    sidebarPanel(
      h4("Enter Your Details"),
      textInput("name", "Name", placeholder = "Enter your full name"),
      numericInput("age", "Chronological Age (years)", value = 30, min = 0, step = 1),
      radioButtons("gender", "Gender", choices = c("Male", "Female"), inline = TRUE),
      checkboxInput("smoker", "Smoker", value = FALSE),
      numericInput("bmi", "BMI (Body Mass Index)", value = 25, min = 0, step = 0.1),
      numericInput("waist_circumference", "Waist Circumference (cm)", value = 80, min = 0, step = 1),
      actionButton("calculate", "Calculate BioAge", class = "btn-primary"),
      br(),
      br(),
      downloadButton("downloadReport", "Download Report", class = "btn-success")
    ),
    mainPanel(
      h3("Result"),
      p(
        "Once you calculate your BioAge, a summary will appear in a popup window. ",
        "Additionally, you can download a detailed report as a PDF using the button above."
      )
    )
  )
)
