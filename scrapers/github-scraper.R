# setwd("/media/janca/Code/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")
source("utils/github-client.R")

row.cache.filename.fmt = "intermediate/%s %s created weekly.csv"

output.file = "intermediate/results.RData"

searches =
  list(
    "Machine Learning" = c("Python", "Java", "R"),
    Analysis = c("R", "Python", "Java"),
    Spark = c("Python", "Java", "Scala"),
    "Deep Learning" = c("C++", "Java", "MatLab", "Python"),
    "Big Data" = c("Python", "Java", "R", "Scala"),
    "Kaggle" = c("Python", "R", "Matlab", "Java"),
    "Data Science" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go"),
    "Data" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go"),
    "Science" = c("Python", "R", "Jupyter Notebook", "Java", "C++", "TeX", "go"),
    "AWS" = c("JavaScript", "Python", "Ruby", "Java", "PHP", "go"),
    "Coursera" = c(
      "HTML",
      "R",
      "CSS",
      "JavaScript",
      "Matlab",
      "Java",
      "Python",
      "Scala",
      "Jupyter Notebook",
      "Ruby"
    ),
    "Mining" = c("Python", "Java", "R", "JavaScript", "Jupyter Notebook", "HTML", "C++", "C#"),
    "Visualization" = c("JavaScript", "Python", "HTML", "Java", "C++", "R", "CSS", "Jupyter Notebook"),
    "Chart" = c("JavaScript", "Java", "HTML", "Python", "ColdFusion", "PHP", "Ruby", "Objective-C", "CSS", "C#", "R")
  )

scrape(
  searches = searches,
  row.cache.filename.fmt = row.cache.filename.fmt,
  output.file = output.file
)
