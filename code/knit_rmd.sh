# a simple wrapper to knit .Rmd files from the shell.
# Inputs: full path the the .Rmd file

input = $1
/usr/bin/Rscript -e "library(knitr); knit(\"${input}\")"