#### Setting this up ####

library(stylo)
library(tidyverse)

theme_set(theme_minimal())

## this is 'BottleRocket2' palette from 'wesanderson' collection
## check 'paletteer' package for more amazing palettes
pal1 <- c("#FAD510FF", "#CB2314FF", "#273046FF", "#354823FF", "#1E1E1EFF")

## if you do not have tidyverse for R, istall it (it might take a while!) using following function
## install.packages("tidyverse")


## read metadata

meta = read_tsv("metadata.tsv")

meta_en = meta %>% filter(lang=="en")
meta_de = meta %>% filter(lang=="de")

#### Analysis with stylo ####

## English corpus
eng=stylo(gui=F,
          corpus.dir = "plain_corpus/ENG/",
          mfw.min=200,
          mfw.max=200,
          analyzed.features = "w",
          ngram.size = 1,
          distance.measure = "delta",
          sampling = "no.sampling",
          sample.size = 10000)

## German corpus
de=stylo(gui=F,
         corpus.dir = "plain_corpus/DEU/",
         mfw.min=200,
         mfw.max=200,
         analyzed.features = "w",
         ngram.size = 1,
         distance.measure = "delta",
         sampling = "no.sampling",
         sample.size = 10000)

## Now we will use the stylo data in the variables to access distance table

## distance table from stylo results
distances_en <- eng$distance.table %>%
  as.matrix() # convert to base R matrix object

distances_de <- de$distance.table %>% 
  as.matrix() # convert to base R matrix object

## distance matrices are symmetric (A to B = B to A) - double information, so we take only lower triangle for similarity scores
lower_triangle = lower.tri(distances_en,diag = F)

## now let's check unique distances distribution

hist(distances_en[lower_triangle]) # OK, ~gaussian is expected
hist(distances_de[lower_triangle]) # something weird! distances clearly come from TWO distributions: one with mean ~1 (the expected, like eng) and another across extreme distances >2.
## Can you find out what is happening there? 

#### Combining distances and metadata ####

## Now we need to make sense of distance relationships : between which novels they are and what is time difference is between them. To do this we need:

## 1. novel-novel pair names
## 2. year difference within the pair
## 3. connecting everything back to distances

## 1. Novel-novel pair names: getting this using interaction() between two identical sets of novel ids. This gives us all possible combinations (100 x 100)
source_target=interaction(rownames(distances_en),rownames(distances_en))

## Now we are constructing a matrix - the same structure as our distance matrix, but now there are "novel X novel" labels at each row X column intersetion
source_target_m=matrix(levels(source_target),nrow=100,ncol=100)

## check the small sample of the matrix
source_target_m[1:2,1:2]

## 2. We calculate difference between each pair of novels from metadata
## We utilize the fact that stylo distance table and our metadata follow alphabetical order, so they are mutually mappable. We only need to get novel x novel year differences (using outer() function) and keep in mind it follows the same order as our two previous matrices: with distances and with labels
y_diff=outer(X = meta_en$year,
             Y = meta_en$year,
             FUN = "-")


## That is it. Now we take only unique "lower triangle" values from each matrix and bind them in a "long" table. Each row of this table is one observation of a novel x novel relationship: it has ID x ID label, stylometric distance between these novels and year difference between them.
d=distances_en[lower_triangle]
l=source_target_m[lower_triangle]
y=y_diff[lower_triangle]

df_en <- tibble(distance=d,
       year_diff=abs(y),
       rel=l,
       lang="en") 

## repeating the same for German corpus
## novel x novel labels
source_target=interaction(rownames(distances_de),rownames(distances_de))
source_target_m=matrix(levels(source_target),nrow=100,ncol=100)
## year diff
y_diff=outer(X = meta_de$year,
             Y = meta_de$year,
             FUN = "-")

d=distances_de[lower_triangle]
l=source_target_m[lower_triangle]
y=y_diff[lower_triangle]

df_de <- tibble(distance=d,
                year_diff=abs(y),
                rel=l,
                lang="de")

## there is another problem with German corpus, some "first editions" dates come from the late 20th century editions - published after death of author. Some novels lack the exact date of composition at all. 

## eltec time span is 1840-1920, so all "differences" over 80 are because of late editions that do not reflect the composition year (we removed late editions earlier)
hist(df_de$year_diff)
hist(df_en$year_diff)

#### Differences in time and style ####

df_de %>%
  # here we filter: 1) novels that do not have exact date; 2) extreme distances
  filter(!is.na(year_diff), distance<2) %>% 
  bind_rows(df_en) %>% # join with english table
  ggplot(aes(year_diff,distance,group=lang)) + # plotting
  geom_point(aes(shape=lang),alpha=0.1) + # plotting
  geom_smooth(aes(color=lang),method="lm") + # plotting
  scale_color_manual(values=pal1)

## We see minor upward slopes for DE and ENG, indicating that, on average, difference in style is increasing with time between text.

## This is however a slightly misleading approach: there are much more data in the first half of "year differences" than in the second. Only novels from 1840s and  1920s have 80 years distances, while 0-10 years distances have all novels in the corpus (indicated in the plot by increased shade on the left). We also assume that stylistic/linguistic diversity does not matter for the period and lump everything together. In other words, we are punished by history because of assuming symmetry in time.

## another way to look at it is anchoring our perspective: let's say we are standing in early 1840s, looking into the future. How much fiction style/language change happens if we compare the "today" of 1840s to all future?
## this will require a little bit of tinkering to choose only the relationships with 1840s novels, but is doable

## combine EN/DF

en2 <- df_en %>% 
  # split column of novel.novel two two columns to join metadata later for each participant of the relationship
  separate(rel, into=c("source", "target"),sep = "\\.") %>%
  # join metadata once
  left_join(meta_en %>% select(id,year),by=c("source" = "id")) %>%
  rename(year_source=year) %>%
  # join metadata twice
  left_join(meta_en %>% select(id,year),by=c("target" = "id")) %>%
  rename(year_target=year)

## repeat for German
de2 <- df_de %>%
  filter(!is.na(year_diff),distance<2,year_diff <= 90) %>% 
  separate(rel, into=c("source", "target"),sep = "\\.") %>%
  left_join(meta_de %>% select(id,year),by=c("source" = "id")) %>%
  rename(year_source=year) %>%
  left_join(meta_de %>% select(id,year),by=c("target" = "id")) %>%
  rename(year_target=year)

## combine and plot
bind_rows(de2,en2) %>% 
  ## calculate corresponding "decade" for each novel
  mutate(dec_target=floor(year_target/10)*10,
         dec_source=floor(year_source/10)*10)  %>%
  ## this is a tricky part, but we just sort the year-to-year relationship by the earliest
  group_by(source,target) %>% 
  mutate(early=paste(sort(c(dec_source,dec_target)), collapse=" ")) %>%
  ## then we take only those relationships that include novels from 1840s (our anchor point)
  filter(str_detect(early, "^1840")) %>% 
  ggplot(aes(year_source,distance,group=lang)) + 
  geom_point(aes(shape=lang),alpha=0.3) + 
  geom_smooth(aes(color=lang),method="gam") + # using generalized additive models to allow the trendline to "wiggle"
  theme_minimal() +
  facet_wrap(~lang) +
  scale_color_manual(values=pal1)

