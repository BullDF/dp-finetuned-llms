// Typst Template - Converted from LaTeX
// Equivalent to your standard LaTeX article template

// Variables (like \newcommand for assignment details)
#let assignmentname = "Empirical Study of Memorization in Differentially Privately Fine-Tuned Large Language Models"
#let shortassignmentname = "Memorization in DP Fine-Tuned LLMs"
#let duedate = "3 March 2026"

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

= Introduction & Related Work

Since the invention of the transformer architecture #cite(<vaswani>, style: "apa"), large language models (LLMs) have shown strong potential in various natural language processing tasks. However, the training of LLMs requires a large amount of text data, inevitably including sensitive information such as medical records. To protect the privacy of individuals, one approach is to leverage methods from _differential privacy_ (DP), which provides a rigorous mathematical framework for quantifying privacy #cite(<dwork>, style: "apa"). Formally, a randomized algorithm $cal(M)$ is $(epsilon, delta)$-differentially private if for all neighboring datasets $X, X'$ and all $S subset.eq Omega$, where $Omega$ is the output space of $cal(M)$,
$
  bb(P)(cal(M)(X) in S) <= e^epsilon bb(P)(cal(M)(X') in S) + delta.
$
In the context of training deep neural networks, we can adapt the computation of the gradient of the loss $cal(L)$ to be an $(epsilon, delta)$-differentially private algorithm: instead of updating the weights by $alpha dot.c nabla cal(L)$ where $alpha$ is the learning rate, we first compute each per-sample gradient $nabla cal(L)_i$ and clip it individually to the norm bound $C$, then sum the clipped per-sample gradients and add random noise from $cal(N)(0, sigma^2 C^2 bold(I))$ to the sum before updating. By choosing the parameters $sigma$ and $C$ strategically, one can show that this algorithm, named _differentially private stochastic gradient descent_ (DP-SGD) #cite(<abadi>, style: "apa"), satisfies $(epsilon, delta)$-differential privacy.

So why is DP-SGD useful? In the study by #cite(<carlini>, style: "apa", form: "prose"), the authors demonstrated that naive gradient descent has a high risk of leading neural networks to unintentionally memorize fine-grained information, such as social security numbers and oddly-specific details. They used a method called _canary insertion_, where they purposefully inserted formatted inputs such as "The random number is ...", known as canaries, into the training dataset. The results showed that unintentional memorization exists, and they stated that only differentially private training techniques are capable of eliminating this issue completely.

Although #cite(<carlini>, style: "apa", form: "prose") pointed out that differentially private algorithms may help with this issue of unintentional memorization, the main focus was on introducing the method of canary insertion and verifying the existence of the problem. More recently, #cite(<du>, style: "apa", form: "prose") applied differentially private techniques to various LLM fine-tuning methods, including FFT, LoRA, prefix-tuning, and P-tuning. However, the datasets they selected came from Wikitext-2-v1 and AG News, which are public sources. It is thus still unclear how effective differentially private training algorithms are on private, sensitive texts.

Therefore, considering the gap in the literature, using a Reddit Mental Health dataset from Kaggle, which is inherently privacy-sensitive, we propose the following research question for this project:

#quote(block: true)[
  _Using canary insertion, at what privacy budget does DP-SGD effectively prevent memorization of sensitive sequences in fine-tuned LLMs, and what is the accuracy cost of that protection?_
]

= Methodology

The proposed methodology is as follows:

1. Choose an LLM to work with. The GPT-2 small model is a good candidate considering limited computational resources and its open-source availability on Hugging Face.
2. Given the #link("https://www.kaggle.com/datasets/entenam/reddit-mental-health-dataset")[Reddit Mental Health Dataset] from Kaggle, purposefully insert canaries into the dataset. Vary the number of times the canaries are inserted for comparison.
3. Using next token prediction, fine-tune the GPT-2 small model on the dataset with canaries inserted using DP-SGD. Vary the privacy budget $epsilon$ for comparison.
4. Input the canary format into the fine-tuned model and check the rank of the canary in the output distribution.
5. On a validation set, measure the _log-perplexity_ defined as the following, which evaluates the model performance:
$
  "log-perp"_theta (x_1, dots.h.c, x_n) = -1/n sum_(i=1)^n log_2 bb(P)(x_i|f_theta (x_1, dots.h.c, x_(i-1))).
$

Given the above methodology, we make the following hypothesis:

#quote(block: true)[
  _The more times the canaries are inserted into the dataset, the lower the privacy budget $epsilon$ needs to be for DP-SGD to effectively prevent memorization of the canaries. As a tradeoff, achieving a lower privacy budget requires adding more noise to the gradients, which degrades model utility as measured by higher log-perplexity on the validation set._
]

I hope this research can shed some light on the intersection of DP and NLP research. The findings may also inspire future research and applications that apply DP to other NLP domains involving LLMs.

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
