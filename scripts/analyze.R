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
    voting_rate ~ year * state,
    voting_rate ~ -1 + state + year,
    voting_rate ~ year + (year | state)
  ), 
  'description' = c(
    'year fixed',
    'year by state interaction',
    'state incpt. year fixed',
    'random intercept by state, random slope by year'
  ),
  'reg_call' = list(
    lm,
    lm,
    lm,
    lmer
  )
)

model_collection = model_collection %>% 
  mutate(model_fit = map2(.x = formulas, .y = reg_call, ~.y(data = voting, formula = .x))) %>% 
  mutate(AIC = map_dbl(.x = model_fit, .f = AIC)) %>% 
  arrange(AIC)

model_collection %>% 
  mutate(tidyfit = map(model_fit, tidy)) %>% 
  unnest(tidyfit)

# Work up ----------------------------------------------------------------- 

# Interaction model -- completely separate intercepts / slope 
summary(mod_interact)

df = augment(mod_interact)

df %>% ggplot() + 
  geom_point(aes(x = year, y = voting_rate)) + 
  geom_line(aes(x = year, y = .fitted)) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr) +  
  facet_wrap(~state)


summary(mod_fx_year)

df = augment(mod_fx_year)

df %>% ggplot() + 
  geom_point(aes(x = year, y = voting_rate)) + 
  geom_line(aes(x = year, y = .fitted)) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr) +  
  facet_wrap(~state)

## One line per state, as in geom_smooth()

vote_spl_state = nest(voting, data = c(year, voting_rate))

vote_spl_state = vote_spl_state %>% 
  mutate(mod_fits = map(data, .f = ~lm(data = .x, formula = voting_rate ~ year)),
         tidy_stats = map(mod_fits, ~tidy(.x)),
         augmentation = map(mod_fits, augment))

# By state, what are the effects?

p_int = vote_spl_state %>% unnest(tidy_stats) %>% select(state, term, estimate) %>% 
  filter(term == "(Intercept)") %>% 
  ggplot(aes(x = estimate, y = state)) + 
  geom_point() + 
  geom_vline(xintercept = 0) + 
  theme_bw()

p_year = vote_spl_state %>% unnest(tidy_stats) %>% select(state, term, estimate, std.error) %>% 
  filter(term == "year") %>% 
  ggplot(aes(x = state, y = estimate)) + 
  geom_point() + 
  geom_errorbar(aes(x = state, ymin = -2*std.error + estimate, ymax = 2*std.error + estimate), width = 0) + 
  geom_hline(yintercept = 0) + 
  theme_bw() + 
  coord_flip()

p_resids = vote_spl_state %>% unnest(augmentation) %>% 
  ggplot(aes(x = year, y = .resid)) + 
  geom_point() + 
  geom_hline(yintercept = 0) +
  facet_wrap(~state) + 
  theme_bw()

p_int + p_year + vplot_wrap + plot_layout(widths = c(1,1,4), guides = 'collect')
p_int + p_year + p_resids + plot_layout(widths = c(1,1,4), guides = 'collect')

## Fit together with random slopes & intercepts state


summary(re_mod_year_yearfx)

tidy(re_mod_year_yearfx)

voting$re_mod_year_yearfx_fit = fitted(re_mod_year_yearfx)

voting %>% ggplot(aes(x = year, y = voting_rate)) +
  geom_point() + 
  geom_line(aes(x = year, y = re_mod_year_yearfx_fit)) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr)+  
  facet_wrap(~state)

aug = augment(re_mod_year_yearfx)

aug %>% ggplot(aes(x = year, y = .resid)) + 
  geom_point() + 
  geom_line() + 
  facet_wrap(~state)
