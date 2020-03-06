# Notes from Malaga meetings
## WG2 meeting agenda:
* transition of leadership
* documenting of group activities / inner reporting pipeline (wiki, github repo)
* reports on NER, PoS and SA subgroups' progress
* state of the papers in writing
* level 2 annotation - agreement on representation, problems with conversions
* survey of tools for particular languages
WG1+WG2 meeting:
* discussing level 2 annotation and challenges
WG2+WG3 meeting:
* research collaboration between groups
* as determined in Budapest, focus is on building on information we should have at Level 2 annotation rather than inventing completely new tools
* possibility of shared pilot studies on using/analyzing ELTeC: e.g. direct speech across languages; Named Entities across collections; syntactic complexity and other ideas discussed previously here: https://wiki.distant-reading.net/index.php?title=WG3_%26_WG2_Collaborative_Meeting_in_Lisbon_-_Research_Questions&oldid=610 - please take a look and think if you would like to get involved in one of these
* WG2 meeting in the fall of 2020 - separate? joined with another group? (not 8-15 and 20-27 September)

## WG2 meeting notes
### 1. Documentation
Notes from the meetings will be placed on wiki: https://wiki.distant-reading.net/
Extra materials, like CoNLL-U files from UDPipe, will be posted on the https://github.com/distantreading/WG2

### 2. Reports and status of works
Works are going as planned, good progress on papers. 
Discussions resolved around accuracy:
* PoS taggers have good performance. However, languages that have a long historic evolution can't be tagged so accurately since historic texts are very different from the modern ones in many dimensions, which increases the need for corrections / using historical language specific taggers.
* In regard to low results of automatic NER tagging, George pointed out that we should have a threshold related to the annotation accuracy achieved by our tools. If the results are poor we should not include the annotations in the ELTeC.
* Semantic analysis group focuses on surveying and identifying lists of positive / negative words in particular languages.
* (new) work is being done on Direct Speech identification by mixed group from Antwerp and Kraków using BERT - covered at length in materials from the Wednesday workshop (to be added here soon) - it could be checked if deep learning approaches could also boost efficiency for problematic subtasks in NER.

### 3. Level 2 Schema
In relation to earlier talks with WG1 leaders, we divided Level 2 annotation into two sublevels, to ensure quicker delivery of any Level 2 annotation.
The first list, deliverable almost now includes:
List 1	tokenization
List 1	lemmatization, both at token-level and MWU-level
List 1	parts of speech
List 1	morphological information (single string, case marking, inflection)
List 1	sentence segmentation
List 1	ID attribute (on word and sentence levels)

The second list covers
List 2	direct speech
List 2	indication of Named Entities
Which will require discussion on representation of multiword expressions.

Sentiment analysis is a very useful task but it was decided it should be removed from Level 2 due to various problems related to non-existing TEI encoding standards, and unclear application units (word, sentence, paragraph, text?). We should produce sentiment scores for ELTeC texts but these scores will not be part of the main Level 2 encoding schema but available as extra annotations containing sentiment analysis in a separate folder on github.

In the joint meeting with WG1 we discussed Ioana’s and Gabor’s annotation proposals, agreeing on the following type of sentence annotation schema:

```
<s xml:id="s1">
  <w lemma="" msd="" pos="" xml:id="w1">word</w>
  <pc join="" pos="PUNCT" xml:id="pc1">.</pc>
</s>
```

e.g.:
```
<p xml:id="p1">
  <s xml:id="s1">
    <w lemma="a" msd="Definite=Def|PronType=Art" pos="DET" xml:id="w1">A</w>
    <w lemma="Radnóthy" msd="Case=Nom|Number=Sing" pos="PROPN" xml:id="w2">Radnóthy</w>
    <w lemma="Elek" msd="Case=Nom|Number=Sing" pos="PROPN" xml:id="w3">Elek</w>
    <w lemma="udvarház" msd="Case=Nom|Number=Sing|Number[psor]=Sing|Person[psor]=3" pos="NOUN" xml:id="w4">udvarháza</w>
    <w lemma="híres" msd="Case=Nom|Degree=Pos|Number=Sing" pos="ADJ" xml:id="w5">híres</w>
    <w lemma="van" msd="Definite=Ind|Mood=Ind|Number=Sing|Person=3|Tense=Past|VerbForm=Fin|Voice=Act" pos="VERB" xml:id="w6">volt</w>
    <w lemma="a" msd="Definite=Def|PronType=Art" pos="DET" xml:id="w7">a</w>
    <w lemma="Kisküküllő" msd="Case=Nom|Number=Sing" pos="PROPN" xml:id="w8">Kisküküllő</w>
    <w lemma="mentén" msd="_" pos="ADP" xml:id="w9">mentén</w>
    <pc join="left" pos="PUNCT" xml:id="pc1">.</pc>
  </s>
</p>
```
Full examples can be found [here](https://github.com/distantreading/WG2/tree/master/annotation-level2-examples)

We also considered the case of shortened forms, like 'des' in French

```
<w>des</w>
<w lemma="de" pos="ADP">de</w>
<w lemma="le" pos="DET" msd="Definite=Def|Gender=Masc|Number=Plur|PronType=Art">les</w>
```

agreeing that they should include both lemmas & POSes in the <w> tag of des, connected by +, e.g. lemma="de+le".

Notes shared with WG1:
https://semestriel.framapad.org/p/9f29-wg1malaga2020

Spaces should be embedded in a separate join element.

On Wednesday meeting we agreed to annotate direct speech as <said> spans to allow for word counting and possibility of future use of attributes e.g. for distinguishing between thoughts and speech.

During the meeting we agreed to discuss whether we need one or more tagsets. In the follow-up WG2 meeting we came to the agreement that we'd propose using Universal Dependencies tagset. While we do not exclude possibility of using other taggers than UDPipe, we recommend mapping their tagsets into UD before including the annotated files into ELTeC. Silvie offered to ask UD people for conversion tools should any of us choose to use tools other than UDPipe and encounter problems with mapping to UD - they stay in touch with developers of various tools and should be able to point us to solutions.

We also ask WG1 to consider the possibility of adding an expos tagset - which would facilitate inclusion of language specific tags for morphologically rich languages. To avoid empty attributes, we'd propose using the phrase "non-available" in texts which would not contain expos information.

So as not to lose grammatical information already obtained, we will place experimental CONLLU and CWBs on our Github for the use of people interested in more advanced linguistic-syntactic analysis.

In case of objections to this schema, we ask for expressing them by 10th March. With no objections, we will propose a formal schema to WG1 to discuss and hopefully accept around half of March, aiming to have design issues with Level 2 annotation resolved by the end of March.

### 4. Collaboration between WG3 and WG2

During the meeting we focused on discussing potential cooperation / use of methods in studying:
* Canonicity
* Lexical density / richness
* Character networks
* Proportion of dialogue / narrative
* Internationalization

We identified some possible shared interests / papers
* Georeferencing Jessie & Diana
* Professions Stefano & Diana
* Gender paper  – > Katja and Jan
* Demo for visualization -> Raquel with Isabel

Other ideas for future factors to be examined across ELTeC were:
* characterization of major / minor characters
* crossreferences of other languages / dialogue in other languages
* verba dicenci
* tracing progress of features across subsequent time periods
* providing for all novels summary / validation of topics with wikipedia summaries
* can exploratory tools detect language evolution
* detecting which influences in the canon become most important  –  library searches for literary handbooks from the time - but could be challenging for non-literary scholars / repeating was already done

We raised the question if the number of reprints includes electronic editions - and should check this with WG 1. Visualizations on the number of reprints could be useful for canonization paper.

To build on the idea of shared projects, we decided that Autumn WG2+WG3 meeting will take a hackathon-like form of working together on specific issues (more below).

### 5. Autumn 2020 meeting
We are planning an autumn Working Group meeting together with WG3, colocated with Core Group meeting. Possible hosts include Triest, Belgrade and Riga, the dates are likely to be first or last days of September.

To help us move towards using ELTeC as a research resource, the meeting will take a form of a hackathon focused on work on specific problems requiring both computational skills and traditional literary expertise - we plan to take upon geographical names in novels, with George, Antonija, Silvie and Benedikt already drafting some ideas.

## Action points:
1. (optional and hopefully non) Voicing objections to Level 2 schema before 10th March, and further acceptance and preparation of the annotations.
2. Organizing a hackathon during the next meeting.
3. We encourage you all to think of for ideas on visualization of canonization data (e.g. take a look at what you can do with http://hyperbase.unice.fr/ and Txm).
4. In continuation of last Grant Period's approach to STSMs, the Action plans to fund approx. 8 STSMs in GP4. As we aim to release the call for STSMs around summer, we should think if we have specific needs that could be tackled through a focused STSM, e.g. creating converters for annotation, preparing annotation of languages that are missing - please contact Joanna and George if you see specific needs you could use someone's help with.

