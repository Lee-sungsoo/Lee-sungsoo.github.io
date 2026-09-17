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
---

<section id="publications">
  <h2>Publications</h2>
  <div class="publications">
    {% bibliography %}
  </div>
</section>

<section id="projects">
  <h2>Projects</h2>
  {% include project_list.liquid %}
</section>

{% if site.data.cv.cv.sections and site.data.cv.cv.sections != empty %}
<section id="cv">
  <h2>CV</h2>
  {% include cv_sections.liquid %}
</section>
{% endif %}
