# =============================================================================
# DATA VISUALISATION WITH GGPLOT2: WORKSHOP MASTER SCRIPT
# -----------------------------------------------------------------------------
# Author : Shaurabh Anand, School of Development, Azim Premji University
# Version: 1.0 (October 2026)
#
# Contents
#   Part 0   Setup: packages and project folder
#   Part 1   R basics needed for plotting
#   Part 2   Tidy (long) data and why ggplot2 needs it
#   Part 3   The grammar of graphics
#   Part 4   One numeric variable: summaries and distributions
#   Part 5   Categorical variables: bar charts
#   Part 6   Change over time: line charts
#   Part 7   Two numeric variables: scatter plots and correlation
#   Part 8   Comparing groups: plots for t-tests, ANOVA and chi-square
#   Part 9   Small multiples: facets
#   Part 10  Labels, scales, colours and themes
#   Part 11  Annotation and highlighting
#   Part 12  Combining plots
#   Part 13  Saving figures
#   Part 14  Solutions to exercises
#   Part 15  Case study: World Bank labour force participation
#            (needs internet the first time it is run)
#   Appendix A  Base R graphics and their ggplot2 equivalents
#   Appendix B  Common errors and what they mean
#   Appendix C  Further reading
#
# How to use
#   1. Open ggplot2-workshop.Rproj in RStudio. This sets the working
#      directory to the project folder, so relative paths such as
#      "figures/plot.png" work. Do not use setwd() with a full path.
#   2. Run the script line by line (Ctrl + Enter on Windows/Linux,
#      Cmd + Enter on macOS). Read the output before moving on.
#   3. Open the document outline (Ctrl + Shift + O) to jump between parts.
#      Comment lines ending in "----" are section headers.
#   4. Each part ends with exercises. Solutions are in Part 14.
#
# Requirements: R 4.1 or later (for the native pipe |>). RStudio recommended.
#
# Data used
#   gapminder : life expectancy, GDP per capita and population for 142
#               countries, 1952-2007 (gapminder R package, Gapminder Foundation)
#   chickwts, Titanic, anscombe : built into R (datasets package)
#   World Bank WDI labour force participation rates (Part 15 only)
# =============================================================================


# PART 0: SETUP ----------------------------------------------------------------

## 0.1 Install packages (once per computer) ----

required_packages <- c("ggplot2",   # plotting
                       "dplyr",     # filter, mutate, group_by, summarise
                       "tidyr",     # pivot_longer, pivot_wider
                       "scales",    # axis label formats
                       "ggrepel",   # text labels that do not overlap
                       "patchwork", # combine several plots in one figure
                       "gapminder") # example dataset

missing_packages <- setdiff(required_packages, rownames(installed.packages()))
if (length(missing_packages) > 0) install.packages(missing_packages)

## 0.2 Load packages (every session) ----

library(ggplot2)
library(dplyr)
library(tidyr)
library(ggrepel)
library(patchwork)
library(gapminder)

# Loading dplyr prints that some functions (filter, lag, intersect, ...) are
# "masked". This is expected: dplyr's versions are used from now on.
# Functions from scales are called as scales::function_name() in this script,
# so the package does not need to be loaded with library().

## 0.3 Working directory and output folder ----

getwd()                                       # should print the project folder
dir.create("figures", showWarnings = FALSE)   # saved plots go here

# When asking for help with an error, include the output of sessionInfo().


# PART 1: R BASICS NEEDED FOR PLOTTING -----------------------------------------

## 1.1 R as a calculator and assignment ----

2 + 3
a <- 2          # "<-" stores the value on the right under the name on the left
b <- 3
a * b
a <- 10         # assigning again replaces the old value
a

## 1.2 Naming rules ----
# Names may contain letters, numbers, "." and "_". They must start with a
# letter and are case-sensitive. The lines below are commented out because
# they cause errors. Remove the "#" from one line at a time to see the message.

# 1c <- 10                 # error: a name cannot start with a number
# first variable <- 20     # error: a name cannot contain a space
# second-variable <- 30    # error: R reads this as "second minus variable"
# first_variable < - 20    # not an assignment: "<-" must not contain a space
first_variable <- 20       # use underscores instead of spaces or hyphens
c1 <- 10
# C1                       # error: object 'C1' not found (case matters)

## 1.3 Vectors ----

vector_example <- c(10, 20, 30, 40)   # c() combines values into a vector
vector_example + 10                   # arithmetic applies to every element
length(vector_example)

## 1.4 Data types and missing values ----

my_vector <- c(4, 5, 6, 7)            # c() creates a vector, not a list
class(my_vector)
mean(my_vector)

my_vector2 <- c(2, "a", 4, 5, 6)      # one text value turns every value into text
class(my_vector2)
mean(my_vector2)                      # NA with a warning: text has no mean

my_vector2_num <- as.numeric(my_vector2)  # "a" cannot become a number, so it becomes NA
my_vector2_num
mean(my_vector2_num)                      # NA: any missing value makes the mean NA
mean(my_vector2_num, na.rm = TRUE)        # na.rm = TRUE removes NAs first

## 1.5 Built-in datasets ----
# data()   # lists all datasets that come with R

head(chickwts)                  # chick weights by feed type (used in Part 8)
titanic <- as.data.frame(Titanic)   # Titanic is stored as a table; convert to rows
head(titanic)                   # Freq = number of people in each combination

## 1.6 The main dataset: gapminder ----
# One row per country per year (1952 to 2007, every 5 years), 142 countries.

gapminder
dim(gapminder)      # number of rows and columns
nrow(gapminder)
ncol(gapminder)
names(gapminder)
head(gapminder, 3)
tail(gapminder, 3)
str(gapminder)      # column types: factor, integer, numeric
summary(gapminder)
if (interactive()) View(gapminder)   # spreadsheet view in RStudio

## 1.7 Reading your own data ----
# Save CSV files in a data/ folder inside the project and use relative paths:
#   my_data <- read.csv("data/my_file.csv")
# read.csv() adds "X" to column names that start with a number (1990 becomes
# X1990) and replaces spaces with dots ("Country Name" becomes Country.Name).
# Use read.csv(..., check.names = FALSE) to keep the original names.

## 1.8 Selecting rows and columns ----

gapminder$lifeExp[1:5]                        # one column as a vector
gapminder[gapminder$country == "India", ]     # base R: rows where the condition is TRUE
subset(gapminder, country == "India")         # base R alternative

india <- filter(gapminder, country == "India")    # dplyr
india

gap_2007  <- filter(gapminder, year == 2007)
asia_2007 <- filter(gapminder, year == 2007, continent == "Asia")  # comma means AND
south_asia <- filter(gapminder,
                     country %in% c("India", "Pakistan", "Bangladesh",
                                    "Sri Lanka", "Nepal"))   # %in%: matches any value in the list

mean(india$lifeExp)
india[which.max(india$lifeExp), c("year", "lifeExp")]          # row with the maximum
gap_2007[which.max(gap_2007$gdpPercap), c("country", "gdpPercap")]

## 1.9 Creating new columns ----

# ifelse(): two categories
gap_2007$lifeExp_group <- ifelse(gap_2007$lifeExp >= 70, "70 or above", "Below 70")
table(gap_2007$lifeExp_group)

# cut(): several categories from a numeric column.
# These cut-offs are for illustration; they are not World Bank income groups.
gap_2007$income_band <- cut(gap_2007$gdpPercap,
                            breaks = c(0, 1000, 4000, 12000, Inf),
                            labels = c("Under 1k", "1k-4k", "4k-12k", "Over 12k"))
table(gap_2007$income_band)

# mutate(): the dplyr way to add or change columns
gap_2007 <- gap_2007 |>
  mutate(pop_million = pop / 1e6)

## 1.10 The pipe ----
# x |> f(y) is the same as f(x, y). Read |> as "then".
# %>% (from the magrittr and dplyr packages) works the same way in most cases.

gapminder |>
  filter(year == 2007) |>
  group_by(continent) |>
  summarise(n_countries = n(),
            mean_lifeExp = mean(lifeExp),
            .groups = "drop")

## Exercise 1 ----
# 1a. Create a data frame with the 1952 rows for Africa. How many countries does it have?
# 1b. Which African country had the highest life expectancy in 1952?
# 1c. Add a column pop_group to gap_2007: "Large" if pop > 100 million, otherwise "Not large".


# PART 2: TIDY (LONG) DATA AND WHY GGPLOT2 NEEDS IT ----------------------------

# ggplot2 expects "long" (tidy) data: one row per observation and one column
# per variable. gapminder is already long: country, year, lifeExp are columns.
# Many published tables, including World Bank downloads, are "wide": one row
# per country and one column per year. They must be reshaped before plotting.

## 2.1 A wide table ----
# Build a wide table of life expectancy in the layout of a World Bank CSV.

lifeExp_wide <- gapminder |>
  select(country, continent, year, lifeExp) |>
  pivot_wider(names_from = year, values_from = lifeExp, names_prefix = "X")
lifeExp_wide
names(lifeExp_wide)   # year columns are X1952, X1957, ... as read.csv() would name them

## 2.2 Summaries of wide data with base R ----
# Mean per year = mean of each column  -> colMeans()
# Mean per country = mean of each row  -> rowMeans()
# Both need numeric columns only. Using the whole table gives an error:

try(colMeans(lifeExp_wide))   # try() shows the error and lets the script continue

# Three ways to keep only the numeric columns
lifeExp_num <- lifeExp_wide[, 3:ncol(lifeExp_wide)]               # by position
lifeExp_num <- lifeExp_wide[, sapply(lifeExp_wide, is.numeric)]   # by type, with sapply
lifeExp_num <- Filter(is.numeric, lifeExp_wide)                   # by type, with Filter

colMeans(lifeExp_num, na.rm = TRUE)          # mean per year
head(rowMeans(lifeExp_num, na.rm = TRUE))    # mean per country

# Mean for India from 1982 onward
india_row <- lifeExp_wide[lifeExp_wide$country == "India", ]
first_col <- which(names(india_row) == "X1982")
rowMeans(india_row[, first_col:ncol(india_row)], na.rm = TRUE)

# Position-based selection (3:ncol, X1982 onward) breaks silently if the
# columns change. The long format below avoids this.

## 2.3 Reshape wide to long ----

lifeExp_long <- lifeExp_wide |>
  pivot_longer(cols = starts_with("X"),       # the columns to stack
               names_to = "year",             # old column names go here
               names_prefix = "X",            # remove the "X"
               names_transform = as.integer,  # "1952" (text) -> 1952 (number)
               values_to = "lifeExp")         # old cell values go here
lifeExp_long

# year must be a number for a line chart. If it stays as text ("X1952"),
# ggplot2 treats each year as a separate category (see 6.5).

## 2.4 Summaries of long data with dplyr ----

# Mean per country (replaces rowMeans)
lifeExp_country <- lifeExp_long |>
  group_by(country, continent) |>
  summarise(mean_lifeExp = mean(lifeExp, na.rm = TRUE), .groups = "drop")
lifeExp_country

# Mean per year (replaces colMeans)
lifeExp_year <- lifeExp_long |>
  group_by(year) |>
  summarise(mean_lifeExp = mean(lifeExp, na.rm = TRUE), .groups = "drop")
lifeExp_year

# Mean for India from 1982 onward (compare with 2.2)
lifeExp_long |>
  filter(country == "India", year >= 1982) |>
  summarise(mean_lifeExp = mean(lifeExp))

## Exercise 2 ----
# 2a. Make a wide table of gdpPercap (one column per year), then reshape it back to long.
# 2b. From the long table, calculate mean gdpPercap per continent per year.


# PART 3: THE GRAMMAR OF GRAPHICS ----------------------------------------------

# Every ggplot2 plot needs three things:
#   data       a data frame
#   aes()      "aesthetic mappings": which column goes to x, y, colour, size, ...
#   geom_*()   the mark used to draw the data: points, lines, bars, ...
#
# Template:
#   ggplot(data = <DATA>, mapping = aes(<MAPPINGS>)) +
#     <GEOM_FUNCTION>()
#
# Optional components, added with "+": scales, facets, coordinates, labels, themes.

## 3.0 Which chart for which question ----
# Question                                   Chart                         geom
# How is one numeric variable distributed?   histogram, density, boxplot   geom_histogram, geom_density, geom_boxplot
# How many observations in each category?    bar chart                     geom_bar, geom_col
# How does a value change over time?         line chart                    geom_line
# How are two numeric variables related?     scatter plot                  geom_point, geom_smooth
# How do groups differ on a numeric value?   boxplot + points, mean + CI   geom_boxplot, geom_jitter, geom_pointrange
# What share does each part make up?         filled bar chart              geom_col(position = "fill")
# Pie charts are hard to read beyond two or three slices. Use bars instead.

## 3.1 First plot ----

ggplot(data = gap_2007, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point()

# Short form: the argument names data = and mapping = are usually left out
ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point()

## 3.2 Mapping vs setting ----

# Inside aes(): the property depends on a column (mapping). A legend is added.
ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp, colour = continent)) +
  geom_point()

# Outside aes(): one fixed value for every point (setting). No legend.
ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(colour = "steelblue", size = 3, alpha = 0.6)   # alpha = transparency (0 to 1)

# Common mistake: a fixed value inside aes(). ggplot2 treats "steelblue" as a
# category name, colours the points with its first default colour (red), and
# adds a legend with one entry.
ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp, colour = "steelblue")) +
  geom_point()

# colour = points, lines and outlines; fill = the inside of bars, boxes and areas.

## 3.3 Layers ----
# Plots are built by adding layers with "+". Put "+" at the END of a line.
# A line that starts with "+" is run as a separate command and fails.
# After ggplot(), layers are joined with "+", not with "|>".

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth()    # adds a smoothed trend with a confidence band

## 3.4 Store a plot and add to it ----

p_base <- ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp))
p_base + geom_point()
p_base + geom_point() + scale_x_log10()

## 3.5 Mappings for all layers vs one layer ----
# Mappings in ggplot() apply to every layer. Mappings in a geom apply to that layer only.

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(aes(colour = continent)) +
  geom_smooth(method = "lm", se = FALSE) +     # one line for all countries
  scale_x_log10()

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp, colour = continent)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +     # one line per continent
  scale_x_log10()

## 3.6 Help ----
# ?geom_point       help page for one function; examples are at the bottom
# https://ggplot2.tidyverse.org/reference/ lists every function

## Exercise 3 ----
# 3a. Plot lifeExp (y) against pop (x) for 2007, with a log scale for x.
# 3b. Colour the points by continent and make all points size 2.
# 3c. Why does aes(colour = "red") not make the points red?


# PART 4: ONE NUMERIC VARIABLE: SUMMARIES AND DISTRIBUTIONS --------------------

## 4.1 Measures of central tendency ----

gdp <- gap_2007$gdpPercap
mean(gdp)
median(gdp)

# R has no built-in function for the statistical mode (mode() returns the
# storage type of an object). The mode is useful for discrete or categorical
# data. For continuous data almost every value is unique, so it says little.

a <- c(2, 2, 3, 4, 4, 4, 5, 5, 5, 6, 7, 8, 10)
table(a)                              # frequency of each value
which.max(table(a))                   # position of the first maximum
as.numeric(names(which.max(table(a))))   # returns only the FIRST mode: 4

calculate_mode <- function(x) {
  unique_x <- unique(x)                    # distinct values
  freq <- tabulate(match(x, unique_x))     # how often each one occurs
  unique_x[freq == max(freq)]              # every value with the highest count
}
calculate_mode(a)                     # 4 and 5 both occur three times
calculate_mode(gap_2007$continent)    # most common continent among countries

## 4.2 Measures of spread ----

var(gdp)
sd(gdp)
range(gdp)
IQR(gdp)        # interquartile range: 75th minus 25th percentile
quantile(gdp)

# Variance and standard deviation written by hand
# sample variance = sum of (x_i - mean)^2, divided by (n - 1)
variance <- function(x) {
  x <- x[!is.na(x)]
  sum((x - mean(x))^2) / (length(x) - 1)
}
std_dev <- function(x) sqrt(variance(x))

variance(gdp)   # same as var(gdp)
std_dev(gdp)    # same as sd(gdp)

## 4.3 Histogram ----

ggplot(gap_2007, aes(x = lifeExp)) +
  geom_histogram()
# The message about "bins = 30" means a default was used. The shape of a
# histogram depends on the bin width, so choose it deliberately.

h1 <- ggplot(gap_2007, aes(x = lifeExp)) + geom_histogram(binwidth = 1)  + labs(title = "binwidth = 1")
h2 <- ggplot(gap_2007, aes(x = lifeExp)) + geom_histogram(binwidth = 5)  + labs(title = "binwidth = 5")
h3 <- ggplot(gap_2007, aes(x = lifeExp)) + geom_histogram(binwidth = 15) + labs(title = "binwidth = 15")
h1 + h2 + h3     # patchwork places plots side by side (Part 12)

ggplot(gap_2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 2.5, boundary = 0,       # boundary = 0: bins start at 0, 2.5, 5, ...
                 fill = "grey60", colour = "white")

## 4.4 Mean and median of a skewed variable ----

gdp_summary <- gap_2007 |>
  summarise(mean = mean(gdpPercap), median = median(gdpPercap))
gdp_summary

ggplot(gap_2007, aes(x = gdpPercap)) +
  geom_histogram(binwidth = 2000, boundary = 0, fill = "grey70", colour = "white") +
  geom_vline(xintercept = gdp_summary$mean, colour = "#D55E00", linewidth = 1) +
  geom_vline(xintercept = gdp_summary$median, colour = "#0072B2",
             linewidth = 1, linetype = "dashed") +
  annotate("text", x = gdp_summary$mean, y = Inf, label = "mean",
           colour = "#D55E00", hjust = -0.15, vjust = 1.5) +
  annotate("text", x = gdp_summary$median, y = Inf, label = "median",
           colour = "#0072B2", hjust = 1.15, vjust = 1.5) +
  labs(x = "GDP per capita (US$), 2007", y = "Number of countries")
# GDP per capita is right-skewed: a few rich countries pull the mean well
# above the median. For skewed data, report the median.

## 4.5 Log scale for skewed data ----

ggplot(gap_2007, aes(x = gdpPercap)) +
  geom_histogram(bins = 20, fill = "grey60", colour = "white") +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1))
# On a log scale equal distances are equal ratios: 1,000 to 10,000 takes the
# same space as 10,000 to 100,000.

## 4.6 Density plot ----

ggplot(gap_2007, aes(x = lifeExp)) +
  geom_density(fill = "grey80")

# Density curves compare groups more clearly than overlapping histograms.
# Oceania is left out: it has 2 countries, too few to estimate a density.
ggplot(filter(gap_2007, continent != "Oceania"),
       aes(x = lifeExp, fill = continent)) +
  geom_density(alpha = 0.4)

## 4.7 Boxplot ----
# Line in the box = median. Box = middle 50% of values (25th to 75th
# percentile, the IQR). Whiskers = most extreme values within 1.5 x IQR of
# the box. Dots = values beyond the whiskers.

ggplot(gap_2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot()

## 4.8 Show the data points too ----
# A boxplot hides the number of observations and gaps in the data.
# Adding the points shows both. Oceania's box is based on only 2 countries.

ggplot(gap_2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot(outlier.shape = NA) +     # hide outlier dots; the jittered points include them
  geom_jitter(width = 0.15, alpha = 0.5) # jitter = small random horizontal shift

ggplot(gap_2007, aes(x = continent, y = lifeExp)) +
  geom_violin(fill = "grey85") +         # violin = mirrored density curve
  geom_jitter(width = 0.1, alpha = 0.5)

## Exercise 4 ----
# 4a. Calculate the mean, median and standard deviation of pop for 2007.
#     Why are the mean and median so different?
# 4b. Draw a histogram of lifeExp for 1952. Try three different bin widths.
# 4c. Draw boxplots of gdpPercap by continent for 2007 with a log y axis.


# PART 5: CATEGORICAL VARIABLES: BAR CHARTS ------------------------------------

## 5.1 geom_bar(): ggplot2 counts the rows ----

ggplot(gap_2007, aes(x = continent)) +
  geom_bar()

## 5.2 geom_col(): you supply the bar heights ----

continent_counts <- gap_2007 |> count(continent)
continent_counts

ggplot(continent_counts, aes(x = continent, y = n)) +
  geom_col()
# geom_col() is the same as geom_bar(stat = "identity").

## 5.3 Simulated data: success and failure ----

set.seed(42)    # makes the random draws the same every time the script runs
tosses <- data.frame(outcome = sample(c("success", "failure"), size = 20,
                                      replace = TRUE, prob = c(0.5, 0.5)))
table(tosses$outcome)

ggplot(tosses, aes(x = outcome)) +
  geom_bar()

# Sampling variation: the true probability is 0.5 in every sample.
set.seed(42)
sims <- data.frame(
  n = rep(c(20, 200, 2000), times = c(20, 200, 2000)),
  outcome = sample(c("success", "failure"), size = 2220, replace = TRUE)
)

ggplot(sims, aes(x = outcome)) +
  geom_bar(aes(y = after_stat(prop), group = 1)) +   # proportions instead of counts
  geom_hline(yintercept = 0.5, linetype = "dashed") +
  facet_wrap(~ n, labeller = label_both) +
  labs(y = "Proportion")
# Larger samples give proportions closer to 0.5.

## 5.4 Ordering bars ----

ggplot(asia_2007, aes(x = country, y = lifeExp)) +
  geom_col()        # alphabetical order and overlapping labels

ggplot(asia_2007, aes(x = lifeExp, y = reorder(country, lifeExp))) +
  geom_col() +
  labs(x = "Life expectancy (years), 2007", y = NULL)
# reorder(country, lifeExp) sorts the categories by value.
# Categories on the y axis make long names readable without rotating them.

# Bars must start at zero because bar length shows the value. When values
# are far from zero, a dot plot is easier to read:
ggplot(asia_2007, aes(x = lifeExp, y = reorder(country, lifeExp))) +
  geom_point() +
  labs(x = "Life expectancy (years), 2007", y = NULL)

## 5.5 Two categorical variables: stacked, dodged and filled bars ----

titanic_class <- titanic |>
  group_by(Class, Survived) |>
  summarise(n = sum(Freq), .groups = "drop")
titanic_class

b1 <- ggplot(titanic_class, aes(x = Class, y = n, fill = Survived)) +
  geom_col() +
  labs(title = "Stacked (counts)", y = "People")
b2 <- ggplot(titanic_class, aes(x = Class, y = n, fill = Survived)) +
  geom_col(position = "dodge") +
  labs(title = "Dodged (counts)", y = "People")
b3 <- ggplot(titanic_class, aes(x = Class, y = n, fill = Survived)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(title = "Filled (shares)", y = "Share")
b1 + b2 + b3 + plot_layout(guides = "collect")   # one shared legend
# Counts answer "how many". Shares answer "what proportion". The filled chart
# shows that the share surviving fell from 1st to 3rd class; the count charts
# mainly show that the crew was the largest group.

## Exercise 5 ----
# 5a. Bar chart of the number of countries in each income_band (gap_2007, see 1.9).
# 5b. Horizontal bar chart of 2007 GDP per capita for the Americas, ordered by value.
# 5c. Using titanic, show the share surviving by Sex as a filled bar chart.


# PART 6: CHANGE OVER TIME: LINE CHARTS ----------------------------------------

## 6.1 One series ----

ggplot(india, aes(x = year, y = lifeExp)) +
  geom_line()

ggplot(india, aes(x = year, y = lifeExp)) +
  geom_line(colour = "darkred", linewidth = 1) +   # linewidth: thickness of lines
  geom_point(colour = "darkred", size = 2) +       # size: size of points
  labs(title = "Life expectancy in India, 1952-2007",
       x = "Year", y = "Life expectancy (years)")

## 6.2 Several series ----

ggplot(south_asia, aes(x = year, y = lifeExp, colour = country)) +
  geom_line(linewidth = 1) +
  geom_point()

## 6.3 The group aesthetic ----
# Without a grouping variable, geom_line() joins all points into one line.

ggplot(gapminder, aes(x = year, y = lifeExp)) +
  geom_line()                           # wrong: one zig-zag line through every country

ggplot(gapminder, aes(x = year, y = lifeExp, group = country)) +
  geom_line(alpha = 0.3)                # one line per country

## 6.4 Lines of summary values ----

continent_year <- gapminder |>
  group_by(continent, year) |>
  summarise(mean_lifeExp = mean(lifeExp), .groups = "drop")

ggplot(continent_year, aes(x = year, y = mean_lifeExp, colour = continent)) +
  geom_line(linewidth = 1) +
  geom_point()
# This is the mean across countries, not across people: a country of 1 million
# counts as much as a country of 1 billion. For a population-weighted mean,
# use weighted.mean(lifeExp, w = pop).

## 6.5 Year stored as text: a common error ----

india_text_year <- india |> mutate(year = paste0("X", year))
ggplot(india_text_year, aes(x = year, y = lifeExp)) +
  geom_line()
# Result: an empty plot and the message "Each group consists of only one
# observation". Convert to numbers first: as.integer(sub("X", "", year)).

## Exercise 6 ----
# 6a. Plot GDP per capita over time for India and China on one chart.
# 6b. Plot population-weighted mean life expectancy per continent over time.


# PART 7: TWO NUMERIC VARIABLES: SCATTER PLOTS AND CORRELATION -----------------

## 7.1 Correlation coefficients ----

cor(gap_2007$gdpPercap, gap_2007$lifeExp)                        # Pearson (default)
cor(log10(gap_2007$gdpPercap), gap_2007$lifeExp)                 # Pearson, log GDP
cor(gap_2007$gdpPercap, gap_2007$lifeExp, method = "spearman")   # Spearman (ranks)
cor.test(log10(gap_2007$gdpPercap), gap_2007$lifeExp)            # p-value and 95% CI

# Pearson's r measures how closely the points follow a straight line.
# Spearman's rho measures whether one variable rises as the other rises,
# along any curve, and is less affected by extreme values.
# A correlation does not show that one variable causes the other.

## 7.2 Scatter plot with a fitted line ----

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth(method = "lm")
# A straight line fits poorly on the original scale.

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  geom_smooth(method = "lm") +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1))
# On a log scale the relationship is close to linear.
# The grey band is the 95% confidence interval of the fitted line.

## 7.3 More variables: colour and size ----

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp, colour = continent, size = pop)) +
  geom_point(alpha = 0.7) +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1)) +
  scale_size_area(max_size = 12, labels = scales::label_comma())
# scale_size_area() makes the AREA of each point proportional to population.

## 7.4 Overplotting ----

ggplot(gapminder, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(alpha = 0.2) +    # transparency shows where points pile up
  scale_x_log10(labels = scales::label_dollar(accuracy = 1))
# All 1,704 country-years. Without labels = ..., wide log axes show numbers
# in scientific notation (1e+03 = 1,000).

## 7.5 Why plot the data: Anscombe's quartet ----
# Four small datasets with nearly identical means, variances and correlation.

anscombe_long <- data.frame(
  set = rep(c("I", "II", "III", "IV"), each = nrow(anscombe)),
  x   = c(anscombe$x1, anscombe$x2, anscombe$x3, anscombe$x4),
  y   = c(anscombe$y1, anscombe$y2, anscombe$y3, anscombe$y4)
)

anscombe_long |>
  group_by(set) |>
  summarise(mean_x = mean(x), mean_y = mean(y), sd_y = sd(y), r = cor(x, y))

ggplot(anscombe_long, aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~ set)
# Same summary statistics, four different relationships. Only set I suits a
# straight-line summary.

## Exercise 7 ----
# 7a. For 1952, calculate the Pearson and Spearman correlations between
#     gdpPercap and lifeExp. Why do they differ?
# 7b. Scatter plot of the 1952 data with a linear fit for each continent.


# PART 8: COMPARING GROUPS: PLOTS FOR T-TESTS, ANOVA AND CHI-SQUARE ------------

# A test result is easier to interpret next to a plot of the data it is based
# on. Each test below comes with a plot of the comparison being tested.

## 8.1 One-sample t-test ----
# Question: is mean life expectancy across African countries in 2007
# different from a reference value of 60 years?
# (The original workshop compared village sex ratios in Karnataka with the
# national value of 943 from Census 2011. Any externally sourced reference
# value is tested the same way.)

africa_2007 <- filter(gap_2007, continent == "Africa")
mu_ref <- 60

t.test(africa_2007$lifeExp, mu = mu_ref, alternative = "two.sided")
# alternative can be "two.sided" (default), "greater" or "less".

africa_ci <- africa_2007 |>
  summarise(mean = mean(lifeExp),
            se   = sd(lifeExp) / sqrt(n()),
            n    = n()) |>
  mutate(lower = mean - qt(0.975, df = n - 1) * se,
         upper = mean + qt(0.975, df = n - 1) * se)
africa_ci

ggplot(africa_2007, aes(x = lifeExp)) +
  annotate("rect", xmin = africa_ci$lower, xmax = africa_ci$upper,
           ymin = -Inf, ymax = Inf, fill = "#D55E00", alpha = 0.2) +
  geom_histogram(binwidth = 2.5, boundary = 0, fill = "grey60", colour = "white") +
  geom_vline(xintercept = africa_ci$mean, colour = "#D55E00", linewidth = 1) +
  geom_vline(xintercept = mu_ref, linetype = "dashed") +
  labs(x = "Life expectancy (years), 2007", y = "Number of countries",
       title = "African countries, 2007",
       subtitle = "Orange line and band: sample mean and 95% CI. Dashed line: reference value of 60.")
# The 95% CI does not include 60, which matches p < 0.05 in the test.

# The same test by hand
t_stat <- function(sample_mean, mu, s, n) {
  (sample_mean - mu) / (s / sqrt(n))
}
n_af <- nrow(africa_2007)
t_value <- t_stat(mean(africa_2007$lifeExp), mu_ref, sd(africa_2007$lifeExp), n_af)
t_value
t_critical <- qt(0.975, df = n_af - 1)           # two-sided test at 5%: 2.5% in each tail
t_critical
p_value <- 2 * pt(-abs(t_value), df = n_af - 1)  # two-sided p-value: both tails
p_value
# These match the t.test() output.

## 8.2 Two-sample t-test (independent groups) ----
# Question: does mean life expectancy in 2007 differ between Asia and the Americas?

asia_americas <- gap_2007 |>
  filter(continent %in% c("Asia", "Americas")) |>
  droplevels()          # remove the unused factor levels (Africa, Europe, Oceania)

t.test(lifeExp ~ continent, data = asia_americas)
# R uses Welch's t-test by default. It does not assume equal variances.
t.test(lifeExp ~ continent, data = asia_americas, var.equal = TRUE)  # Student's t-test (pooled variance)

group_ci <- asia_americas |>
  group_by(continent) |>
  summarise(mean = mean(lifeExp), sd = sd(lifeExp), n = n(), .groups = "drop") |>
  mutate(se = sd / sqrt(n),
         lower = mean - qt(0.975, df = n - 1) * se,
         upper = mean + qt(0.975, df = n - 1) * se)
group_ci

ggplot(asia_americas, aes(x = continent, y = lifeExp)) +
  geom_jitter(width = 0.1, alpha = 0.4) +
  geom_pointrange(data = group_ci, aes(y = mean, ymin = lower, ymax = upper),
                  colour = "#D55E00", position = position_nudge(x = 0.25)) +
  labs(x = NULL, y = "Life expectancy (years), 2007",
       subtitle = "Grey: countries. Orange: group mean with 95% CI.")
# Asia has a wider spread than the Americas. Overlapping CIs alone do not show
# that a difference is non-significant; use the test result for that.

# Pooled two-sample t-test by hand (matches var.equal = TRUE)
m1 <- group_ci$mean[1]; s1 <- group_ci$sd[1]; n1 <- group_ci$n[1]   # Americas
m2 <- group_ci$mean[2]; s2 <- group_ci$sd[2]; n2 <- group_ci$n[2]   # Asia
sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))     # pooled standard deviation
t2_value <- (m1 - m2) / (sp * sqrt(1 / n1 + 1 / n2))
df2 <- n1 + n2 - 2
p2_value <- 2 * pt(-abs(t2_value), df = df2)
c(t = t2_value, df = df2, p = p2_value)

## 8.3 Paired t-test ----
# Question: did life expectancy in African countries change between 1997 and 2007?
# Each country is measured twice, so the two sets of values are paired.

africa_paired <- gapminder |>
  filter(continent == "Africa", year %in% c(1997, 2007)) |>
  select(country, year, lifeExp) |>
  pivot_wider(names_from = year, values_from = lifeExp, names_prefix = "y") |>
  mutate(change = y2007 - y1997)
africa_paired

t.test(africa_paired$y2007, africa_paired$y1997, paired = TRUE)
# This is the same as a one-sample t-test of the differences against 0:
t.test(africa_paired$change, mu = 0)
# Notes: pass two vectors, as above. When vectors are passed, a data = argument
# is ignored. Recent versions of R do not accept paired = TRUE in the formula
# form t.test(y ~ group, ...).

# Plot 1: slope chart, one line per country
africa_slope <- gapminder |>
  filter(continent == "Africa", year %in% c(1997, 2007)) |>
  left_join(select(africa_paired, country, change), by = "country") |>
  mutate(direction = ifelse(change < 0, "Decreased", "Increased"))

ggplot(africa_slope, aes(x = factor(year), y = lifeExp, group = country,
                         colour = direction)) +
  geom_line(alpha = 0.7) +
  geom_point(size = 1.5) +
  scale_colour_manual(values = c(Decreased = "#D55E00", Increased = "grey55")) +
  labs(x = NULL, y = "Life expectancy (years)", colour = NULL,
       title = "African countries, 1997 and 2007")

# Plot 2: distribution of the differences. The test asks whether their mean is 0.
ggplot(africa_paired, aes(x = change)) +
  geom_histogram(binwidth = 1, boundary = 0, fill = "grey60", colour = "white") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = mean(africa_paired$change), colour = "#D55E00", linewidth = 1) +
  labs(x = "Change in life expectancy, 1997 to 2007 (years)",
       y = "Number of countries")

sum(africa_paired$change < 0)   # number of countries where life expectancy fell
# The mean change is small and positive, and the test is not significant at
# 5%. The plots show what the test summary hides: most countries gained, and a
# group of countries lost several years.

## 8.4 One-way ANOVA ----
# Question: does chick weight differ by feed type?
# chickwts: weights (g) of 71 chicks after six weeks on one of six feeds.

anova_model <- aov(weight ~ feed, data = chickwts)
summary(anova_model)

ggplot(chickwts, aes(x = reorder(feed, weight, FUN = median), y = weight)) +
  geom_boxplot(outlier.shape = NA, fill = "grey90") +
  geom_jitter(width = 0.15, alpha = 0.6) +
  labs(x = "Feed (ordered by median weight)", y = "Weight after six weeks (g)")

# ANOVA tests whether at least one mean differs. Tukey's HSD compares every pair.
tukey <- TukeyHSD(anova_model)
tukey

tukey_df <- as.data.frame(tukey$feed)
tukey_df$comparison <- rownames(tukey_df)
tukey_df$significant <- ifelse(tukey_df$`p adj` < 0.05, "p < 0.05", "p >= 0.05")

ggplot(tukey_df, aes(x = diff, y = reorder(comparison, diff), colour = significant)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_pointrange(aes(xmin = lwr, xmax = upr)) +
  scale_colour_manual(values = c("p < 0.05" = "#0072B2", "p >= 0.05" = "grey60")) +
  labs(x = "Difference in mean weight (g), 95% family-wise CI", y = NULL, colour = NULL)
# Intervals that cross 0: no evidence of a difference for that pair.

# ANOVA assumes residuals that are roughly normal with similar spread in each group.
chick_resid <- data.frame(feed = chickwts$feed,
                          fitted = fitted(anova_model),
                          residual = residuals(anova_model))

ggplot(chick_resid, aes(sample = residual)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = "Normal Q-Q plot of residuals")
# Points close to the line: residuals are approximately normal.

ggplot(chick_resid, aes(x = feed, y = residual)) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_jitter(width = 0.1) +
  labs(title = "Residuals by group")
# Similar vertical spread across groups: the equal-variance assumption is reasonable.

## 8.5 Chi-square test of independence ----
# Question: was survival on the Titanic related to passenger class?
# (The original workshop asked whether having an Anganwadi in a village is
# related to the village being declared open-defecation free. The steps are
# the same for any two categorical variables.)

class_table <- xtabs(Freq ~ Class + Survived, data = titanic)
class_table
prop.table(class_table, margin = 1)   # share surviving within each class (rows sum to 1)

chi_result <- chisq.test(class_table)
chi_result
chi_result$expected    # counts expected if survival did not depend on class
# Every expected count should be 5 or more. If not, use fisher.test().

ggplot(titanic_class, aes(x = Class, y = n, fill = Survived)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::label_percent()) +
  scale_fill_manual(values = c(No = "grey70", Yes = "#0072B2")) +
  labs(x = NULL, y = "Share of people in each class")

# Standardised residuals: observed minus expected, on a common scale.
# Positive = more people than expected; negative = fewer.
# Cells beyond about +2 or -2 drive the test result.
resid_df <- as.data.frame(as.table(chi_result$stdres))
resid_df

ggplot(resid_df, aes(x = Survived, y = Class, fill = Freq)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = round(Freq, 1))) +
  scale_fill_gradient2(low = "#D55E00", mid = "white", high = "#0072B2", midpoint = 0) +
  labs(fill = "Standardised\nresidual")

## Exercise 8 ----
# 8a. Test whether mean life expectancy in 2007 differs between Africa and Asia.
#     Plot the comparison.
# 8b. Run a one-way ANOVA of lifeExp by continent for 2007, without Oceania. Plot it.
# 8c. Was survival on the Titanic related to Sex? Run chisq.test().


# PART 9: SMALL MULTIPLES: FACETS ----------------------------------------------

# Facets split one plot into panels, one per group, with shared axes.

ggplot(gapminder, aes(x = year, y = lifeExp, group = country)) +
  geom_line(alpha = 0.3) +
  facet_wrap(~ continent)

# Small panels have little room for axis labels, so set fewer breaks
ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point() +
  scale_x_log10(breaks = c(1000, 10000),
                labels = scales::label_dollar(accuracy = 1)) +
  facet_wrap(~ continent)

# facet_grid(rows ~ columns): two grouping variables
gapminder |>
  filter(year %in% c(1952, 1977, 2007), continent != "Oceania") |>
  ggplot(aes(x = gdpPercap, y = lifeExp)) +    # data piped in with |>, layers joined with +
  geom_point(alpha = 0.6) +
  scale_x_log10(breaks = c(1000, 10000),
                labels = scales::label_dollar(accuracy = 1)) +
  facet_grid(continent ~ year)

# scales = "free_y": each panel gets its own y axis. This shows the pattern
# within each panel, but values can no longer be compared across panels.
ggplot(continent_year, aes(x = year, y = mean_lifeExp)) +
  geom_line() +
  facet_wrap(~ continent, scales = "free_y")

## Exercise 9 ----
# 9a. Histogram of lifeExp in 2007 with one panel per continent.


# PART 10: LABELS, SCALES, COLOURS AND THEMES ----------------------------------

## 10.1 Labels ----

p_scatter <- ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp, colour = continent)) +
  geom_point(size = 2, alpha = 0.8)

p_scatter +
  labs(title = "Life expectancy and income, 2007",
       subtitle = "Each point is a country",
       x = "GDP per capita (US$, inflation-adjusted)",
       y = "Life expectancy at birth (years)",
       colour = "Continent",
       caption = "Source: Gapminder, via the gapminder R package")
# Axis titles should state the variable and its unit. The caption gives the source.

## 10.2 Axis scales and number formats ----

p_scatter +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1),
                breaks = c(500, 1000, 5000, 10000, 50000)) +
  scale_y_continuous(breaks = seq(40, 80, by = 10))

# Other formats:
#   scales::label_comma()                               1,000,000
#   scales::label_percent()                             25%  (for values between 0 and 1)
#   scales::label_number(scale = 1e-6, suffix = " M")   1 M

## 10.3 Zooming: scale limits vs coord_cartesian() ----
# Scale limits REMOVE data outside the range before anything is calculated.
# coord_cartesian() keeps all the data and only zooms the view.
# This changes boxplots, smoothed lines and any other computed layer.

z1 <- ggplot(gap_2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(60, 80)) +
  labs(title = "scale_y_continuous(limits)", subtitle = "Data outside 60-80 removed")
z2 <- ggplot(gap_2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot() +
  coord_cartesian(ylim = c(60, 80)) +
  labs(title = "coord_cartesian(ylim)", subtitle = "All data used, view zoomed")
z1 + z2
# The warning "Removed ... rows" comes from z1. Compare the medians for
# Africa: they differ because z1 dropped countries before computing them.

## 10.4 Colour ----
# Categories: distinct hues. Ordered or numeric values: one hue, light to dark.
# About 1 in 12 men and 1 in 200 women have a colour vision deficiency, most
# often red-green. Avoid palettes that depend on telling red from green.

p_scatter_log <- p_scatter + scale_x_log10(labels = scales::label_dollar(accuracy = 1))

# Okabe-Ito palette: distinguishable with the common colour vision deficiencies.
# Yellow (#F0E442) is placed last because small points in yellow are hard to
# see on a white background.
okabe_ito <- c("#E69F00", "#56B4E9", "#009E73", "#0072B2",
               "#D55E00", "#CC79A7", "#000000", "#F0E442")
p_scatter_log + scale_colour_manual(values = okabe_ito)

p_scatter_log + scale_colour_viridis_d(end = 0.9)     # viridis: also readable in greyscale
p_scatter_log + scale_colour_brewer(palette = "Dark2")
# RColorBrewer::display.brewer.all() shows every Brewer palette (needs RColorBrewer).

# A fixed colour for each named group
p_scatter_log +
  scale_colour_manual(values = c(Africa = "#E69F00", Americas = "#56B4E9",
                                 Asia = "#009E73", Europe = "#0072B2",
                                 Oceania = "#CC79A7"))

# Continuous colour scale
ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp, colour = pop_million)) +
  geom_point(size = 2) +
  scale_x_log10() +
  scale_colour_viridis_c(trans = "log10", labels = scales::label_comma()) +
  labs(colour = "Population\n(million)")

## 10.5 Themes ----

t1 <- p_scatter_log + theme_grey()    + labs(title = "theme_grey (default)")
t2 <- p_scatter_log + theme_bw()      + labs(title = "theme_bw")
t3 <- p_scatter_log + theme_minimal() + labs(title = "theme_minimal")
t4 <- p_scatter_log + theme_classic() + labs(title = "theme_classic")
(t1 + t2) / (t3 + t4) & theme(legend.position = "none")   # & applies to every panel

# base_size sets all text sizes. Use 16 or more for slides and posters.
p_scatter_log + theme_minimal(base_size = 16)

# theme() changes individual elements
p_scatter_log +
  labs(title = "Life expectancy and income, 2007") +
  theme_minimal() +
  theme(legend.position = "bottom",
        panel.grid.minor = element_blank(),
        plot.title = element_text(face = "bold"),
        plot.title.position = "plot")       # align the title with the plot's left edge

# theme_set() applies a theme to every plot made after it in this session
theme_set(theme_minimal(base_size = 13))

## Exercise 10 ----
# 10a. Take any plot from Parts 4-7. Add a title, axis titles with units, a
#      source caption, a colour-blind-safe palette and theme_bw().


# PART 11: ANNOTATION AND HIGHLIGHTING -----------------------------------------

## 11.1 Text labels ----

# Labelling every point with geom_text() produces overlapping text
ggplot(asia_2007, aes(x = gdpPercap, y = lifeExp, label = country)) +
  geom_point() +
  geom_text() +
  scale_x_log10()

# ggrepel moves labels apart and draws a line to the point where needed
ggplot(asia_2007, aes(x = gdpPercap, y = lifeExp, label = country)) +
  geom_point() +
  geom_text_repel(size = 3, max.overlaps = 20, seed = 42) +  # seed: same layout every run
  scale_x_log10()

## 11.2 Highlight and label a selection ----

focus <- c("India", "China", "Bangladesh", "Pakistan", "Sri Lanka", "Nepal")
focus_2007 <- filter(gap_2007, country %in% focus)

ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(colour = "grey75") +                              # all countries as context
  geom_point(data = focus_2007, colour = "#D55E00", size = 2) + # selected countries on top
  geom_text_repel(data = focus_2007, aes(label = country), size = 3.5, seed = 42) +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1)) +
  labs(x = "GDP per capita (US$)", y = "Life expectancy (years)",
       title = "Selected Asian countries, 2007")

## 11.3 Highlight one line among many ----

ggplot(gapminder, aes(x = year, y = lifeExp, group = country)) +
  geom_line(colour = "grey85") +
  geom_line(data = india, colour = "#D55E00", linewidth = 1.2) +
  annotate("text", x = 2008, y = india$lifeExp[india$year == 2007],
           label = "India", hjust = 0, colour = "#D55E00") +
  coord_cartesian(xlim = c(1952, 2014)) +    # extra space on the right for the label
  labs(x = NULL, y = "Life expectancy (years)")
# Labelling the line directly removes the need for a legend.

## 11.4 Reference lines and shaded periods ----

ggplot(india, aes(x = year, y = lifeExp)) +
  annotate("rect", xmin = 1987, xmax = 2007, ymin = -Inf, ymax = Inf,
           fill = "grey90") +
  annotate("text", x = 1997, y = 40, label = "Last 20 years", colour = "grey40") +
  geom_hline(yintercept = mean(india$lifeExp), linetype = "dashed") +
  annotate("text", x = 1953, y = mean(india$lifeExp) + 1.5,
           label = "1952-2007 mean", hjust = 0) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(x = NULL, y = "Life expectancy (years)")
# Layers are drawn in order: the shaded rectangle comes first so it sits behind the line.


# PART 12: COMBINING PLOTS -----------------------------------------------------

p_hist <- ggplot(gap_2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 2.5, boundary = 0, fill = "grey60", colour = "white") +
  labs(x = "Life expectancy (years)", y = "Countries")
p_box <- ggplot(gap_2007, aes(x = lifeExp, y = continent)) +   # horizontal: labels fit in a narrow panel
  geom_boxplot() +
  labs(x = "Life expectancy (years)", y = NULL)
p_line <- ggplot(continent_year, aes(x = year, y = mean_lifeExp, colour = continent)) +
  geom_line(linewidth = 1) +
  scale_colour_manual(values = okabe_ito) +
  labs(x = NULL, y = "Mean life expectancy (years)", colour = NULL)

p_hist + p_box              # side by side
p_hist / p_box              # one above the other
(p_hist + p_box) / p_line   # grid

combined <- (p_hist + p_box) / p_line +
  plot_annotation(title = "Life expectancy: distribution in 2007, groups and trends",
                  caption = "Source: Gapminder",
                  tag_levels = "A")      # panel labels A, B, C
combined


# PART 13: SAVING FIGURES ------------------------------------------------------

# ggsave() saves the last plot displayed, or the plot given in plot =.
# Always set width, height and units so the output is the same every time.

ggsave("figures/combined_lifeExp.png", plot = combined,
       width = 10, height = 7, units = "in", dpi = 300)    # raster: for slides and documents

ggsave("figures/combined_lifeExp.pdf", plot = combined,
       width = 10, height = 7, units = "in")               # vector: sharp at any size

# SVG output needs the svglite package: ggsave("figures/plot.svg", ...)
# Text size in a saved file depends on width and height: a larger canvas
# makes text look smaller. Check the saved file, not the RStudio plot pane.
# Journals usually state the width (single or double column) and minimum dpi.

# Alternative text describes a figure for readers using screen readers.
# Add it to figures you publish online.
p_alt <- p_scatter_log +
  labs(alt = paste("Scatter plot of life expectancy against GDP per capita",
                   "for 142 countries in 2007. Life expectancy rises with",
                   "income, steeply at low incomes and slowly at high incomes."))
get_alt_text(p_alt)

## Exercise 13 ----
# 13a. Save the plot from Exercise 10 as a PNG, 6 x 4 inches, 300 dpi, in figures/.


# PART 14: SOLUTIONS TO EXERCISES ----------------------------------------------

## Solutions 1 ----

# 1a
africa_1952 <- filter(gapminder, year == 1952, continent == "Africa")
nrow(africa_1952)
# 1b
africa_1952[which.max(africa_1952$lifeExp), c("country", "lifeExp")]
# 1c
gap_2007$pop_group <- ifelse(gap_2007$pop > 100e6, "Large", "Not large")
table(gap_2007$pop_group)

## Solutions 2 ----

# 2a
gdp_wide <- gapminder |>
  select(country, continent, year, gdpPercap) |>
  pivot_wider(names_from = year, values_from = gdpPercap, names_prefix = "X")
gdp_long <- gdp_wide |>
  pivot_longer(cols = starts_with("X"), names_to = "year", names_prefix = "X",
               names_transform = as.integer, values_to = "gdpPercap")
# 2b
gdp_long |>
  group_by(continent, year) |>
  summarise(mean_gdpPercap = mean(gdpPercap), .groups = "drop")

## Solutions 3 ----

# 3a and 3b
ggplot(gap_2007, aes(x = pop, y = lifeExp, colour = continent)) +
  geom_point(size = 2) +
  scale_x_log10(labels = scales::label_comma())
# 3c: inside aes(), "red" is treated as a data value (a category called "red"),
# not as a colour. To make every point red, put colour = "red" outside aes().

## Solutions 4 ----

# 4a
mean(gap_2007$pop)
median(gap_2007$pop)
sd(gap_2007$pop)
# A few very large countries (China, India) pull the mean far above the median.
# 4b
gap_1952 <- filter(gapminder, year == 1952)
ggplot(gap_1952, aes(x = lifeExp)) + geom_histogram(binwidth = 2)
ggplot(gap_1952, aes(x = lifeExp)) + geom_histogram(binwidth = 5)
ggplot(gap_1952, aes(x = lifeExp)) + geom_histogram(binwidth = 10)
# 4c
ggplot(gap_2007, aes(x = continent, y = gdpPercap)) +
  geom_boxplot() +
  scale_y_log10(labels = scales::label_dollar(accuracy = 1))

## Solutions 5 ----

# 5a
ggplot(gap_2007, aes(x = income_band)) +
  geom_bar()
# 5b
gap_2007 |>
  filter(continent == "Americas") |>
  ggplot(aes(x = gdpPercap, y = reorder(country, gdpPercap))) +
  geom_col() +
  scale_x_continuous(labels = scales::label_dollar(accuracy = 1)) +
  labs(x = "GDP per capita (US$), 2007", y = NULL)
# 5c
titanic |>
  group_by(Sex, Survived) |>
  summarise(n = sum(Freq), .groups = "drop") |>
  ggplot(aes(x = Sex, y = n, fill = Survived)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::label_percent()) +
  labs(y = "Share")

## Solutions 6 ----

# 6a
gapminder |>
  filter(country %in% c("India", "China")) |>
  ggplot(aes(x = year, y = gdpPercap, colour = country)) +
  geom_line(linewidth = 1) +
  geom_point()
# 6b
gapminder |>
  group_by(continent, year) |>
  summarise(lifeExp_weighted = weighted.mean(lifeExp, w = pop), .groups = "drop") |>
  ggplot(aes(x = year, y = lifeExp_weighted, colour = continent)) +
  geom_line(linewidth = 1) +
  labs(y = "Population-weighted mean life expectancy (years)")

## Solutions 7 ----

# 7a
cor(gap_1952$gdpPercap, gap_1952$lifeExp)                       # Pearson
cor(gap_1952$gdpPercap, gap_1952$lifeExp, method = "spearman")  # Spearman
# Pearson is pulled down by one extreme value (Kuwait, GDP per capita above
# US$100,000) and by the curved relationship. Spearman uses ranks: the extreme
# value counts only as the highest rank, and the shape of the curve does not
# matter as long as both variables rise together.
# 7b
ggplot(gap_1952, aes(x = gdpPercap, y = lifeExp, colour = continent)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  scale_x_log10(labels = scales::label_dollar(accuracy = 1))

## Solutions 8 ----

# 8a
africa_asia <- gap_2007 |>
  filter(continent %in% c("Africa", "Asia")) |>
  droplevels()
t.test(lifeExp ~ continent, data = africa_asia)
ggplot(africa_asia, aes(x = continent, y = lifeExp)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.5)
# 8b
gap_2007_no_oceania <- gap_2007 |>
  filter(continent != "Oceania") |>
  droplevels()
summary(aov(lifeExp ~ continent, data = gap_2007_no_oceania))
ggplot(gap_2007_no_oceania,
       aes(x = reorder(continent, lifeExp, FUN = median), y = lifeExp)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  labs(x = NULL)
# 8c
sex_table <- xtabs(Freq ~ Sex + Survived, data = titanic)
sex_table
prop.table(sex_table, margin = 1)
chisq.test(sex_table)
# The plot for 8c is Solution 5c.

## Solutions 9 ----

ggplot(gap_2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 5, boundary = 0) +
  facet_wrap(~ continent)

## Solutions 10 and 13 ----

ex10_plot <- ggplot(gap_2007, aes(x = continent, y = lifeExp, fill = continent)) +
  geom_boxplot(show.legend = FALSE) +
  scale_fill_manual(values = okabe_ito) +
  labs(title = "Life expectancy by continent, 2007",
       x = NULL, y = "Life expectancy at birth (years)",
       caption = "Source: Gapminder") +
  theme_bw()
ex10_plot
ggsave("figures/exercise10.png", plot = ex10_plot,
       width = 6, height = 4, units = "in", dpi = 300)


# PART 15: CASE STUDY: WORLD BANK LABOUR FORCE PARTICIPATION -------------------

# This part applies the workshop to World Bank data on labour force
# participation rates (LFPR): the percentage of the population aged 15+ that
# is working or looking for work (modelled ILO estimates).
#   SL.TLF.CACT.FE.ZS  female LFPR
#   SL.TLF.CACT.MA.ZS  male LFPR
# The first run downloads the data with the WDI package and saves it to
# data/lfpr_worldbank.csv. Later runs read that file and need no internet.

## 15.1 Download once, then read from file ----

if (!requireNamespace("WDI", quietly = TRUE)) install.packages("WDI")

lfpr_file <- file.path("data", "lfpr_worldbank.csv")

if (!file.exists(lfpr_file)) {
  dir.create("data", showWarnings = FALSE)
  lfpr_download <- WDI::WDI(country = "all",
                            indicator = c(female = "SL.TLF.CACT.FE.ZS",
                                          male   = "SL.TLF.CACT.MA.ZS"),
                            start = 1990, end = 2023,
                            extra = TRUE)   # adds region and income group
  write.csv(lfpr_download, lfpr_file, row.names = FALSE)
}

lfpr_raw <- read.csv(lfpr_file)
str(lfpr_raw)

# The download includes aggregates such as "World" and "South Asia" (region =
# "Aggregates"). Keep countries only.
lfpr <- lfpr_raw |>
  filter(region != "Aggregates", !is.na(region)) |>
  mutate(region = trimws(region)) |>
  select(country, iso3c, region, income, year, female, male)
head(lfpr)

## 15.2 The original workshop exercises, with long data ----

# A. Mean female LFPR for India, 1990-2023
lfpr |>
  filter(country == "India") |>
  summarise(mean_female = mean(female, na.rm = TRUE))

# B. Mean female LFPR for India, 2000 onward
lfpr |>
  filter(country == "India", year >= 2000) |>
  summarise(mean_female = mean(female, na.rm = TRUE))

# C. Mean LFPR per country
lfpr_country <- lfpr |>
  group_by(country, region) |>
  summarise(female = mean(female, na.rm = TRUE),
            male   = mean(male, na.rm = TRUE),
            .groups = "drop") |>
  filter(!is.na(female), !is.na(male))    # countries with no data give NaN
lfpr_country

# D. Mean LFPR per year (across countries)
lfpr_year <- lfpr |>
  group_by(year) |>
  summarise(female = mean(female, na.rm = TRUE),
            male   = mean(male, na.rm = TRUE),
            .groups = "drop")
lfpr_year

## 15.3 Bar chart: countries ranked by mean female LFPR ----
# Around 190 countries do not fit on one readable bar chart. Show one region.

lfpr_country |>
  filter(region == "South Asia") |>
  ggplot(aes(x = female, y = reorder(country, female))) +
  geom_col(fill = "#0072B2") +
  labs(x = "Mean female LFPR, 1990-2023 (%)", y = NULL,
       caption = "Source: World Bank WDI, ILO modelled estimates")

## 15.4 Line charts: change over time ----

lfpr_year |>
  pivot_longer(cols = c(female, male), names_to = "sex", values_to = "lfpr") |>
  ggplot(aes(x = year, y = lfpr, colour = sex)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_colour_manual(values = c(female = "#D55E00", male = "#0072B2")) +
  labs(x = NULL, y = "Mean LFPR across countries (%)", colour = NULL)

# India against every other country
ggplot(lfpr, aes(x = year, y = female, group = country)) +
  geom_line(colour = "grey85", na.rm = TRUE) +
  geom_line(data = filter(lfpr, country == "India"),
            colour = "#D55E00", linewidth = 1.2, na.rm = TRUE) +
  labs(x = NULL, y = "Female LFPR (%)",
       title = "Female LFPR: India (orange) and other countries")

## 15.5 Scatter plot: male vs female LFPR ----

cor(lfpr_country$male, lfpr_country$female)

ggplot(lfpr_country, aes(x = male, y = female)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey50") +
  geom_point(alpha = 0.5) +
  geom_point(data = filter(lfpr_country, region == "South Asia"),
             colour = "#D55E00", size = 2) +
  geom_text_repel(data = filter(lfpr_country, region == "South Asia"),
                  aes(label = country), size = 3, seed = 42) +
  coord_equal() +    # same scale on both axes, so the dashed line is at 45 degrees
  labs(x = "Mean male LFPR, 1990-2023 (%)", y = "Mean female LFPR, 1990-2023 (%)",
       subtitle = "Dashed line: equal male and female LFPR.\nOrange: South Asian countries.")

## 15.6 Gender gap by region ----

lfpr_country |>
  mutate(gap = male - female) |>
  ggplot(aes(x = gap, y = reorder(region, gap, FUN = median))) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(height = 0.15, alpha = 0.4) +
  labs(x = "Male minus female LFPR, mean 1990-2023 (percentage points)", y = NULL)


# APPENDIX A: BASE R GRAPHICS AND THEIR GGPLOT2 EQUIVALENTS --------------------
#
# Base R                           ggplot2
# plot(x, y)                       ggplot(df, aes(x, y)) + geom_point()
# plot(x, y, type = "l")           + geom_line()
# points(x, y)                     + geom_point()   (an extra layer)
# text(x, y, labels)               + geom_text(), or ggrepel::geom_text_repel()
# barplot(heights, names.arg)      + geom_col()
# barplot(table(x))                + geom_bar()
# hist(x)                          + geom_histogram()
# boxplot(y ~ g)                   aes(g, y) + geom_boxplot()
# abline(h = v)                    + geom_hline(yintercept = v)
# abline(lm(y ~ x))                + geom_smooth(method = "lm")
# par(mfrow = c(1, 2))             p1 + p2 (patchwork), or facet_wrap()
# main =, xlab =, ylab =           + labs(title =, x =, y =)
# las = 2, cex.names = 0.7         categories on the y axis, or
#                                  theme(axis.text.x = element_text(angle = 90, hjust = 1))
# col = "red"                      colour = "red" (outside aes())
# pch = 16                         shape = 16
# lwd = 2                          linewidth = 2
# cex = 0.7                        size = 0.7 (points), size = (text, in mm)
# png("f.png"); plot(); dev.off()  ggsave("f.png", width =, height =, dpi =)


# APPENDIX B: COMMON ERRORS AND WHAT THEY MEAN ---------------------------------
#
# object 'x' not found
#     A typo in the name, or the line that creates the object was not run.
# could not find function "ggplot"
#     The package is not loaded. Run library(ggplot2).
# A line starting with "+" gives an error
#     Move "+" to the end of the previous line.
# 'x' must be numeric
#     A text or factor column was included. Select numeric columns only.
# Each group consists of only one observation
#     x is text or a factor in geom_line(). Convert it to a number, or set group =.
# Removed k rows containing missing values (or non-finite values)
#     The data contain NA, or values fall outside the scale limits.
# `stat_bin()` using `bins = 30`
#     Set binwidth = or bins = in geom_histogram().
# Colour does not change and a legend appears
#     A fixed colour was placed inside aes(). Move it outside.
# Bars appear in alphabetical order
#     Use reorder(category, value).
# cannot open file 'data/x.csv': No such file or directory
#     Check getwd() and the relative path. Open the .Rproj file first.


# APPENDIX C: FURTHER READING --------------------------------------------------
#
# Wickham, Cetinkaya-Rundel and Grolemund. R for Data Science, 2nd ed.
#     https://r4ds.hadley.nz
# Wickham, Navarro and Pedersen. ggplot2: Elegant Graphics for Data Analysis, 3rd ed.
#     https://ggplot2-book.org
# Healy. Data Visualization: A Practical Introduction.
#     https://socviz.co
# Wilke. Fundamentals of Data Visualization.
#     https://clauswilke.com/dataviz
# ggplot2 function reference: https://ggplot2.tidyverse.org/reference
# R Graph Gallery (code for many chart types): https://r-graph-gallery.com
# swirl, interactive R lessons in the console:
#     install.packages("swirl"); library(swirl); swirl()

# End of script
