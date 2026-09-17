---
layout: about
title: about
permalink: /
subtitle: Ph.D. student in Data Science, SeoulTech

profile:
  align: left
  image: prof_pic.jpg
  image_circular: false # crops the image to make it circular
  more_info: >
    <p>Department of Data Science</p>
    <p>Seoul National University of Science and Technology</p>

social: true # includes social icons under the profile photo

announcements:
  enabled: false # includes a list of news items

latest_posts:
  enabled: false
---

I am a Ph.D. student in the Department of Data Science at Seoul National University of Science and Technology (SeoulTech), advised by Prof. Hakyeon Lee.

My research is on agentic AI for R&D proposal evaluation and project selection, where multi-agent language model systems are used to make expert judgement reproducible and auditable. I also work on technology opportunity discovery through text-embedding inversion of patent vacancies, which turns empty regions of a patent embedding space back into readable descriptions of unexplored technologies. A third thread is LLM-based recommender agents.

Feel free to reach out if any of this overlaps with what you are working on.

## Publications {#publications}

<div class="publications">
{% bibliography %}
</div>

## Projects {#projects}

{% include project_list.liquid %}

{% if site.data.cv.cv.sections and site.data.cv.cv.sections != empty %}

## CV {#cv}

{% include cv_sections.liquid %}
{% endif %}
