#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(rstudioapi)
source("params.R", encoding="UTF-8")

# 作業フォルダをリポジトリのルートに設定
setwd(dirname(getSourceEditorContext()$path))
setwd("..")

# score.csvとrate.csvの列名にあるプレイヤー名と、params.Rにあるメンバー一覧が一致しているかをチェック
# 一致していなければ、csvファイルの列名を修正
# TODO: 実装する
checkCsvColumnName <- function() {

    # scoreData <- read.csv(scoreFilePath, fileEncoding="UTF-8-BOM")
    # rateData <- read.csv(rateFilePath, fileEncoding="UTF-8-BOM")

    # browser()

    # scoreDataMembers <- list(names(scoreData[3 : length(scoreData)]))
    # humanMembers <- members[1 : c(length(members) - 3)]

    # if(identical(scoreDataMembers, humanMembers)) {
    # }
}

# 対象プレイヤーとその相手１人との間でレートを計算する
calc1On1RawRate <- function(playerScore, playerRate, opponentScore, opponentRate, gameMode) {
    
    # playerが勝った前提で話を進める
    factor <- ifelse(gameMode == "south", 1.1, 0.7)
    weight <- opponentRate / playerRate

    # TODO: playerが勝つ場合、レートが安定したら以下を採用
    # weight <- (playerRate + opponentRate) / playerRate

    # playerが勝っていなかった場合、各変数を更新する
    if(playerScore < opponentScore) {
        factor <- ifelse(gameMode == "south", 0.8, 0.5)
        weight <- playerRate / (playerRate + opponentRate)
    }

    invisible((playerScore - opponentScore) * weight * factor / 1000)
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # csvのプレイヤー名との整合性確認
    # checkCsvColumnName()

    # 点数結果のリストの初期化
    scoreResults <- vector(mode = "list", length = length(members))
    names(scoreResults) <- members

    rateData <- read.csv(rateFilePath, fileEncoding="UTF-8-BOM")

    observeEvent(input$submitNewData, {

        # 今回の対戦で参加した人に対応する部分に点数を記入する
        scoreResults[input$player1Name] <- input$player1Score
        scoreResults[input$player2Name] <- input$player2Score
        scoreResults[input$player3Name] <- input$player3Score
        scoreResults[input$player4Name] <- input$player4Score
        scoreResults[sapply(scoreResults, is.null)] <- NA

        saveDatetime <- format(Sys.time(), "%Y/%m/%d %H:%M")
        meta <- list("date" = saveDatetime, "gameMode" = input$gameMode)

        write.table(c(meta, scoreResults), scoreFilePath, append=T, sep=",", row.names=F, col.names=F)

        # 今回の結果を踏まえ、直前のレートからレートを計算する        
        recentRates <- tail(rateData, n=1)

        # browser()

        # 点差を考慮した1対1レートの総計レーティング
        newRates <- recentRates
        for(i in 1 : length(scoreResults)) {

            if(is.na(scoreResults[i])) next
            playerName <- names(scoreResults[i])
            rateChangeSum <- 0

            for(j in 1 : length(scoreResults)) {

                if(i == j) next
                if(is.na(scoreResults[j])) next
                opponentName <- names(scoreResults[j])
                rateChange <- calc1On1RawRate(as.numeric(scoreResults[playerName]),
                                            as.numeric(recentRates[playerName]),
                                            as.numeric(scoreResults[opponentName]),
                                            as.numeric(recentRates[opponentName]),
                                            meta["gameMode"])
                rateChangeSum <- rateChangeSum + rateChange
            }
            newRates[playerName] <- newRates[playerName] + rateChangeSum
        }

        write.table(newRates, rateFilePath, append=T, sep=",", row.names=F, col.names=F)
        output$newDataSaved <- renderText(paste0("保存した時間：[", Sys.time(), "]"))
    })

    # TODO: もう少し改良する？
    observeEvent(input$showRateGraph, {
        count <- data.frame()
        count[c(1:dim(rateData)[1]),1] <- c(1:dim(rateData)[1])
        colnames(count) <-c("times")
        rateData <- cbind(count,rateData)

        output$plot <- renderPlot({
            rateData %>% ggplot()+
            aes(x = times, y = 1000, color = "")+
            geom_line()+
            geom_line(aes(x = times, y = mori, color = "mori"))+
            geom_line(aes(x = times, y = ishikawa, color = "ishikawa"))+
            geom_line(aes(x = times, y = nishimura, color = "nishimura"))+
            geom_line(aes(x = times, y = ogasawara, color = "ogasawara"))+
            geom_line(aes(x = times, y = tsuchiya, color = "tsuchiya"))+
            geom_line(aes(x = times, y = toriyama, color = "toriyama"))+
            # geom_line(aes(x=times, y = cpuW, color = "cpuW"))+
            labs(title = "rate", y = "", x = "times")
        })
    })
})
