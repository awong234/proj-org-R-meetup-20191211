library(readxl)
library(ggplot2)
library(dplyr)
library(curl)
library(cowplot)
library(Cairo)

data = readxl::read_excel('notes/projinfo.xlsx')

data$`Project name` = factor(data$`Project name`, levels = data$`Project name`[order(data$`Project inception`)])

data = data %>% filter(! `Project name` %in% c("'pbar'", "ga-intro-analysis"))

curl_download("http://www.marinemammalcenter.org/assets/images/education/folkens/gray-whale-732x334.jpg", destfile = 'img/whale.jpg')
curl_download("https://lydiacarline.files.wordpress.com/2012/12/fruitfly3.jpg?w=567&h=418", destfile = 'img/fruit-fly.jpg')

plot = ggplot(data %>% arrange(`Project inception`)) +
  geom_errorbar(aes(x = `Project name`, ymin = `Project inception`, ymax = `Last update`, color = `Epoch`), width = 0, size = 2) +
  coord_flip() +
  theme_bw() +
  theme(panel.grid = element_blank()) +
  ggtitle("Project duration decreases over time")

Cairo(1920, 1080, file = 'img/whale-fruit-fly-plot.png', type = 'png', dpi = 150)
ggdraw() +
  draw_plot(plot) +
  draw_image("http://www.marinemammalcenter.org/assets/images/education/folkens/gray-whale-732x334.jpg", width = 0.2, x = 0.2, y = -0.15) +
  draw_image("https://lydiacarline.files.wordpress.com/2012/12/fruitfly3.jpg?w=567&h=418", width = 0.1, x = 0.65, y = 0.35)
dev.off()
