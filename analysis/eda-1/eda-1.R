rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr)
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(scales)    # format
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(ggalluvial)
library(janitor)  # tidy data
library(testit)   # For asserting conditions meet expected patterns.

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./analysis/eda-1/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/eda-1/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------
# base::source(paste0(local_root,"local-functions.R")) # project-level

# ---- load-data ---------------------------------------------------------------


library(readr)
ds_pub_count <-
  read_csv("data-private/derived/manipulation/csv/k_t_vidan.csv") %>% 
  # each xYYYY column must be an integer
  rename(measure = x) %>% 
  mutate(across(starts_with("x"), ~ as.integer(.))) 

# ---- tweak-data-0 -------------------------------------
# ds_pub_count %>% glimpse(0)
# row 1 contains the total count unique titles
# row 2 contains the total number of books published
# rows 3-28 contain counts of copies published by genre
# row 29-80 contains total counts by oblast
# rows 81-108 contains total copies published by publisher type
# now let's tidy this data and create four serparate tibbles
# 1. ds_totals - total coutns (rows 1-2)
# 2. ds_genre - counts by genre (rows 3-28)
# 3. ds_oblast - counts by oblast (rows 29-80)
# 4. ds_publisher - counts by publisher type (rows 81-108)
ds_totals <- ds_pub_count %>%
  slice(1:2) %>%
  pivot_longer(cols = -c(1), names_to = "year", values_to = "count") %>%
  mutate(year = str_remove(year, "x") %>% as.integer())
ds_totals %>% glimpse()
 
ds_genre <- ds_pub_count %>%
  slice(3:28) %>%
  pivot_longer(cols = -c(1), names_to = "year", values_to = "count") %>%
  mutate(year = str_remove(year, "x") %>% as.integer())
ds_genre %>% glimpse()

ds_oblast <- ds_pub_count %>%
  slice(29:80) %>%
  pivot_longer(cols = -c(1), names_to = "year", values_to = "count") %>%
  mutate(year = str_remove(year, "x") %>% as.integer())
ds_oblast %>% glimpse()

ds_publisher_type <- ds_pub_count %>%
  slice(81:108) %>%
  pivot_longer(cols = -c(1), names_to = "year", values_to = "count") %>%
  mutate(year = str_remove(year, "x") %>% as.integer())
ds_publisher %>% glimpse()

# we now have four tabless, each offerring a different breakdown:
# total, genre, oblast, and publisher type
# ---- inspect-data-2 -------------------------------------

# ---- analysis-below -------------------------------------

# ----- g1-total-counts ------------------------------------------------
g1 <- 
  ds_totals %>% 
  filter(year >= 2013) %>%
  ggplot(aes(x = year, y = count, color=measure)) +
  geom_line() +
  geom_point()+
  # the x ticks should be integers
  scale_x_continuous(breaks = seq(2013, max(ds_totals$year), by = 2)) +
  # make y-axis labels have comma separators
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Total Counts of Books Published",
    x = "Year",
    y = "Count"
  ) 
g1

# ----- g2-genre-counts ------------------------------------------------
ds_genre %>% glimpse()
g2 <- 
  ds_genre %>% 
  filter(year >= 2013) %>%
  ggplot(aes(x = year, y = count, color=measure, group = measure)) +
  geom_line() +
  geom_point()+
  # the x ticks should be integers
  scale_x_continuous(breaks = seq(2013, max(ds_totals$year), by = 2)) +
  # make y-axis labels have comma separators
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Total Counts of Books by Genre",
    x = "Year",
    y = "Count"
  ) 
g2

