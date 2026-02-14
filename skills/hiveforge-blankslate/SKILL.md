# HiveForge BlankSlate

Monitor the BlankSlate feature request pipeline through the HiveForge MCP gateway.
BlankSlate is the public feature request board where users submit ideas.

## Configuration

Requires environment variables:
- `HIVEFORGE_API_URL` — HiveForge MCP base URL
- `HIVEFORGE_SERVICE_KEY` — Service key for authentication

## Available Actions

### Get Pipeline Stats

Get overall pipeline statistics — total requests, build counts, stage breakdown.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/stats" | jq
```

### List Requests

Get feature requests, optionally filtered by status.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/requests?status=submitted&limit=10" | jq
```

Optional parameters:
- `status` — Filter: `submitted`, `evaluated`, `triaged`, `enriched`, `approved`, `building`, `review`, `shipped`, `rejected`
- `limit` — Max results

## Guidelines

- Use this for daily brief summaries and pipeline monitoring
- For daily briefs, report: new submissions (last 24h), in-progress builds, recently shipped
- Pipeline stages flow: submitted → evaluated → triaged → enriched → approved → building → review → shipped
- Keep summaries concise — "3 new submissions, 1 building, 2 shipped yesterday"
- This is read-only — you cannot modify requests through this skill
