// Typst Template - Converted from LaTeX
// Equivalent to your standard LaTeX article template

// Variables (like \newcommand for assignment details)
#let assignmentname = "Empirical Study of Memorization in Differentially Privately Fine-Tuned Large Language Models"
#let shortassignmentname = "Memorization in DP Fine-Tuned LLMs"
#let duedate = "17 Apr 2026"

// Markers for headings without number
#show selector(<nonumber>): set heading(numbering: none)

// Page setup - equivalent to geometry package
#set page(
  paper: "a4",
  margin: (
    x: (8.5in - 7in) / 2, // Centers 7in width on page
    y: (11in - 8.5in) / 2, // Centers 8.5in height on page
  ),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 10pt)
      #grid(
        columns: (1fr, 2fr, 1fr),
        align: (left, center, right),
        [#duedate], [#shortassignmentname], [Johnny Meng],
      )
      #v(-1.5em)
      #line(length: 100%, stroke: 0.5pt)
    ]
  },
  footer: context {
    align(center)[
      #set text(size: 12pt)
      #counter(page).display("1")
    ]
  },
)

// Text settings
#set text(
  size: 11pt,
  lang: "en",
  hyphenate: false, // Equivalent to \usepackage[none]{hyphenat}
)

// Paragraph settings
#set par(
  justify: true,
  leading: 0.65em * 1.5, // Equivalent to \onehalfspacing
  spacing: 7mm, // Paragraph spacing
  first-line-indent: 0em, // Equivalent to parskip package
)

// Heading numbering
#set heading(numbering: "1.")

// List settings
#set list(indent: 1.5em)
#set enum(indent: 1.5em)

// Citation style: APA
#set cite(style: "apa")

// Heading spacing
#show heading: it => {
  set block(above: 1.5em, below: 1.5em)
  it
}

// Hyperlinks
#show link: set text(fill: blue)

// Figure placement
#show figure: set figure(placement: auto)

// Theorem-like environments
#let proof(body) = [
  _Proof._ #body #h(1fr) $square.filled$
]

#let solution(body) = [
  _Solution._ #body #h(1fr) $square.filled$
]

// Custom math commands (like \newcommand)
#let del = $partial$

// Title page
#align(center)[
  #text(size: 18pt, weight: "bold")[
    #assignmentname
  ]

  #v(0.5em)

  #text(size: 14pt)[
    Yuwei (Johnny) Meng
  ]

  #v(0.3em)

  #text(size: 12pt)[
    #duedate
  ]
]

#v(1em)

// Document content starts here

=== #link("https://github.com/BullDF/dp-finetuned-llms", "Link to GitHub Repo") <nonumber>

= Abstract <nonumber>

= Introduction

In 2017, a group of researchers at Google Brain proudly announced the architecture of the transformer neural model, which revolutionized the field of Natural Language Processing (NLP) and led to the rise of large language models (LLMs). Training LLMs requires large amounts of data, and if not curated carefully, these datasets might contain sensitive information such as social security numbers or medical records. This poses a severe problem in model security and ethics, as shown by #cite(<carlini>, form: "prose") that neural networks have a high risk of unintentionally memorizing fine-grained information and oddly-specific details. To mitigate this issue and protect the privacy of individuals, one approach is to leverage methods from _differential privacy_ (DP), which provides a rigorous mathematical framework for quantifying privacy #cite(<dwork>). With DP, researchers have developed DP-based training methods, such as DP-SGD, to train neural networks and showed that they effectively mitigate privacy concerns during training. Background information about DP and DP-SGD utilized in this paper is described in @sec:background.

Despite the prominent performance of DP-augmented training methods, the use of these methods in training or fine-tuning LLMs still remains underexplored in both research and industrial settings. Specifically, the benefits of DP in reducing unintentional memorization of training data are to be precisely quantified. Therefore, this study aims to narrow down this gap by investigating the following research question:

#quote(block: true)[
  _At what privacy budget $epsilon$ does DP-SGD effectively prevent memorization of sensitive sequences in fine-tuned LLMs, and what is the accuracy cost of that protection?_
]

= Background <sec:background>

Differential privacy is a mathematical framework that leverages probability theories to rigorously quantify privacy in algorithms #cite(<dwork>). Formally, let $cal(X)$ denote the data space and $X = (x_1, dots.c.h, x_n) in cal(X)^n$ be a dataset. We can then define another dataset $X' = (x'_1, dots.c.h, x'_n) in cal(X)^n$ to be a _neighboring dataset_ of $X$, denoted as $X ~ X'$, if there exists $i in {1, dots.c.h, n}$ such that $x_i != x'_i$, and for all $j != i$, $x_j = x'_j$. With this setup, we say that a randomized algorithm $cal(M)$ is _$(epsilon, delta)$-differentially private_ if for all datasets $X ~ X'$, and all $S subset.eq Omega$ where $Omega$ is the output space of $cal(M)$,
$
  bb(P)(cal(M)(X) in S) <= e^epsilon bb(P)(cal(M)(X') in S) + delta.
$
In the context of training deep neural networks, we can adapt this definition and make gradient descent a differentially private algorithm so that the trained models do not memorize specific details of any training data. Defining $cal(L)$ as the loss function, $alpha$ as the learning rate, instead of updating the weights by $alpha nabla cal(L)$ at every step, we first compute each per-sample gradient $nabla cal(L)_i$ and clip it to the L2 norm bound $C$, then sum the clipped per-sample gradients and add random noise from $cal(N)(0, sigma^2 C^2 bold(I))$ to the sum before updating. By choosing the parameters $sigma$ and $C$ strategically, one can show that this algorithm, named _differentially private stochastic gradient descent_ (DP-SGD), satisfies $(epsilon, delta)$-differential privacy #cite(<abadi>).

= Related Work

Since the introduction of the concept of DP, most previous work focused on using DP techniques on training or fine-tuning neural networks of simpler architectures compared to transformers. For example, albeit on language modeling, #cite(<mcmahan>, form: "prose") applied another DP algorithm called _federated averaging_ (FedAvg) on training recurrent language models such as RNNs and LSTMs. In the study, they experimented with various hyperparameters for noise and gradient clipping to quantify the downside of DP training on the performance of language models. On the other hand, the study by #cite(<carlini>, form: "prose") conducted experiments on investigating language modeling ability of LSTM models on the Penn Treebank dataset. A similar characteristic shared across these two papers is that the models they used in their experiments are rather small: 600,000 parameters for the model in #cite(<carlini>, form: "prose") and 1.35M parameters for the model in #cite(<mcmahan>, form: "prose"), notably also trained on a Reddit dataset. Since LLMs have grown exponentially in size nowadays, it necessitates, urgently, more research on deploying DP techniques on training larger models.

Studies on applying DP techniques on fine-tuning LLMs do exist, with #cite(<yu>, form: "prose") being a foundational one. In this paper, the authors conducted two experiments, one on natural language understanding and the other on natural language generation, both using DP-SGD, and they compared the model performance against the state-of-the-art on different benchmarks. For NLU tasks, they used RoBERTa models, while for NLG tasks, the models they used come from the GPT-2 suite, with GPT-2 Small being the smallest model but still having 117M parameters, much larger than the models in previous studies. More recently, a paper by #cite(<du>, form: "prose") also examines the effect of DP-SGD in fine-tuning GPT-2 models. However, they focused more on comparing different fine-tuning methods, including FFT, LoRA, prefix-tuning, and P-tuning, rather than directly investigating DP-SGD on GPT-2.

Despite these studies on DP fine-tuning LLMs, the datasets they used to evaluate their models are not inherently private: #cite(<yu>, form: "prose") used data from the restaurant domain and DART which is open-domain, while #cite(<du>, form: "prose") used Wikitext-2-v1 and AG News. The downside is that all these datasets are public sources and do not contain sensitive information. In order to gauge into how DP techniques perform on private datasets, which was the reason DP was developed in the first place, it is preferred to apply them to a more private, sensitive domain so that we can truly evaluate the effectiveness of DP before its actual deployment in real-world settings. This is thus the main motivation of this project: applying DP techniques to a mental health dataset, which is inherently privacy-sensitive.

= Methodology

= Results & Discussion

= Conclusion

== Limitations & Future Directions

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
