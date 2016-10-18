#=====================================================================================#

# HF SCALING ON TESTS SETS // ERRORS

sets$nonCP_sc  <- 0
sets$CP_sc     <- 0
il174$nonCP_sc <- 0
il174$CP_sc    <- 0
il2ip$nonCP_sc <- 0
il2ip$CP_sc    <- 0


# copyright Samuel Tan 2015
# function to scale HF
scale_hf.fn <- function(n, a, b) {
  # n is level, a is scaling factor, b is constant
  
}
# mean average error
mae <- function(x) {
  mean(abs(x), na.rm = TRUE)
}

# no median
zoe.stats <- function(x) {
  a = c(MAE = mae(x)
        , SD = sd(x, na.rm = TRUE),
        Min = min(x, na.rm = TRUE)
        , Max = max(x, na.rm = TRUE))
  return(as.list(a))
}

scalings <- data.table(bs = as.factor(basisList[-6]))
scalings[, a.nonCP := c(0.875, 0.928, 0.962, 0.977, 1.005)]
scalings[, b.nonCP := c(-10.913, -12.505, -8.791, 1.906, 3.468)]
scalings[, a.CP := c(0.940, 0.967, 0.984, 1.002, 0.999)]
scalings[, b.CP := c(-16.459, -9.789, -5.087, -0.088, 1.01)]
setkey(scalings, "bs")

il174 <- il174[scalings]
il174[, nonCP_sc := (nonCP/2 *a.nonCP + b.nonCP)*2]
il174[, CP_sc := (CP/2 *a.CP + b.CP)*2]

sets <- merge(sets, scalings, by = c("bs"))
sets[, nonCP_sc := (nonCP/2 *a.nonCP + b.nonCP)*2]
sets[, CP_sc := (CP/2 *a.CP + b.CP)*2]



il2ip <- merge(il2ip, scalings, by = c("bs"))
il2ip[, nonCP_sc := (nonCP/2 *a.nonCP + b.nonCP)*2]
il2ip[, CP_sc := (CP/2 *a.CP + b.CP)*2]


#il174[, zoe.stats(aVQZ - nonCP_sc), by = .(bs)]
#il174[bs == "aVDZ", aVQZ - CP]

# gather from one observation each row to gathering basis sets and then spreading by 
# basis set
#gather(sets[, !c("a.nonCP", "b.nonCP", "a.CP", "b.CP"), with = FALSE]
#       , comp, en, nonCP:CP_sc) %>% 
#  spread(bs, en) %>% 
#  data.table()

# show condition aDVZ and show rows sys bs and energy 
#sets[bs == "aVDZ", c("sys","bs", "energy"), with = FALSE]
