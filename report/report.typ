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



= Background

Differential privacy (DP) is a mathematical framework that leverages probability theories to rigorously quantify privacy in algorithms #cite(<dwork>). Formally, let $cal(X)$ denote the data space and $X = (x_1, dots.c.h, x_n) in cal(X)^n$ be a dataset. We can then define another dataset $X' = (x'_1, dots.c.h, x'_n) in cal(X)^n$ to be a _neighboring dataset_ of $X$, denoted as $X ~ X'$, if there exists $i in {1, dots.c.h, n}$ such that $x_i != x'_i$, and for all $j != i$, $x_j = x'_j$. With this setup, we say that a randomized algorithm $cal(M)$ is _$(epsilon, delta)$-differentially private_ if for all datasets $X ~ X'$, and all $S subset.eq Omega$ where $Omega$ is the output space of $cal(M)$,
$
  bb(P)(cal(M)(X) in S) <= e^epsilon bb(P)(cal(M)(X') in S) + delta.
$
In the context of training deep neural networks, we can adapt this definition and make gradient descent a differentially private algorithm so that the trained models do not memorize specific details of any training data. Defining $cal(L) $ as the loss function, $alpha $ as the learning rate, instead of updating the weights by $alpha nabla cal(L) $ in every epoch, we first compute each per-sample gradient $nabla cal(L)_i $ and clip it to the norm bound $C $, then sum the clipped per-sample gradients and add random noise from $cal(N)(0, sigma^2 C^2 bold(I)) $ to the sum before updating. By choosing the parameters $sigma $ and $C $ strategically, one can show that this algorithm, named _differentially private stochastic gradient descent_ (DP-SGD), satisfies $(epsilon, delta) $-differential privacy #cite(<abadi>).

= Related Work

= Methodology

= Results & Discussion

= Conclusion

== Limitations & Future Directions

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
