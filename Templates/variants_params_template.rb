# Generated by Variants

VARIANTS_PARAMS = {
{% for param in parameters %}
    {{ param.name }}: "{{ param.value }}",
{% endfor %}
{% for env_var in env_vars %}
    {{ env_var.name }}: {{ env_var.value }},
{% endfor %}
}.freeze
