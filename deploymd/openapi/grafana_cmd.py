from grafana_client import GrafanaApi

# Connect to Grafana API endpoint using the `GrafanaApi` class
grafana = GrafanaApi.from_url(
    "http://admin:test123@192.168.0.101:32095/grafana/")

# Search dashboards based on tag
grafana.search.search_dashboards(tag="applications")

# Find a user by email
user = grafana.users.find_user("test@example.org")

# Add user to team 2
grafana.teams.add_team_member(2, user["id"])

# Create or update a dashboard
grafana.dashboard.update_dashboard(
    dashboard={"dashboard": {...}, "folderId": 0, "overwrite": True})

# Delete a dashboard by UID
grafana.dashboard.delete_dashboard(dashboard_uid="foobar")

# Create organization
grafana.organization.create_organization(
    organization={"name": "new_organization"})
