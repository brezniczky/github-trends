# setwd("/media/janca/Code/Prog/Github Analysis/analytics-and-hadoop-trends/github-trends/")

library(ggplot2)
library(grid)
library(gridBase)

start.date = as.Date("2008-01-01")

get.all.names = function(results) {
  all.names = list()
  
  # happily abusing a list as a set :)
  for(result in results) {
    for(name in names(result)) {
      if (is.null(all.names[[name]])) {
        all.names[[name]] = NA
      }
    }
  }
  
  return(names(all.names))
}

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
    "green3",
    "slateblue4",
    "violetred3",
    "cyan",
    "peachpuff3"
  )
  
  # Returns a list, functioning as a name -> col assignment
  all.names = get.all.names(results)
  l = as.list(all.cols)[1:length(all.names)]
  names(l) <- all.names
  return(l)
}

get.series.order = function(results) {
  # create an alphabetic ordering
  # apart from R: first and Python: last
  
  all.names = get.all.names(results)
  all.names = all.names[!all.names %in% c("R", "Python")]
  return(c("R", all.names, "Python"))
}

sort.to = function(new.index, list.of.values) {
  ans = list.of.values[new.index]
  # TODO: I'm surely ignoring something here
  ans = ans[!is.na(names(ans))]
  return(ans)
}

test.sort.to = function() {
  ni = 1:5
  act.values = list(`1` = 3, `2` = 4, `4` = 16)
  sorted = sort.to(new.index = ni, list.of.values = act.values)
  if (!identical(as.numeric(sorted), c(3, 4, 16))) {
    stop("sort failed")
  }
}

test.sort.to()

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

plot.stacked = function(series.list, col) {
  n.days = length(series.list[[1]])
  n.series = length(series.list)
  time = as.Date("2008-01-01") + (0:(n.days - 1)) * 7
  time = rep(time, each = length(series.list))
  
  type = factor(names(series.list), levels = names(series.list), ordered = TRUE)
  type = rep(type, n.days)
  
  series.mat = do.call(rbind, series.list)
  value = as.vector(series.mat)
  
  col = rep(rev(col), n.days)
  
  xs = c(as.Date(c("2008-01-01", "2009-01-01", "2010-01-01", "2011-01-01", "2012-01-01", 
                   "2013-01-01", "2014-01-01", "2015-01-01", "2016-01-01", "2017-01-01")))
  
  p =
    ggplot(data.frame(time, type, value), aes(time, value)) +
    geom_area(aes(fill = type)) + scale_fill_manual(values = col) +
    # white background
    theme_bw() +
    theme(axis.line = element_line(colour = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank(),
          panel.background = element_blank()) +
    scale_x_date(date_labels = "%Y-%m", breaks = xs) +
    theme(axis.text.x = element_text(vjust = 0.5, size = 13,
                                     lineheight = 0.8, angle = 90)) +
    theme(axis.text.y = element_text(size=13, lineheight = 0.8)) +
    theme(legend.position="none") +
    ggtitle("Breakdown by Share (%)") +
    theme(
      plot.title = element_text(lineheight = .8, face = "bold", hjust = 0.5)) +
    ylab("") + xlab("")

  plot.new()
  vps = baseViewports()
  pushViewport(vps$figure)
  vp1 = plotViewport(c(0, 1, 2, 1))
  print(p, vp = vp1)
}

plot.perc.of.total = function(series.list, col) {
  sums = apply(do.call(rbind, series.list), MARGIN = 2, FUN = sum)
  sums[sums == 0] = 1
  for(name in names(series.list))
    series.list[[name]] = series.list[[name]] / sums * 100

  plot.stacked(series.list, col)
}

smooth.plot = function(raw.values, main, format.type = "GitHub") {
  # format.type: one of "GitHub" and "SO" (for StackOverflow)
  #
  # assumes: the color.table and series.order variables are set 
  #          in the parent environment

  format.types = 
    list(GitHub = "'%s' Repositories\nCreated on GitHub per Year (Est.)",
         SO = "'%s' Questions\non StackOverflow per Year (Est.)")
  if (sum(format.type == names(format.types)) == 0)
    stop("Unknown chart format type")
  
  main.format = format.types[[format.type]]

  raw.values = sort.to(new.index = series.order, 
                       list.of.values = raw.values)
  
  par(mfrow = c(2, 1))
  
  layout(mat = matrix(nrow = 1, data = c(2, 1)), widths = c(2, 3))
  
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
  
  par(mar=c(5, 0.5, 5, 5))
  matplot(certain.xs,
          mtx.values,
          type = "l",
          xlim = c(min(xs), max(xs)),
          ylim = c(ymin, ymax),
          ylab = "", xlab = "", xaxt = "n", yaxt = "n",
          main = sprintf(main.format, main),
          col = cols, lty = 1, las = 2, bty = "n")
  
  plot.smooth.edges(xs = xs, values = values, weights = weights, cols = cols)

  axis(4, las=2, pos = max(xs) + 1) #labels=timelabels) #las=2, xlim=c(min(xs), max(xs)))
  
  xs = c(as.Date(c("2008-01-01", "2009-01-01", "2010-01-01", "2011-01-01", "2012-01-01", 
                   "2013-01-01", "2014-01-01", "2015-01-01", "2016-01-01", "2017-01-01")))
  timelabels=format(xs, "%Y-%m")
  axis(1, at=xs, labels=timelabels, las=2, xlim=c(min(xs), max(xs)))
  legend(xs[1], max(do.call(c, values)), legend = rev(names(values)),
         col = rev(cols), bty = "n", lwd = 2, lty = 1)
  
  plot.perc.of.total(series.list = rev(values), cols)
}

double.plot = function(github.raw.values, SO.raw.values, main) {
  smooth.plot(github.raw.values, main, "GitHub")
  smooth.plot(SO.raw.values, main, "SO")
}
