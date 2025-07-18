cat("\014")                     # Clear console
rm(list = ls(all.names = TRUE)) # Clear the environment
# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # Load common functions for the project
# ---- load-packages -----------------------------------------------------------
library(palmerpenguins)
library(ggthemes)
# ---- declare-globals ---------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
ds0 <- palmerpenguins::penguins
# ---- inspect-data-0 ----------------------------------------------------------
ds0
print(x = ds0, n = 5) # Print the dataset to see 5 rows
ds0 %>% print(n = 5) # Alternative way to print the dataset
ds0 %>% glimpse() # Inspect the structure of the dataset
# ---- tweak-data --------------------------------------------------------------

# ---- tweak-data-1 ------------------------------------------------------------

# ---- table-1 -----------------------------------------------------------------

# ---- graph-1 -----------------------------------------------------------------
# Візуалізувати взаємозвʼязок між довжиною плавників і масою тіла пінгвінів 
# Використала підказку з документації ggplot2
ds0 %>% 
  ggplot2::ggplot(aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
  geom_point() +
  labs(
    title = "Penguin Flipper Length vs Body Mass",
    x = "Flipper Length (mm)",
    y = "Body Mass (g)"
  ) +
  theme(
    text = element_text(size = 12),
    legend.position = "bottom"
  ) +
  scale_color_brewer(palette = "Set1") +
  theme_minimal()

# ---- save-to-disk ------------------------------------------------------------
