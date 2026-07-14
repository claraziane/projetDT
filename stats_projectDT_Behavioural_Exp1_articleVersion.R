library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(effectsize)
library(car)
library(data.table)
library(pwrss)
library(simr)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Articles/articleBehavioural/SUBMITTED/PsyArXiv/dataTable_EXP1_IMI_CV_syncConsistency.csv")
head(DATA)

DATA$Movement <- factor(DATA$Movement, levels = c("tapping", "walking")) 
DATA$Instruction <- factor(DATA$Instruction, levels = c("ignore", "synchronize"))
DATA$Cognitive.Load <- factor(DATA$Cognitive.Load, levels = c("singleTask", "oddball"))

# Define the specific contrasts for posthocs
contrasts(DATA$Movement) <- contr.sum
contrasts(DATA$Instruction) <- contr.sum
contrasts(DATA$Cognitive.Load) <- contr.sum

# model <- lmer(Mean.IMI..ms. ~ 1 + Movement + Cognitive.Load + Instruction + Movement:Cognitive.Load + Movement:Instruction + Cognitive.Load:Instruction + Movement:Cognitive.Load:Instruction + (1|Participant), data = DATA)
# model <- lmer(CV ~ 1 + Movement + Cognitive.Load + Instruction + Movement:Cognitive.Load + Movement:Instruction + Cognitive.Load:Instruction + Movement:Cognitive.Load:Instruction + (1|Participant), data = DATA)
model <- lmer(Sync.Consistency..logit. ~ 1 + Movement + Cognitive.Load + Instruction + Movement:Cognitive.Load + Movement:Instruction + Cognitive.Load:Instruction + Movement:Cognitive.Load:Instruction + (1|Participant), data = DATA)
summary(model)

Anova(model, type=3, test.statistic = "F")
eta_squared(model, partial = TRUE)

## Compute post hoc for Movement * Modality interaction
contrast_mvtInstruction <- list(
  "Tap stim - Tap sync"   = c(1, 0, -1, 0),  
  "Walk stim - Walk sync" = c(0, 1, 0, -1),
  "Tap stim - Walk stim"  = c(1, -1, 0, 0),
  "Tap sync - Walk sync"  = c(0, 0, 1, -1)
)
emm_mvtInstruction <- emmeans(model, ~ Movement * Instruction)
summary(emm_mvtInstruction)

# Run targeted comparisons with Bonferroni correction
contrast(emm_mvtInstruction, contrast_mvtInstruction, adjust = "bonferroni")

## Compute post hoc for Movement * Cognitive load interaction
contrast_mvtload <- list(
  "Tap ST - Tap DT"   = c(1, 0, -1, 0),  
  "Walk ST - Walk DT" = c(0, 1, 0, -1),
  "Tap ST - Walk ST"  = c(1, -1, 0, 0),
  "Tap DT - Walk DT"  = c(0, 0, 1, -1)
)
emm_mvtload <- emmeans(model, ~ Movement * Difficulty)
summary(emm_mvtload)

# Run targeted comparisons with Bonferroni correction
contrast(emm_mvtload, contrast_mvtload, adjust = "bonferroni")

## Compute post hoc for Load * Instruction interaction
contrast_loadInstruction <- list(
  "ST stim - ST sync"   = c(1, 0, -1, 0),  
  "DT stim - DT sync" = c(0, 1, 0, -1),
  "ST stim - DT stim"  = c(1, -1, 0, 0),
  "ST sync - DT sync"  = c(0, 0, 1, -1)
)
emm_loadInstruction <- emmeans(model, ~ Difficulty * Instruction)
summary(emm_loadInstruction)

# Run targeted comparisons with Bonferroni correction
contrast(emm_loadInstruction, contrast_loadInstruction, adjust = "bonferroni")

# Power analysis
# Using pwrss library
power.f.mixed.anova(eta.squared = 0.02,
                    factor.level = c(0,3),
                    power = 0.80,
                    alpha = 0.05,
                    effect = "within")

power.f.test(ncp = 10.71, # non-centrality under alternative
             df1 = 1, # numerator degrees of freedom
             df2 = 29, # denominator degrees of freedom
             alpha = 0.05, # type 1 error rate
             plot = FALSE)

# Using simr library
fixef(model)
powerSim(
  model,
  test = fixed(
    "Movement1",
    method = "z"
  ),
  nsim = 1000
)