# Keyword Trends

Stuff for having a look at GitHub and StackOverflow trends.

You can check out the main report rendered as a markdown document over here:
[Picking a Language for Analytics and Machine Learning](https://github.com/brezniczky/github-trends/blob/master/analysis.md)

This is a guide in a few charts and comments towards picking your first analytics language.
The conclusion is Python, however it is not a definitive answer and the reasoning isn't 100% either, yet appears correct.
This is not a guide to the "best language for analytics", although is close enough.

The foster child in its infancy is here:
[Picking a Language for Server-Side Programming ](https://github.com/brezniczky/github-trends/blob/master/analysis_server.md)

This one is barely a series of charts.

### Required packages

The plotting requires gridBase and [ggplot2](http://ggplot2.org/).

The data collection depends on the httr and httuv libraries.

From an absolute zero, just issue:

```
install.packages(c("ggplot2", "httr", "httuv", "gridBase"))
```

### Legal

Copyright (c) 2017 Janos Brezniczky

('cause why not)

Otherwise licensed under AGPL v3.0.
See the [license](LICENSE.md) for details.

(same reason)

### Thanks

Too many items from StackOverflow answers have been consulted with to 
mention just quickly, mainly for the plotting adjustments. Thanks!

