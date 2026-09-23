---
layout: about
title: Research
permalink: /research/
nav: true
nav_order: 2
---

<section id="publications">
  <h2>Publications <span class="home-count">{% bibliography_count %}</span></h2>
  <div class="publications">
    {% bibliography %}
  </div>
</section>

<section id="presentations">
  <h2>Presentations <span class="home-count">{{ site.data.presentations | size }}</span></h2>
  {% include presentation_list.liquid %}
</section>

{% if site.data.patents and site.data.patents != empty %}
<section id="patents">
  <h2>Patents <span class="home-count">{{ site.data.patents | size }}</span></h2>
  {% include patent_list.liquid %}
</section>
{% endif %}
