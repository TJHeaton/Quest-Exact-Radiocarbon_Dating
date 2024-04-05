# Calibrate and plot single 14C date of Thera against IntCal20

# Use colour-blind friendly palette from
# https://www.color-hex.com/color-palette/49436
# and plot 1 sigma intervals on the curve and the observations

# Specific colours I have used for histograms are:
scalefac <- 1.5
BC <- TRUE
MookConvention <- TRUE
set.seed(17)
prob_scale_fac <- 3 # How high to scale posterior probability 

# Show calibration against the curve
IntCal20 <- read.csv("intcal20.csv", header = TRUE)
Mult_SigmaInterval <- 1 # Do we want 1 sigma or two sigma

IntCal20$C14Upper <- IntCal20$X14C.age + Mult_SigmaInterval * IntCal20$Sigma
IntCal20$C14Lower <- IntCal20$X14C.age - Mult_SigmaInterval * IntCal20$Sigma
IntCal20$BC <- -(1950.5 - IntCal20$CAL.BP) 

# cal_age are the calendar ages you are scanning over 
calib <- function(cal_age, radiocarbon_age, radiocarbon_sigma, calcurve) {
  posterior_likelihood <- approx(calcurve[,1], 
                                 dnorm(radiocarbon_age, 
                                       mean = calcurve[,2], 
                                       sd = sqrt(radiocarbon_sigma^2 + rep(calcurve[,3], length(radiocarbon_sigma))^2)), 
                                 cal_age, 
                                 rule=2)$y
  return(posterior_likelihood)
}

# Calibrate vs IntCal20
calcurve <- IntCal20 


# Calibration of a single sample from Thera
radiocarbon_age <- 3350 
radiocarbon_sigma <- 10

radiocarbon_age_grid <- seq(radiocarbon_age - 4*radiocarbon_sigma, 
                            radiocarbon_age + 4*radiocarbon_sigma, 
                            by = 1)

min.age <- radiocarbon_age - 2000
max.age <- radiocarbon_age + 2000
cal_age_grid <- seq(min.age, max.age, by = 1)

# Calibrate vs IntCal20
posterior_probs <- calib(cal_age = cal_age_grid, 
               radiocarbon_age = radiocarbon_age,
               radiocarbon_sigma = radiocarbon_sigma, 
               calcurve = calcurve)
# Normalise the posterior probabilities
posterior_probs <- posterior_probs/sum(posterior_probs)
max_posterior_prob <- max(posterior_probs)

cal_age_lim_plot <- c(3340.1, 3829.9)
radiocarbon_age_lim_plot <- (
  range(calcurve$X14C.age[calcurve$CAL.BP < cal_age_lim_plot[2] & calcurve$CAL.BP > cal_age_lim_plot[1]]) + c(-2,2)*mean(calcurve$Sigma)
)


# Store oldpar so do not change after running in main environment 
oldpar <- par(no.readonly = TRUE)

par(mar = c(5, 4.8, 2, 2) + 0.1)
plot(cal_age_grid, posterior_probs, type="n", 
     xlab = "Calendar Age (cal BC)", ylab = "", 
     las = 1,  cex.lab = 1.3,
     xaxs = "i", yaxs = "i",
     ylim = radiocarbon_age_lim_plot , xlim = -(1950.5 - rev(cal_age_lim_plot)))
if(!MookConvention) {
  mtext(text = expression(paste("Radiocarbon Age (", ""^14, "C yr", " BP)")), side = 2, line = 3.2, cex = 1.3) 
} else {
  mtext(text = expression(paste("Radiocarbon Age (BP)")), side = 2, line = 3.2, cex = 1.3) 
}

lines(calcurve$BC,calcurve$X14C.age, col = rgb(213,94,0, maxColorValue = 255))
polygon(c(calcurve$BC, rev(calcurve$BC)), 
        c(calcurve$C14Upper, rev(calcurve$C14Lower)), 
        col = rgb(213,94,0, alpha = 127, maxColorValue = 255), 
        border=NA)

xtick <- seq(1300, 2000, by = 10)
axis(side = 1, at = xtick, labels = FALSE, lwd = 0.5, tck = -0.015)
ytick <- seq(3000, 3700, by = 10)
axis(side = 2, at = ytick, labels = FALSE, lwd = 0.5, tck = -0.015)


# Create a histogram of the calibrated ages
pol <- cbind(c(min(cal_age_grid), cal_age_grid, max(cal_age_grid)), c(0, posterior_probs, 0))
if(BC) {
  polBC <- pol
  polBC[,1] <- -(1950.5 - polBC[,1])
  pol <- polBC
}

# Rescale to fit on the graph
pol[,2] <- pol[,2] * (radiocarbon_age_lim_plot[2] - radiocarbon_age_lim_plot[1]) / (prob_scale_fac * max_posterior_prob)
pol[,2] <- pol[,2] + radiocarbon_age_lim_plot[1]
polygon(pol, col= rgb(1,0,1,.2))

# Create a polygon to represent density of the radiocarbon determination
radpol <- cbind( c(0, dnorm(radiocarbon_age_grid, mean = radiocarbon_age, sd = radiocarbon_sigma), 0), 
                 c(min(radiocarbon_age_grid), radiocarbon_age_grid, max(radiocarbon_age_grid)))
radpol[,1] <- radpol[,1] * 0.1 * (cal_age_lim_plot[2] - cal_age_lim_plot[1]) / max(radpol[,1])

if(BC) {
  radpol[,1] <- -(1950.5 - cal_age_lim_plot[2] + radpol[,1])
}
polygon(radpol, col = rgb(1,0,1,.5))


legend("topright", legend = c("IntCal20"), 
       lty = c(-1), pch = c(15), lwd = 2,
       col = rgb(213,94,0, alpha = 127, maxColorValue = 255), 
       cex = 1, pt.cex = 2)

# Revert to old par
par(oldpar)













