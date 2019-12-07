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
}

options(device = 'x11')

# Import data ------------------------------------------------------------------

voting = vroom(file = 'output/a5a.tsv')

voting = voting %>% filter(type == 'Citizen')

# Analyze ----------------------------------------------------------------------

# Has voting participation decreased over the years?

# voting = split(voting, f = voting$type)

vplot_wrap = 
  voting %>% ggplot() + 
  geom_point(aes(x = year, y = voting_rate)) + 
  geom_line(aes(x = year, y = voting_rate)) + 
  geom_smooth(aes(x = year, y = voting_rate), method = 'lm') + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4)) +  
  theme_bw() + 
  theme(legend.position = 'bottom',
        panel.grid.minor = element_blank()) + 
  facet_wrap(~state) 
vplot_wrap

# Perform regressions

## Overall fit

mod_year = lm(formula = voting_rate ~ year, data = voting)

summary(mod_year)

## One line per state, as in the graphic

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
  facet_wrap(~state)

p_int + p_year + vplot_wrap + plot_layout(widths = c(1,1,4), guides = 'collect')

## Fit together with random slopes & intercepts state

re_mod = lme4::lmer(data = voting, formula = voting_rate ~ year + (1|state))

tidy(re_mod)

voting$re_mod_fit = fitted(re_mod)
yr = substr(sort(voting$year), start = 3, stop = 4) %>% unique
voting %>% ggplot(aes(x = year, y = voting_rate)) +
  geom_point() + 
  geom_line(aes(x = year, y = re_mod_fit)) + 
  scale_x_continuous(breaks = seq(1992, 2016,by=4), labels = yr)+  
  facet_wrap(~state)
