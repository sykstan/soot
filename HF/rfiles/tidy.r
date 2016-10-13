
#=====================================================================================#

# ASSIGN NAMES TO COLUMNS

setnames(s22, c("sys", "VDZ", "VTZ", "VQZ", "aVDZ","aVTZ","aVQZ"))

setnames(s66, c("sys", "VDZ", "VTZ", "VQZ", "aVDZ","aVTZ","aVQZ"))

setnames(il174, c("sys","p", "VDZ", "VTZ", "VQZ", "aVDZ","aVTZ","aVQZ"))

setnames(il2ip, c("cat","an", "r", "conf", "VDZ", "VTZ", "aVQZ"))

setnames(s88_mp2.dt, c("basis", "System","Suite"),c("bs", "sys","set"))

setnames(il174_sapt, c("size", "r", "cationtype", "anion", "conf","elst10","exch10","ind20","exchind20","hf2","hf3","tothf"))

# tothf = elst10 + exch10 + ind20 + exchind20 + hf2 (delta E_HF^(2)) 
# il174_sapt[, tothf - elst10 - exch10 - ind20 - exchind20 - hf2]


#=====================================================================================#

# ADD NEW COLUMNS // REMOVE COMLUMNS // COMBINE D.FRAMES

s22$set      <- "S22"   # Use the same value (0) for all rows
s66$set      <- "S66"
il174$set    <- "il174"
il174_sapt$cation    <- paste("c",il174_sapt$r,"m", il174_sapt$cationtype, sep = "")

# COMBINE DATAFRAMES VERTICALLY
sets <- rbind(s22, s66)

# add keys and factors for 

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
il174 <- gather(il174, "bs", "energy", 5:9) %>% data.table()
il2ip <- gather(il2ip, "bs", "nonCP", 5:6) %>% data.table()
# SPLITS CP AND NON-CP COLUMN CALLED "p" AND SEPARTES ENERGIES BETWEEN THE NEW ROWS
il174 <- data.table(spread(il174, "p", "energy"))
setnames(il174, c("cp", "non-cp"), c("CP", "nonCP"))

sets <- gather(sets, "bs", "nonCP", 2:6) %>% data.table()

#=====================================================================================#

# ADD  NON-CP HF TO SETS

#s88_mp2.dt[spin_en == "SCF", ]

#merge(il174_sapt, il174[, c("cation", "anion", "conf", "avqz")], by = c("cation", "anion", "conf"))
s88_mp2 <- s88_mp2.dt[spin_en == "SCF", ]
sets[, set := as.factor(set)]
sets[, bs := as.factor(bs)]
il174[, bs := as.factor(bs)]

setkey(sets, "sys", "set", "bs")
setkey(s88_mp2, "sys", "set", "bs")
setkey(il174, "bs")
#sets$nonCP <- NULL
#merge(sets, s88_mp2[ sets, c("sys", "bs", "nonCP", "CP")], by = c("sys", "set", "bs"))
sets <- sets[s88_mp2[sets, c("sys",  "set", "bs", "CP"), with = FALSE]]

remove(s88_mp2, s88_mp2.dt)

