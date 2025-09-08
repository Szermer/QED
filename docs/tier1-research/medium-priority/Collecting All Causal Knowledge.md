---
title: "CauseNet"
description: "Collecting All Causal Knowledge"
keywords: ""
source: "https://causenet.org/"
---

## Collecting All Causal Knowledge

CauseNet aims at creating a causal knowledge base that comprises all human causal knowledge and to separate it from mere causal beliefs, with the goal of enabling large-scale research into causal inference.

Causal knowledge is seen as one of the key ingredients to advance artificial intelligence. Yet, few knowledge bases comprise causal knowledge to date, possibly due to significant efforts required for validation. Notwithstanding this challenge, we compile CauseNet, a large-scale knowledge base of _claimed_ causal relations between causal concepts. By extraction from different semi- and unstructured web sources, we collect more than 11 million causal relations with an estimated extraction precision of 83\% and construct the first large-scale and open-domain causality graph. We analyze the graph to gain insights about causal beliefs expressed on the web and we demonstrate its benefits in basic causal question answering. Future work may use the graph for causal reasoning, computational argumentation, multi-hop question answering, and more.

## Download

We provide three versions of our causality graph CauseNet:

* [CauseNet-Full](https://groups.uni-paderborn.de/wdqa/causenet/causality-graphs/causenet-full.jsonl.bz2): The complete dataset
* [CauseNet-Precision](https://groups.uni-paderborn.de/wdqa/causenet/causality-graphs/causenet-precision.jsonl.bz2): A subset of CauseNet-Full with higher precision
* [CauseNet-Sample](https://groups.uni-paderborn.de/wdqa/causenet/causality-graphs/causenet-sample.json): A small sample dataset for first explorations and experiments without provenance data

## Statistics

|   | Relations | Concepts | File Size |
| --- | --- | --- | --- |
| CauseNet-Full | 11,609,890 | 12,186,195 | 1.8GB |
| CauseNet-Precision | 199,806 | 80,223 | 135MB |
| CauseNet-Sample | 264 | 524 | 54KB |

## Data Model

The core of CauseNet consists of causal concepts which are connected by causal relations. Each causal relation has comprehensive provenance data on where and how it was extracted.

![drawing](https://causenet.org/img/data-model.svg)

## Examples of Causal Relations

Causal relations are represented as shown in the following example. Provenance data is omitted.

```
{
    "causal_relation": {
        "cause": {
            "concept": "disease"
        },
        "effect": {
            "concept": "death"
        }
    }
}
```

For CauseNet-Full and CauseNet-Precision, we include comprehensive provenance data. In the following, we give one example per source.

For relations extracted from natural language sentences we provide:

* `surface`: the surface form of the sentence, i.e., the original string
* `path_pattern`: the linguistic path pattern used for extraction

### ClueWeb12 Sentences

* `clueweb12_page_id`: page id as provided in the ClueWeb12 corpus
* `clueweb12_page_reference`: page reference as provided in the ClueWeb12 corpus
* `clueweb12_page_timestamp`: page access data as stated in the ClueWeb12 corpus

```
{
    "causal_relation":{
        "cause":{
            "concept":"smoking"
        },
        "effect":{
            "concept":"disability"
        }
    },
    "sources":[
        {
            "type":"clueweb12_sentence",
            "payload":{
                "clueweb12_page_id":"urn:uuid:4cbae00e-8c7f-44b1-9f02-d797f53d448a",
                "clueweb12_page_reference":"http://atlas.nrcan.gc.ca/site/english/maps/health/healthbehaviors/smoking",
                "clueweb12_page_timestamp":"2012-02-23T21:10:45Z",
                "sentence": "In Canada, smoking is the most important cause of preventable illness, disability and premature death.",
                "path_pattern":"[[cause]]/N\t-nsubj\tcause/NN\t+nmod:of\t[[effect]]/N"
            }
        }
    ]
}
```

### Wikipedia Sentences

* `wikipedia_page_id`: the Wikipedia page id
* `wikipedia_page_title`: the Wikipedia page title
* `wikipedia_revision_id`: the Wikipedia revision id of the last edit
* `wikipedia_revision_timestamp`: the timestamp of the Wikipedia revision id of the last edit
* `sentence_section_heading`: the section heading where the sentence comes from
* `sentence_section_level`: the level where the section heading comes from

```
{
    "causal_relation":{
        "cause":{
            "concept":"human_activity"
        },
        "effect":{
            "concept":"climate_change"
        }
    },
    "sources":[
        {
            "type":"wikipedia_sentence",
            "payload":{
                "wikipedia_page_id":"13109",
                "wikipedia_page_title":"Global warming controversy",
                "wikipedia_revision_id":"860220175",
                "wikipedia_revision_timestamp":"2018-09-19T04:52:18Z",
                "sentence_section_heading":"Global warming controversy",
                "sentence_section_level":"1",
                "sentence": "The controversy is, by now, political rather than scientific: there is a scientific consensus that climate change is happening and is caused by human activity.",
                "path_pattern":"[[cause]]/N\t-nmod:agent\tcaused/VBN\t+nsubjpass\t[[effect]]/N"
            }
        }
    ]
}
```

### Wikipedia Lists

* `list_toc_parent_title`: The heading of the parent section the list appears in
* `list_toc_section_heading`: The heading of the section the list appears in
* `list_toc_section_level`: The nesting level of the section within the table of content (toc)

```
{
    "causal_relation":{
        "cause":{
            "concept":"separation_from_parents"
        },
        "effect":{
            "concept":"stress_in_early_childhood"
        }
    },
    "sources":[
        {
            "type":"wikipedia_list",
            "payload":{
                "wikipedia_page_id":"33096801",
                "wikipedia_page_title":"Stress in early childhood",
                "wikipedia_revision_id":"859225864",
                "wikipedia_revision_timestamp":"2018-09-12T16:22:05Z",
                "list_toc_parent_title":"Stress in early childhood",
                "list_toc_section_heading":"Causes",
                "list_toc_section_level":"2"
            }
        }
    ]
}
```

### Wikipedia Infoboxes

* `infobox_template`: The Wikipedia template of the infobox
* `infobox_title`: The title of the Wikipedia infobox
* `infobox_argument`: The argument of the infobox (the key of the key-value pair)

```
{
    "causal_relation":{
        "cause":{
            "concept":"alcohol"
        },
        "effect":{
            "concept":"cirrhosis"
        }
    },
    "sources":[
        {
            "type":"wikipedia_infobox",
            "payload":{
                "wikipedia_page_id":"21365918",
                "wikipedia_page_title":"Cirrhosis",
                "wikipedia_revision_id":"861860835",
                "wikipedia_revision_timestamp":"2018-09-30T15:40:21Z",
                "infobox_template":"Infobox medical condition (new)",
                "infobox_title":"Cirrhosis",
                "infobox_argument":"causes"
            }
        }
    ]
}
```

## Loading CauseNet into Neo4j

We provide [sample code](https://causenet.org/data/load-into-neo4j.ipynb) to load CauseNet into the graph database [Neo4j](https://neo4j.com/).

The following figure shows an excerpt of CauseNet within Neo4j (showing a coronavirus causing the disease SARS):

![drawing](https://causenet.org/img/graph.svg)

## Concept Spotting Datasets

For the construction of CauseNet, we employ a causal concept spotter as a causal concept can be composed of multiple words (e.g., “global warming”, “human activity”, or “lack of exercise”). We determine the exact start and end of a causal concept in a sentence with a sequence tagger. Our training and evaluation data is available as part of our [concept spotting datasets](https://groups.uni-paderborn.de/wdqa/causenet/concept-spotting): one for Wikipedia infoboxes, Wikipedia lists, and ClueWeb sentences. We split each dataset into 80% training, 10% development and 10% test set

## Paper

CauseNet forms the basis for our CIKM 2020 paper [CauseNet: Towards a Causality Graph Extracted from the Web](https://papers.dice-research.org/2020/CIKM-20/heindorf_2020a_public.pdf). Please make sure to refer to it as follows:

```
@inproceedings{heindorf2020causenet,
  author    = {Stefan Heindorf and
               Yan Scholten and
               Henning Wachsmuth and
               Axel-Cyrille Ngonga Ngomo and
               Martin Potthast},
  title     = {CauseNet: Towards a Causality Graph Extracted from the Web},
  booktitle = {{CIKM}},
  publisher = {{ACM}},
  year      = {2020}
}
```

For questions and feedback please contact:

Stefan Heindorf, Paderborn University  
Yan Scholten, Technical University of Munich  
Henning Wachsmuth, Paderborn University  
Axel-Cyrille Ngonga Ngomo, Paderborn University  
Martin Potthast, Leipzig University

## Licenses

The code is licensed under a [MIT license](https://opensource.org/licenses/MIT). The data is licensed under a [Creative Commons Attribution 4.0 International license](https://creativecommons.org/licenses/by/4.0/).