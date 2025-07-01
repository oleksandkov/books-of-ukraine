rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console
# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# Project Directory should be the root by default unless overwritten

# ---- load-packages -----------------------------------------------------------
# Choose to be greedy: load only what's needed
# Three ways, from least (1) to most(3) greedy:
# -- 1.Attach these packages so their functions don't need to be qualified: 
# http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr)
library(ggplot2)   # graphs
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates
library(labelled)  # labels
library(dplyr)     # data wrangling
library(tidyr)     # data wrangling
library(scales)    # format
library(broom)     # for model
library(emmeans)   # for interpreting model results
library(ggalluvial)
# -- 2.Import only certain functions of a package into the search path.
# import::from("magrittr", "%>%")
# -- 3. Verify these packages are available on the machine, but their functions need to be qualified
requireNamespace("readr"    )# data import/export
requireNamespace("readxl"   )# data import/export
requireNamespace("janitor"  )# tidy data
requireNamespace("testit"   )# For asserting conditions meet expected patterns.
requireNamespace("googlesheets4") # for Google Sheets import

# ---- load-sources ------------------------------------------------------------
base::source("./scripts/common-functions.R") # project-level
base::source("./scripts/operational-functions.R") # project-level

# ---- declare-globals ---------------------------------------------------------

local_root <- "./manipulation/"
local_data <- paste0(local_root, "data-local/") # for local outputs

if (!fs::dir_exists(local_data)) {fs::dir_create(local_data)}

data_private_derived <- "./data-private/derived/manipulation/"
if (!fs::dir_exists(data_private_derived)) {fs::dir_create(data_private_derived)}

prints_folder <- paste0(local_root, "prints/")
if (!fs::dir_exists(prints_folder)) {fs::dir_create(prints_folder)}


# ---- declare-functions -------------------------------------------------------

#' Import all sheets from Google Spreadsheet
#' 
#' This function imports all available sheets (tabs) from a Google Spreadsheet
#' and returns them as a named list of data frames
#'
#' @param sheet_url Character string with Google Sheets URL
#' @param clean_names Logical, whether to clean column names using janitor
#' @return Named list of data frames, one for each sheet
import_all_sheets <- function(sheet_url, clean_names = TRUE) {
  
  # Get sheet information
  sheet_info <- googlesheets4::gs4_get(sheet_url)
  sheet_names <- sheet_info$sheets$name
  
  cat("Знайдено", length(sheet_names), "вкладок (sheets):\n")
  cat(paste(sheet_names, collapse = ", "), "\n")
  
  # Import each sheet
  all_sheets <- list()
  
  for (sheet_name in sheet_names) {
    cat("Завантажуємо вкладку:", sheet_name, "\n")
    
    # Import the sheet
    sheet_data <- googlesheets4::read_sheet(
      ss = sheet_url,
      sheet = sheet_name,
      .name_repair = "minimal"
    )
    
    # Clean column names if requested
    if (clean_names) {
      sheet_data <- janitor::clean_names(sheet_data)
    }
    
    # Store in list with sheet name as key
    all_sheets[[sheet_name]] <- sheet_data
    
    cat("  - Розмір:", nrow(sheet_data), "рядків x", ncol(sheet_data), "колонок\n")
  }
  
  return(all_sheets)
}

# ----- define-query -----------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
# a google spreadsheet with multiple tabs stores the main input of the project
# https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?usp=sharing

# URL Google Spreadsheet
main_spreadsheet_url <- "https://docs.google.com/spreadsheets/d/1FOrg2bg3o-YrnnvGkRdax9sF5xOL-r08839ARJMAE9w/edit?usp=sharing"

# Authenticate with Google Sheets (якщо потрібно)
# googlesheets4::gs4_auth() # Розкоментуйте якщо потрібна автентифікація

# For public sheets, disable authentication
googlesheets4::gs4_deauth()

cat("Починаємо завантаження даних з Google Spreadsheet...\n")

# Import all sheets from the main spreadsheet
all_data <- import_all_sheets(
  sheet_url = main_spreadsheet_url,
  clean_names = TRUE
)

# Display summary of imported data
cat("\n=== ПІДСУМОК ЗАВАНТАЖЕННЯ ===\n")
cat("Загалом завантажено", length(all_data), "таблиць:\n")

for (sheet_name in names(all_data)) {
  df <- all_data[[sheet_name]]
  cat(sprintf("  • %s: %d рядків × %d колонок\n", 
              sheet_name, nrow(df), ncol(df)))
  
  # Show first few column names
  col_preview <- head(names(df), 5)
  if (ncol(df) > 5) {
    col_preview <- c(col_preview, "...")
  }
  cat(sprintf("    Колонки: %s\n", paste(col_preview, collapse = ", ")))
}

# Create individual data frames for easier access
# Automatically assign each sheet to a variable based on its name
for (sheet_name in names(all_data)) {
  # Create a valid R variable name from sheet name
  var_name <- janitor::make_clean_names(sheet_name)
  assign(var_name, all_data[[sheet_name]])
  cat("Створено змінну:", var_name, "\n")
}





# ---- write-to-disk -------------------------

# Save all imported data to local files for faster access in future runs
cat("\nЗбереження даних на диск...\n")

# Save the complete list of all sheets
saveRDS(
  object = all_data,
  file = paste0(data_private_derived, "all_sheets_raw.rds")
)
cat("Збережено повний список таблиць у:", paste0(data_private_derived, "all_sheets_raw.rds\n"))

# Save each sheet as individual RDS file
for (sheet_name in names(all_data)) {
  file_name <- paste0(janitor::make_clean_names(sheet_name), ".rds")
  file_path <- paste0(data_private_derived, file_name)
  
  saveRDS(
    object = all_data[[sheet_name]],
    file = file_path
  )
  cat("Збережено:", sheet_name, "→", file_path, "\n")
}

# Optional: Save as CSV files for external access
csv_folder <- paste0(data_private_derived, "csv/")
if (!fs::dir_exists(csv_folder)) {fs::dir_create(csv_folder)}

for (sheet_name in names(all_data)) {
  file_name <- paste0(janitor::make_clean_names(sheet_name), ".csv")
  file_path <- paste0(csv_folder, file_name)
  
  readr::write_csv(
    x = all_data[[sheet_name]],
    file = file_path
  )
}
cat("CSV файли збережено у:", csv_folder, "\n")

cat("\n=== ЗАВЕРШЕНО ===\n")
cat("Всі дані успішно завантажено та збережено!\n")

# ---- ds_year create ----- 



library(tidyverse)

# 1. Зчитати початкові дані
df_raw <- readRDS("data-private/derived/manipulation/k_t_vidan.rds")

# 2. Примусово перетворити всі колонки (крім першої) на character
df_raw_clean <- df_raw %>%
  mutate(across(-1, ~ as.character(.)))

# 3. Зібрати у довгий формат
ds_year <- df_raw_clean %>%
  pivot_longer(
    cols = -1,
    names_to = "yr",
    values_to = "value_raw"
  ) %>%
  mutate(
    yr = as.integer(str_remove(yr, "^x")),
    value_clean = str_remove_all(value_raw, " "),
    measure = if_else(str_detect(value_clean, "\\."), "circulation", "number of titles"),
    value = as.numeric(value_clean)
  ) %>%
  select(yr, measure, value) %>%
  arrange(yr, measure)

# 4. Перевірити
print(ds_year)

# ---- ds_language create ----
ds <- readRDS("data-private/derived/manipulation/movi_narodu_svitu.rds")

# Припустимо, що стовпці мають імена на кшталт:
# "x2018", "x_2", "x2019", "x_3", ..., і мова в колонці "mova"

# 1. Знайдемо стовпці з назвами років і накладами
cols_number <- grep("^x\\d{4}$", names(ds), value = TRUE)     # Наприклад: x2018, x2019
cols_circulation <- grep("^x_\\d+$", names(ds), value = TRUE) # Наприклад: x_2, x_3

# 2. Додамо ідентифікатор мови (рядкова назва)
ds$mova <- as.character(ds$x)  # або інша назва, яку ти побачиш

# 3. Перетворимо у довгий формат окремо:
long_number <- ds %>%
  select(mova, all_of(cols_number)) %>%
  pivot_longer(
    cols = -mova,
    names_to = "yr",
    names_prefix = "x",
    values_to = "value"
  ) %>%
  mutate(measure = "number of titles")

long_circulation <- ds %>%
  select(mova, all_of(cols_circulation)) %>%
  pivot_longer(
    cols = -mova,
    names_to = "temp",
    names_prefix = "x_",
    values_to = "value"
  ) %>%
  mutate(
    measure = "circulation",
    yr = as.character(as.numeric(temp) + 2016)  # Якщо x_2 — це 2018, тоді +2016
  ) %>%
  select(-temp)

# 4. Об'єднуємо обидва
long_all <- bind_rows(long_number, long_circulation)

# 5. Перетворюємо в широку форму: колонки — мови
ds_language <- long_all %>%
  pivot_wider(
    names_from = mova,
    values_from = value
  ) %>%
  arrange(yr, measure)

# Результат:
View(ds_language)


rm(df_raw, df_raw_clean, ds, long_number, long_circulation, long_all)


# ---- ds_genre_naclad ----


library(dplyr)

df3 <- readRDS("data-private/derived/manipulation/naklad_tematic.rds")


library(tidyr)
library(dplyr)
library(stringr)

genre_col <- names(df3)[1]

df3_fixed <- df3 %>%
  mutate(across(-all_of(genre_col), ~ as.numeric(as.character(.))))

df3_long <- df3_fixed %>%
  pivot_longer(
    cols = -all_of(genre_col),
    names_to = "yr",
    values_to = "circulation"
  ) %>%
  mutate(
    yr = as.integer(str_remove(yr, "^x"))
  )

ds_genre_naclad <- df3_long %>%
  pivot_wider(
    names_from = !!genre_col,
    values_from = "circulation"
  ) %>%
  mutate(measure = "circulate") %>%
  relocate(yr, measure)

ds_genre_naclad
print(names(ds_genre_naclad))
ds_genre_naclad <- ds_genre_naclad %>%
  rename("Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса. Поліграфія")

# ---- ds_genre_num ----

library(dplyr)
library(tidyr)
library(janitor)
library(stringr)

# 1. Завантаження
df <- readRDS("data-private/derived/manipulation/tematicni_rozdili.rds")

# 2. Витягуємо перший рядок як роки
years <- as.character(unlist(df[1, -1]))
new_names <- c("genre", years)

# 3. Видаляємо перший рядок і оновлюємо заголовки
df_fixed <- df[-1, ]
colnames(df_fixed) <- new_names

# 4. Приводимо всі стовпці, крім genre, до character
df_fixed <- df_fixed %>%
  mutate(across(-genre, as.character))

# 5. Перехід у long-формат
df_long <- df_fixed %>%
  mutate(genre = as.character(genre)) %>%
  pivot_longer(
    cols = -genre,
    names_to = "yr",
    values_to = "value_raw"
  )

# 6. Додавання measure + чистка значень
df_long <- df_long %>%
  mutate(
    yr = as.integer(yr),
    value = as.numeric(str_remove_all(value_raw, " ")),
    measure = "number of titles"
  )

# 7. Перехід у wide-формат
ds_genre_num <- df_long %>%
  select(yr, measure, genre, value) %>%
  pivot_wider(
    names_from = genre,
    values_from = value
  ) %>%
  arrange(yr)

# 8. Перевірка
glimpse(ds_genre_num)


ds_genre_num <- ds_genre_num %>%
  rename_with(~str_replace_all(., "\\n", " "))

print(names(ds_genre_num))



# ---- ds_genre_num_0506 ---- 

library(dplyr)
library(tidyr)
library(janitor)
library(stringr)


df <- readRDS("data-private/derived/manipulation/tematicni_rozdili_05_06.rds") %>%
  clean_names()

# 2. Витягуємо роки з першого рядка (усі крім першої колонки)
years <- as.character(unlist(df[1, -1]))
new_names <- c("genre", years)

# 3. Видаляємо перший рядок і призначаємо нові імена колонок
df_fixed <- df[-1, ]
colnames(df_fixed) <- new_names

# 4. Приводимо всі значення до character
df_fixed <- df_fixed %>%
  mutate(across(-genre, as.character))

# 5. Перехід у long-формат
df_long <- df_fixed %>%
  mutate(genre = as.character(genre)) %>%
  pivot_longer(
    cols = -genre,
    names_to = "yr",
    values_to = "value_raw"
  ) %>%
  mutate(
    yr = as.integer(str_extract(yr, "\\d{4}")),  # Витягуємо саме 2005/2006
    value = as.numeric(str_remove_all(value_raw, " ")),
    measure = "number of titles"
  )

# 6. Перехід у wide-формат
ds_genre_0506 <- df_long %>%
  select(yr, measure, genre, value) %>%
  pivot_wider(
    names_from = genre,
    values_from = value
  ) %>%
  arrange(yr)

# 7. Перевірка
ds_genre_num_2 <- ds_genre_0506 %>%
  mutate(yr = c(2005, 2006))
glimpse(ds_genre_num_2)

needed_cols <- c(
  "Політична і соціально-економічна література",
  "Природничо-наукова література",
  "Технічна література",
  "Сільськогосподарська література.",
  "Охорона здоров’я. Медична література",
  "Література з фізичної культури і спорту",
  "Література з освіти та культури",
  "Друк у цілому. Книгознавство. Преса. Поліграфія",
  "Мистецтво. Мистецтвознавство",
  "Література по філологічним наукам",
  "Художня література",
  "Дитяча література",
  "Література універсального змісту"
)

ds_genre_num_0506_filtered <- ds_genre_num_2 %>%
  select(
    "yr",
    "measure",
    "Політична і соціально-економічна\nлітература, у т.ч:",
    "Природничо-наукова література, у т.ч.:",
    "Технічна література, у т.ч.:",
    "Сільськогосподарська література, у т.ч.:",
    "Охорона здоров’я. Медична література",
    "Література з фізичної культури і спорту",
    "Література з освіти та культура, у т.ч.:",
    "Друк у цілому. Книгознавство. Преса. \nПоліграфія, у т.ч.:",
    "Мистецтво. Мистецтвознавство, у т.ч.:",
    "Література по філологічним наукам, у т.ч.:",
    "Художня література, у т.ч.:",
    "Дитяча література, у т.ч.:",
    "Література універсального змісту"
  )

names(ds_genre_num_0506_filtered) <- names(ds_genre_num_0506_filtered) %>%
  str_replace_all("\\n", " ") %>%
  str_squish() %>%
  str_replace_all("  +", " ")

print(names(ds_genre_num_0506_filtered))

ds_genre_num_0506_filtered_1 <- ds_genre_num_0506_filtered %>%
  rename(
    "Політична і соціально-економічна література" = "Політична і соціально-економічна література, у т.ч:",
    "Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса. Поліграфія, у т.ч.:",
    "Природничо-наукова література" = "Природничо-наукова література, у т.ч.:" 
    , "Технічна література" = "Технічна література, у т.ч.:" 
    , "Сільськогосподарська література" = "Сільськогосподарська література, у т.ч.:"
    , "Охорона здоров'я. Медична література" = "Охорона здоров’я. Медична література"
    , "Література з фізичної культури і спорту" = "Література з фізичної культури і спорту"
    , "Література з освіти і культури" = "Література з освіти та культура, у т.ч.:"
    , "Друк у цілому. Книгознавство. Преса Поліграфія" = "Друк у цілому. Книгознавство. Преса. Поліграфія, у т.ч.:"
    , "Мистецтво. Мистецтвознавство" = "Мистецтво. Мистецтвознавство, у т.ч.:"
    , "Література з філологічних наук" = "Література по філологічним наукам, у т.ч.:"
    , "Художня література. Фольклор" = "Художня література, у т.ч.:"
    , "Дитяча література" = "Дитяча література, у т.ч.:"
    , "Література універсального змісту" = "Література універсального змісту"
  )
print(names(ds_genre_num_0506_filtered_1))



which(str_detect(names(ds_genre_num_2), "Друк у цілому."))
names(ds_genre_num_2)[which(str_detect(names(ds_genre_num_2), "Друк у цілому."))]

# ---- ds_genre_num_whole----



# 2. Вибираємо лише 2005 і 2006 з додаткового файлу
ds_0506 <- ds_genre_num_0506_filtered_1 %>% filter(yr %in% c(2005, 2006))

# 3. Видаляємо ці роки з основної таблиці
ds_genre_num_no_0506 <- ds_genre_num %>% filter(!yr %in% c(2005, 2006))

# 4. Об'єднуємо
ds_genre_number <- bind_rows(ds_genre_num_no_0506, ds_0506) %>% arrange(yr)
ds_genre_number <- ds_genre_number %>%
  rename("Друк у цілому. Книгознавство. Преса. Поліграфія" = "Друк у цілому. Книгознавство. Преса Поліграфія")



# ---- ds_genre ----

long_naclad <- ds_genre_naclad %>%
  pivot_longer(
    cols = -c(yr, measure),
    names_to = "genre",
    values_to = "value"
  )

long_number <- ds_genre_number %>%
  pivot_longer(
    cols = -c(yr, measure),
    names_to = "genre",
    values_to = "value"
  )

# 3. Об'єднати
combined_long <- bind_rows(long_naclad, long_number)

# 4. wide: кожен жанр — колонка
ds_genre <- combined_long %>%
  pivot_wider(
    id_cols = c(yr, measure),
    names_from = genre,
    values_from = value
  ) %>%
  arrange(yr, measure)

print(names(ds_genre_naclad))
print(names(ds_genre_number))

saveRDS(ds_genre, "data-private/derived/manipulation/ds_genre.rds")


identical(names(ds_genre_naclad), names(ds_genre_number))

rm(long_naclad, long_number, combined_long, combined_wide, ds_genre_number, ds_genre_naclad, df, df_fixed, df_long, df3, df3_fixed, df3_long, ds_0506, df_genre_0506, ds_genre_num, ds_genre_num_0506_filtered, ds_genre_num_0506_filtered_1, ds_genre_num_no_0506, ds_genre_num_2, ds_genre_0506)
