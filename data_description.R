setwd("C:/Users/lorie/OneDrive/Bureau/agriculture")
# Install and load ggplot2 if not already installed
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(lubridate)) install.packages("lubridate")
if (!require(dplyr)) install.packages("dplyr")
if (!require(zoo)) install.packages("zoo")
if (!require(tidyr)) install.packages("tidyr")
if (!require(scales)) install.packages("scales")
library(tidyr)
library(ggplot2)
library(dplyr)
library(lubridate)
library(zoo)
library(scales)
#load the dataframe
tsdm_raw <- read.csv("data/nrm1010_tsdm.csv", header=TRUE, sep=",")
tsdm_raw$OBSERVATION_DATE <- as.Date(tsdm_raw$OBSERVATION_DATE, format="%d/%m/%Y")

#to upper
tsdm_raw$PADDOCK_ID <- toupper(tsdm_raw$PADDOCK_ID)
meta_raw <-  read.csv("data/global_paddocks_new.csv", header=TRUE, sep=",")
#the climate data
climate_2017 <- read.csv("data/climate_2017.csv", header=TRUE, sep=",")
climate_2018 <- read.csv("data/climate_2018.csv", header=TRUE, sep=",")
climate_2019 <- read.csv("data/climate_2019.csv", header=TRUE, sep=",")
climate_2020 <- read.csv("data/climate_2020.csv", header=TRUE, sep=",")
climate_2021 <- read.csv("data/climate_2021.csv", header=TRUE, sep=",")
climate_2022 <- read.csv("data/climate_2022.csv", header=TRUE, sep=",")
#save them into a list
climate_list <- list()
climate_list[[1]]<- climate_2017
climate_list[[2]]<- climate_2018
climate_list[[3]]<- climate_2019
climate_list[[4]]<- climate_2020
climate_list[[5]]<- climate_2021
climate_list[[6]]<- climate_2022
#set the name
names(climate_list) <- c("climate_2017","climate_2018","climate_2019","climate_2020","climate_2021","climate_2022" )
#select the unique paddocks with TSDM
unique_paddocks_ids <- unique(tsdm_raw$PADDOCK_ID)
#filter the meta to have only the one present in TSDM
meta_with_tsdm <- meta_raw[meta_raw$PADDOCK_ID%in%unique_paddocks_ids,]
#filter out the paddocks that are not grazing
grazing_paddock_ids <- meta_with_tsdm %>%
  filter(PASTURE_STATE == "Grazing") %>%
  pull(PADDOCK_ID) %>%
  unique()
#filter out paddock without grazing
meta_with_tsdm_grazing <- meta_with_tsdm[meta_with_tsdm$PADDOCK_ID%in%grazing_paddock_ids,]

#filter the climate data also 
climate_list_tsdm <- lapply(climate_list, function(df){
  df[df$PADDOCK_ID %in% grazing_paddock_ids, ]
})
tsdm_grazing = tsdm_raw[tsdm_raw$PADDOCK_ID%in%grazing_paddock_ids,]

#get the monthly df to deal with the missing values
monthly_mean_df <- tsdm_grazing %>%
  mutate(
    Year = year(OBSERVATION_DATE),
    Month = month(OBSERVATION_DATE, label = TRUE)
  ) %>%
  group_by(PADDOCK_ID, Year, Month) %>%
  summarise(
    monthly_mean = mean(TSDM_MEAN, na.rm = TRUE)
  ) %>%
  arrange(PADDOCK_ID, Year, Month)

monthly_count_df <- tsdm_grazing %>%
  mutate(
    Year = year(OBSERVATION_DATE),
    Month = month(OBSERVATION_DATE, label = TRUE, abbr = TRUE)
  ) %>%
  group_by(PADDOCK_ID, Year, Month) %>%
  summarise(
    observation_count = n()  # Count observations for each month and year per paddock
  ) %>%
  ungroup()
#check if all combiantion have values
total_counts_df <- monthly_count_df %>%
  group_by(PADDOCK_ID) %>%
  summarise(
    total_observations = sum(observation_count)
  ) %>%
  ungroup()
# Step 3: Check which paddocks have a different total count than expected (72)
paddocks_with_missing_counts <- total_counts_df %>%
  filter(total_observations != 162) %>%
  pull(PADDOCK_ID)
#remove them from the final_df
final_included_paddocks <- tsdm_grazing[!tsdm_grazing$PADDOCK_ID %in% paddocks_with_missing_counts, ]
#get the total, so weighted by landsize_ha 
final_included_paddocks <- final_included_paddocks %>%
  inner_join(meta_with_tsdm_grazing  %>% select(PADDOCK_ID, LANDSIZE_HA), by = "PADDOCK_ID") %>%
  mutate(TOTAL = TSDM_MEAN * LANDSIZE_HA) %>%
  select(-LANDSIZE_HA)  # Remove landsize_area if you don’t need it in the final data frame

#now, create descriptive
paddock_monthly_stats <- final_included_paddocks %>%
  mutate(
    Year = year(OBSERVATION_DATE),
    Month = month(OBSERVATION_DATE, label = TRUE, abbr = TRUE),
    Date = as.Date(paste(Year, month(OBSERVATION_DATE), "01", sep = "-"))  # Use the first day of each month
  ) %>%
  group_by(Year, Month, Date) %>%
  summarise(
    mean_value = mean(TSDM_MEAN, na.rm = TRUE),
    std_dev = sd(TSDM_MEAN, na.rm = TRUE)
  ) %>%
  ungroup()
#plot the graph of TSDM
ggplot(paddock_monthly_stats, aes(x = Date, y = mean_value, group = 1)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  geom_ribbon(aes(ymin = mean_value - std_dev, ymax = mean_value + std_dev), fill = "lightblue", alpha = 0.2) +
  labs(title = "Mean Averaged Monthly TSDM with Standard Deviation",
       x = "Date(Year)",
       y = "TSDM kg/ha") +
  
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(labels = comma) +
  theme_minimal() +
  theme(theme(
    panel.grid = element_blank(),                 # Remove all grid lines
    axis.text.x = element_text(angle = 45, hjust = 1)
  ))

#aggregate all climate df them
combined_climate <- do.call (rbind, climate_list_tsdm)
#filter df to have the same as for TSDM
combined_climate_filtered <- combined_climate[combined_climate$PADDOCK_ID %in% final_included_paddocks$PADDOCK_ID, ]
#group by month and year and paddock
combined_climate_filtered$DATE = as.Date(combined_climate_filtered$DATE)
#plot the frquence of each variable
create_histogram <- function(data, variable, title) {
  ggplot(data, aes_string(x = variable)) +
    geom_histogram(bins = 30, fill = "steelblue", color = "black") +
    labs(title = title, x = variable, y = "Frequency") +
    theme_minimal()
}

#take the monthly average
# Convert the data to a long format
combined_climate_long <- combined_climate_filtered %>%
  pivot_longer(cols = c(RAIN, MAX_TEMP, MIN_TEMP, RH_TMAX, RH_TMIN, EVAP, RADIATION),
               names_to = "Variable", values_to = "Value")

# Plot the count histogram for each variable in one figure
ggplot(combined_climate_long, aes(x = Value)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "black") +
  labs(title = "Distribution of Climate Variables",
       x = "Value",
       y = "Count") +
  facet_wrap(~ Variable, scales = "free") +  # Separate plot for each variable with free scales
  theme_minimal()

#Step 1: Group by Paddock, Year, and Month to calculate initial aggregations

paddock_monthly_climate <- combined_climate_filtered %>%
  mutate(Year = year(DATE), Month = month(DATE, label = TRUE)) %>%
  group_by(PADDOCK_ID, Year, Month) %>%
  summarise(
    RAIN = sum(RAIN, na.rm = TRUE),
    MAX_TEMP = max(MAX_TEMP, na.rm = TRUE),
    MIN_TEMP = min(MIN_TEMP, na.rm = TRUE),
    RH_TMAX = max(RH_TMAX, na.rm = TRUE),
    RH_TMIN = min(RH_TMIN, na.rm = TRUE),
    EVAP = mean(EVAP, na.rm = TRUE),
    RADIATION = mean(RADIATION, na.rm = TRUE)
  ) %>%
  ungroup()

# Step 2: Group overall (across paddocks), apply aggregations, and create Date column
overall_monthly_climate <- paddock_monthly_climate %>%
  group_by(Year, Month) %>%
  summarise(
    RAIN = mean(RAIN, na.rm = TRUE),
    MAX_TEMP = max(MAX_TEMP, na.rm = TRUE),
    MIN_TEMP = min(MIN_TEMP, na.rm = TRUE),
    RH_TMAX = max(RH_TMAX, na.rm = TRUE),
    RH_TMIN = min(RH_TMIN, na.rm = TRUE),
    EVAP = mean(EVAP, na.rm = TRUE),
    RADIATION = mean(RADIATION, na.rm = TRUE)
  ) %>%
  mutate(Date = as.Date(ISOdate(Year, match(Month, month.abb), 1))) %>%
  ungroup()

# Plotting each variable
# Plot RAIN
p1 <- ggplot(overall_monthly_climate, aes(x = Date, y = RAIN)) +
  geom_line(color = "steelblue") +
  labs(title = "Trend of Rain Over Time", x = "Date", y = "RAIN") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p1)

