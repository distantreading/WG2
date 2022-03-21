#### Setting things up ####

library(stylo)
library(tidyverse)
library(paletteer)

theme_set(theme_minimal())

## this is a 'clean' palette from 'base' collection
## check 'paletteer' package for more amazing palettes
pal1 <- c("#5DA5DAFF", "#FAA43AFF", "#60BD68FF", "#F15854FF", "#B276B2FF", "#8D4B08FF")

meta <-  read_tsv("metadata.tsv")
## getting languages
langs <- sort(unique(meta$lang))
## getting corpora paths
paths <- list.dirs("plain_corpus/",full.names = T,recursive = F)

paths
## empty variable for table
df_all <- NULL


## begin the main loop
for (i in 1:length(langs)) {
  
  # filter corresponding meta
  m <- meta %>% filter(lang==langs[i])
  
  # run stylo
  results=stylo(gui=F, # turn off gui
            corpus.dir = paths[i], # provide a path for corpus
            mfw.min=200, # MFW
            mfw.max=200, # MFW
            analyzed.features = "w", # a word is a feature
            ngram.size = 1,  # a single word is a feature
            distance.measure = "delta", # burrow's delta
            sampling = "no.sampling", # no sampling
            sample.size = 10000, 
            display.on.screen = FALSE, # don't display plot
            corpus.lang="Other") # corpus language to "Other"
  
  # distances
  distances <- as.matrix(results$distance.table)
  lower_triangle = lower.tri(distances,diag = F)
  
  # labels
  source_target=interaction(rownames(distances),rownames(distances)) %>%
    levels() %>% matrix(nrow=nrow(distances),ncol=nrow(distances))

  # years
  y_diff=outer(X = m$year, Y = m$year, FUN = "-")
  
  df <- tibble(distance=distances[lower_triangle],
                  year_diff=abs(y_diff[lower_triangle]),
                  rel= source_target[lower_triangle],
                  lang=langs[i])
  
  ## rebind table together
  ## P.S. Growing tables is nasty in R, but we won't have too many corpora anyways
  df_all <- rbind(df_all, df)

} ## end of loop


## exploring distance distribution
df_all %>% filter(lang=="en") %>% pull(distance) %>% hist()

df_all %>% ggplot(aes(distance,fill=lang)) + geom_histogram() + facet_wrap(~lang) + scale_fill_manual(values=pal1)

#### Distance in time ####

df_all %>%
  mutate(year_diff = abs(year_diff)) %>% 
  # here we filter: 1) novels that do not have exact date; 2) extreme difference
  filter(!is.na(year_diff),year_diff < 85) %>% 
  ggplot(aes(year_diff,distance,group=lang)) + # plotting
  geom_point(aes(shape=lang),alpha=0.1) + # plotting
  geom_smooth(aes(color=lang),method="lm") + # plotting
  scale_color_manual(values=pal1) + facet_wrap(~lang)

## correlations
df_all %>%
  mutate(year_diff = abs(year_diff)) %>%
  filter(!is.na(year_diff), distance<2) %>% 
  group_by(lang) %>% 
  summarise(correlation=cor(year_diff,distance))


df2 <- df_all %>%
  filter(!is.na(year_diff),distance<2) %>% 
  separate(rel, into=c("source", "target"),sep = "\\.") %>%
  left_join(meta %>% select(id,year),by=c("source" = "id")) %>%
  rename(year_source=year) %>%
  left_join(meta %>% select(id,year),by=c("target" = "id")) %>%
  rename(year_target=year) %>% 
  mutate(dec_target=floor(year_target/10)*10,
         dec_source=floor(year_source/10)*10) 

df2 %>% 
  ## this is a tricky part, but we just sort the year-to-year relationship by the earliest in the pair to be sure then the relationship is properly arranged (from past to)
  group_by(source,target) %>% 
  mutate(early=paste(sort(c(year_source,year_target)), collapse=" ")) %>%
  separate(early, c("s","t"),convert = T, sep=" ") %>% 
  ## then we take only those relationships that include novels from 1840s (our anchor point)
  filter(s<1850) %>% 
  ggplot(aes(t,distance,group=lang)) + # plotting
  geom_point(aes(shape=lang),alpha=0.2) + # plotting
  geom_smooth(aes(color=lang),method="gam") + # using generalized additive models to allow the trendline to "wiggle"
  theme_minimal() + # plotting
  facet_wrap(~lang) + # plotting
  scale_color_manual(values=pal1) + # plotting 
  labs(title="Distances from 1840s to the future")

## another way to explore complex distance-based relationships is heatmap
df2 %>%
  group_by(source,target) %>% 
  mutate(early=paste(sort(c(dec_source,dec_target)), collapse=" ")) %>%
  separate(early, c("s", "t"),sep=" ") %>% 
  group_by(lang, s,t) %>% summarise(distance=mean(distance)) %>%
  group_by(lang) %>% 
  mutate(scaled_value=(distance-min(distance))/(max(distance)-min(distance))) %>% 
  ggplot(aes(s, t,fill=scaled_value)) + geom_tile() + facet_wrap(~lang) + scale_fill_gradient2(low = "#32236C", mid = "#32236C", high = "#01ECB5")
