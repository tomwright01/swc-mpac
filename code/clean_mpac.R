library(dplyr)
library(stringr)

SQL_FILE = "data/permits.sqlite"

if(file.exists(SQL_FILE)){
  file.remove(SQL_FILE)
}

data_mpac <- read.csv('data/permits.csv',
                      stringsAsFactors=FALSE)

data_mpac_clean <- data_mpac[,c('ROLL_NO', 
                                'rec_date',
                                'add_date',
                                'isu_date',
                                'LAST_REVIEW_DATE',
                                'comp_date',
                                'minor2',
                                'CURRENT_VALUE',
                                'FORECASTED_VALUE',
                                'reg',
                                'Zone',
                                'REGION',
                                'mpac_wd0',
                                'mpac_wd')]

# Convert reg to city
data_mpac_clean$City <- str_sub(data_mpac_clean$reg,4)

# Convert column names to lower case
names(data_mpac_clean) <- tolower(names(data_mpac_clean))

write.csv(data_mpac_clean,"data/permits_short.csv", row.names=FALSE)

# break into 3 datasets for inclusion in an sql table
mpac_types <- data_mpac_clean[,c('mpac_wd0','mpac_wd')]
mpac_types <- unique(mpac_types)
names(mpac_types) <- c('id','description')

mpac_regions <- data_mpac_clean[,c('region','zone','city')]
mpac_regions <- unique(mpac_regions)
names(mpac_regions) <- c('id','zone','city')

mpac_permits <- data_mpac_clean[,c('roll_no',
                                   'rec_date',
                                   'add_date',
                                   'isu_date',
                                   'last_review_date',
                                   'comp_date',
                                   'minor2',
                                   'current_value',
                                   'forecasted_value',
                                   'region',
                                   'mpac_wd0')]

names(mpac_permits) <- c('roll_no',
                         'rec_date',
                         'add_date',
                         'isu_date',
                         'last_review_date',
                         'comp_date',
                         'minor2',
                         'current_value',
                         'forecasted_value',
                         'region_id',
                         'work_type_id')

# database work
db <- src_sqlite(SQL_FILE, create=TRUE)

copy_to(dest = db,
        df = mpac_permits,
        name = "PERMITS",
        temporary = FALSE)

copy_to(dest = db,
        df = mpac_regions,
        name = "REGIONS",
        temporary = FALSE)

copy_to(dest = db,
        df = mpac_types,
        name = "WORK_TYPES",
        temporary = FALSE)

