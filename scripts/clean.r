# script to clean data and create 
# data objects to work with
# loads imported.data
# and saves to cleaned.data

require(data.table)
require(magrittr)
require(tidyr)

load(file = "~/GoogleDrive/Zoe-Sam/soot/data/imported.data")

# MP2 energies are still in Hartrees, and column names are still unintelligible
# f.g.e = fragment, ghost/real, energy
s88_mp2.dt <- gather(s88_mp2.dt, f.g.e, en, complex_rw2S:frag2_gwSCF) %>%
    data.table()

# convert to kJ/mol
s88_mp2.dt[, en := en * 2625.5]

s88_mp2.dt <- separate(s88_mp2.dt, f.g.e, c("sys_g", "spin_en"), sep = "w") %>%
    spread(sys_g, en) %>%
    data.table()

# similarly for ILs
il_mp2.dt <- gather(il_mp2.dt, f.g.e, en, complex_rwSS:frag2_gwOS) %>%
    data.table()

il_mp2.dt[, en := en * 2625.5]        # convert to kJ/mol

il_mp2.dt <- separate(il_mp2.dt, f.g.e, c("sys_g", "spin_en"), sep = "w") %>%
    spread(sys_g, en) %>%
    data.table()

# so that no numbers in future column names
s88_mp2.dt[ , spin_en := as.factor(spin_en)]
il_mp2.dt[ , spin_en := as.factor(spin_en)]
levels(s88_mp2.dt$spin_en) <- c("two", "OS", "SS", "SCF")  # original 2, 2S, 2T, SCF (after ordering due to as.factor)


### ============== SETTING KEYS AND FACTOR ORDERS =============== ###
# order by INCREASING basis set size
s88_mp2.dt$basis <- factor(s88_mp2.dt$basis, levels = basisList)
il_mp2.dt$basis <- factor(il_mp2.dt$basis, levels = basisList)
setkey(s88_mp2.dt, basis, System, Suite, spin_en)
setkey(il_mp2.dt, basis, System, chain, cation, anion, conf, spin_en)

# and others
setkey(all_both.dt, System, Suite)

### ============== CALCULATING NEW COLUMNS =============== ###
# only separated by spen, so that can calculate CP and nonCP
s88_mp2.dt[, nonCP := complex_r - frag1_r - frag2_r]
s88_mp2.dt[, CP := complex_r - frag1_g - frag2_g]

il_mp2.dt[, nonCP := complex_r - frag1_r - frag2_r]
il_mp2.dt[, CP := complex_r - frag1_g - frag2_g]

### ==================== SAVE STUFF ====================== ###
save(list = c("basisList", "all_both.dt", "s88_mp2.dt", "il_mp2.dt")
     , file = "~/GoogleDrive/Zoe-Sam/soot/data/cleaned.data")