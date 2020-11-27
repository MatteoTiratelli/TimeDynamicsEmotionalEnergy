library(tidyverse)
library(cowplot)

setwd("/Users/matteo/Downloads/export")

data <- read_csv("0.csv")
names(data)[2] <- 'Terror'
data %>%
  mutate(row.number = row_number()) -> data

for (i in (c(1,2,3,5,6,7))){ # PyTrends returns an empty dataset for the Berlin Truck Attacks
  filename = paste0(i,".csv")
  read_csv(filename) -> temp
  names(temp)[2] <- 'Terror'
  temp %>%
    mutate(row.number = row_number()) -> temp
  bind_rows(data, temp) -> data
}

data$Event <- as.factor(data$Event)
data$Event <- fct_relevel(data$Event, "Charlie Hebdo shooting", after = Inf)

ggplot(data, aes(x=row.number, y=as.numeric(Terror))) +
  geom_line() + 
  theme_classic() + 
  xlab(NULL) +
  ylab(NULL) +
  labs(title = "Figure A1: Emotional attention after terrorist attacks (hourly searches)", caption = "Notes: Hourly searches for 'terrorism' (translated into the relevant language) in the country directly affected by the attack. The pattern of searches following\nthe Charlie Hebdo attacks is significantly different to the others, but none resemble Collins's Explosion-Plateau-Dissipation model.") +
  facet_wrap(vars(Event), nrow = 4, ncol = 3) +
  theme(plot.title.position = "plot",
        plot.caption.position =  "plot",
        plot.caption = element_text(hjust = 0),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA),
        legend.background= element_rect(fill = "transparent", colour = NA)) -> Appendix


save_plot("Appendix.pdf", Appendix, base_width = 8.7, base_height = 7, units = "in")
