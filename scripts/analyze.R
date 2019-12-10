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

