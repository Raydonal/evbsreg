## Self-contained: computes evbs_monitor() and cnc_diagnostics() directly from
## the package data, so this script has no dependency on a cached intermediate
## file. Run from the repository root: Rscript scripts/20_figs_final.R
suppressMessages(library(evbsreg)); options(warn = -1)
if (!requireNamespace("ismev", quietly = TRUE))
  stop("install the 'ismev' package for the Fremantle case study")
dir.create("fig", showWarnings = FALSE)

data(itajai)
Xi <- cbind(1, itajai$pressure); yi <- itajai$wind
data(fremantle, package = "ismev")
fremantle$tt <- (fremantle$Year - mean(fremantle$Year)) / 100
Xf <- cbind(1, fremantle$SOI, fremantle$tt); yf <- fremantle$SeaLevel

fi <- evbsreg.fit(Xi, yi)
j  <- which.max(colMeans(cnc_diagnostics(fi)$Bj))          # #82, Apr 2017

ci  <- evbs_monitor(Xi, yi, burn = 40)
cin <- evbs_monitor(Xi, yi, burn = 40, use = "max")
cf  <- evbs_monitor(Xf, yf, burn = 40)
cfn <- evbs_monitor(Xf, yf, burn = 40, use = "max")

## The curvature-based index at Fremantle flags the sample minimum (#6, 1903)
## for the first part of the monitored range and the sample maximum (#11,
## 1909) from t = 68 onward; mark that transition the same way the Itajai
## panel marks Apr 2017, instead of asserting the index never leaves control.
t_switch <- min(cf$t[cf$flagged == 11])

## ---- FIG A: control chart, curvature-based vs naive ----
png("fig/carta_final.png", width = 10, height = 4.6, units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.6, 3.0, 1))
yl <- c(0.75, 1.30)

# Itajai
plot(ci$t, ci$F, type = "n", ylim = yl,
     xlab = expression("Observation index " * italic(t)),
     ylab = expression(F[italic(t)]),
     main = "Itajai wind gusts (n = 124)", cex.lab = 1.15)
polygon(c(-9, 999, 999, -9), c(0.5, 0.5, 1, 1), col = rgb(1, 0, 0, 0.07), border = NA)
lines(cin$t, cin$F, col = "grey55", lwd = 1.6, lty = 2)
lines(ci$t, ci$F, col = "#c1121f", lwd = 2.4)
points(ci$t, ci$F, col = "#c1121f", pch = 16, cex = .45)
abline(h = 1, lwd = 2, lty = 2); abline(v = j, col = "grey40", lty = 3)
text(j + 2, 1.20, "Apr 2017", col = "grey30", cex = .85, adj = 0)
text(j + 2, 0.80, "endpoint not identifiable", col = "#c1121f", cex = .8, adj = 0, font = 3)
legend("topright", c("curvature-based", "naive (delete max)"),
       col = c("#c1121f", "grey55"), lwd = c(2.4, 1.6), lty = c(1, 2),
       bty = "n", cex = .85)

# Fremantle
plot(cf$t, cf$F, type = "n", ylim = yl,
     xlab = expression("Observation index " * italic(t)),
     ylab = expression(F[italic(t)]),
     main = "Fremantle sea levels (n = 86)", cex.lab = 1.15)
polygon(c(-9, 999, 999, -9), c(0.5, 0.5, 1, 1), col = rgb(1, 0, 0, 0.07), border = NA)
lines(cfn$t, cfn$F, col = "grey55", lwd = 1.6, lty = 2)
lines(cf$t, cf$F, col = "#1b7837", lwd = 2.4)
points(cf$t, cf$F, col = "#1b7837", pch = 16, cex = .45)
abline(h = 1, lwd = 2, lty = 2); abline(v = t_switch, col = "grey40", lty = 3)
text(min(cf$t) + 2, 1.27, "flags minimum", col = "#1b7837", cex = .8, adj = 0, font = 3)
text(t_switch + 2, 1.27, "flags maximum", col = "#1b7837", cex = .8, adj = 0, font = 3)
text(min(cf$t) + 2, 0.80, "naive: signals from the start", col = "grey40", cex = .8, adj = 0, font = 3)
legend("bottomright", c("curvature-based", "naive (delete max)"),
       col = c("#1b7837", "grey55"), lwd = c(2.4, 1.6), lty = c(1, 2),
       bty = "n", cex = .85)
dev.off()

## ---- FIG B: contrast of B_j on a common scale ----
Bi <- colMeans(cnc_diagnostics(fi)$Bj)
ff <- evbsreg.fit(Xf, yf); Bf <- colMeans(cnc_diagnostics(ff)$Bj)

png("fig/contraste_final.png", width = 10, height = 4.3, units = "in", res = 170)
par(mfrow = c(1, 2), mar = c(4.3, 4.5, 2.6, 1))
plot(Bi, type = "h", lwd = 2, col = "grey55",
     xlab = expression("Observation index " * italic(j)), ylab = expression(B[italic(j)]),
     main = "Itajai: concentrated influence", ylim = c(0, .62), cex.lab = 1.12)
abline(h = 2 / length(yi), col = "red", lty = 2)
points(j, Bi[j], pch = 19, col = "#c1121f", cex = 1.4)
text(j, Bi[j], "#82 (Apr 2017) ", pos = 2, col = "#c1121f", font = 2, cex = .85)

plot(Bf, type = "h", lwd = 2, col = "grey55",
     xlab = expression("Observation index " * italic(j)), ylab = expression(B[italic(j)]),
     main = "Fremantle: diffuse influence", ylim = c(0, .62), cex.lab = 1.12)
abline(h = 2 / length(yf), col = "red", lty = 2)
jf <- which.max(Bf); points(jf, Bf[jf], pch = 19, col = "#1b7837", cex = 1.4)
text(jf, Bf[jf], sprintf(" #%d (%d)", jf, fremantle$Year[jf]), pos = 4, col = "#1b7837", font = 2, cex = .85)
dev.off()

cat("figures written to fig/carta_final.png and fig/contraste_final.png\n")
cat(sprintf("Itajai   F: before t=%d mean %.3f | at/after mean %.3f\n",
    j, mean(ci$F[ci$t < j]), mean(ci$F[ci$t >= j])))
cat(sprintf("Fremantle F: flags min for %d/%d instants (mean %.3f) | flags max for %d/%d (mean %.3f) | overall mean %.3f\n",
    sum(cf$flagged == 6), nrow(cf), mean(cf$F[cf$flagged == 6]),
    sum(cf$flagged == 11), nrow(cf), mean(cf$F[cf$flagged == 11]), mean(cf$F)))
cat(sprintf("Fremantle naive F: range [%.3f, %.3f], below 1 at %d/%d instants\n",
    min(cfn$F), max(cfn$F), sum(cfn$F < 1), nrow(cfn)))
