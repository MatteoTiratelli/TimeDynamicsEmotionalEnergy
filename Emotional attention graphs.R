library(tidyverse)
library(cowplot)
library(magick)
library(gtrendsR)
library(ggarrange)

## Collect data

setwd('/Users/matteo/Desktop/Emotional Attention')

search <- tibble(Event = c('Charlie Hebdo shooting (France)','November 2015 Paris attacks (France)',
                           '2016 Nice truck attack (France)','2016 Berlin truck attack (Germany)',
                           'Boston Marathon bombings (United States)','Manchester Arena bombing (United Kingdom)', # 8 most deadly recent terrorist attacks in USA and Western Europe
                           '2016 Brussels bombings (Belgium)', '2017 Barcelona attacks (Spain)'),
                 TopicSearchCode = c('/m/012m7z4x','/g/11bwpyd6bz','/g/11c0rkxllm','/g/11c2nmxm9z',
                                     '/m/0t4zkny','/g/11df0whly0','/g/11cm88pk6n','/g/11f03_cv65'), # These were extracted manually from Google Trends
                 Country = c('FR','FR','FR','DE','US','GB','BE','ES'),
                 Date = c("2015-01-07 2015-09-07", "2015-11-13 2016-07-13", "2016-07-14 2017-03-14", "2016-12-19 2017-08-19",
                          "2013-04-15 2013-12-15", "2017-05-22 2018-01-22","2016-03-22 2016-11-22","2017-08-17 2018-04-17")) # Date of attack plus 8 months

results <- vector("list", length = length(search$Event))

for (i in 1:length(search$Event)){
  gtrends(keyword = search$TopicSearchCode[i],
          geo = search$Country[i],
          time = search$Date[i]) -> results[[i]]
}
Output <- data.frame(date = as.Date(as.character('2012-01-01')),
                     hits = as.character(2010),
                     keyword = as.character('2010'),
                     geo = as.character('2010'),
                     row.number = as.integer('2010'),
                     stringsAsFactors=FALSE)

for (i in 1:length(search$Event)){
  results[[i]]$interest_over_time[1:4] -> temp
  temp %>%
    mutate(row.number = row_number()) -> temp
  bind_rows(Output, temp) -> Output
}
Output <- as_tibble(Output[-1,])
Output <- merge(Output, search[,1:2], all.x = TRUE, by.x = 'keyword', by.y = 'TopicSearchCode')
Output$Event <- as.factor(Output$Event)

## Reproduce Collins graph

Collins <- ggplot(Output, aes(x=row.number, y=as.numeric(hits))) +
  theme_classic() + 
  xlab(NULL) +
  ylab('Conflict solidarity') +
  scale_x_continuous(breaks = c(14,90,180), 
                     labels = c('2 weeks', '3 months', '6 months')) +
  labs(caption = "Panel A: Public display of U.S. flags after the September 11th attacks. Graph reproduced from Collins (2012), figure 13. Data from Collins (2004).") +
  theme(plot.caption = element_text(hjust = 0),
        plot.caption.position =  "plot",
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA))

ggdraw() +
  draw_image("CollinsCurve.png", x = -0.01, y = 0.03, scale = 0.8) +
  draw_plot(Collins) -> panel_a


## Original graph

panel_b <- ggplot(Output, aes(x=row.number, y=as.numeric(hits), linetype=Event)) +
  geom_line() + 
  theme_classic() + 
  xlab(NULL) +
  ylab('Google Trends Index') +
  scale_x_continuous(breaks = c(14,90,180), 
                     labels = c('2 weeks', '3 months', '6 months')) +
  labs(caption = "Panel B: Google Trends Index of searches for each of the events listed, in the country where the event took place.") +
  theme(plot.caption = element_text(hjust = 0),
        plot.caption.position =  "plot",
        legend.position = c(0.7,0.6),
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA),
        legend.background= element_rect(fill = "transparent", colour = NA))

## Combine and save

plot_grid(panel_a, panel_b, axis = 'lb', ncol = 1) -> DataVis

save_plot("DataVis1.pdf", DataVis, base_width = 8.5, base_height = 9.6, units = "in")
save_plot("DataVis.png", DataVis, base_width = 8.5, base_height = 9.6, units = "in")

