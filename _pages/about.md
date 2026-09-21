---
layout: about
title: Home
permalink: /
nav: true
nav_order: 1
description: Sungsoo Lee, Ph.D. student in Data Science at Seoul National University of Science and Technology (SeoulTech), working on AI support for R&D decisions and recommender systems.
---

<section id="about">
  <h2>About Me</h2>
  <p>
    I am a Ph.D. student in the Department of Data Science at Seoul National University of Science and Technology (SeoulTech), advised by Prof. Hakyeon Lee.
  </p>
  <p>
    I work on ways to support the decisions that run through the whole R&D process — which technologies to watch, which proposals to fund, what to build next — with the latest AI. I am also interested in recommender systems, and more broadly in problems where data and AI help people choose better.
  </p>
  <p>
    If any of this overlaps with what you are working on, I would be glad to hear from you. Feel free to email me anytime.
  </p>
</section>

{% if site.data.education and site.data.education != empty %}
<section id="education">
  <h2>Education</h2>
  {% include education_list.liquid %}
</section>
{% endif %}

{% if site.data.honors and site.data.honors != empty %}
<section id="honors">
  <h2>Honors</h2>
  {% include honors_list.liquid %}
</section>
{% endif %}
