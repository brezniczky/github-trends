all.cols = c("blue", "darkgreen", "yellow", "red", "purple", "orange")

# do not forget the k-filter's radius
start.date = as.Date("2008-01-01") + 22 * 7

smooth.plot = function(raw.values, main) {
  # 53 wide kernel filter is used, close enough to
  # a yearly basis, which is relatively robust against
  # seasonality based fluctuations
  k1 = kernel("daniell", 26)
  
  # keep recurring items at well-defined locations to
  # enhance readability and colour coding based consistency
  move.to = function(n, item, target.idx) {
    idx = which(n == item)
    if (length(idx) > 0) {
      n[idx] = n[target.idx]
      n[target.idx] = item
    }
    return(n)
  }
  
  n = names(raw.values)
  n = move.to(n, "Python", 1)
  n = move.to(n, "R", 2)
  n = move.to(n, "Java", 3)
  raw.values = raw.values[n]
  
  values = list()
  for(name in names(raw.values)) {
    values[[name]] = 52 * kernapply(raw.values[[name]], k1)
  }
  
  ymax = max(unlist(sapply(values, max)))
  ymin = min(unlist(sapply(values, min)))
  
  xs = start.date + 0:(length(values[[1]]) - 1) * 7
  mx.values = do.call(cbind, values)
  cols = all.cols[1:ncol(mx.values)]
  matplot(xs,
          mx.values, ylim=c(ymin, ymax), type="l",
          ylab="", xlab="", xaxt="n",
          main=sprintf("'%s' repositories created on GitHub per year (est.)", main),
          # legend=rownames(values),
          # beside=TRUE,
          # args.legend=(x=ncol(counts) + 3),
          col=cols, lty=1, las=2, bty="n")
  # xs = xs[1 + round((0 : 7) * (length(xs) - 1) / 7)]
  xs = c(as.Date(c("2008-06-15", "2009-06-15", "2010-06-15", "2011-06-15", "2012-06-15", "2013-06-15", "2014-06-15", "2015-06-15", "2016-06-15")))
  timelabels=format(xs,"%Y-%m")  #%H:%M
  axis(1, at=xs, labels=timelabels, las=2, xlim=c(min(xs), max(xs)))
  legend(xs[1] - 100, max(do.call(c, values)), legend=names(values), col=cols, bty="n",
         lwd=2, lty=1)
}
