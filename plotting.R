# setwd("/media/janca/Code/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")

start.date = as.Date("2008-01-01")

get.color.table = function(results) {
  
  all.cols = c(
    "blue",   
    "darkgreen",
    "green",
    "purple",
    "dodgerblue3",
    "brown",   
    "orange",
    "black",
    "yellow",
    "red",      
    "lightblue3",
    "lightgoldenrod3",
    "ivory3",
    "ivory4",
    "greenyellow",
    "green3"
  )
  
  all.names = list()
  
  # happily abusing a list as a set :)
  for(result in results) {
    for(name in names(result)) {
      if (is.null(all.names[[name]])) {
        all.names[[name]] = NA        
      }
    }
  }
  
  # Returns a list, functioning as a name -> col assignment
  l = as.list(all.cols)[1:length(all.names)]
  names(l) <- names(all.names)
  return(l)
}

get.filtered.data = function(raw.values, max.radius) {
  # return a list(value=, width=) structure
  
  filters = c()
  
  output.length = max(length(raw.values) - max.radius * 2, 0)
  values = rep(NA, output.length)
  widths  = rep(NA, output.length)
  
  l = length(raw.values)
  a = 1
  
  # this is probably hugely inefficient :)
  # not caring about it just feels so good.
  # yes, the middle chunk could be still done with kernapply()
  for (i in 1:length(raw.values)) {
    r = min(i - 1, length(raw.values) - i, max.radius)
    if (r > length(filters)) {
      filters[[r]] = kernel("daniell", r)
    }
    
    if (r > 0) {
      values[[a]] = kernapply(raw.values[(i - r):(i + r)], filters[[r]])
    } else {
      values[[a]] = raw.values[i]
    }
    widths[[a]] = 2 * r + 1
    a = a + 1
  }
  
  return(list(values = values, widths = widths))
}

plot.smooth.edges = function(xs, values, weights, cols) {
  max.weight = max(weights)
  uncertain.filter = weights != max.weight
  # include those point(s) from which a section will need to be drawn
  # to an uncertain (visually: alpha blent) point
  uncertain.filter = uncertain.filter | c(uncertain.filter[-1], TRUE)
  
  uncertain.left.idxs = (1:length(uncertain.filter))[uncertain.filter]

  for(i in 1:length(values)) {
    v = values[[names(values)[i]]]
    for(j in 1:(length(uncertain.left.idxs) - 1)) {
      x.idx.l = uncertain.left.idxs[j]
      x.idx.r = uncertain.left.idxs[j + 1]
      if (x.idx.l == (x.idx.r - 1)) {
        weight = (weights[x.idx.l] + weights[x.idx.r]) / 2 / max.weight
        crgb = col2rgb(cols[i]) / 255
        col = rgb(crgb[1], crgb[2], crgb[3], weight)
        lines(c(xs[x.idx.l], xs[x.idx.r]), c(v[x.idx.l], v[x.idx.r]), col = col)
      }
    }
  }
}

plot.perc.of.total = function(series.list, col) {
  agg.series = lapply(
    series.list,
    FUN = function(row) {
      time = rep(1:((length(row) + 11) / 12), each = 12)
      time = time[1:length(row)]
      return(aggregate(row, by = list(time = time),
                       FUN = mean)$x)
    }
  )
  
  agg.matrix = do.call(rbind, agg.series)
  period.totals = apply(agg.matrix, MARGIN = 2, FUN = sum)
  period.totals[period.totals == 0] = 1
  agg.matrix = agg.matrix / rep(period.totals, each = nrow(agg.matrix)) * 100
  
  barplot(
    agg.matrix,
    col = col,
    border = 0,
    space = 0,
    main = "Breakdown by Share (%)",
    las = 2
  )
}

smooth.plot = function(raw.values, main, format.type = "GitHub") {
  # format.type: one of "GitHub" and "SO" (for StackOverflow)

  format.types = 
    list(GitHub = "'%s' Repositories\nCreated on GitHub per Year (Est.)",
         SO = "'%s' Questions\non StackOverflow per Year (Est.)")
  if (sum(format.type == names(format.types)) == 0)
    stop("Unknown chart format type")
  
  main.format = format.types[[format.type]]

  par(mfrow = c(2, 1))
  
  layout(mat = matrix(nrow = 1, data = c(1, 2)), widths = c(3, 2))
  
  # TODO: possibly sort the series in a definite order
  
  # ensure consistent coloring across charts
  cols = as.character(color.table[names(raw.values)])

  values = list()
  weights = list()
  
  # a max. 53 period wide moving average is used, 
  # close to a yearly basis, which is relatively robust 
  # against seasonality based fluctuations in the middle
  # section
  for(name in names(raw.values)) {
    filtered = get.filtered.data(raw.values[[name]], 26)
    values[[name]] = filtered$value * 365 / 7
    weights[[name]] = filtered$width
  }
  
  weights = weights[[names(raw.values)[1]]]
  max.weight = max(weights)

  ymax = max(unlist(sapply(values, max)))
  ymin = min(unlist(sapply(values, min)))

  certain.filter = weights == max.weight

  # paint everything with less than max. weight in
  # a second pass
  xs = start.date + 0:(length(values[[1]]) - 1) * 7
  certain.xs = xs[certain.filter]
  mtx.values = do.call(cbind, values)[certain.filter, ]
  
  matplot(certain.xs,
          mtx.values,
          type="l",
          xlim = c(min(xs), max(xs)),
          ylim=c(ymin, ymax), 
          ylab="", xlab="", xaxt="n",
          main=sprintf(main.format, main),
          col=cols, lty=1, las=2, bty="n")
  
  plot.smooth.edges(xs = xs, values = values, weights = weights, cols = cols)

  xs = c(as.Date(c("2008-01-01", "2009-01-01", "2010-01-01", "2011-01-01", "2012-01-01", 
                   "2013-01-01", "2014-01-01", "2015-01-01", "2016-01-01", "2017-01-01")))
  timelabels=format(xs, "%Y-%m")
  axis(1, at=xs, labels=timelabels, las=2, xlim=c(min(xs), max(xs)))
  legend(xs[1], max(do.call(c, values)), legend=rev(names(values)), col=rev(cols), bty="n",
         lwd=2, lty=1)
  
  # plot.perc.of.total(mx.values, cols, xs, timelabels)
  plot.perc.of.total(series.list = raw.values, cols)
}

double.plot = function(github.raw.values, SO.raw.values, main) {
  smooth.plot(github.raw.values, main, "GitHub")
  smooth.plot(SO.raw.values, main, "SO")
}
