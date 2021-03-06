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

il_mp2.dt[, Suite := as.factor("IL")]

# so that no numbers in future column names
s88_mp2.dt[ , spin_en := as.factor(spin_en)]
il_mp2.dt[ , spin_en := as.factor(spin_en)]
levels(s88_mp2.dt$spin_en) <- c("two", "OS", "SS", "SCF")  # original 2, 2S, 2T, SCF (after ordering due to as.factor)


### ============== SETTING KEYS AND FACTOR ORDERS =============== ###
# order by INCREASING basis set size
s88_mp2.dt$Basis <- factor(s88_mp2.dt$Basis, levels = basisList)
il_mp2.dt$Basis <- factor(il_mp2.dt$Basis, levels = basisList)
setkey(s88_mp2.dt, Basis, System, Suite, spin_en)
setkey(il_mp2.dt, Basis, System, Suite, chain, cation, anion, conf, spin_en)

# and others
setkey(all_both.dt, System, Suite)

### ============== CALCULATING NEW COLUMNS =============== ###
# only separated by spen, so that can calculate CP and nonCP
s88_mp2.dt[, nonCP := complex_r - frag1_r - frag2_r]
s88_mp2.dt[, CP := complex_r - frag1_g - frag2_g]

il_mp2.dt[, nonCP := complex_r - frag1_r - frag2_r]
il_mp2.dt[, CP := complex_r - frag1_g - frag2_g]

### ============== MERGING MP2 ENERGIES, S88 & IL174 ================== ###
to_merge.mp2 <- c("Basis", "System", "Suite", "spin_en", "nonCP", "CP")
il_mp2.dt[, to_merge.mp2, with = FALSE ]
s88_mp2.dt[spin_en == "OS" | spin_en == "SS", to_merge.mp2, with = FALSE]

# bind, longify nonCP and CP, then spread to OS and SS
# gather(name-of-new-key, name-of-new-value, range-of-columns)
# spread(factor-column-to-spread, actual-values-to-spread)
# factor column becomes column names, with corresponding values under
all_mp2.dt <- rbind(s88_mp2.dt[spin_en == "OS" | spin_en == "SS", to_merge.mp2, with = FALSE]
                    , il_mp2.dt[, to_merge.mp2, with = FALSE ]) %>%
    gather(comp, en, nonCP:CP) %>%
    spread(spin_en, en) %>%
    data.table()
# should be 3348 = 279 * 6 * 2 rows (279 = 191 + 88)


### ==================== SAVE STUFF ====================== ###
save(list = c("basisList", "all_both.dt", "all_mp2.dt")
     , file = "~/GoogleDrive/Zoe-Sam/soot/data/cleaned.data")
