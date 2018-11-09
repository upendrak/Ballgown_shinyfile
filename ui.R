library(shiny)
library(shinyFiles)
library(ballgown)

shinyUI(pageWithSidebar(
  # headerPanel(
  #   'Ballgown Shiny'
  # ),
  fluidPage(
    column(3,offset = 3, titlePanel("Ballgown Shiny App")) 
  ),
  sidebarPanel(
    tags$h3('Select your Ballgown folder:'),
    
    # Shiny button   
    shinyDirButton(id = 'dir', label = 'Folder select', title = 'Please select the Ballgown folder'),
    
    tags$h3('Select your Design Matrix file:'),
    
    shinyFilesButton(id = 'design_mtx', label = 'File select', title = 'Please select the design matrix file', multiple = FALSE),
    
    tags$h3('Select your Parameters:'),
    
    textInput("covariate", label = "Name of the covariate of interest for the differential expression tests", value = ""),
    
    selectInput("featureInput", "Genomic feature",
                choices = c("transcript", "exon")),
    
    selectInput("measInput", "Expression measurement",
                choices = c("FPKM", "cov", "rcount", "ucount", "mrcount", "mcov"))
  ),
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("TABLES",
                         fluidRow(
                           column(12,
                                  h3('Design Matrix')
                         ),
                         offset = 1),
                           dataTableOutput("contents"),
                         fluidRow(
                           column(12,
                                  h3('Transcript-level expression')
                           ),
                           offset = 1),
                         dataTableOutput("transContent"),
                         shinySaveButton(id = 'downloadTrans1', label =  'Save file', title = "Save file as...", filetype = "txt")
                ),
                tabPanel("DIFFERENTIAL EXPRESSION", dataTableOutput("decontents"),
                shinySaveButton(id = 'downloadexpression1', label =  'Save file', title = "Save file as...", filetype = "txt")
                ),
                tabPanel("PLOTS",
                         fluidRow(
                           column(12,
                                  p(h3('Gene view between experiment covariates'),
                                    'Abundances of transcript mapping to a given gene,',
                                    'Visualization of the assembled transcripts across experimental covariates.',
                                    'This plot colors transcripts by expression level')
                           ),
                           offset = 1),
                         textInput('gv_var_input', label = 'Enter the name of the gene: ', value = ''),
                         plotOutput("plot2"),
                         shinySaveButton(id = 'downloadplot2', label =  'Save plot', title = "Save plot as...", filetype = "png"),
                         fluidRow(
                           column(12,
                                  p(h3('gene view'),
                                    'Abundances of transcript mapping to a given gene,',
                                    'Visualization of the assembled transcripts',
                                    'This plot colors transcripts by expression level')
                           ),
                           offset = 1),
                         textInput('gv_var_sample', label = 'Enter the name of the sample: ', value = ''),
                         plotOutput('plot1'),
                         shinySaveButton(id = 'downloadplot1', label =  'Save plot', title = "Save plot as...", filetype = "png")
                         
    )
  )
)
))
