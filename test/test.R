cat("Testing\n")
cat("\n============================================================ fwildclusterboot ============================================================\n")
library(fwildclusterboot)
data(voters)
lm_fit <- lm(
  proposition_vote ~ treatment + ideology1 + log_income + Q1_immigration , 
  data = voters
)
boot_lm <- boottest(
  lm_fit, 
  clustid = "group_id1",
  param = "treatment",
  B = 999
)
boot_lmjl <- boottest(
  lm_fit,
  clustid = "group_id1",
  param = "treatment",
  B = 999#,
#  engine = "WildBootTests.jl"
)
#setBoottest_engine("WildBootTests.jl")
boot_lmjl2 <- boottest(
  lm_fit, 
  clustid = "group_id1",
  param = "treatment",
  B = 999
)
summary(boot_lm)
summary(boot_lmjl)
summary(boot_lmjl2)

cat("\n============================================================ httpgd ============================================================\n")
library(httpgd)
hgd()

cat("\n============================================================ musicMetadata ============================================================\n")
library(musicMetadata)
print(classify_labels('Interscope'))

cat("\n============================================================ nvimcom ============================================================\n")
library(nvimcom)

cat("\n============================================================ summclust ============================================================\n")
library(summclust)
summclust(lm_fit, cluster = ~group_id1, params = "treatment")

cat("\n============================================================ synthdid ============================================================\n")
library(synthdid)
data('california_prop99')
setup = panel.matrices(california_prop99)
tau.hat = synthdid_estimate(setup$Y, setup$N0, setup$T0)
se = sqrt(vcov(tau.hat, method='placebo'))
sprintf('95%% CI (%1.2f, %1.2f)', tau.hat - 1.96 * se, tau.hat + 1.96 * se)
cat("\n============================================================ END ============================================================\n")
