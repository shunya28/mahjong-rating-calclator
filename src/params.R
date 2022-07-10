members <- list("石川" = "ishikawa",
                "土屋" = "tsuchiya",
                "西邑" = "nishimura",
                "森" = "mori",
                "小笠原" = "ogasawara",
                "鳥山" = "toriyama",
                # 新規メンバーはこれより上に追加する
                # server.RのcheckCsvColumnNameをまだ実装してないので、メンバー追加時はcsvファイルにも同じ順番で列名を追加する
                "CPU(普通)" = "cpuM",
                "CPU(弱い)" = "cpuW",
                "挑戦者" = "challenger")

gameModes <- list("東風戦" = "east", "半荘戦" = "south")

scoreFilePath <- "./data/score.csv"
rateFilePath <- "./data/rate.csv"
