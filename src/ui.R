#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source("params.R", encoding="UTF-8")

newDataPage <- tabPanel(
    "新規データ入力",
    sidebarLayout(
        sidebarPanel(
            selectInput("gameMode",
                        h3("ゲームモード"),
                        choices = gameModes,
                        selected = gameModes[2])
        ),
        mainPanel(
            fluidRow(
                column(3,
                       selectInput("player1Name",
                                   label = h3("player1"),
                                   choices = members,
                                   selected = members[1]
                       ),
                       numericInput("player1Score", "点数", "25000", step = 100),
                ),
                column(3,
                       selectInput("player2Name",
                                   label = h3("player2"),
                                   choices = members,
                                   selected = members[2]
                       ),                 
                       numericInput("player2Score", "点数", "25000", step = 100),
                ),
                column(3,
                       selectInput("player3Name",
                                   label = h3("player3"),
                                   choices = members,
                                   selected = members[3]
                       ),
                       numericInput("player3Score", "点数", "25000", step = 100),
                ),
                column(3,
                       selectInput("player4Name",
                                   label = h3("player4"),
                                   choices = members,
                                   selected = members[4]
                       ),
                       numericInput("player4Score", "点数", "25000", step = 100),
                ),
            ),
            actionButton("submitNewData", "保存"),
            textOutput("newDataSaved")
        )
    )
)

graphPage <- tabPanel(
    "解析",
    sidebarLayout(
        sidebarPanel(
            actionButton("showRateGraph", "レーティング表示")
        ),
        mainPanel(
            div(plotOutput("plot", height = "80%"), style = "height: 100vh")
        )
    )
)

# Define UI for application that draws a histogram
shinyUI(
    navbarPage("麻雀友人戦レーティングシステム", newDataPage, graphPage)
)
