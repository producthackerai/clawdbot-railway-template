# HiveForge Tasks

Manage TaskCrush tasks through the HiveForge MCP gateway.

## Configuration

Requires environment variables:
- `HIVEFORGE_API_URL` — HiveForge MCP base URL (e.g., `http://hiveforge-mcp.railway.internal:3000`)
- `HIVEFORGE_SERVICE_KEY` — Service key for authentication

## Available Actions

### List Tasks

Get tasks from a workspace. Defaults to personal workspace.

```bash
curl -s -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/tasks?workspace=personal" | jq
```

Optional query parameters:
- `workspace` — `personal`, `work`, or `app` (default: personal)
- `status` — `backlog`, `todo`, `in_progress`, or `done`
- `goal_id` — Filter by goal ID
- `limit` — Max results (default: 50)

### Create Task

Create a new task. Always confirm with the user before creating.

```bash
curl -s -X POST -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/tasks" \
  -d '{
    "title": "Task title here",
    "description": "Optional description",
    "workspace": "personal",
    "priority": "medium",
    "status": "todo"
  }' | jq
```

Fields:
- `title` (required) — Task title
- `description` — Optional description
- `workspace` — `personal` or `work` (default: personal)
- `priority` — `low`, `medium`, `high`, or `urgent` (default: medium)
- `status` — `backlog`, `todo`, `in_progress`, or `done` (default: todo)
- `goalId` — Optional goal to link to
- `acceptanceCriteria` — Optional array of strings

### Update Task

Update an existing task by ID.

```bash
curl -s -X PUT -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  -H "Content-Type: application/json" \
  "$HIVEFORGE_API_URL/api/v1/openclaw/tasks/TASK_ID" \
  -d '{
    "status": "done"
  }' | jq
```

Any field from Create Task can be updated.

## Guidelines

- Default to the `personal` workspace unless the user specifies otherwise
- Never use the `app` workspace — that is for super_admin internal use only
- Always confirm before creating or modifying tasks
- When listing tasks, show the top 5 by priority unless asked for more
- Include task ID, title, status, and priority in summaries
