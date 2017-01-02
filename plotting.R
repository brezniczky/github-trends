all.cols = c("blue", "darkgreen", "green", "purple", "red", "brown", "orange", "black", "yellow")

# do not forget the k-filter's radius
start.date = as.Date("2008-01-01") + 22 * 7


plot.perc.of.total = function(series.list, col) {
  agg.series = lapply(
    series.list, FUN = function(row) {
      time = rep(1:((length(row) + 11) / 12), each=12)
      time = time[1:length(row)]
      return(aggregate(row, by = list(time = time),
                       FUN = mean)$x)
    }
  )
  
  agg.matrix = do.call(rbind, agg.series)
  period.totals = apply(agg.matrix, MARGIN = 2, FUN = sum)
  period.totals[period.totals == 0] = 1
  agg.matrix = agg.matrix / rep(period.totals, each = nrow(agg.matrix)) * 100

  barplot(agg.matrix, 
          col = col, border = 0, space = 0,
          main = "Breakdown by share (%)")
}

smooth.plot = function(raw.values, main) {
  par(mfrow = c(2, 1))
  
  layout(mat = matrix(nrow = 1, data = c(1, 2)), widths = c(3, 2))
  
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

  # TODO: this colour preference assignment needs to be thought through  
  n = names(raw.values)
  n = move.to(n, "Python", 1)
  n = move.to(n, "R", 2)
  n = move.to(n, "Java", 3)
  n = move.to(n, "C#", 4)
  n = move.to(n, "go", 5)
  # sometimes there are fewer/not all of them are present
  # remove wrongly inserted empty cells
  n = n[!is.na(n)]
  
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
          main=sprintf("'%s' repositories\ncreated on GitHub per year (est.)", main),
          # legend=rownames(values),
          # beside=TRUE,
          # args.legend=(x=ncol(counts) + 3),
          col=cols, lty=1, las=2, bty="n")
  xs = c(as.Date(c("2008-06-15", "2009-06-15", "2010-06-15", "2011-06-15", "2012-06-15", "2013-06-15", "2014-06-15", "2015-06-15", "2016-06-15")))
  timelabels=format(xs, "%Y-%m")
  axis(1, at=xs, labels=timelabels, las=2, xlim=c(min(xs), max(xs)))
  legend(xs[1], max(do.call(c, values)), legend=names(values), col=cols, bty="n",
         lwd=2, lty=1)
  
  # plot.perc.of.total(mx.values, cols, xs, timelabels)
  plot.perc.of.total(series.list = raw.values, cols)
}
