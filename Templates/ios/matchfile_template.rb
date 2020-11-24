{% if git_url %}
git_url("{{ git_url }}")

{% else %}
# Sample: "git@github.com:backbase/match.git"
git_url(YOUR_MATCH_GIT_URL)

{% endif %}

storage_mode("git")

{% if export_method %}
# appstore, development, adhoc, enterprise
type("{{ export_method }}")

{% endif %}

{% if bundle_id %}
app_identifier("{{ bundle_id }}")

{% endif %}
