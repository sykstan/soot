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

s22 <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/data/soot.xlsx",sep='')
                 , sheetName = "S22", header = TRUE) %>%
  data.table()

s66 <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/data/soot.xlsx",sep='')
                 , sheetName = "S66", header = TRUE) %>%
  data.table()


il2ip <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/data/orig-il-int.xlsx",sep='')
                 , sheetName = "Sheet1", header = TRUE) %>%
    data.table()

il174 <- read.xlsx(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/HF/data/il174.xlsx",sep='')
                , sheetName = "Sheet1", header = TRUE) %>%
    data.table()

il174_sapt <- read.table(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/data/il_aDZ_HF.edat",sep=""),
                    sep='|', strip=TRUE, header = TRUE) %>%
    data.table()

s22_sapt_vdz <- read.table(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/data/S22_DZ_sapt23_allEn.edat",sep=""),
                         sep='|', strip=TRUE, header = TRUE) %>%
  data.table()

s22_sapt_avdz <- read.table(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/data/S22_aDZ_sapt23_allEn.edat",sep=""),
                          sep='|', strip=TRUE, header = TRUE) %>%
  data.table()

s66_sapt_vdz <- read.table(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/data/S66_DZ_sapt23_allEn.edat",sep=""),
                           sep='|', strip=TRUE, header = TRUE) %>%
  data.table()

s66_sapt_avdz <- read.table(file = paste(path,"/Shared-w_-Me/Zoe-Sam/soot/data/S66_aDZ_sapt23_allEn.edat",sep=""),
                            sep='|', strip=TRUE, header = TRUE) %>%
  data.table()

# FROM SAM
load(file = paste(path, "/Shared-w_-Me/Zoe-Sam/soot/data/cleaned.data",sep = ''))

remove(path, all_both.dt, all_mp2.dt, il_mp2.dt)

