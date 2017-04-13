# setwd("/media/janca/Code/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")
source("utils/so-client.R")

row.cache.filename.fmt = "intermediate/SO %s %s created weekly.csv"

output.file = "intermediate/SO_results.RData"

searches =
  list(
    "Machine Learning" = c("Python", "Java", "R", "C#", "SQL"), # added C#! 
    Analysis = c("R", "Python", "Java", "R", "C#", "SQL"),  # added C#!
    Spark = c("Python", "Java", "Scala", "R", "SQL"), # no c#
    "Deep Learning" = c("C++", "Java", "MatLab", "Python", "R", "C#", "SQL"),   # added C#!
    "Big Data" = c("Python", "Java", "R", "Scala", "C#", "SQL"),
    "Kaggle" = c("Python", "R", "Matlab", "Java", "SQL"), # no C#
    "Data Science" = c("Python", "R", "Jupyter Notebook", "C#", "SQL"), # added C#!
       # pending "Java", "C++", "TeX", "go", 
    # "Data" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go", "C#", "SQL"), # added C#!
    # "Science" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go", "C#", "SQL"), # added C#!
    "AWS" = c("JavaScript", "Python", "Ruby", "Java", "PHP", "go", "C#", "SQL"), # added C#!
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
    "Mining" = c("Python", "Java", "R", "JavaScript", "Jupyter Notebook", "HTML", "C++", "C#", "SQL"),
    "Visualization" = c("JavaScript", "Python", "HTML", "Java", "C++", "R", "CSS", "Jupyter Notebook", "SQL"),
    "Chart" = c("JavaScript", "Java", "HTML", "Python", "ColdFusion", "PHP", "Ruby", "Objective-C", "CSS", "C#", "R", "SQL")
  )


so.scrape(searches = searches,
          row.cache.filename.fmt = row.cache.filename.fmt,
          output.file = output.file,
          app.key = "e7vMoB4rv7qyegz6yaH3QA((")
