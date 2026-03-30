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

Large language models (LLMs) trained on sensitive data risk unintentionally memorizing private information, posing significant privacy concerns. Differential privacy (DP) offers a rigorous mathematical framework to mitigate this risk, but its effectiveness in reducing memorization in fine-tuned LLMs remains underexplored. In this paper, we empirically investigate the relationship between the privacy budget $epsilon$ and canary memorization in GPT-2 Small fine-tuned with DP-SGD on a mental health Reddit dataset. Using the canary insertion technique, we insert synthetic sensitive sequences at varying frequencies and measure memorization by the exposure metric across combinations of $epsilon in {0.5, 1, 2, 4, 8, infinity}$ and insertion frequencies $"freq" in {1, 5, 10, 50}$. Our results show that without DP, the model memorizes canaries with exposure scaling with insertion frequency, reaching the theoretical maximum of 19.78 bits. With any finite $epsilon$, memorization is effectively suppressed to near-random levels regardless of frequency. The utility cost of DP is a 39-44% increase in validation perplexity over the no-DP baseline. We conclude that DP must be applied, but the specific value of $epsilon$ has limited impact on memorization within the tested range.

= Introduction

In 2017, a group of researchers at Google Brain proudly announced the architecture of the transformer neural model, which revolutionized the field of Natural Language Processing (NLP) and led to the rise of large language models (LLMs) #cite(<vaswani>). Training LLMs requires large amounts of data, and if not curated carefully, these datasets might contain sensitive information such as social security numbers or medical records. This poses a severe problem in model security and ethics, as shown by #cite(<carlini>, form: "prose") that neural networks have a high risk of unintentionally memorizing fine-grained information and oddly-specific details. To mitigate this issue and protect the privacy of individuals, one approach is to leverage methods from _differential privacy_ (DP), which provides a rigorous mathematical framework for quantifying privacy #cite(<dwork>). With DP, researchers have developed DP-based training methods, such as DP-SGD, to train neural networks and have shown that they effectively mitigate privacy concerns during training. Background information about DP and DP-SGD utilized in this paper is described in @sec:background.

Despite the prominent performance of DP-based training methods, the use of these methods in training or fine-tuning LLMs still remains underexplored in both research and industrial settings. Specifically, the benefits of DP in reducing unintentional memorization of training data are to be precisely quantified. Therefore, this study aims to narrow down this gap by investigating the following research question:

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

Since the introduction of the concept of DP, most previous work focused on using DP techniques on training or fine-tuning neural networks of simpler architectures compared to transformers. For example, on language modeling, #cite(<mcmahan>, form: "prose") applied a DP algorithm called _federated averaging_ (FedAvg) on training recurrent language models such as RNNs and LSTMs. In the study, they experimented with various hyperparameters for noise and gradient clipping to quantify the downside of DP training on the performance of language models. On the other hand, the study by #cite(<carlini>, form: "prose") conducted experiments on investigating language modeling ability of LSTM models on the Penn Treebank dataset. A similar characteristic shared across these two papers is that the models they used in their experiments are rather small: 600,000 parameters for the model in #cite(<carlini>, form: "prose") and 1.35M parameters for the model in #cite(<mcmahan>, form: "prose"). Since LLMs have grown exponentially in size nowadays, there is an urgent need for more research on deploying DP techniques on training larger models.

Studies on applying DP techniques on fine-tuning LLMs do exist, with #cite(<yu>, form: "prose") being a foundational one. In this paper, the authors conducted two experiments, one on natural language understanding (NLU) and the other on natural language generation (NLG), both using DP-SGD, and they compared the model performance against the state-of-the-art on different benchmarks. The models they used come from the GPT-2 and RoBERTa suites, with GPT-2 Small being the smallest model but still having 117M parameters which is much larger than the models in previous studies. More recently, a paper by #cite(<du>, form: "prose") also examined the effect of DP-SGD in fine-tuning GPT-2 models. However, they focused more on comparing different fine-tuning methods, including FFT, LoRA, prefix-tuning, and P-tuning, rather than directly investigating DP-SGD on GPT-2.

Despite these studies on DP fine-tuning LLMs, the datasets they used to evaluate their models are not inherently private: #cite(<yu>, form: "prose") used data from the restaurant domain and DART which is open-domain, while #cite(<du>, form: "prose") used Wikitext-2-v1 and AG News. The downside is that all these datasets are public sources and do not contain sensitive information. In order to understand how DP techniques perform on private datasets, which was the reason DP was developed in the first place, it is preferred to apply them to a more private, sensitive domain so that we can truly evaluate the effectiveness of DP before its actual deployment in real-world settings. This is thus the main motivation of this project: applying DP techniques to a mental health dataset, which is inherently privacy-sensitive.

= Methodology

== Model

In this project, we used the GPT-2 Small model developed by OpenAI #cite(<radford>). GPT-2 Small is a decoder transformer model that transforms an input directly to the output, unlike BERT which outputs embeddings of the input sequence. As such, GPT-2 is known for its ability in language generation, which matches the objective of this study. The GPT-2 Small model consists of an embedding layer with positional encoding, 12 transformer blocks, and an output layer, adding up to 117M parameters and thus is a great balance of performance and computational cost.

== Data

The data used in this project is a #link("https://huggingface.co/datasets/solomonk/reddit_mental_health_posts", "Reddit Mental Health Dataset") available for downloads on Hugging Face. There are 151,228 rows in total in the dataset, each row being a post related to mental health containing attributes such as the user, the text of the post, the time posted, and more. Only the text of the posts is of interest in this project. Other attributes are discarded. From the raw dataset, we randomly sampled 10,000 posts to form the fine-tuning set, and 1,000 more as the validation set.

== Experimental Design

In the study by #cite(<carlini>, form: "prose"), the authors proposed the method of _canary insertion_. In this context, a _canary_ refers to a piece of text purposefully inserted into the training data in order to measure the extent to which the model memorizes the training data instead of learning the underlying patterns. In their study, they used canaries of the form
#quote(block: true)[
  _The random number is ..._
]
and fill in the blank with 9-digit numbers. By varying the number of times the canaries were inserted and the privacy budget $epsilon$ in DP-SGD, the authors were able to quantify how much DP helps with reducing unintentional memorization of the training data.

In the current project, we adopted the same design and applied it to our mental health dataset with the following form of canaries:
#quote(block: true)[
  _My patient ID is ..._
]
and fill in the blank with a random 6-digit number representing a patient ID. The reason for choosing this canary form is that it is directly related to mental health, which is the theme of the dataset, and is inherently private information that a patient would not wish to reveal which is the main motivation of the project.

With this canary form, we varied the number of times the canaries were inserted into the training set, with $"freq" = 1, 5, 10, 50$. We also pre-specified some values of privacy budget to conduct the experiment, with $epsilon = 0.5, 1, 2, 4, 8, infinity$, where $epsilon = infinity$ means vanilla gradient descent. For each pair of frequency and privacy budget $epsilon$, we fine-tuned GPT-2 Small using the training set with canaries inserted for 3 epochs. The Python library `Opacus` was used for DP-SGD support. Each model was then assessed by calculating the _log-perplexity_ on the validation set as a proxy for model utility, mathematically expressed as
$
  "log-perp"_theta (x_1, dots.h.c, x_n) = -1/n sum_(i=1)^n log_2 bb(P)(x_i|f_theta (x_1, dots.h.c, x_(i-1))).
$
To see more fine-grained differences between different privacy budget $epsilon$, we report the validation _perplexity_ instead, expressed as
$
  "perp"_theta (x_1, dots.h.c, x_n) = exp("log-perp"_theta (x_1, dots.h.c, x_n)).
$
To measure unintentional memorization of the training data, we also computed the _exposure_ of each model as
$
  "exposure" = log_2(900000) - log_2("rank"),
$
where $"rank"$ measures the rank of the probability that the random number in the canaries appears among all 900,000 possible 6-digit numbers. A small exposure means that the model does not memorize the canaries and the output distribution is generated entirely by chance, while $"rank" = 1$ and $"exposure" = log_2(900000) approx 19.78$ indicates that the model memorizes the canaries perfectly #cite(<carlini>).

It is worth noting that not all parameters in the GPT-2 Small model were fine-tuned. In the project, we froze the embedding & positional encoding layer as well as the transformer head, and only fine-tuned the 12 transformer blocks. This was necessary due to GPU memory constraints, consistent with the approach of #cite(<yu>, form: "prose").

= Results & Discussion

== Main Results

#figure(
  image("figures/perplexity_vs_epsilon.png"),
  caption: [Validation perplexity vs privacy budget $epsilon$],
  placement: auto,
) <fig:utility>

@fig:utility shows the line plot of validation perplexity vs privacy budget $epsilon = 0.5, 1, 2, 4, 8, infinity$ used in this project. From the plot, we see that for all privacy budgets $epsilon$, the effect from the frequency of canaries inserted into the training set is negligible, as the validation perplexities are mostly indistinguishable across frequencies. This is expected because the frequencies of canaries do not affect much how the model understands language during fine-tuning. Furthermore, we notice that the higher the privacy budget $epsilon$, the smaller the validation perplexity, which is also expected as a higher privacy budget $epsilon$ means less privacy and thus the model can learn more patterns from the training data. These results are further compared against those from #cite(<yu>, form: "prose") in @tab:perplexity.

#figure(
  table(
    columns: (auto, auto, auto),
    align: (left, right, right),
    [*Model*], [*Validation Perplexity*], [*% Increase from Baseline*],
    table.cell(colspan: 3, align: center, [*#cite(<yu>, form: "prose"), $epsilon = 6$*]),
    [GPT-2 Small], [Not reported], [-],
    [GPT-2 Small + DP], [4.51], [N/A],
    [GPT-2 Medium], [3.19], [-],
    [GPT-2 Medium + DP], [4.02], [26.0%],
    [GPT-2 Large], [3.06], [-],
    [GPT-2 Large + DP], [3.87], [26.5%],
    [GPT-2 XL], [3.01], [-],
    [GPT-2 XL + DP], [3.79], [25.9%],
    table.cell(colspan: 3, align: center, [*This Project*]),
    [Baseline (no canaries, $epsilon = infinity$)], [23.76], [-],
    [Baseline (with canaries, $epsilon = infinity$)], [24.80], [-],
    [$epsilon = 0.5$], [34.13], [43.7%],
    [$epsilon = 1.0$], [33.87], [42.6%],
    [$epsilon = 2.0$], [33.63], [41.5%],
    [$epsilon = 4.0$], [33.34], [40.3%],
    [$epsilon = 8.0$], [33.02], [39.0%],
  ),
  caption: [Validation perplexity of GPT-2 models with and without DP fine-tuning. For #cite(<yu>, form: "prose"), % increase is relative to the same model size without DP. For this project, % increase is relative to the no-canary baseline (23.76).],
  placement: auto,
) <tab:perplexity>

In @tab:perplexity, note that the validation perplexities across the two studies are not comparable, as this metric is highly dependent on the validation data. However, as a general trend, we see that DP models perform worse than non-DP models in both studies, corroborating the plot shown in @fig:utility. One discrepancy between the studies is that #cite(<yu>, form: "prose") obtained lower percent increase from baselines, averaging to 26.1% while ours are 40.3% and 39.0% for comparable privacy budgets $epsilon = 4, 8$ in this study. This difference can be explained by various factors, the most prominent being that their training dataset consists of 42K samples, which is larger than ours and so the models might have learned to generalize better even with DP.

#figure(
  image("figures/exposure_vs_epsilon_with_baserate.png"),
  caption: [Canary exposure vs privacy budget $epsilon$ with vanilla (not fine-tuned) & domain (fine-tuned without canaries) base rates.],
  placement: auto,
) <fig:exposure>

@fig:exposure shows the line plot of canary exposure vs privacy budget $epsilon$. It is clear that unintentional memorization of the canaries occurs at $epsilon = infinity$, or no DP, even when the canary is inserted only once. The more times the canaries are inserted, the higher the canary exposure, with a maximum possible canary exposure of 19.78 achieved at $"freq" = 10$ and $"freq" = 50$. This result highlights a significant privacy risk, as if sensitive personal information is leaked into the training dataset, then the model is shown to more or less memorize that information if trained without privacy, which poses a significant threat to individual privacy. On the other hand, we notice that DP significantly reduces privacy concerns. With $epsilon = 8$, the model does not appear to memorize the canaries even when the canaries are inserted 50 times, as shown that the canary exposure does not increase as the privacy budget $epsilon$ increases from $0.5$ to $8$ for all frequencies. Altogether, we conclude that to reduce unintentional memorization, the privacy budget $epsilon$ can be large, but it must exist.

== Ablation Study

One noteworthy characteristic shown in @fig:exposure is that at $"freq" = 10$ the canary exposure seems to start high compared to other frequencies. Therefore, we conducted an ablation study to see whether this is entirely by chance or a model artifact. Since we generated 4 canary numbers, one for each frequency, for each canary we also used the vanilla, not fine-tuned GPT-2 Small model and the domain fine-tuned GPT-2 without canaries and measured the canary exposure on these models. The results are shown in the left portion of @fig:exposure. Interestingly, the canary number 116632 for $"freq" = 10$ also has high canary exposure on the vanilla and domain GPT-2 Small models, even though these models have not seen this number in our experimental setup. Therefore, this phenomenon must be a model artifact from the original training of the GPT-2 Small model and thus does not affect our conclusion that DP effectively reduces unintentional memorization of the training data.

= Conclusion

== Summary

To summarize, this paper aimed to evaluate the effectiveness of using differential privacy techniques to train LLMs in reducing unintentional memorization of the training data. We employed the method of canary insertion proposed by #cite(<carlini>, form: "prose"), experimented with different combinations of canary insertion frequencies and privacy budgets $epsilon$, and evaluated the fine-tuned GPT-2 Small model using perplexity for model utility and canary exposure for privacy. Our results showed that the higher the privacy budget $epsilon$, the lower the validation perplexity, which is expected because the model can generalize better with less privacy. For canary exposure, we saw that the specific value of $epsilon$ did not significantly affect the extent to which the canaries are memorized, nor did frequency if DP is used. We thus came to the conclusion that DP effectively reduces unintentional memorization in a medical context, which directly answers our research question.

== Limitations & Future Directions

There are several limitations associated with this study. First of all, we only experimented with the GPT-2 Small model due to limited computational resources, but this model is a relatively small and old LLM. More recent LLMs such as GPT-4 are much larger in size and have more parameters. Therefore, if resources permit, future researchers should study these larger LLMs in order to fully understand the benefits of DP in training LLMs. The dataset used in this project is also relatively small. DP training is computationally expensive, but future studies should attempt to include a larger dataset for both training and validation if possible so that we would be more confident in measuring model performance and generalizability.

= Acknowledgements

I am extremely grateful to Professor Sasho Nikolov for giving valuable feedback and conceptual guidance in differential privacy throughout the process of this research.

// For bibliography, uncomment and create bib.bib file:
#pagebreak()
#bibliography("bib.bib", full: true)
