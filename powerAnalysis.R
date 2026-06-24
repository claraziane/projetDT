# Load libraries
library(pwrss)
library(dplyr)
library(tidyr)


## A priori power analysis
mean_tap  <- 0.044 # Value taken from Dalla Bella et al. (2024)
mean_walk <- 0.020 # Value taken from Wittwer et al. (2013)

sd_tap  <- 0.010 # Value taken from Dalla Bella et al. (2024)
sd_walk <- 0.004 # Value taken from Wittwer et al. (2013)

# As correlation between tapping and walking CV is unknown in healthy older adults,
# several plausible r values are tested
r_values <- c(0, .25, .50, .75)

# Determining sample size needed for all r values
for (r in r_values) {
  
  sd_diff <- sqrt(sd_tap^2 + sd_walk^2 - 2*r*sd_tap*sd_walk)
  
  cat("\nCorrelation =", r, "\n")
  print(
    pwrss.t.2means( # For paired-sample t-test
      mu1 = mean_tap,
      mu2 = mean_walk,
      sd1 = sd_diff,
      paired = TRUE,
      paired.r = 0,
      power = 0.80,
      alpha = 0.05,
      alternative = "not equal"
    )
  )
}

## Post hoc power analysis

# EXP1
# Load result table
DATA <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projetDT/Results/All/01/statsTable.csv")
head(DATA)

# Compute mean CVs for tapping and walking across instructions and task difficulties for each participant
participant_means <- DATA %>%
  group_by(Participants, Movement) %>%
  summarise(
    CV_mean = mean(mvtVar, na.rm = TRUE),
    .groups = "drop"
  )

# Extract mean CV values for each particpant
wide <- participant_means %>%
  pivot_wider(
    names_from = Movement,
    values_from = CV_mean
  )

# Compute mean difference and SD
diff <- wide$Tap - wide$Walk
delta <- mean(diff)
sd_diff <- sd(diff)

# Determine n
n <- length(diff)

# Run power analysis
stats::power.t.test(
  n = n,
  delta = delta,
  sd = sd_diff,
  sig.level = 0.05,
  type = "paired"
)

# EXP 2
DATA2 <- read.csv("/Users/claraziane/Library/CloudStorage/OneDrive-UniversitedeMontreal/Projets/projectBehavioural/Results/Motor/statsTable.csv")
head(DATA2)

# Compute mean CVs for tapping and walking across instructions and task difficulties for each participant
participant_means2 <- DATA2 %>%
  group_by(Participants, Movement) %>%
  summarise(
    CV_mean2 = mean(mvtVar, na.rm = TRUE),
    .groups = "drop"
  )

# Extract mean CV values for each particpant
wide2 <- participant_means2 %>%
  pivot_wider(
    names_from = Movement,
    values_from = CV_mean2
  )

# Remove participants with NaN values
wide2 <- na.omit(wide2)

# Compute mean difference and SD
diff2 <- wide2$Tap - wide2$Walk
delta2 <- mean(diff2)
sd_diff2 <- sd(diff2)

# Determine n
n2 <- length(diff2)

# Run power analysis
stats::power.t.test(
  n = n2,
  delta = delta2,
  sd = sd_diff2,
  sig.level = 0.05,
  type = "paired"
)