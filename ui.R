# ui.R
library(shiny)

ui <- fluidPage(
  titlePanel("BioAge Calculator"),
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Name"),
      numericInput("age", "Chronological Age", value = 30),
      radioButtons("gender", "Gender", choices = c("Male", "Female")),
      checkboxInput("smoker", "Smoker"),
      numericInput("bmi", "BMI", value = 25),
      numericInput("waist_circumference", "Waist Circumference (cm)", value = 80),
      actionButton("calculate", "Calculate BioAge"),
      downloadButton("downloadReport", "Download Report")
    ),
    mainPanel(
      h3("Your BioAge"),
      textOutput("bioage_result")
    )
  )
)
