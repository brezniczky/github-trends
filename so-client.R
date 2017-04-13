# TODO: save all responses in perhaps a database or JSON
#       for later semantic analysis
# TODO: sparse scraping

# stackr::stack_questions() does not seem to support 
# by label & body text filtering, so left with querying
# the StackExchange API in a more generic way

# StackOverflow has at least a one second granualarity
# for specifying time ranges, therefore 
library(httr)

source("generic-client.R")

get.SO.question.count = function(fromdate, todate, body, tagged, app.key, num.retries = 3, stop.on.paging = FALSE) {
  # url = 
  #   'http://api.stackexchange.com/2.2/search/advanced?' +
  #   'fromdate=1483228800&todate=1483660800&order=desc&' +
  #   'sort=activity&body=aws&tagged=python&site=stackoverflow&key=e7vMoB4rv7qyegz6yaH3QA(('

  fromdate.secs = as.integer(fromdate) * 60 * 60 * 24
  # the last second is left off so that the intervals are completely covered
  # and do not overlap
  todate.secs = as.integer(todate) * 60 * 60 * 24 - 1
  
  tagged = URLencode(tagged, reserved = TRUE)
  body = URLencode(body, reserved = TRUE)

  has_more = FALSE

  page.index = 1
  ans = 0
  while ((page.index == 1) || has_more) {
    url = 
      sprintf( 
        'http://api.stackexchange.com/2.2/search/advanced?fromdate=%d&todate=%d&order=desc&sort=activity&body=%s&tagged=%s&site=stackoverflow&key=%s&pagesize=100&page=%d',
         fromdate.secs, todate.secs, body, tagged, app.key, page.index
      )
    
    print(url)

    retry(
      {
        # do not make more than 30 requests per second
        Sys.sleep(2.5)
        req = GET(url) 
  
        if (req$status_code != 200) {
          Sys.sleep(18)
          stop(sprintf("http status of %d received", req$status_code))
        }
      }, 
      times = num.retries)
    
    # for crash recovery
    dbg.last.req <<- req
  
    backoff = req$backoff
    if (!is.null(backoff)) {
      print(sprintf("backoff requested: waiting %d seconds", backoff))
      Sys.sleep(backoff - 2)
    }

    co.req = content(req)
    has_more = co.req$has_more

    ans = ans + length(co.req$items)
    print(ans)
    
    if (stop.on.paging && has_more) {
      attr(ans, "has_more") = TRUE
      return(ans)
    }
    
    page.index = page.index + 1
    if (has_more) {
      print(sprintf("stepping to page %d", page.index))
    }
  }

  attr(ans, "has_more") = FALSE
  return(ans)
}

get.SO.question.counts = function(fromdates, todates,
                                  body, tagged, app.key, retries = 3) {
  
  if (length(todates) != length(fromdates))
    stop("fromdates and todates are not of equal length")

  # avoid getting the overall count if it takes multiple steps -
  # will be typically inefficient in the longer run as activity
  # is likely to increase
  total.count = get.SO.question.count(fromdates[1], tail(todates, 1),
                                      body, tagged, app.key, 
                                      retries, stop.on.paging = TRUE)

  if (total.count > 0) {
    ans = rep(NA, length(fromdates))
    
    if (attr(total.count, "has_more")) {
      # the total was not obtained
      start.i = 1
    } else {
      start.i = 2
    }

    if (length(todates) >= start.i) {
      for(i in start.i:length(fromdates)) {
        count =  get.SO.question.count(fromdates[i], todates[i],
                                       body, tagged, app.key,
                                       retries)
        ans[i] = count
      }
    }
    
    if (start.i == 2) {
      ans[1] = total.count - sum(ans[-1])
    }
    
  } else {
    ans = rep(0, length(fromdates))
  }
  attr(ans, "has_more") = attr(total.count, "has_more")
  return(ans)
}

so.scrape = function(searches,
                     row.cache.filename.fmt,
                     output.file,
                     app.key) { 

  start.date = as.Date("2008-01-01")
  n.periods = 52 * 9 + 14 # up to 2017-004-03
  http.error.status.base = 400
  http.error.status.too.many.reqs = 403

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
      
      # try to skip the first few years containing all zeroes (frequent case)
      nweeks = 52 * 7
      if (length(counts) < nweeks) {
        while(nweeks > length(counts)) {
          first.nweeks.scrape = 
            get.SO.question.count(start.date, as.Date(7 * nweeks - 1 + start.date), 
                                  keyword, language, app.key, stop.on.paging = TRUE)
          if (first.nweeks.scrape == 0) {
            print(sprintf("first %d weeks are 0", nweeks))
            # TODO: pad nicely, thoughtfully etc.
            while (length(counts) < nweeks) {
              counts = c(counts, 0)
            }
            break
          }
          else {
            nweeks = nweeks - 52
          }
        }
      }
      
      if (length(counts) < n.periods) { # cached data may lean beyond
        next.cache = 9 * (length(counts) %/% 9) + n.periods %% 9
        try.more = TRUE
 
        while(length(counts) < n.periods) {
          i = length(counts)
          d1 = start.date + i * 7
          
          if (((i + 4) <= n.periods) && try.more) {
            d1 = d1 + 7 * (0:3)
            d2 = d1 + 7
            print(sprintf("scraping from %s to %s", head(d1), tail(d2)))
            new.counts =
              get.SO.question.counts(d1, d2, keyword, language, app.key)
            counts = c(counts, new.counts)
            if (attr(new.counts, "has_more")) {
              try.more = FALSE
            }
          } else {
            d2 = d1 + 6
            print(sprintf("scraping from %s to %s", d1, d2))
            count = get.SO.question.count(d1, d2, keyword, language, app.key)
            print(count)
            counts[i + 1] = count
          }

          if (length(counts) >= next.cache) {
            write.csv(data.frame(values = counts), file = row.cache.filename)
            next.cache = next.cache + 9
          }
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

test = function() {
  ns = 
    get.SO.question.counts(
      c(as.Date("2015-01-01"), as.Date("2015-01-07")),
      c(as.Date("2015-01-07"), as.Date("2015-01-14")),
      body = "Analysis",
      tagged = "Python",
      app.key = "e7vMoB4rv7qyegz6yaH3QA(("
    )
  
  n1 =
    get.SO.question.count(
      as.Date("2015-01-01"), 
      as.Date("2015-01-07"), 
      body = "Analysis",
      tagged = "Python",
      app.key = "e7vMoB4rv7qyegz6yaH3QA(("
    )
  
  n2 = 
    get.SO.question.count(
      as.Date("2015-01-07"), 
      as.Date("2015-01-14"), 
      body = "Analysis",
      tagged = "Python",
      app.key = "e7vMoB4rv7qyegz6yaH3QA(("
    )
  
  if ((n1 != ns[1]) || (n2 != ns[2])) {
    stop("values do not add up")
  }
}
