# load all the raw data
# and save it because reading in Excel files is the bottleneck

# copied from load.r of Sam's first srs-mp2 project
# unless otherwise mentioned, the data come from the same sources

require(xlsx)
require(data.table)
require(plyr)
require(magrittr)


### ============== READING IN =============== ###

# add interaction type from S66 paper 
# and Grafova JCTC 2010 paper
# Mon 09 May 2016


# ================= CCSD(T)/CBS benchmark energies ================== #
#                          AND                                        #
# ================= SAPT2+3/aVDZ energies =========================== #
# for S22 and S66, CCSD(T) and SAPT2+3 data in one sheet by Santiago
# BUT WE NEED SAPT2 energies, HENCE WILL READ IN THE OTHER VALUES
s88_ccsdt.dt <- read.xlsx(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_S66_MP2.xlsx"
                               , sheetName = "SAPT", header = TRUE) %>%
    data.table()

s22_sapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_aDZ_sapt2.edat"
                        , header = TRUE, sep = "|", strip.white = TRUE) %>%
    data.table()

s66_sapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_aDZ_sapt2.edat"
                          , header = TRUE, sep = "|", strip.white = TRUE) %>%
    data.table()

# s22_dz_sapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_DZ_sapt23.edat"
#                           , header = TRUE, sep = "|", strip.white = TRUE) %>%
#     data.table()
# 
# s66_dz_sapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_DZ_sapt23.edat"
#                           , header = TRUE, sep = "|", strip.white = TRUE) %>%
#     data.table()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #
# ----------------- all of the components!! ------------------------- #
s22_dz_allsapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_DZ_sapt23_allEn.edat"
                          , header = TRUE, sep = "|", strip.white = TRUE) %>%
    data.table()

s66_dz_allsapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_DZ_sapt23_allEn.edat"
                          , header = TRUE, sep = "|", strip.white = TRUE) %>%
    data.table()

s22_adz_allsapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_aDZ_sapt23_allEn.edat"
                                , header = TRUE, sep = "|", strip.white = TRUE) %>%
    data.table()

s66_adz_allsapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_aDZ_sapt23_allEn.edat"
                                , header = TRUE, sep = "|", strip.white = TRUE) %>%
    data.table()
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #


# for ILs
# formerly adapted from the spreadsheet jason_mp2_il1IP.xlsx, sheet CCSDT_cp
# now with ALL of Jason's energies (should be 174, no more corrEn > 0)
il_ccsdt.dt <- read.csv(file = "~/GoogleDrive/Zoe-Sam/soot/data/jason-CBS.csv"
                        , header = TRUE) %>%
    data.table()


# testccsd <- read.table("~/GoogleDrive/Zoe-Sam/soot/data/il_ccsdDT.edat", sep = "|", 
#                      header = TRUE, strip.white = TRUE) %>%
#     data.table()

# extracted 07 Oct 2016 from Raijin
il_sapt.dt <- read.table("~/GoogleDrive/Zoe-Sam/soot/data/il_aDZ_sapt2.edat"
                         , sep = "|", header = TRUE, strip.white = TRUE) %>%
    data.table()



# ================= MP2/VTZ OS & SS (& maybe RefEn for now) ======== #

# for S22 and S66
# omitting extrapolation (Thur 11 Feb 2016)
basisList <- c("VDZ", "VTZ", "VQZ", "aVDZ", "aVTZ", "aVQZ")

# read them in al list of data.frames, convert to data.table() later
# DO NOTE THAT AS OF 11 OCT 2016, THE S88 VALUES HAVE SCF ENERGIES AND 
# LOTS OF OTHER COMPONENTS, WHEREAS IL VALUES ONLY HAVE SPIN COMPONENT ENERGIES
s88_mp2.dt <- lapply(basisList, function(x) read.xlsx(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_S66_MP2.xlsx", 
                                                  sheetName = x, header = TRUE, 
                                                  colInd = c(1:23))) 
il_mp2.dt <- lapply(basisList, function(x) read.xlsx(file = "~/GoogleDrive/scs-it/data/jason_mp2_il1IP.xlsx", 
                                                     sheetName = x, header = TRUE))
# later
# ================= HF/aVQZ energies =============================== #
# from Zoe (09 Oct 2016)
# s22_hf.dt <- read.xlsx(file = "~/GoogleDrive/Zoe-Sam/soot/data/soot2.xlsx"
#                        , sheetName = "S22", header = TRUE) %>%
#     data.table()
# 
# s66_hf.dt <- read.xlsx(file = "~/GoogleDrive/Zoe-Sam/soot/data/soot2.xlsx"
#                        , sheetName = "S66", header = TRUE) %>%
#     data.table()




### ============== TOUCH-UP's ON RAW DATA =============== ###
# light! no merging of any kind yet

# omit charge-transfer complexes
s88_ccsdt.dt <- s88_ccsdt.dt[Suite != "CT"]
# apply factor again to drop CT from factor levels
s88_ccsdt.dt[, Suite := factor(Suite)]
s88_ccsdt.dt[, System := factor(System)]

# delete the SAPT columns for old s88
s88_ccsdt.dt[, c("Elst", "Exch", "Ind", "Disp", "CT", "Total", "categ", "santiagoCorr") := NULL]

# calculate correlation energy, by subtracting HF/aVQZ (from Zoe's soot2.xlsx)
s88_ccsdt.dt[, corrEn := benchmark - HF_aVQZ]
# then get rid of the columns
# s88_ccsdt.dt[, benchmark := NULL]
# s88_ccsdt.dt[, HF_aVQZ := NULL]


# SAPT columns
s22_sapt.dt[, Size := NULL]
s22_dz_allsapt.dt[, Size := NULL]
s22_adz_allsapt.dt[, Size := NULL]
s66_sapt.dt[, Size := NULL]
s66_dz_allsapt.dt[, Size := NULL]
s66_adz_allsapt.dt[, Size := NULL]
il_sapt.dt[, Size := NULL]

# Suite
s22_sapt.dt[, Suite := as.factor("S22")]
s22_dz_allsapt.dt[, Suite := as.factor("S22")]
s22_adz_allsapt.dt[, Suite := as.factor("S22")]
s66_sapt.dt[, Suite := as.factor("S66")]
s66_dz_allsapt.dt[, Suite := as.factor("S66")]
s66_adz_allsapt.dt[, Suite := as.factor("S66")]

# basis sets
s22_dz_allsapt.dt[, basis := as.factor("VDZ")]
s22_adz_allsapt.dt[, basis := as.factor("aVDZ")]
s66_dz_allsapt.dt[, basis := as.factor("VDZ")]
s66_adz_allsapt.dt[, basis := as.factor("aVDZ")]

s88_sapt.dt <- rbind(s22_sapt.dt, s66_sapt.dt)
s88_allsapt.dt <- rbind(s22_dz_allsapt.dt, s22_adz_allsapt.dt, s66_dz_allsapt.dt, s66_adz_allsapt.dt)

setnames(s88_sapt.dt, c("System" , "Electrostatics", "Exchange", "Induction", "Dispersion"
                        , "SAPT.Charge.Transfer", "Total.HF", "Total.SAPT2", "Total.SAPT2.3")
         , c("System", "Elst", "Exch", "Ind", "Disp", "CT", "SAPT.HF", "SAPT2", "SAPT2.3"))
# setnames(s66_sapt.dt, c("System" , "Electrostatics", "Exchange", "Induction", "Dispersion"
#                         , "SAPT.Charge.Transfer", "Total.HF", "Total.SAPT2", "Total.SAPT2.3")
#          , c("System", "Elst", "Exch", "Ind", "Disp", "CT", "SAPT.HF", "SAPT2", "SAPT2.3"))
setnames(il_sapt.dt, c("Chain", "Cation", "Anion", "Conf" 
                       , "Electrostatics", "Exchange", "Induction", "Dispersion"
                       , "SAPT.Charge.Transfer", "Total.HF", "Total.SAPT2", "Total.SAPT2.3")
         , c("chain", "cation", "anion", "conf", "Elst", "Exch", "Ind", "Disp", "CT", "SAPT.HF", "SAPT2", "SAPT2.3"))

# set keys for merging
setkey(s88_ccsdt.dt, System, Suite)
setkey(s88_sapt.dt, System, Suite)
setkey(s88_allsapt.dt, System, Suite, basis)

# merge new SAPT2 energies with ccsdt, S88
s88_both.dt <- merge(s88_ccsdt.dt, s88_sapt.dt, all = TRUE)

# 
names(s88_mp2.dt) <- basisList
names(il_mp2.dt) <- basisList

# combine into one
s88_mp2.dt <- ldply(s88_mp2.dt)
il_mp2.dt <- ldply(il_mp2.dt)

# column name of basis sets
colnames(s88_mp2.dt)[1] <- "basis"
colnames(il_mp2.dt)[1] <- "basis"

s88_mp2.dt <- data.table(s88_mp2.dt)
il_mp2.dt <- data.table(il_mp2.dt)

# basis column to factor
s88_mp2.dt[ , basis := as.factor(basis)]
il_mp2.dt[ , basis := as.factor(basis)]

# omit CT complexes
s88_mp2.dt <- s88_mp2.dt[Suite != "CT"]
# apply factor again to drop CT from factor levels
s88_mp2.dt[, Suite := factor(Suite)]
s88_mp2.dt[, System := factor(System)]


# create system/name column for IL174 (facilitate merging with S88)
il_ccsdt.dt[, System := as.factor(paste(chain, cation, anion, conf, sep = "-"))]
il_sapt.dt[, System := as.factor(paste(chain, cation, anion, conf, sep = "-"))]
il_mp2.dt[, System := as.factor(paste(chain, cation, anion, conf, sep = "-"))]

# setkeys for merging
setkey(il_ccsdt.dt, chain, cation, anion, conf, System)
setkey(il_sapt.dt, chain, cation, anion, conf, System)

# merge new SAPT energies with CCSD(T), IL174
il_both.dt <- merge(il_ccsdt.dt, il_sapt.dt)

# should we delete chain, cation, anion, conf for ILs?? or just drop them when merging, like so
all_both.dt <- rbind(s88_both.dt, il_both.dt[, !c("chain", "cation", "anion", "conf"), with = FALSE], fill = TRUE)
all_both.dt[is.na(Suite), Suite := "IL"]


# save for faster future loading
save(list = c("basisList", "s88_ccsdt.dt", "il_ccsdt.dt", "s22_sapt.dt", "s66_sapt.dt", "il_sapt.dt", "s88_allsapt.dt"
              , "s88_both.dt", "il_both.dt", "all_both.dt", "s88_mp2.dt", "il_mp2.dt")
     , file = "~/GoogleDrive/Zoe-Sam/soot/data/imported.data")
