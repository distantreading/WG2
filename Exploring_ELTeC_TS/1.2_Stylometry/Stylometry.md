# Exploring and comparing ELTeC corpora with stylometry
by Maciej Eder, Joanna Byszuk, Artjoms Šeļa

## Orientation
Stylo functions hands-on demo:
https://github.com/JoannaBy/stylo_nutshell

Example corpora:
https://github.com/COST-ELTeC/ELTeC-ukr
https://computationalstylistics.github.io/resources/

You can use one of the training corpora from the CSG website or the Ukrainian corpus (either normal version or pre-processed that is uploaded here) for first experiments. At the session we looked at stylo() and oppose() functions.  
Please note that oppose() might require a corpus language parameter: oppose(corpus.lang="Other").  
All methods are described in stylo nutshell linked above.  

## Advanced stylometry in Advanced hands-on subfolder

If you would want to reproduce the notebooks, not just glance at them, you might want to install RStudio on top of R + tidyverse library

Inside R console run: install.packages("tidyverse")