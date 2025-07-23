cat("\014") # Clear console
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

# Далі нам потрібно вказати ggplot(), як інформація з наших даних
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
#> Повідомляє, що вилучено 2 рядки, що містять відсутні значення (geom_point()).

#> Додає точки до графіка, які представляють кожного пінгвіна
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point()

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

# Завдання 3 Створіть діаграму розсіювання bill_depth_mm проти bill_length_mm.
ggplot(
  data = penguins,
  mapping = aes(x = bill_depth_mm, y = bill_length_mm, color = species)
) +
  geom_point()
# Розсіювання не щільне, багато викидів, вірогідно для Adelie ці показники слабо корегуються

# Завлання 4 Що станеться, якщо створити діаграму розсіювання видів проти bill_depth_mm?
# Який вибір geom може бути кращим?
# Не розумію
# Завдання 4 - ПРАВИЛЬНЕ РІШЕННЯ:
# Species vs bill_depth_mm потребує іншого geom!

# Варіант А: Box plot (коробчаста діаграма)
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm, color = species)
) +
  geom_boxplot() +
  labs(
    title = "Bill Depth Distribution by Species",
    subtitle = "Comparison across Adelie, Chinstrap, and Gentoo",
    x = "Species (види)",
    y = "Bill Depth (мм)"
  )

# Варіант Б: Violin plot (скрипкова діаграма)
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm, fill = species)
) +
  geom_violin() +
  geom_point(position = "jitter", alpha = 0.5) +
  labs(
    title = "Bill Depth Distribution by Species",
    x = "Species",
    y = "Bill Depth (mm)"
  ) +
  scale_fill_colorblind()

# Варіант В: Strip chart (стрічкова діаграма)
ggplot(
  data = penguins,
  mapping = aes(x = species, y = bill_depth_mm, color = species)
) +
  geom_jitter(width = 0.2, alpha = 0.7) +
  stat_summary(fun = mean, geom = "point", size = 3, color = "black") +
  labs(
    title = "Individual Bill Depths by Species",
    x = "Species",
    y = "Bill Depth (mm)"
  )
# Завдання 5.	Чому наступне дає помилку і як би ви її виправили?
#ggplot(data = penguins) + 
  #geom_point()
# Task 6.1	What does the na.rm argument do in geom_point()? 
# Обробляє відсутні дані
# Task 6.2 What is the default value of the argument? 
# FALSE
# Task 6.3 What happens if you set na.rm = TRUE?
# - Ми встановлюємо na.rm = TRUE в загальних функціях R, щоб виключити відсутні (NA) значення.
# Task 7. Add the following caption to the plot you made in the previous exercise:
# “Data come from the palmerpenguins package.”
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  labs(
    caption = "Data come from the palmerpenguins package."
  )
# Використовуємо labs() для додавання підпису до графіка. 
# Дані з https://ggplot2.tidyverse.org/reference/labs.html
# labs(
#   ...,
#   title = waiver(),
#   subtitle = waiver(),
#   caption = waiver(),
#   tag = waiver(),
#   alt = waiver(),
#   alt_insight = waiver()
# )

# xlab(label)
# 
# ylab(label)
# 
# ggtitle(label, subtitle = waiver())
# 
# get_labs(plot = last_plot())
# Tasc 8.1 8.	Відтворіть наступну візуалізацію.

# Tasc 8.2 З якою естетикою слід відіставити bill_depth_mm?
# Tasc 8.3 І чи слід це відображати на глобальному рівні чи на рівні геоми?
# ---- task-8-recreation-step-by-step ---------------------------------------
# Завдання 8.1: Відтворення візуалізації з penguins
# Крок 1: Ідентифікуємо компоненти target visualization
target_components <- list(
  x_axis = "flipper_length_mm", # горизонтальна вісь
  y_axis = "body_mass_g", # вертикальна вісь
  point_color = "species", # колір точок за видами
  point_size = "bill_depth_mm", # розмір точок за глибиною дзьоба
  geom_type = "geom_point", # тип геометрії
  additional_layer = "geom_smooth" # лінія тренду
)

# Крок 2: Базова структура
task_8_base <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g
  )
)

# Крок 3: Додаємо aesthetics поетапно
task_8_with_aesthetics <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g,
    size = bill_depth_mm, # SIZE для bill_depth_mm
    color = species # COLOR для species
  )
)

# Крок 4: Повна візуалізація
task_8_complete <- task_8_with_aesthetics +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_colorblind() +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    size = "Bill depth (mm)",
    color = "Species",
    caption = "Data come from the palmerpenguins package."
  )

# Виводимо результат
task_8_complete
# Відповідність кольторів та розмірів
# ---- task-8-color-solutions -----------------------------------------------

# ВАРІАНТ 1: Точне відтворення R4DS book (default colors)
task_8_book_exact <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g,
    size = bill_depth_mm,
    color = species
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  # НЕ ДОДАЄМО scale_color_* - використовуємо default
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    size = "Bill depth (mm)",
    color = "Species",
    caption = "Data come from the palmerpenguins package."
  )

# ВАРІАНТ 2: Accessibility-focused (твоя поточна версія)
task_8_accessible <- task_8_book_exact +
  scale_color_colorblind()

# ВАРІАНТ 3: Manual color specification (повний контроль)
task_8_manual_colors <- task_8_book_exact +
  scale_color_manual(
    values = c(
      "Adelie" = "#F8766D", # Default ggplot2 red
      "Chinstrap" = "#00BA38", # Default ggplot2 green
      "Gentoo" = "#619CFF" # Default ggplot2 blue
    )
  )

# Виводимо book-exact версію для відповідності:
task_8_book_exact

# ---- task-8-final-book-reproduction ---------------------------------------

# ШІ: Остаточна версія для співпадіння з книжкою:
task_8_final <- ggplot(
  data = penguins,
  mapping = aes(
    x = flipper_length_mm,
    y = body_mass_g,
    size = bill_depth_mm,    # SIZE aesthetic - GLOBAL level
    color = species          # COLOR aesthetic - GLOBAL level
  )
) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  # ВИДАЛЯЄМО scale_color_colorblind() для book reproduction
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)",
    y = "Body mass (g)",
    size = "Bill depth (mm)",
    color = "Species",
    caption = "Data come from the palmerpenguins package."
  )

# Display результат:
task_8_final

# Task 9
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = island)
  ) +
  geom_point() +
  geom_smooth(se = FALSE)
# Task 10 Will these two graphs look different? Why/why not?
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
  geom_smooth(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  )
# ---- english-lesson-readiness-assessment ----------------------------------

# 🌟 EXCEPTIONAL PROGRESS EVALUATION
progress_assessment <- tribble(
  ~skill_domain, ~achievement_level, ~english_integration, ~transferable_skills,
  "R Programming", "Advanced beginner", "Technical vocabulary mastery", "Logical thinking patterns",
  "Data Visualization", "Intermediate", "Grammar of Graphics terminology", "Visual communication skills",
  "Problem Analysis", "Advanced", "Structured questioning in English", "Critical thinking frameworks",
  "Documentation", "Intermediate+", "Bilingual commenting proficiency", "Academic writing preparation"
)

# 💡 FIDES Framework Integration з English Learning:
fides_english_synergy <- list(
  feasibility = "Technical English vocabulary already acquired",
  impact = "R4DS terminology enhances academic English proficiency",
  development = "Analytical skills transfer to language learning",
  engagement = "Data projects create authentic communication contexts",
  sustainability = "Bilingual coding builds long-term language confidence"
)
# ---- english-lesson-readiness-assessment ----------------------------------

# 🌟 EXCEPTIONAL PROGRESS EVALUATION
progress_assessment <- tribble(
  ~skill_domain, ~achievement_level, ~english_integration, ~transferable_skills,
  "R Programming", "Advanced beginner", "Technical vocabulary mastery", "Logical thinking patterns",
  "Data Visualization", "Intermediate", "Grammar of Graphics terminology", "Visual communication skills",
  "Problem Analysis", "Advanced", "Structured questioning in English", "Critical thinking frameworks",
  "Documentation", "Intermediate+", "Bilingual commenting proficiency", "Academic writing preparation"
)

# 💡 FIDES Framework Integration з English Learning:
fides_english_synergy <- list(
  feasibility = "Technical English vocabulary already acquired",
  impact = "R4DS terminology enhances academic English proficiency",
  development = "Analytical skills transfer to language learning",
  engagement = "Data projects create authentic communication contexts",
  sustainability = "Bilingual coding builds long-term language confidence"
)
# ---- english-lesson-colors --------------------------------------------

# 🟡 1. ВИВЧИТИ ОСНОВНІ КОЛЬОРИ:
basic_colors <- c(
  "red" = "червоний", # як помідор
  "blue" = "синій", # як небо
  "green" = "зелений", # як трава
  "yellow" = "жовтий", # як сонце
  "orange" = "помаранчевий", # як апельсин
  "purple" = "фіолетовий", # як лаванда
  "pink" = "рожевий", # як сакура
  "black" = "чорний", # як ніч
  "white" = "білий", # як сніг
  "gray" = "сірий" # як хмари
)

# 🎯 2. ПРАКТИКА З PENGUINS ГРАФІКАМИ
# Змінюємо кольори у візуалізаціях

# 🔵 3. ВИВЧИТИ ВІДТІНКИ (SHADES)
color_shades <- c(
  "light blue" = "світло-синій",
  "dark blue" = "темно-синій",
  "bright red" = "яскраво-червоний"
)

# 🌈 4. КОЛЬОРОВІ КОМБІНАЦІЇ
color_combinations <- c(
  "red and blue" = "червоний і синій",
  "green and yellow" = "зелений і жовтий"
)

# ✅ 5. ДОМАШНЄ ЗАВДАННЯ
# Створити 3 графіки з різними кольорами
# ---- color-practice-exercises -----------------------------------------

# 📊 ЗАВДАННЯ 1: Червоні точки (Red points)
ggplot(data = penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(color = "red") + # RED POINTS
  labs(title = "Red Penguins")

# 📊 ЗАВДАННЯ 2: Сині точки (Blue points)
ggplot(data = penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(color = "blue") + # BLUE POINTS
  labs(title = "Blue Penguins")

# 📊 ЗАВДАННЯ 3: Зелені точки (Green points)
ggplot(data = penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(color = "green") + # GREEN POINTS
  labs(title = "Green Penguins")
