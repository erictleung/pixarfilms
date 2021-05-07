# Contributing to pixarfilms

This outlines how to propose a change to pixarfilms.

## Fixing typos

Small typos or gramamtical errors in documentation may be edited directly using
the GitHub web interface, so long as the changes are made in the _source_ file.

- YES: you edit a roxygen comment in a `.R` file below `R/`.
- NO: you edit an `.Rd` file below `man/`.

## New data

If you find new data that could be added, please open an issue for us to
discuss further to see if it's within the scope of this project.

## New vignette

If you have analyzed this data and would like to share your analysis, feel free
to contribute your analysis as an RMarkdown document within the `vignette/`
directory.

## Out of date information

The data within this package is scraped or manually entered from websites like
Wikipedia. Take a look at the scripts in `data-raw/*.R` to see how the data was
collected.

If it was from Wikipedia or other open resources, feel free to edit Wikipedia
itself (when appropriate) to update the data. You are welcome to run the data
gathering script yourself, but I will personally run it otherwise if this is
brought up.

It the manual data entry information is out-of-date or incorrect, feel free to
make those edits and please make a comment within the script with your source
of update so that we can verify it.

## Code of Conduct

Please note that this project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
