retry = function(expr, times) {
  
  retried = 0
  
  expr = substitute(expr)
  
  while (retried < times) {
    tryCatch({
      eval(expr, envir = parent.frame())
      break
    },
    error = function(e) {
      retried <<- retried + 1
      if (retried < times) {
        print(e)
        print("retrying ...")
      } else {
        stop(e)
      }
    })
  }
}

