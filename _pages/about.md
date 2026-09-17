---
layout: about
title: about
permalink: /
description: Sungsoo Lee, Ph.D. student in Data Science at Seoul National University of Science and Technology (SeoulTech).

profile:
  image: prof_pic.jpg
  role: Ph.D. Student
  affiliation:
    - Department of Data Science
    - Seoul National University of Science and Technology
  interests:
    - Technology Intelligence
    - R&D Intelligence
    - Recommender Systems
    - LLM Agents
---

<section id="about">
  <h2>About Me</h2>
  <p>
    I am a Ph.D. student in the Department of Data Science at Seoul National University of Science and Technology (SeoulTech), advised by Prof. Hakyeon Lee. My research is on technology and R&D intelligence: turning patents, papers, and proposals into evidence that helps organizations decide what to develop next. I build LLM agent systems that read and evaluate technical documents, and recommender systems that surface opportunities people would not have searched for. Before the Ph.D., I completed an M.S. in Data Science at SeoulTech, where I studied embedding inversion for discovering technology vacancies.
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
  <h2>Honors &amp; Awards</h2>
  {% include honors_list.liquid %}
</section>
{% endif %}

<section id="publications">
  <h2>Publications <span class="home-count">{% bibliography_count %}</span></h2>
  <div class="publications">
    {% bibliography %}
  </div>
</section>

{% if site.data.patents and site.data.patents != empty %}
<section id="patents">
  <h2>Patents <span class="home-count">{{ site.data.patents | size }}</span></h2>
  {% include patent_list.liquid %}
</section>
{% endif %}

<section id="projects">
  <h2>Projects <span class="home-count">{{ site.projects | size }}</span></h2>
  {% include project_list.liquid %}
</section>
