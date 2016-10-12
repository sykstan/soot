# load all the raw data
# and save it because reading in Excel files 
# is the bottleneck
# install.packages("ggplot2")
require(xlsx)
require(data.table)
require(plyr)

require(magrittr)


### ============== READING IN =============== ###
# s22.dt <- read.csv(file = "~/GoogleDrive/scs-it/data/S22 – benchmark noncovalent complexes.csv"
#                    , header = TRUE, sep = ",")

s22 <- read.xlsx(file = "/Users/zoz/Google Drive/Shared-w_-Me/Zoe-Sam/soot/HF/soot2.xlsx"
                      , sheetName = "S22", header = TRUE) %>%
    data.table()

s66 <- read.xlsx(file = "/Users/zoz/Google Drive/Shared-w_-Me/Zoe-Sam/soot/HF/soot2.xlsx"
                 , sheetName = "S66", header = TRUE) %>%
  data.table()

#il_bench.dt <- read.xlsx(file = "~/GoogleDrive/scs-it/data/jason_mp2_il1IP.xlsx"
#                         , header = TRUE, sheetName = "CCSDT_cp") %>%
#    data.table()

#il_sapt.dt <- read.table("~/GoogleDrive/scs-it/data/il_aDZ_sapt2plus3.edat"
#                         , sep = "|", header = TRUE, strip.white = TRUE) %>%
#    data.table()

# Ways to remove the column
#data$size      <- NULL

# ASSIGN NAMES TO COLUMNS
setnames(s22, c("sys", "vdz", "vtz", "avtz"))

setnames(s66, c("sys", "vdz", "vtz", "avtz"))

# ADD NEW COLUMNS
# REMOVE COMLUMNS
s22[, set := NULL]
il_sapt.dt[, Total.HF := NULL]

s22$set      <- "s22"   # Use the same value (0) for all rows
s66$set      <- "s66"

# COMBINE DATAFRAMES VERTICALLY
hf_raw <- rbind(s22, s66) 


# list of bases
#basisList <- c("CCD", "CCT", "CCQ", "ACCD", "ACCT", "ACCQ")

# omitting extrapolation (Thur 11 Feb 2016)
basisList <- c("VDZ", "VTZ", "aVQZ")



# combine into one
mp2.dt <- ldply(mp2.dt)
il_mp2.dt <- ldply(il_mp2.dt)

colnames(mp2.dt)[1] <- "basis"
colnames(il_mp2.dt)[1] <- "basis"

mp2.dt <- data.table(mp2.dt)
il_mp2.dt <- data.table(il_mp2.dt)

# basis column to factor
mp2.dt[ , basis := as.factor(basis)]
il_mp2.dt[ , basis := as.factor(basis)]

# create system/name column
il_mp2.dt[, system := as.factor(paste(chain, cation, anion, conf, sep = "-"))]
il_bench.dt[, system := as.factor(paste(chain, cation, anion, conf, sep = "-"))]
il_sapt.dt[, system := as.factor(paste(chain, cation, anion, conf, sep = "-"))]

# specify NA's
il_bench.dt[corrEn > 0, corrEn := NA]

save(list = c("basisList", "bench.dt", "il_bench.dt", "il_sapt.dt", "mp2.dt", "il_mp2.dt", "numbas.dt")
              , file = "~/GoogleDrive/scs-it/imported.data")