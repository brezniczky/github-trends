# Note that the httpuv library also needed to 
# be installed for a successful run.
library(httr)

# from the GitHub oauth 2.0 demo of httr
oauth_endpoints("github")
myapp <- oauth_app("github",
                   key = "58de786e774abc09f6c7",
                   secret = "8f1e9618afe09676ccd74fb20bed6394b49a85e6")
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
gtoken <- config(token = github_token)

searches =
  list(
    "Machine Learning" = c("Python", "Java", "R"),
    Analysis = c("R", "Python", "Java"),
    Spark = c("Python", "Java", "Scala"),
    "Deep Learning" = c("C++", "Java", "MatLab", "Python"),
    "Big Data" = c("Python", "Java", "R", "Scala")
  )

start.date = as.Date("2008-01-01")
n.periods = 52 * 9
http.error.status.base = 400
http.error.status.too.many.reqs = 403

results = list()

for(keyword in names(searches)) {
  results[[keyword]] = list()
  
  for(language in searches[[keyword]]) {

    print(sprintf("keyword: %s language: %s", keyword, language))

    row.cache.filename = sprintf("%s %s created weekly.csv",  keyword, language)

    if (file.exists(row.cache.filename)) {
      df = read.csv(row.cache.filename)
      counts = df$values
    } else {
      counts = c()
    }

    if (length(counts) <= n.periods) { 
      for(i in length(counts):n.periods) {
        d1 = start.date + i * 7
        d2 = d1 + 6
        url = 
          sprintf(
            "https://api.github.com/search/repositories?q=%s+language:%s+created:%s..%s",
            URLencode(keyword), URLencode(language), d1, d2)
        print(url)
        repeat {
          Sys.sleep(1)
          req <- GET(url, gtoken)
          if (req$status_code != http.error.status.too.many.reqs) {
            if (req$status_code >= http.error.status.base)
              stop("bad status code, request:", content(req))
            else
              break
          }
          print("retrying...")
        }
        count = content(req)$total_count
        print(count)
        counts[i + 1] = count
  
        if (i %% 52 == 51)
          write.csv(data.frame(values = counts), file=row.cache.filename)
      }
    }

    results[[keyword]][[language]] = counts
  }
}
save(file="intermediate/results.RData", results)
