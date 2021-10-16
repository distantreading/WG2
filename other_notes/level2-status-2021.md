# Collected notes from pandemic discussions over email and small team meeting summarizing them in September

## 1. Encoding contraction/clitics
Reference to take a look:
[Parla Clarin example](https://clarin-eric.github.io/parla-clarin/#sec-ananorm)
The expected manner of encoding:
```
<w>du<w lemma="de" pos="ADP"  norm="de"/><w lemma="le" pos="DET" msd="Definite=Def|PronType=Art" norm="le"/></w>
```
Lou: The proposed solution looks quite strange to me, though it is certainly valid by the existing schema -- unless we decide to make e.g. @pos obligatory on every `<w>` which would  maybe not be such a bad idea.

## 2. POS encoding
We expect UD format, but any tagger can be used, as long as the results are mapped to the UD tagset.
Some examples of taggers are [UDPipe](https://lindat.mff.cuni.cz/services/udpipe/), [Stanza](https://stanfordnlp.github.io/stanza/) or Treetagger, Spacy, etc. Only UD Pipe and Stanza have pre-trained models that are already UD compatible.  
-> So the next version of the schema will revert to enforcing use of UDP values for the @pos attribute -- and complain if other values are used.

## 3. XPOS annotation
xpos tags = foreign parts of speechs can optionally be encoded with @ana attribute - this will require an explanation in the header (Lou will inform us of how to, given that most reactions so far lean towards @ana, see below). The @ana can contain any "local" tagset
It also- needs to be decided whether to use pointers or the extended TEI pointer syntax for the value of @ana.

## 4. MSD annotation
msd is a posible but optional parameter, should have its value as UD morphological features

## 5. Should we have @id attribute for each word
This is already allowed on any structure, but not required or recommended. If there is a public demand that this is needed we might come back to this question and determine how to do it.

## 6. Splitting into sentences with ```<s>``` is required.
For title and chapter - we provide a sentence tag within the header

##7. Punctuation
Punctuation should be marked with <pc>. We also require the use of @join="right" on the tokens that should not be followed by a space.

## 8. Finding a place for a "modernized" version to be encoded, i.e. allow for a modern and an ancient ortography?
Lou is slightly against it, arguing that a search for changing ortography can be done with lemmas. We might come back to it after completing level 2 if it will seem important still then.
Lou: If there's a strong feeling that for some languages the ability to encode explicitly a normalised form is necessary, then we could easily introduce the TEI @norm attribute on `<w>`. It might be good in this context to reconsider whether we also need the `<corr>` element.
Tomaž: Well, we now also have the @norm attribute on words (needed for syntactic words as per 1. above), so this could be easily used also for the modernised form of words. There is a problem if a word has a modernised form, and this form is then decomposed into 2 syntactic words - while the encoding could be further complicated, I suggest that in this case we don't have the modernised form, but just the syntactic words. A bit ugly, I admit.

## 9. Providing information about quality of annotation
This is a new suggestion from Michael: should we provide a measure of quality of the various annotations?
When this came up in the small meeting we were in favour of providing information about the quality of annotation of particular texts. But implementing this requires some discussions - do we define a uniform manner of evaluating the quality? at what stage should it be measured (pre or post possible manual corrections)? where and how should it be encoded? We plan to come back to this question in the near WG2 meeting and discuss available options.

Ideas:
Lou: In the first instance, maybe a paragraph in the readme file for the level2 repository would suffice, but it should find its way into the corpus header encodingDesc too.
Tomaz: I think this would be nice, but it is expensive to manually check all the annotations for a big enough sample (by somebody who understands UD), so I am a bit skeptical that people will be able to do it.

## 10. Encoding additional NE 
The discussion on this issue is postponed to a later meeting

## More on @ana from Lou:
Concerning @ana -- the value of this attribute in TEI is defined explicitly as  xsd:anyURI. So we might represent the magic xpos code "wibble" in one of the following ways:
(1) ana="#wibble" : somewhere in the current document there is an element with an @xml:id which explains what a wibble is.
(2) ana="http://somewhere.org/wibble" : the explanation for wibble is at the URI indicated
(3) ana= "sw:wibble" : a shortened form of (2) : implies the existence of a mapping from "sw" to "https:whatever" using e.g. tei:prefixDef ([see](https://tei-c.org/release/doc/tei-p5-doc/en/html/ref-prefixDef.html))
Syntactically speaking, ana="wibble" is also valid, but means something we probably don't want (i.e. the content of a file called "wibble" in the current context) I would recommend either 1 or 3. For (1), you need to define explicitly all the codes you will use in your corpus somewhere, and include those definitions whenever a single text or the whole corpus
is being validated. For (3) you need to define only the prefix for inclusion similarly.  In either case, I'd put the definitions in a separate XML file and then xInclude that either in the text or the
corpus header as need be.
Example: for option 1
```
<interpGrp type="xpos">
<interp xml:id="wibble">an imaginary categorisation</interp>
<interp xml:id="hatstand">another imaginary categorisation</interp>
<!-- ... etc ... -->
</interpGrp>
```
Example for option 3
Assuming that documentation of the scheme in which wibble is defined is available from "http://somewhere.org",  and that this contains a section for each code, we might say
 something like 
 ```
 <prefixDef ident="sw" matchPattern="([a-z]+)"
replacementPattern="http://somewhere.org/$1" />
```

There is a good article on why the TEI extended pointer syntax needs some revision  at https://doi.org/10.4000/jtei.907. It's unclear to me whether there are any useful; implementations of it we could rely on
for our use case.

A second (or third) thought on pos/xpos attribute. We could simply use the existing @pos to provide the POS tag in the original tagset (the "xpos" value), and define a new @udp attribute to hold its UD
equivalent. Strictly speaking, that would have to be in a different namespace, but it is easy enough to add. So rather than `<w pos="NOUN" ana="my:sbsing">fish</w>`
we might do 
```
<w my:udp="NOUN" pos="sbsing">fish</w>
```
Not much to choose between them, maybe. I await with interest your reactions.

