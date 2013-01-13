{% unless site.post_types.portfolio == empty %}
<div class="row">
  <div class="span4">
    <h2 class="section-title">Selected Work</h2>
    <a href="/portfolio/" class="btn-more">more &raquo;</a>
    <ul>
    {% for page in site.post_types.portfolio limit: 4 %}
      <li class="{% cycle 'odd', 'even' %}">
        <a href="#">
          <img src="/images/portfolio/{{ page.slug }}/small.jpg" alt="{{ page.title }}" title="{{ page.title }}"/>
          <span>{{ page.title }}</span>
        </a>
      </li>
    {% endfor %}
    </ul>
  </div>
</div>
{% endunless %}