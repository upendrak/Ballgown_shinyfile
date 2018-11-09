#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ballgown)
library(genefilter)
library(downloader)
library(dplyr)
library(RCurl)
library(ballgown)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  shinyDirChoose(input, 'dir', roots=c(wd='/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp/'))
  shinyFileChoose(input, 'design_mtx', roots=c(wd='/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp/'), filetypes=c('txt', 'csv'))

  bg1 <- reactive({
    inFile <- parseFilePaths(roots=c(wd='/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp'), input$design_mtx)
    if(is.null(inFile))
      return(NULL)
    ctab_path <- parseDirPath(roots=c(wd='/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp'), input$dir)
    ctab_fdr <- basename(ctab_path)
    ctab_fdr_ucmp<-tools::file_path_sans_ext(ctab_fdr)
    pheno_data <- read.table(inFile$datapath, header = TRUE, sep = "\t")
    sample_full_path <- paste(ctab_fdr_ucmp,pheno_data[,1], sep = '/')
    bg <- ballgown(samples=as.vector(sample_full_path),pData=pheno_data)
  })
  
  output$contents <- renderDataTable({
    inFile <- parseFilePaths(roots=c(wd='/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp'), input$design_mtx)
    if( NROW(inFile)) {
      df <- read.csv(as.character(inFile$datapath), header = TRUE, sep = "\t")
      return(df)
    }
  })
  
  output$transContent <- renderDataTable({
    ranscript_data_frame = texpr(bg1(), 'all')
    return(ranscript_data_frame)
  })
  
  observe({
    volumes <- c("wd"="/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp/")
    shinyFileSave(input, "downloadTrans1", roots=volumes, session=session)
    fileinfo <- parseSavePath(volumes, input$downloadTrans1)
    if (nrow(fileinfo) > 0) {
      write.table(texpr(bg1(), 'all'), as.character(fileinfo$datapath), quote = F, sep = "\t", row.names = F)
    }
  })
  
  output$decontents <- renderDataTable({
    results_genes = stattest(bg1(), feature=input$featureInput, meas=input$measInput, covariate=input$covariate, getFC=TRUE)
    return(results_genes)
  })
  
  observe({
    volumes <- c("wd"="/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp/")
    shinyFileSave(input, "downloadexpression1", roots=volumes, session=session)
    fileinfo <- parseSavePath(volumes, input$downloadexpression1)
    if (nrow(fileinfo) > 0) {
      write.table(stattest(bg1(), feature=input$featureInput, meas=input$measInput, covariate=input$covariate, getFC=TRUE), 
                  as.character(fileinfo$datapath), quote = F, sep = "\t", row.names = F)
    }
  })
  
  output$plot1 <- renderPlot({
    all_sample_list <- c(strsplit(input$gv_var_sample, " ")[[1]])
    plotTranscripts(gene=input$gv_var_input, gown=bg1(), samples=all_sample_list, colorby=input$featureInput, meas=input$measInput, labelTranscripts=TRUE)
    })
  
  observe({
    volumes <- c("wd"="/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp/")
    shinyFileSave(input, "downloadplot1", roots=volumes, session=session)
    fileinfo <- parseSavePath(volumes, input$downloadplot1)
    if (nrow(fileinfo) > 0) {
      ggsave(plotTranscripts(gene=input$gv_var_input, gown=bg1(), samples=all_sample_list, colorby=input$featureInput, meas=input$measInput, labelTranscripts=TRUE), filename = as.character(fileinfo$datapath), width = 12)
    }
  })

  output$plot2 <- renderPlot({
    plotMeans(gene=input$gv_var_input, gown=bg1(), groupvar=input$covariate, colorby=input$featureInput, meas=input$measInput, labelTranscripts=TRUE)
  })
  
  observe({
    volumes <- c("wd"="/Users/upendra_35/Documents/CyVerse/Images_apps/DE/VICE/Ballgown_shinyapp/")
    shinyFileSave(input, "downloadplot2", roots=volumes, session=session)
    fileinfo <- parseSavePath(volumes, input$downloadplot2)
    if (nrow(fileinfo) > 0) {
      ggsave(plotMeans(gene=input$gv_var_input, gown=bg1(), groupvar=input$covariate, colorby=input$featureInput, meas=input$measInput, labelTranscripts=TRUE), filename = as.character(fileinfo$datapath))
    }
  })
  
})

