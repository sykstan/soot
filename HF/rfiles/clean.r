# script to clean data and create 
# data objects to work with
# loads imported.data
# and saves to cleaned.data

require(data.table)
require(magrittr)
require(tidyr)

load(file = "~/GoogleDrive/scs-it/imported.data")


### ============== DATA MUNGING =============== ###
# extrapolation: general formula
# why SCS scaled for 2T, 2 (weird, uses 2S), SCF, frag1_2S, 
# different numbers for frag1_2T and frag1_2
# not scaled for complex_2S??
# and no numbers for frag2_2T onwards (funny coeff for frag1_SCF and frag2_2S)
# >> SCF(intEn, VQZ) + (3^3 * 2(intEn, VTZ) - 4^4 * 2(intEn, VQZ)) / (-37)

# weird, "." wouldn't work as a separator so used "w"
mp2.dt <- gather(mp2.dt, f.g.e, en, complex_rw2S:frag2_gwSCF) %>%
    data.table()

mp2.dt[, en := en * 2625.5]         # convert to kJ/mol

mp2.dt <- separate(mp2.dt, f.g.e, c("sys_g", "spen"), sep = "w") %>%
    spread(sys_g, en) %>%
    data.table()

il_mp2.dt <- gather(il_mp2.dt, f.g.e, en, complex_rwSS:frag2_gwOS) %>%
    data.table()

il_mp2.dt[, en := en * 2625.5]        # convert to kJ/mol

il_mp2.dt <- separate(il_mp2.dt, f.g.e, c("sys_g", "spen"), sep = "w") %>%
    spread(sys_g, en) %>%
    data.table()

# so that no numbers in future column names
mp2.dt[ , spen := as.factor(spen)]
il_mp2.dt[ , spen := as.factor(spen)]
levels(mp2.dt$spen) <- c("two", "OS", "SS", "SCF")  # original 2, 2S, 2T, SCF

#write.table(il_spen.dt, file = "il_spen.dt", sep = " | ", row.names = FALSE)

### ============== SETTING KEYS AND FACTOR ORDERS =============== ###
# order by INCREASING basis set size
mp2.dt$basis <- factor(mp2.dt$basis, levels = basisList)
il_mp2.dt$basis <- factor(il_mp2.dt$basis, levels = basisList)
setkey(mp2.dt, basis, system, suite, spen)
setkey(il_mp2.dt, basis, system, chain, cation, anion, conf, spen)
setkey(bench.dt, system, suite, categ)
setkey(il_bench.dt, system, chain, cation, anion, conf)
setkey(il_sapt.dt, system, chain, cation, anion, conf)

### =========== ILs merge SAPT with CCSD(T) ============== ###
il_bench.dt <- merge(il_bench.dt, il_sapt.dt, all = TRUE)
### ======= ILs benchmark merging--outer merge =========== ###


### ============== CALCULATING NEW COLUMNS =============== ###
# only separated by spen, so that can calculate cp and ncp
mp2.dt[, ncp := complex_r - frag1_r - frag2_r]
mp2.dt[, cp := complex_r - frag1_g - frag2_g]

il_mp2.dt[, ncp := complex_r - frag1_r - frag2_r]
il_mp2.dt[, cp := complex_r - frag1_g - frag2_g]

# calculate aVQZ SCF, to subtract from benchmark to obtain correlation energy
tmp.SCF <- mp2.dt[basis == "aVQZ" & spen == "SCF"][ ,c("system", "suite", "cp"), with = FALSE]
setkey(tmp.SCF, system, suite)     # for merging

bench.dt <- tmp.SCF[bench.dt]           # merge
setnames(bench.dt, "cp", "HF")          # name change
bench.dt[, corrEn := benchmark - HF]    # correlation correction
bench.dt[, santiagoCorr := 2625.5 * santiagoCorr]       # convert to kJ/mol




# set up categories by 25% rule
# note that all systems have Disp contributing to more than 25% of Total
bench.dt[ Ind / Total > 0.25 & (CT < -4 | CT / Total > 0.25), form := "IDC"]
bench.dt[ Ind / Total > 0.25 & CT / Total < 0.25, form := "ID"]
bench.dt[ Ind / Total < 0.25 & CT / Total < 0.25, form := "D"]

## technically should be in idc.r, but this is needed for why_ncp.r

# # same for ILs
# # note however, CT is larger for ILs, not sure if we'll get sensible distributions
# il_bench.dt[ Ind / Total > 0.25 & CT < -4, form := "IDC"]
# il_bench.dt[ Ind / Total > 0.25 & CT / Total < 0.25, form := "ID"]
# il_bench.dt[ Ind / Total < 0.25 & CT / Total < 0.25, form := "D"]
################ kinda very bad #####################


### ================================================= ###
### ========= for S88 ======== ###
spen.dt <- gather(mp2.dt[spen == "OS" | spen == "SS", !c("frag1_g", "frag2_g", "cp"), with = FALSE]      # omit unraw data cols
                  , comp, en, complex_r:ncp) %>%
    spread(spen, en) %>%
    data.table()

spen.dt[, ratio := OS / SS]

spen.dt <- gather(spen.dt, spen, en, OS:ratio) %>%
    unite(lol, spen, comp, sep = ".") %>%
    spread(lol, en) %>%
    data.table()

# shorter names
setnames(spen.dt
         , c("OS.complex_r", "OS.frag1_r", "OS.frag2_r"
             , "SS.complex_r", "SS.frag1_r", "SS.frag2_r"
             , "ratio.complex_r", "ratio.frag1_r", "ratio.frag2_r")
         , c("OS.c", "OS.1", "OS.2"
             , "SS.c", "SS.1", "SS.2"
             , "ratio.c", "ratio.1", "ratio.2"))
setkey(spen.dt, basis, system, suite)

### ======= for ILs ======= ###
il_spen.dt <- gather(il_mp2.dt[, !c("frag1_g", "frag2_g", "cp"), with = FALSE]      # omit unraw data cols
                     , comp, en, complex_r:ncp) %>%
    spread(spen, en) %>%
    data.table()

il_spen.dt[, ratio := OS / SS]

il_spen.dt <- gather(il_spen.dt, spen, en, OS:ratio) %>%
    unite(lol, spen, comp, sep = ".") %>%
    spread(lol, en) %>%
    data.table()

# shorter names
setnames(il_spen.dt
         , c("OS.complex_r", "OS.frag1_r", "OS.frag2_r"
             , "SS.complex_r", "SS.frag1_r", "SS.frag2_r"
             , "ratio.complex_r", "ratio.frag1_r", "ratio.frag2_r")
         , c("OS.c", "OS.1", "OS.2"
             , "SS.c", "SS.1", "SS.2"
             , "ratio.c", "ratio.1", "ratio.2"))
setkey(il_spen.dt, basis, system, chain, cation, anion, conf)



# merge with benchmarks
spen.dt <- merge(bench.dt[, !c("HF", "categ", "benchmark", "santiagoCorr", "form"), with = FALSE], spen.dt)
il_spen.dt <- merge(il_bench.dt, il_spen.dt)



### ================================================= ###
### =========== COMBINE S88 and ILs NCP MP2 DATA ========== ###
# how about merge spen.dt with il_spen.dt; fill suite column with NA for ILs
all_spen.dt <- rbind(spen.dt[, !c("benchmark"), with = FALSE]
                     , il_spen.dt[, !c("chain", "cation", "anion", "conf"), with = FALSE]
                     , fill = TRUE)
# add factor in
all_spen.dt[is.na(suite), suite := as.factor("IL")]

setkey(all_spen.dt, system, suite, basis)
### ================================================= ###
### ================================================= ###


### ================ FOR CP BOOTSTRAP =================== ###
### ================================================= ###
cp.spen.dt <- gather(mp2.dt[spen == "OS" | spen == "SS", !c("frag1_r", "frag2_r", "ncp"), with = FALSE]      # omit unraw data cols
                  , comp, en, complex_r:cp) %>%
    spread(spen, en) %>%
    data.table()

cp.spen.dt[, ratio := OS / SS]
cp.spen.dt <- gather(cp.spen.dt, spen, en, OS:ratio) %>%
    unite(lol, spen, comp, sep = ".") %>%
    spread(lol, en) %>%
    data.table()

# ILs
cp.il_spen.dt <- gather(il_mp2.dt[, !c("frag1_r", "frag2_r", "ncp"), with = FALSE]      # omit unraw data cols
                     , comp, en, complex_r:cp) %>%
    spread(spen, en) %>%
    data.table()

cp.il_spen.dt[, ratio := OS / SS]

cp.il_spen.dt <- gather(cp.il_spen.dt, spen, en, OS:ratio) %>%
    unite(lol, spen, comp, sep = ".") %>%
    spread(lol, en) %>%
    data.table()

# rename to shorter column names
setnames(cp.spen.dt
         , c("OS.complex_r", "OS.frag1_g", "OS.frag2_g"
             , "SS.complex_r", "SS.frag1_g", "SS.frag2_g"
             , "ratio.complex_r", "ratio.frag1_g", "ratio.frag2_g")
         , c("OS.c", "OS.1", "OS.2"
             , "SS.c", "SS.1", "SS.2"
             , "ratio.c", "ratio.1", "ratio.2"))
setkey(cp.spen.dt, basis, system, suite)

setnames(cp.il_spen.dt
         , c("OS.complex_r", "OS.frag1_g", "OS.frag2_g"
             , "SS.complex_r", "SS.frag1_g", "SS.frag2_g"
             , "ratio.complex_r", "ratio.frag1_g", "ratio.frag2_g")
         , c("OS.c", "OS.1", "OS.2"
             , "SS.c", "SS.1", "SS.2"
             , "ratio.c", "ratio.1", "ratio.2"))
setkey(cp.il_spen.dt, basis, system, chain, cation, anion, conf)


# merge with benchmarks
cp.spen.dt <- merge(bench.dt[, !c("HF", "categ", "benchmark", "santiagoCorr", "form"), with = FALSE], cp.spen.dt)
cp.il_spen.dt <- merge(il_bench.dt, cp.il_spen.dt)


### ================================================== ###
### ================ COMBINE ALL CP TOGETHER ========= ###
cp.all_spen.dt <- rbind(cp.spen.dt[, !c("benchmark"), with = FALSE]
                     , cp.il_spen.dt[, !c("chain", "cation", "anion", "conf"), with = FALSE]
                     , fill = TRUE)
# add factor in
cp.all_spen.dt[is.na(suite), suite := as.factor("IL")]

setkey(cp.all_spen.dt, system, suite, basis)
### ================================================== ###
### ================================================== ###



### ============= NUMBER OF BASIS FNs ================ ###
numbas.dt$basis <- factor(numbas.dt$basis, levels = basisList)
numbas.dt <- merge(numbas.dt, spen.dt, by = c("basis", "suite", "system"))
setkey(numbas.dt, basis, suite, system)
### ================================================== ###



### ================ SAVE STUFF ====================== ###
save(list = c("basisList", "mp2.dt", "il_mp2.dt", "bench.dt", "spen.dt", "il_spen.dt", "all_spen.dt"
              , "cp.all_spen.dt", "numbas.dt")
     , file = "~/GoogleDrive/scs-it/cleaned.data")