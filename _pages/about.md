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
    - Technology intelligence
    - Patent analytics
    - Embedding inversion
    - LLM agents
    - Recommender systems
---

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

{% if site.data.cv.cv.sections and site.data.cv.cv.sections != empty %}
<section id="cv">
  <h2>CV</h2>
  {% include cv_sections.liquid %}
</section>
{% endif %}
