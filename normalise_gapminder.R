library(RSQLite)

SQL_FILE = "data/gapminder.sqlite"

if(file.exists(SQL_FILE)){
  file.remove(SQL_FILE)
}

data_gapminder <- read.csv('data/gapminder-FiveYearData.csv')

continents <- data.frame(ID = 1:length(levels(data_gapminder$continent)),
                         Name = levels(data_gapminder$Continent)))

countries <- data.frame(ID = 1:length(levels(data_gapminder$country)),
                        Name = levels(data_gapminder$Country))

COUNTRY <- data_gapminder %>% group_by(country) %>% summarise(id = as.integer(unique(country)),
                                                              continent = as.character(unique(continent)))

COUNTRY <- data.frame(COUNTRY)

POPULATION <- data_gapminder[,c('country','year','pop')]
POPULATION$country <- as.integer(data_gapminder$country)

LIFE_EXP <- data_gapminder[,c('country','year','lifeExp')]
LIFE_EXP$country <- as.integer(data_gapminder$country)

GDP_PER_CAP <- data_gapminder[,c('country','year','gdpPercap')]
GDP_PER_CAP$country <- as.integer(data_gapminder$country)

# ReMerge data frames to check
new_data <- COUNTRY %>% 
  inner_join(POPULATION, by=c("id" = "country")) %>%
  inner_join(LIFE_EXP, by=c("id" = "country", "year" = "year")) %>%
  inner_join(GDP_PER_CAP, by=c("id" = "country", "year" = "year"))

new_data$continent <- factor(new_data$continent)
new_data <- data.frame(new_data)

all.equal(data_gapminder[,c('country','year','pop','continent','lifeExp','gdpPercap')],
          new_data[,c('country','year','pop','continent','lifeExp','gdpPercap')])


db <- dbConnect(SQLite(), dbname=SQL_FILE)

dbWriteTable(conn = db,
             name = "COUNTRY",
             value = COUNTRY,
             row.names = FALSE)

dbWriteTable(conn = db,
             name = "POPULATION",
             value = POPULATION,
             row.names = FALSE)

dbWriteTable(conn = db,
             name = "LIFE_EXP",
             value = LIFE_EXP,
             row.names = FALSE)

dbWriteTable(conn = db,
             name = "GDP_PER_CAP",
             value = GDP_PER_CAP,
             row.names = FALSE)

