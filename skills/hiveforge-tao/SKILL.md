---
name: hiveforge-tao
description: Log AI traces and search interaction history via the Tao Data observability platform
---

# HiveForge Tao Data

Access Tao Data observability platform through the HiveForge MCP gateway.
Use this to log AI traces and search interaction history.

## Configuration

Requires environment variables:
- `HIVEFORGE_API_URL` — HiveForge MCP base URL
- `HIVEFORGE_SERVICE_KEY` — Service key for authentication

Note: Tao Data must be configured on the HiveForge side (OPENCLAW_TAODATA_API_KEY).

## Available Actions

### Log Trace

Log an AI interaction trace for observability.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/traces" \
  -d '{
    "input": "User message",
    "output": "AI response",
    "model": "claude-haiku-4-5",
    "tags": ["openclaw", "telegram"],
    "metadata": {"channel": "telegram", "user": "cam"}
  }' | jq
```

### Search Traces

Search past interaction traces.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/traces?query=task+creation&limit=10" | jq
```

Optional parameters:
- `query` — Search text
- `tags` — Comma-separated tag filter
- `limit` — Max results

## Guidelines

- Use this for debugging and observability, not for user-facing features
- Trace logging should be fire-and-forget — never block on it
- Include the messaging channel (telegram, slack, whatsapp) in trace tags
