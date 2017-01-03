source("github-client.R")

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
    )
  )

scrape(
  searches = searches,
  row.cache.filename = row.cache.filename,
  output.file = output.file
)
