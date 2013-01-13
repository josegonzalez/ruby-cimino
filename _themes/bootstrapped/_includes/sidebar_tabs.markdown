<div class="row">
  <div class="span4">
    <div class="tabbable" style="margin-bottom: 18px;">
      <ul class="nav nav-tabs">
        <li class="active"><a href="#tab-recent" data-toggle="tab">Recent</a></li>
        <li><a href="#tab-categories" data-toggle="tab">Categories</a></li>
      </ul>
      <div class="tab-content" style="padding-bottom: 9px; border-bottom: 1px solid #ddd;">
        <div class="tab-pane active" id="tab-recent">
          <ul>
            {% for post in site.posts limit: 5 %}
              <li><a href="{{ post.url }}" title="{{ post.title }}">{{ post.title }}</a></li>
            {% endfor %}
          </ul>
        </div>
        <div class="tab-pane" id="tab-categories">
          <ul>
            {% for topic in site.iterable.categories %}
              <li><a href="/categories/{{ topic.name | replace:' ', '-' | downcase }}">{{ topic.name }}</a></li>
            {% endfor %}
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>