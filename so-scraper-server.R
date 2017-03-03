# setwd("/media/janca/Code/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")
source("so-client.R")

row.cache.filename.fmt = "intermediate_server/SO %s %s created weekly.csv"

output.file = "intermediate_server/SO_results.RData"

all.languages = c("Python",
                  "go",
                  "C",
                  "C++",
                  "C#",
                  "Java",
                  "PHP",
                  "Ruby",
                  "JavaScript")

searches =
  list(
    Server       = all.languages,
    Microservice = all.languages,
    Service      = all.languages,
    "Web Server" = all.languages,
    "Cloud"      = all.languages
  )


so.scrape(searches = searches,
          row.cache.filename.fmt = row.cache.filename.fmt,
          output.file = output.file,
          app.key = "e7vMoB4rv7qyegz6yaH3QA((")

