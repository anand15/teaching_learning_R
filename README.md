# Data visualisation with ggplot2: workshop materials

A single R script for a hands-on workshop on data visualisation with ggplot2. It starts from R basics, covers descriptive statistics and the grammar of graphics, pairs each common statistical test with a plot of the comparison being tested, and ends with preparing and saving figures for publication.

Prepared by Shaurabh Anand, School of Development, Azim Premji University, Bengaluru.

## Files

| File | Purpose |
|---|---|
| `ggplot2_workshop_master.R` | The workshop script. Run it line by line. |
| `ggplot2-workshop.Rproj` | Opens the folder as an RStudio project, so relative paths work. |
| `figures/` | Created by the script. Saved plots go here. |
| `data/` | Created by Part 15 when the World Bank data are downloaded. |

## Requirements

- R 4.1 or later (the script uses the native pipe `|>`)
- RStudio (recommended)
- Packages: ggplot2, dplyr, tidyr, scales, ggrepel, patchwork, gapminder. Part 0 of the script installs any that are missing. Part 15 also installs WDI.
- Internet access to install packages, and once more to run Part 15. Parts 0 to 14 run offline after the packages are installed.

## How to use

1. Download the repository (Code > Download ZIP) and unzip it, or clone it.
2. Double-click `ggplot2-workshop.Rproj` to open the project in RStudio.
3. Open `ggplot2_workshop_master.R` and run Part 0 to install and load the packages.
4. Run the rest line by line with Ctrl + Enter (Cmd + Enter on macOS). Use the document outline (Ctrl + Shift + O) to move between parts.

## Contents

| Part | Topic | Data |
|---|---|---|
| 0 | Setup: packages and project folder | |
| 1 | R basics: assignment, naming rules, vectors, data types, missing values, selecting rows, new columns, the pipe | gapminder, chickwts, Titanic |
| 2 | Wide vs long data; `colMeans()`/`rowMeans()` on wide data; `pivot_longer()`; grouped summaries | gapminder |
| 3 | Grammar of graphics: data, aesthetics, geoms; mapping vs setting; layers; choosing a chart | gapminder |
| 4 | Mean, median, mode, variance, standard deviation (built-in and by hand); histograms, density plots, boxplots, violin plots; log scales | gapminder |
| 5 | Bar charts: `geom_bar()` vs `geom_col()`; ordering; stacked, dodged and filled bars; simulated sampling variation | gapminder, Titanic |
| 6 | Line charts; the `group` aesthetic; summary lines; year stored as text | gapminder |
| 7 | Scatter plots, Pearson and Spearman correlation, fitted lines, overplotting, Anscombe's quartet | gapminder, anscombe |
| 8 | One-sample, two-sample and paired t-tests; one-way ANOVA with Tukey's HSD and residual checks; chi-square test with standardised residuals. Each test is shown with a plot. | gapminder, chickwts, Titanic |
| 9 | Facets: `facet_wrap()`, `facet_grid()`, free scales | gapminder |
| 10 | Labels, axis formats, scale limits vs `coord_cartesian()`, colour-blind-safe palettes, themes | gapminder |
| 11 | Text labels with ggrepel, highlighting, reference lines and shaded periods | gapminder |
| 12 | Combining plots with patchwork | gapminder |
| 13 | Saving with `ggsave()`: size, resolution, file format; alt text | gapminder |
| 14 | Solutions to the exercises at the end of Parts 1 to 13 | |
| 15 | Case study: female and male labour force participation rates | World Bank WDI |
| Appendices | Base R graphics and ggplot2 equivalents; common errors; further reading | |

## Data sources

- **gapminder**: life expectancy, GDP per capita (US$, inflation-adjusted) and population for 142 countries, 1952 to 2007, at five-year intervals. From the gapminder R package by Jennifer Bryan, an excerpt of data from the Gapminder Foundation. <https://CRAN.R-project.org/package=gapminder>
- **chickwts**, **Titanic**, **anscombe**: datasets included with R (package `datasets`).
- **World Bank World Development Indicators**: labour force participation rate, female (`SL.TLF.CACT.FE.ZS`) and male (`SL.TLF.CACT.MA.ZS`), % of population aged 15+, modelled ILO estimates, 1990 to 2023. Downloaded with the WDI R package. World Bank data are licensed under CC BY 4.0. <https://data.worldbank.org>

## Notes for instructors

- Each part ends with short exercises. Solutions are in Part 14, so the script can be run from top to bottom.
- Part 15 downloads the World Bank data the first time it runs and saves it to `data/lfpr_worldbank.csv`. To run the workshop without internet access, run Part 15 once beforehand and commit that file to the repository.
- Code that is meant to fail is either commented out (syntax errors) or wrapped in `try()`, so the script does not stop.
- Random steps (`sample()`, jittered points, ggrepel labels) use fixed seeds or are noted in comments. Jittered point positions change between runs.

## Licence

The code and teaching material in this repository are released under the MIT License (see `LICENSE`). The datasets keep their own licences, listed under Data sources.
