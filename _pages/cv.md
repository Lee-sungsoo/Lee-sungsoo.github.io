---
layout: about
title: CV
permalink: /cv/
nav: true
nav_order: 4
---

{% comment %}
  The CV is a plain PDF drop-in: put the file at assets/pdf/cv.pdf and the page
  switches by itself from the placeholder line to the download button and the
  embedded viewer. site.static_files is what makes the check possible, since
  Liquid cannot stat a path.
{% endcomment %}
{% assign cv_file = site.static_files | where: 'path', '/assets/pdf/cv.pdf' | first %}
{% assign cv_url = '/assets/pdf/cv.pdf' | relative_url %}

<section id="cv">
  <h2>CV{% if cv_file %} <a class="cv-download btn btn-sm btn-outline-primary" href="{{ cv_url }}" download>Download PDF</a>{% endif %}</h2>
  {% if cv_file %}
    <object class="cv-embed" data="{{ cv_url }}" type="application/pdf">
      <p>Your browser cannot display the PDF here. <a href="{{ cv_url }}">Download it instead</a>.</p>
    </object>
  {% else %}
    <p>My full CV is not posted yet. Feel free to email me for a copy.</p>
  {% endif %}
</section>
