# Note that the httpuv library also needed to
# be installed for a successful run.
library(httr)

get.url = function(d1, d2, keyword, language) {
  url =
    sprintf(
      "https://api.github.com/search/repositories?q=%s+language:%s+created:%s..%s",
      URLencode(keyword, reserved = TRUE),
      URLencode(language, reserved = TRUE),
      d1,
      d2
    )
  return(url)
}

get.count = function(d1, d2, keyword, language, gtoken) {
  http.error.status.base = 400
  http.error.status.too.many.reqs = 403
  
  url = get.url(d1, d2, keyword, language)
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
  
  return(content(req)$total_count)
}

#' Download keyword-specific statistics from GitHub
#'
#' An intermediate storage of cache files is created to reduce data loss
#' when it is re-run after a crash.
#'
#' @param searches Vector or list of the keywords to get stats for
#' @param row.cache.filename.fmt Path/pattern to use for cache files
#' @param output.file Path to the target .RData file receving the statistics
scrape = function(searches,
                  row.cache.filename.fmt,
                  output.file) {

  # from the GitHub oauth 2.0 demo of httr
  oauth_endpoints("github")
  myapp <- oauth_app("github",
                     key = "58de786e774abc09f6c7",
                     secret = "8f1e9618afe09676ccd74fb20bed6394b49a85e6")
  github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
  gtoken <- config(token = github_token)
  
  start.date = as.Date("2008-01-01")
  n.periods = 52 * 9 + 14 # up to 2017-03-27
  
  results = list()
  
  for (keyword in names(searches)) {
    results[[keyword]] = list()
    
    for (language in searches[[keyword]]) {
      print(sprintf("keyword: %s language: %s", keyword, language))
      
      row.cache.filename = sprintf(row.cache.filename.fmt,  keyword, language)
      
      if (file.exists(row.cache.filename)) {
        df = read.csv(row.cache.filename)
        counts = df$values
      } else {
        counts = c()
      }
      
      print("-- detecting empty preceding periods --")
      
      zero.periods.detected = n.periods
      while (zero.periods.detected > length(counts)) {
        count = get.count(start.date, start.date + zero.periods.detected * 7 - 1, 
                          keyword, language, gtoken)
        if (count > 0) {
          zero.periods.detected = zero.periods.detected %/% 2
        }
        else {
          break
        }
      }
      
      print(sprintf("-- finished, %d periods found --", zero.periods.detected))

      if (zero.periods.detected > length(counts)) {
        counts = c(counts, rep(0, zero.periods.detected - length(counts)))
      }

      if (length(counts) < n.periods) {
        for (i in length(counts):(n.periods - 1)) {
          d1 = start.date + i * 7
          d2 = d1 + 6
          
          count = get.count(d1, d2, keyword, language, gtoken)
          print(count)
          
          counts[i + 1] = count
          
          if (i %% 52 == 51)
            write.csv(data.frame(values = counts), file = row.cache.filename)
        }
      }
      counts = counts[1:n.periods]
      write.csv(data.frame(values = counts), file = row.cache.filename)
      
      results[[keyword]][[language]] = counts
      # allow to have a peek on the intermediate results
      save(file = output.file, results)
    }
  }
}
