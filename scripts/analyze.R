# Perform some analysis on the data

# Setup ------------------------------------------------------------------------

{
  library(vroom)
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(purrr)
  library(broom)
  library(lme4)
  library(patchwork)
  library(Cairo)
}

options(device = 'x11')

# Import data ------------------------------------------------------------------

voting = vroom(file = 'output/voting_rates.tsv')

voting = voting %>% filter(type == 'Citizen')

# Analyze ----------------------------------------------------------------------

# labels for years in plots
yr = substr(sort(voting$year), start = 3, stop = 4) %>% unique

# Has voting participation decreased over the years?

# voting = split(voting, f = voting$type)

vplot_wrap = 
  voting %>% ggplot() + 
  geom_point(aes(x = year, y = voting_rate)) + 
  geom_line(aes(x = year, y = voting_rate)) + 
  geom_smooth(aes(x = year, y = voting_rate), method = 'lm') + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr) +  
  theme_bw() + 
  theme(legend.position = 'bottom',
        panel.grid.minor = element_blank()) + 
  facet_wrap(~state) + 
  ggtitle("Voting percentage over time, by state")

# Export image
Cairo(1920, 1620, dpi = 150, type = 'png', file = 'img/voting_prop_by_state.png')
vplot_wrap
dev.off()


# Perform regressions -------------------------------------------------------

model_collection = tibble(
  'formulas' = list(
    voting_rate ~ year,
    voting_rate ~ -1 + year * state,
    voting_rate ~ -1 + state + year,
    voting_rate ~ year + (year | state),
    voting_rate ~ year + (1 | state),
    voting_rate ~ (1 | state) + (1| year) + year
  ), 
  'description' = as.character(formulas),
  'reg_call' = list(
    lm,
    lm,
    lm,
    lmer,
    lmer,
    lmer
  )
)

model_collection = model_collection %>% 
  mutate(model_fit = map2(.x = formulas, .y = reg_call, ~.y(data = voting, formula = .x, REML = FALSE))) %>% 
  mutate(AIC = map_dbl(.x = model_fit, .f = AIC))

saveRDS(model_collection, file = 'output/model_tbl.RDS')

# Work up ----------------------------------------------------------------- 

pick_index = T
plot_list = model_collection %>% filter(pick_index) %>% pluck('model_fit')
names(plot_list) = model_collection$description[pick_index]
map_dfr(.x = plot_list, .f = ~mutate(voting, .fitted = fitted(.x)), .id = 'model') %>% 
 # filter(state %in% c("New York", "California", "Oklahoma", "North Carolina")) %>%
 # filter(state == "New York") %>%
  ggplot() + 
  geom_line(aes(x = year, y = .fitted, color = model)) + 
  geom_point(aes(x = year, y = voting_rate)) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr) +  
  facet_wrap(~state)

## Fit together with random slopes & intercepts state

re_mod_year_yearfx = model_collection %>% 
  pluck('model_fit', which(model_collection$description == 'voting_rate ~ (1 | state) + (1 | year) + year'))

voting$re_mod_year_yearfx_fit = fitted(re_mod_year_yearfx)

Cairo(1920, 1620, dpi = 150, type = 'png', file = 'img/random_effects_4_fit.png')
voting %>% ggplot(aes(x = year, y = voting_rate)) +
  geom_point() + 
  geom_line(aes(x = year, y = re_mod_year_yearfx_fit)) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr)+  
  facet_wrap(~state) + 
  ggtitle('voting_rate ~ (1 | state) + (1 | year) + year\nRandom intercepts for year and state, with year fixed effect')
dev.off()


system(command = 'touch analysis_done.conf')