# setwd("/media/janca/Code/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")
source("so-client.R")

row.cache.filename.fmt = "intermediate/SO %s %s created weekly.csv"

output.file = "intermediate/SO_results.RData"

searches =
  list(
    "Machine Learning" = c("Python", "Java", "R", "C#"), # added C#! 
    Analysis = c("R", "Python", "Java", "R", "C#"),  # added C#!
    Spark = c("Python", "Java", "Scala", "R"), # no c#
    "Deep Learning" = c("C++", "Java", "MatLab", "Python", "R", "C#"),   # added C#!
    "Big Data" = c("Python", "Java", "R", "Scala", "C#"),
    "Kaggle" = c("Python", "R", "Matlab", "Java"), # no C#
    "Data Science" = c("Python", "R", "Jupyter Notebook", "C#"), # added C#!
       # pending "Java", "C++", "TeX", "go", 
    # "Data" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go", "C#"), # added C#!
    # "Science" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go", "C#"), # added C#!
    "AWS" = c("JavaScript", "Python", "Ruby", "Java", "PHP", "go", "C#"), # added C#!
    # # "Coursera" = c(
    # #   "HTML",
    # #   "R",
    # #   "CSS",
    # #   "JavaScript",
    # #   "Matlab",
    # #   "Java",
    # #   "Python",
    # #   "Scala",
    # #   "Jupyter Notebook",
    # #   "Ruby"
    # # )
    "Mining" = c("Python", "Java", "R", "JavaScript", "Jupyter Notebook", "HTML", "C++", "C#"),
    "Visualization" = c("JavaScript", "Python", "HTML", "Java", "C++", "R", "CSS", "Jupyter Notebook"),
    "Chart" = c("JavaScript", "Java", "HTML", "Python", "ColdFusion", "PHP", "Ruby", "Objective-C", "CSS", "C#", "R")
  )


so.scrape(searches = searches,
          row.cache.filename.fmt = row.cache.filename.fmt,
          output.file = output.file,
          app.key = "e7vMoB4rv7qyegz6yaH3QA((")
