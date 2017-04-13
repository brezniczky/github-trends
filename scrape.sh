#!/bin/bash

# TODO: get these running (so and github scraping) in parallel

Rscript scrapers/so-scraper.R
Rscript scrapers/so-scraper-server.R
Rscript scrapers/github-scraper.R
Rscript scrapers/github-scraper-server.R
