# Perform some analysis on the data

# Setup ------------------------------------------------------------------------

{
  library(vroom)
  library(dplyr)
  library(ggplot2)
}

options(device = 'x11')

# Import data ------------------------------------------------------------------

voting = vroom(file = 'output/a5a.tsv')


# Analyze ----------------------------------------------------------------------

voting %>% group_by(state, year) %>% summarize(vdiff = diff(voting_rate)) %>% 
  pull(vdiff) %>% summary

# Has voting participation decreased over the years?

# voting = split(voting, f = voting$type)

vplot = voting %>% ggplot() + 
  geom_point(aes(x = year, y = voting_rate, color = state, shape = type)) + 
  geom_line(aes(x = year, y = voting_rate, color = state, linetype = type)) + 
  geom_smooth(aes(x = year, y = voting_rate), method = 'lm') + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4)) +  
  theme_bw() + 
  theme(legend.position = 'bottom',
        panel.grid.minor = element_blank()) + 
  facet_wrap(~type)
vplot

vplot_wrap = 
  vplot + 
  facet_wrap(~state) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4)) + 
  theme(legend.position = 'bottom', axis.text.x = element_text(angle = 270))
vplot_wrap
