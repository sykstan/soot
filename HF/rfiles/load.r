# load all the raw data
# and save it because reading in Excel files 
# is the bottleneck
# install.packages("ggplot2")
require(xlsx)
require(data.table)
require(plyr)
require(magrittr)
require(tidyr)


### ============== READING IN =============== ###


#path = "/Users/zoz/Google Drive"  # HOME PC 
path  = "/Users/zoes/GoogleDrive" # WORK MAC

s22 <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/soot.xlsx",sep='')
                 , sheetName = "S22", header = TRUE) %>%
  data.table()

s66 <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/soot.xlsx",sep='')
                 , sheetName = "S66", header = TRUE) %>%
  data.table()


il2ip <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/orig-il-int.xlsx",sep='')
                 , sheetName = "Sheet1", header = TRUE) %>%
    data.table()

il174 <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/il174.xlsx",sep='')
                , sheetName = "Sheet1", header = TRUE) %>%
    data.table()

il174_sapt <- read.table(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/data/il_aDZ_HF.edat",sep=""),
                    sep='|', strip=TRUE, header = TRUE) %>%
    data.table()

load(file = paste(path, "/Shared-w_-Me/Zoe-Sam/soot/data/cleaned.data",sep = ''))

remove(path)

#=====================================================================================#

# ASSIGN NAMES TO COLUMNS

setnames(s22, c("sys", "vdz", "vtz", "vqz", "avdz","avtz","avqz"))

setnames(s66, c("sys", "vdz", "vtz", "vqz", "avdz","avtz","avqz"))

setnames(il174, c("sys", "vdz", "vtz", "vqz", "avdz","avtz","avqz"))

setnames(il174_sapt, c("size", "r", "cationtype", "anion", "conf","elst10","exch10","ind20","exchind20","hf2","hf3","tothf"))

# tothf = elst10 + exch10 + ind20 + exchind20 + hf2 (delta E_HF^(2)) 
# il174_sapt[, tothf - elst10 - exch10 - ind20 - exchind20 - hf2]

#=====================================================================================#

# ADD NEW COLUMNS // REMOVE COMLUMNS // COMBINE D.FRAMES

s22$set      <- "s22"   # Use the same value (0) for all rows
s66$set      <- "s66"
il174$set    <- "il174"
il174_sapt$cation    <- paste("c",il174_sapt$r,"m", il174_sapt$cationtype, sep = "")

# COMBINE DATAFRAMES VERTICALLY
sets <- rbind(s22, s66) 

remove(s22, s66)

# SPLIT COLUMNS
il174 <- separate(data=il174, col=sys, into=c("cation","anion","conf"),sep="-", extra="drop")

#=====================================================================================#

# HF SCALING ON TESTS SETS // ERRORS

sets$sc_vdz  <- (sets$vdz/2) * 0.875 + -10.9 #+ 13.2

sets$sc_vtz  <- (sets$vtz/2) * 0.928 + -12.5 #+ 13.2


sets$vdz_err <- sets$avqz/2 - sets$sc_vdz

sets$vtz_err <- sets$avqz/2 - sets$sc_vtz

#=====================================================================================#

#ADD ACCQ TO SAPT TABLE

setkey(il174, cation, anion, conf)
setkey(il174_sapt, cation, anion, conf)

#merge(il174_sapt, il174[, c("cation", "anion", "conf", "avqz")], by = c("cation", "anion", "conf"))
il174_sapt <- il174_sapt[il174[, c("cation", "anion", "conf", "avdz","avqz"), with = FALSE]]

#=====================================================================================#

df <- data.frame(il174_sapt$avqz - il174_sapt$avdz, il174_sapt$avqz - il174_sapt$tothf)

setnames(df, c("avqz - avdz","avqz - SAPT0HF"))

hf_diff   = il174_sapt$avqz - il174_sapt$avdz
sapt_diff = il174_sapt$avqz - il174_sapt$tothf



