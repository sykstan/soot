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


# ================= S88 CCSD(T)/CBS benchmark energies ================== #

# for S22 and S66, CCSD(T) and SAPT2+3 data in one sheet by Santiago
# BUT WE NEED SAPT2 energies, HENCE WILL READ IN THE OTHER VALUES
s88_ccsdt.dt <- read.xlsx(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_S66_MP2.xlsx"
                               , sheetName = "SAPT", header = TRUE) %>%
    data.table()

s88_ccsdt.dt <- s88_ccsdt.dt[Suite != "CT"]         # omit charge-transfer complexes
s88_ccsdt.dt[, Suite := factor(Suite)]              # apply factor again to drop CT from factor levels
s88_ccsdt.dt[, System := factor(System)]

# delete the SAPT columns for old s88
s88_ccsdt.dt[, c("Elst", "Exch", "Ind", "Disp", "CT", "Total", "categ", "santiagoCorr") := NULL]

# calculate correlation energy, by subtracting HF/aVQZ (from Zoe's soot2.xlsx)
s88_ccsdt.dt[, corrEn := benchmark - HF_aVQZ]
# then get rid of the columns (or maybe not)
# s88_ccsdt.dt[, benchmark := NULL]
# s88_ccsdt.dt[, HF_aVQZ := NULL]


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #
# ================= SAPT2+3/aVDZ energies =========================== #
# ----------------- all of the components!! ------------------------- #
s22_dz_sapt.dt <- data.table(Suite = as.factor("S22"), Basis = as.factor("VDZ")
                             , read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_DZ_sapt23_allEn.edat"
                                          , header = TRUE, sep = "|", strip.white = TRUE))

s66_dz_sapt.dt <- data.table(Suite = as.factor("S66"), Basis = as.factor("VDZ")
                             , read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_DZ_sapt23_allEn.edat"
                          , header = TRUE, sep = "|", strip.white = TRUE))

s22_adz_sapt.dt <- data.table(Suite = as.factor("S22"), Basis = as.factor("aVDZ")
                                 , read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_aDZ_sapt23_allEn.edat"
                                , header = TRUE, sep = "|", strip.white = TRUE))

s66_adz_sapt.dt <- data.table(Suite = as.factor("S66"), Basis = as.factor("aVDZ")
                                 , read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_aDZ_sapt23_allEn.edat"
                                , header = TRUE, sep = "|", strip.white = TRUE))

s88_sapt.dt <- rbind(s22_dz_sapt.dt, s22_adz_sapt.dt, s66_dz_sapt.dt, s66_adz_sapt.dt)
# 
# s22_sapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S22_aDZ_sapt2.edat"
#                           , header = TRUE, sep = "|", strip.white = TRUE) %>%
#     data.table()
# 
# s66_sapt.dt <- read.table(file = "~/GoogleDrive/Zoe-Sam/soot/data/S66_aDZ_sapt2.edat"
#                           , header = TRUE, sep = "|", strip.white = TRUE) %>%
#     data.table()
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #


# ************************ MERGING CCSD(T) and SAPT *********************** #
# set keys for merging
setkey(s88_ccsdt.dt, System, Suite)
setkey(s88_sapt.dt, System, Suite, Basis)

# ============>   ACTUAL MERGE   <============= #
s88_both.dt <- s88_ccsdt.dt[s88_sapt.dt]
# ************************************************************************* #



# ================= ILs CCSD(T)/CBS benchmark energies ================== #

# formerly adapted from the spreadsheet jason_mp2_il1IP.xlsx, sheet CCSDT_cp
# now with ALL of Jason's energies (should be 174, no more corrEn > 0)
il_ccsdt.dt <- read.csv(file = "~/GoogleDrive/Zoe-Sam/soot/data/jason-CBS.csv"
                        , header = TRUE) %>%
    data.table()

# testccsd <- read.table("~/GoogleDrive/Zoe-Sam/soot/data/il_ccsdDT.edat", sep = "|", 
#                      header = TRUE, strip.white = TRUE) %>%
#     data.table()

# extracted 07 Oct 2016 from Raijin
il_sapt.dt <- data.table(Suite = as.factor("IL"), Basis = as.factor("aVDZ")
                         , read.table("~/GoogleDrive/Zoe-Sam/soot/data/il_aDZ_sapt2plus3_allEn.edat"
                                      , sep = "|", header = TRUE, strip.white = TRUE))
# ======================================================================== #

# ************************************************************************ #
# create System column
il_ccsdt.dt[, System := as.factor(paste(chain, cation, anion, conf, sep = "-"))]
il_sapt.dt[, System := as.factor(paste(Chain, Cation, Anion, Conf, sep = "-"))]

# setkeys for merging
setkey(il_ccsdt.dt, chain, cation, anion, conf, System)
setkey(il_sapt.dt, Chain, Cation, Anion, Conf, System)

# end up with 174 due to missing ntf2 values
il_both.dt <- merge(il_ccsdt.dt[, c("System", "corrEn"), with = FALSE], il_sapt.dt, by = c("System"))

# ************************************************************************ #


# ++++++++++++++++++++++++++ MERGING BOTH ++++++++++++++++++++++++++++++++ #
all_both.dt <- rbind(s88_both.dt[, !c("HF_aVQZ", "benchmark"), with = FALSE]
                     , data.table(il_both.dt[, !c("Chain", "Cation", "Anion", "Conf"), with = FALSE]))
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #



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
# note that the last two columns for ILs are actually added (13 Oct 2016)
# they are complex_rwSCF = E_int_HF_nonCP & complex_gwSCF = E_int_HF_CP
# ACTUALLY, STILL READING FROM OLD FILE, NO CHANGE FOR NOW
il_mp2.dt <- lapply(basisList, function(x) read.xlsx(file = "~/GoogleDrive/scs-it/data/jason_mp2_il1IP.xlsx", 
                                                     sheetName = x, header = TRUE))

names(s88_mp2.dt) <- basisList              # name sheet by basis
names(il_mp2.dt) <- basisList

s88_mp2.dt <- ldply(s88_mp2.dt)             # combine into one
il_mp2.dt <- ldply(il_mp2.dt)

colnames(s88_mp2.dt)[1] <- "Basis"          # column name of basis sets
colnames(il_mp2.dt)[1] <- "Basis"

s88_mp2.dt <- data.table(s88_mp2.dt)        # make them data.tables
il_mp2.dt <- data.table(il_mp2.dt)

s88_mp2.dt[ , Basis := as.factor(Basis)]    # basis column to factor
il_mp2.dt[ , Basis := as.factor(Basis)]

s88_mp2.dt <- s88_mp2.dt[Suite != "CT"]     # omit CT complexes

s88_mp2.dt[, Suite := factor(Suite)]        # apply factor again to drop CT from factor levels
s88_mp2.dt[, System := factor(System)]


# create system/name column for IL174 (facilitate merging with S88)
il_mp2.dt[, System := as.factor(paste(chain, cation, anion, conf, sep = "-"))]

# MERGING FOR MP2 TO BE DONE IN CLEAN.R


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

# 
# setnames(s88_sapt.dt, c("System" , "Electrostatics", "Exchange", "Induction", "Dispersion"
#                         , "SAPT.Charge.Transfer", "Total.HF", "Total.SAPT2", "Total.SAPT2.3")
#          , c("System", "Elst", "Exch", "Ind", "Disp", "CT", "SAPT.HF", "SAPT2", "SAPT2.3"))
# # setnames(s66_sapt.dt, c("System" , "Electrostatics", "Exchange", "Induction", "Dispersion"
# #                         , "SAPT.Charge.Transfer", "Total.HF", "Total.SAPT2", "Total.SAPT2.3")
# #          , c("System", "Elst", "Exch", "Ind", "Disp", "CT", "SAPT.HF", "SAPT2", "SAPT2.3"))
# setnames(il_sapt.dt, c("Chain", "Cation", "Anion", "Conf" 
#                        , "Electrostatics", "Exchange", "Induction", "Dispersion"
#                        , "SAPT.Charge.Transfer", "Total.HF", "Total.SAPT2", "Total.SAPT2.3")
#          , c("chain", "cation", "anion", "conf", "Elst", "Exch", "Ind", "Disp", "CT", "SAPT.HF", "SAPT2", "SAPT2.3"))



# save for faster future loading
save(list = c("basisList", "all_both.dt", "s88_mp2.dt", "il_mp2.dt")
     , file = "~/GoogleDrive/Zoe-Sam/soot/data/imported.data")
