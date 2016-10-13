zoe_hf.dt <- gather(s88_mp2.dt[spin_en == "SCF", c("basis", "System", "Suite", "nonCP", "CP"), with = FALSE]
       , comp, en, nonCP:CP) %>%
    spread(basis, en) %>%
    data.table()

zoe_hf.dt[, as.list(nomed.stats(aVDZ - VDZ)), by = .(Suite, comp)]
