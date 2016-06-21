library(ggplot2)

# load the data from the csv file
permits <- read.csv("data/permits_short.csv", header = TRUE)

# convert the data columns from strings to date objects
permits$rec_date <- as.Date(permits$rec_date, date_format)
permits$add_date <- as.Date(permits$add_date, date_format)
permits$isu_date <- as.Date(permits$isu_date, date_format)
permits$last_review_date <- as.Date(permits$last_review_date, date_format)
permits$comp_date <- as.Date(permits$comp_date, date_format)

# fix the problem with 0 values dates in the comp_date column
permits[permits$comp_date==as.Date('1582-10-14', format='%Y-%m-%d'),'comp_date'] <- NA

# calculate the total_time for completed permits
permits$total_time <- permits$comp_date - permits$rec_date

# add a column with just the year value for the permit issue date
permits$isu_year <- as.integer(format(permits$isu_date,'%Y'))

# examine the permits data frame
nrow(permits)
ncol(permits)

head(permits)

# plot time taken against isu_year
ggplot(data = permits, aes(x=isu_year, y=total_time, by=mpac_wd)) +
  geom_line(aes(color=city)) + geom_point()

# and a density plot for fun
ggplot(data = permits, aes(x = current_value, fill=mpac_wd)) +
  geom_density(alpha=0.6) + facet_wrap( ~ city) + scale_x_log10()