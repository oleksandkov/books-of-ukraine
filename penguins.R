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
# Використала підказку з документації ggplot2 27 - холст, 28 - пензлик
# ds0 %>% 
#   ggplot2::ggplot(aes(x = flipper_length_mm, y = body_mass_g, color = species)) +
#   geom_point() +
#   # labs(
#   #   title = "Penguin Flipper Length vs Body Mass",
#   #   x = "Flipper Length (mm)",
#   #   y = "Body Mass (g)"
#   # ) +
#   # theme(
#   #   text = element_text(size = 12),
#   #   legend.position = "bottom"
#   # ) +
#   # scale_color_brewer(palette = "Set1") +
#   theme_minimal()

# Першим аргументом ggplot() є набір даних для використання в графіку, 
# тому ggplot(data = penguins) створює порожній графік, 
# який призначений для відображення даних про пінгвінів, 
# але оскільки ми ще не розповіли, як їх візуалізувати, наразі він порожній. 
ggplot(data = penguins)

#Далі нам потрібно вказати ggplot(), як інформація з наших даних 
# буде візуально представлена. 
# Аргумент mapping функції ggplot() визначає, 
# як змінні у вашому наборі даних зіставляються 
# з візуальними властивостями (естетикою) вашого графіка. 
# Аргумент mapping завжди визначено у функції aes(), 
# а аргументи x та y функції aes() вказують, 
# які змінні слід зіставити з осями x та y. 
# Наразі ми зіставимо лише довжину ласт з естетикою x та масу тіла з естетикою y. 
# ggplot2 шукає зіставлені змінні в аргументі dataargument, 
# у цьому випадку пінгвінів.)
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()
#> Повідомляє, що вилучено 2 рядки, що містять відсутні значення (geom_point()).

#> Далі нам потрібно визначити геому (geom): геометричний обʼєкт, 
#> який графік використовує для представлення даних. 
#> Ці геометричні обʼєкти доступні в ggplot2 
#> з функціями, які починаються з geom_. 
#> 
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point()

#> Додаємо колір до точок, щоб відобразити різні види пінгвінів.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")

#> Додаємо лінію регресії, щоб показати тренд даних.
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")
#> окрім кольору, ми також можемо зіставити види з естетикою форми
ggplot(
data = penguins,
mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")
# Покращую підписи графіка за допомогою функції labs() у новому шарі
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()
# Завлання 3 Створіть діаграму розсіювання bill_depth_mm проти bill_length_mm.
ggplot(
  data = penguins,
  mapping = aes(x = bill_depth_mm, y = bill_length_mm, color = species)
) +
  geom_point()

# ---- save-to-disk ------------------------------------------------------------
