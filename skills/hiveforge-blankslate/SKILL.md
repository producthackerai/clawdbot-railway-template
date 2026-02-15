# HiveForge BlankSlate

Monitor and manage the BlankSlate feature request pipeline through the HiveForge MCP gateway.
BlankSlate is the public feature request board where users submit ideas that flow through
the multi-tier build pipeline: submit → evaluate → triage → enrich → approve → build → review → ship.

## Configuration

Requires environment variables:
- `HIVEFORGE_API_URL` — HiveForge MCP base URL
- `HIVEFORGE_SERVICE_KEY` — Service key for authentication

## Public Endpoints (Read-Only)

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

### Get Request Detail

Get full details for a specific request including evaluation scores and triage results.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/requests/REQUEST_ID" | jq
```

### Get Request Pipeline

Get the full pipeline history for a request — every stage transition, build event, and evaluation.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/requests/REQUEST_ID/pipeline" | jq
```

### Get Changelog

Get recently shipped features.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/changelog?limit=10" | jq
```

### Get Metrics

Get platform-wide metrics and trends.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/metrics" | jq
```

## Admin Endpoints

These require the HiveForge service key and perform administrative actions.

### Pipeline Stats (Admin)

Detailed pipeline stage counts and triage breakdown.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/admin/pipeline-stats" | jq
```

### Rankings

Get the latest feature request rankings (from daily ranking cron).

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/admin/rankings" | jq
```

### Human Approve

Approve a feature request that was flagged for review. Always confirm with the user first.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/admin/requests/REQUEST_ID/approve" \
  -d '{"reason": "Approved via ProductHackerAI"}' | jq
```

### Human Reject

Reject a feature request. Always confirm with the user first.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/admin/requests/REQUEST_ID/reject" \
  -d '{"reason": "Not aligned with roadmap"}' | jq
```

### Trigger Triage

Re-run triage classification on a specific request.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/admin/requests/REQUEST_ID/triage" | jq
```

### Confirm Build Type

Confirm the build type for a standalone request (required gate before HiveForge dispatch).

```bash
curl -s -X PATCH -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/blankslate/admin/requests/REQUEST_ID/confirm" | jq
```

## Guidelines

- Use public endpoints for daily brief summaries and pipeline monitoring
- For daily briefs, report: new submissions (last 24h), in-progress builds, recently shipped
- Pipeline stages flow: submitted → evaluated → triaged → enriched → approved → building → review → shipped
- Keep summaries concise — "3 new submissions, 1 building, 2 shipped yesterday"
- Admin actions (approve, reject, triage) require explicit user confirmation
- When showing request details, highlight: title, status, triage complexity, evaluation score
