library(readxl)
library(ggplot2)
library(dplyr)
library(curl)
library(cowplot)
library(Cairo)

data = readxl::read_excel('notes/projinfo.xlsx')

data$`Project name` = factor(data$`Project name`, levels = data$`Project name`[order(data$`Project inception`)])

data = data %>% filter(! `Project name` %in% c("'pbar'", "ga-intro-analysis"))

first_rep = data[match(T, data$`Successful replication`), ]
git_init  = data[match(T, data$`git init`), ]
renv      = data[match('renv', data$`Package reproducibility`), ]
make      = data[match(T, data$`Uses make`), ]

plot = ggplot(data %>% arrange(`Project inception`)) +
  geom_errorbar(aes(x = `Project name`, ymin = `Project inception`, ymax = `Last update`, color = `Epoch`), width = 0, size = 2) +
  coord_flip() +
  annotate('text', x = 8, y = first_rep$`Project inception`, label = 'First successful replication') +
  annotate('segment', x = 7.5, xend = first_rep$`Project name`, y = first_rep$`Project inception`, yend = first_rep$`Project inception`) +
  annotate('text', x = 8, y = git_init$`Project inception`, label = 'First successful replication') +
  annotate('segment', x = 7.5, xend = git_init$`Project name`, y = git_init$`Project inception`, yend = git_init$`Project inception`) +
  annotate('text', x = 8, y = renv$`Project inception`, label = 'First successful replication') +
  annotate('segment', x = 7.5, xend = renv$`Project name`, y = renv$`Project inception`, yend = renv$`Project inception`) +
  annotate('text', x = 8, y = make$`Project inception`, label = 'First successful replication') +
  annotate('segment', x = 7.5, xend = make$`Project name`, y = make$`Project inception`, yend = make$`Project inception`) +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  ggtitle("Project duration decreases over time")

Cairo(1920, 1080, file = 'img/whale-fruit-fly-plot.png', type = 'png', dpi = 150)
ggdraw() +
  draw_plot(plot) +
  draw_image("http://www.marinemammalcenter.org/assets/images/education/folkens/gray-whale-732x334.jpg", width = 0.2, x = 0.2, y = -0.15) +
  draw_image("https://lydiacarline.files.wordpress.com/2012/12/fruitfly3.jpg?w=567&h=418", width = 0.1, x = 0.65, y = 0.35)
dev.off()
