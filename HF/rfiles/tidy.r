#basis = c("vdz","vtz","vqz","avdz","avtz","avqz")
#=====================================================================================#

# ASSIGN NAMES TO COLUMNS

setnames(s22, c("sys", "VDZ", "VTZ", "VQZ", "aVDZ","aVTZ","aVQZ"))

setnames(s66, c("sys", "VDZ", "VTZ", "VQZ", "aVDZ","aVTZ","aVQZ"))

setnames(il174, c("sys","p", "VDZ", "VTZ", "VQZ", "aVDZ","aVTZ","aVQZ"))

setnames(s88_mp2.dt, c("basis", "System","Suite"),c("bs", "sys","set"))

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


# ADD ACCQ TO SAPT TABLE

setkey(il174,      "cation", "anion", "conf")
setkey(il174_sapt, "cation", "anion", "conf")

#merge(il174_sapt, il174[, c("cation", "anion", "conf", "avqz")], by = c("cation", "anion", "conf"))
il174_sapt <- il174_sapt[il174[, c("cation", "anion", "conf", "aVDZ","aVQZ"), with = FALSE]]

#=====================================================================================#

# GATHER INTO OBSERVATIONS

# PUTS ALL BS INTO ONE COLUMN
il174 <- gather(il174, "bs", "energy", 5:10)
# SPLITS CP AND NON-CP COLUMN CALLED "p" AND SEPARTES ENERGIES BETWEEN THE NEW ROWS
il174 <- data.table(spread(il174, "p", "energy"))


sets <- data.table(gather(sets, "bs", "nonCP", 2:7))

#=====================================================================================#

# ADD  NON-CP HF TO SETS

#s88_mp2.dt[spin_en == "SCF", ]

#merge(il174_sapt, il174[, c("cation", "anion", "conf", "avqz")], by = c("cation", "anion", "conf"))
s88_mp2 <- data.table( s88_mp2.dt[spin_en == "SCF", ] )

setkey(sets, "sys", "set", "bs")
setkey(s88_mp2, "sys", "set", "bs")
sets$nonCP <- NULL
sets <- sets[s88_mp2[, c("sys", "set", "bs", "nonCP","CP"), with = FALSE]]

remove(s88_mp2, s88_mp2.dt)

#=====================================================================================#


# HF SCALING ON TESTS SETS // ERRORS

sets$sc_vdz  <- (sets$vdz/2) * 0.875 + -10.9 #+ 13.2

sets$sc_vtz  <- (sets$vtz/2) * 0.928 + -12.5 #+ 13.2


sets$vdz_err <- sets$avqz/2 - sets$sc_vdz

sets$vtz_err <- sets$avqz/2 - sets$sc_vtz


#=====================================================================================#

df <- data.frame(il174_sapt$avqz - il174_sapt$avdz, il174_sapt$avqz - il174_sapt$tothf)

setnames(df, c("avqz - avdz","avqz - SAPT0HF"))

hf_diff   = il174_sapt$avqz - il174_sapt$avdz
sapt_diff = il174_sapt$avqz - il174_sapt$tothf


