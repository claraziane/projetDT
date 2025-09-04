library(lme4) # Mixed models
library(lmerTest) # Mixed models
library(emmeans) # Posthoc tests
library(tidyverse) # GGPlot
library(car)

# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/01/Motor/statsTable_Behav.csv") #Behavioural result table
head(DATA)
# View(DATA)

# Check normal distribution of the dependent variables
hist(DATA$mvtVar) #Check normal distribution of the data
hist(DATA$IMI) #Check normal distribution of the data

# Declare factor levels
DATA$Movement <- factor(DATA$Movement, levels = c("Tap", "Walk")) 
DATA$Instruction <- factor(DATA$Instruction, levels = c("none", "stim", "sync"))
DATA$Difficulty <- factor(DATA$Difficulty, levels = c("ST", "DT"))

# Define specific contrasts for posthocs
contrasts(DATA$Movement) <- contr.sum
contrasts(DATA$Instruction) <- contr.sum
contrasts(DATA$Difficulty) <- contr.sum

## MOVEMENT VARIABILITY
model <- lmer(mvtVar ~ 1 + Movement + Difficulty + Instruction + Movement:Difficulty + Movement:Instruction + Difficulty:Instruction + Movement:Difficulty:Instruction + (1|Participants), data = DATA)
summary(model)

model2 = Anova(model, type = "III")
print(model2)

emm_Mvt <- emmeans(model, ~ Movement, at = list(Movement = unique(DATA$Movement)))
summary(emm_Mvt)

emm_Difficulty <- emmeans(model, ~ Difficulty)
summary(emm_Difficulty)

emm_Instruction <- emmeans(model, ~ Instruction)
summary(emm_Instruction)

## Compute post hoc for Movement * Difficulty interaction
contrast_mvtDifficulty <- list(
  "Tap ST - Tap DT"    = c(1, 0, -1, 0),  # Movement = Walk and Difficulty = ST vs. Movement = Walk and Difficulty = DT
  "Walk ST - Walk DT"  = c(0, 1, 0, -1)   # Movement = Tap and Difficulty = ST vs. Movement = Tap and Difficulty = DT
)

emm_mvtDifficulty <- emmeans(model, ~ Movement * Difficulty)
summary(emm_mvtDifficulty)
contrast(emm_mvtDifficulty, contrast_mvtDifficulty, adjust = "bonferroni")
