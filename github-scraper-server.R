# setwd("/media/janca/Code1/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")
source("utils/github-client.R")

row.cache.filename.fmt = "intermediate_server/%s %s created weekly.csv"

output.file = "intermediate_server/results.RData"

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
    "Cloud"      = all.languages,
    "Serverless" = c("JavaScript", "C#", "Python", "SQL", "Java")
  )

scrape(
  searches = searches,
  row.cache.filename.fmt = row.cache.filename.fmt,
  output.file = output.file
)
