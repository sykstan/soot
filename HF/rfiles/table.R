# first 5 observations
#newdata <- mydata[1:5,]

subset <- sets [ which(sets$set=='s22' | sets$set == 's66')]

bs.s = c('vdz', 'vtz', 'vqz', 'avdz','avtz')

ave_vdz  <- mean(subset$avqz - subset$vdz ) 
ave_vtz  <- mean(subset$avqz - subset$vtz )
ave_vqz  <- mean(subset$avqz - subset$vqz )
ave_avdz <- mean(subset$avqz - subset$avdz)
ave_avtz <- mean(subset$avqz - subset$avtz)

aves <- c(ave_vdz, ave_vtz, ave_vqz, ave_avdz, ave_avtz)

mae_vdz  <- mean(abs(subset$avqz - subset$vdz )) 
mae_vtz  <- mean(abs(subset$avqz - subset$vtz ))
mae_vqz  <- mean(abs(subset$avqz - subset$vqz ))
mae_avdz <- mean(abs(subset$avqz - subset$avdz))
mae_avtz <- mean(abs(subset$avqz - subset$avtz))

maes <- c(mae_vdz, mae_vtz, mae_vqz, mae_avdz, mae_avtz)

min_vdz  <- min(subset$avqz - subset$vdz ) 
min_vtz  <- min(subset$avqz - subset$vtz )
min_vqz  <- min(subset$avqz - subset$vqz )
min_avdz <- min(subset$avqz - subset$avdz)
min_avtz <- min(subset$avqz - subset$avtz)

mins <- c(min_vdz, min_vtz, min_vqz, min_avdz, min_avtz)

max_vdz  <- max(subset$avqz - subset$vdz ) 
max_vtz  <- max(subset$avqz - subset$vtz )
max_vqz  <- max(subset$avqz - subset$vqz )
max_avdz <- max(subset$avqz - subset$avdz)
max_avtz <- max(subset$avqz - subset$avtz)

maxs <- c(max_vdz, max_vtz, max_vqz, max_avdz, max_avtz)

std_vdz  <- sd(subset$avqz - subset$vdz ) 
std_vtz  <- sd(subset$avqz - subset$vtz )
std_vqz  <- sd(subset$avqz - subset$vqz )
std_avdz <- sd(subset$avqz - subset$avdz)
std_avtz <- sd(subset$avqz - subset$avtz)


stds <- c(std_vdz, std_vtz, std_vqz, std_avdz, std_avtz)

raw_summary_s22_s66 <- data.frame(bs.s,aves, maes, mins, maxs, stds)

remove(subset, bs.s, aves, ave_vdz, ave_vtz, ave_vqz, ave_avdz, ave_avtz, maes, mae_vdz, mae_vtz, 
       mae_vqz, mae_avdz, mae_avtz, mins, min_vdz, min_vtz, min_vqz, min_avdz, min_avtz, max_vdz, 
       max_vtz, max_vqz, max_avdz, max_avtz, maxs, std_vdz, std_vtz, std_vqz, std_avdz, std_avtz, stds)

