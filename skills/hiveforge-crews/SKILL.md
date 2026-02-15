---
name: hiveforge-crews
description: Execute HornetHive AI crews for research, content, strategy, and analysis — plus RAG knowledge search
---

# HiveForge Crews

Execute HornetHive AI crews through the HiveForge MCP gateway.
Crews are specialized AI teams that perform complex tasks.

## Configuration

Requires environment variables:
- `HIVEFORGE_API_URL` — HiveForge MCP base URL
- `HIVEFORGE_SERVICE_KEY` — Service key for authentication

Note: HornetHive must be configured on the HiveForge side (OPENCLAW_HORNETHIVE_API_KEY).

## Available Actions

### Execute Crew

Run a specialized AI crew.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/crews/researcher_crew/execute" \
  -d '{
    "inputs": {
      "topic": "AI productivity tools market analysis",
      "depth": "detailed"
    }
  }' | jq
```

Available crew types:
- `researcher_crew` — Research and analysis
- `writer_crew` — Content creation
- `analyst_crew` — Data analysis
- `strategist_crew` — Strategy planning
- `developer_crew` — Technical tasks
- `marketing_crew` — Marketing content
- `product_crew` — Product planning
- `design_crew` — Design specifications

### RAG Search

Search the HornetHive knowledge base.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/rag/query" \
  -d '{
    "query": "What is our product roadmap?",
    "options": {"topK": 5}
  }' | jq
```

## Guidelines

- Crew execution can take 30-120 seconds — warn the user about wait time
- Use researcher_crew for general questions that need deep analysis
- Use writer_crew for content generation (blog posts, reports, docs)
- RAG search is fast and good for finding existing knowledge
- Always summarize crew results concisely for chat
