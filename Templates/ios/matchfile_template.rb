{% if git_url %}
git_url("{{ git_url }}")

{% else %}

git_url(YOUR_MATCH_GIT_URL)

{% endif %}

storage_mode("git")

{% if export_method %}

type("{{ export_method }}")

{% endif %}

{% if app_identifiers %}

{% if app_identifiers.count == 1 %}

app_identifier("{{ app_identifiers[0] }}")

{% else %}

app_identifier([
{% for identifier in app_identifiers %}
    "{{ identifier }}"{% if not forloop.last %},{% endif %}
{% endfor %}])

{% endif %}

{% endif %}
