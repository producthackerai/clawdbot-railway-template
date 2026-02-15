---
name: hiveforge-github
description: Interact with GitHub repos — list PRs, issues, check CI status, view commits, and manage the Product Hacker codebase
---

# GitHub Integration

Manage Product Hacker GitHub repositories through the `gh` CLI.
The `GITHUB_TOKEN` env var provides authentication automatically.

## Key Repositories

- `camfortin/task-crush` — Main TaskCrush app + BlankSlate board
- `producthackerai/clawdbot-railway-template` — OpenClaw deployment config (that's me)
- `jrobnc/hiveforge-mcp` — HiveForge MCP gateway

## Available Actions

### List Pull Requests

```bash
gh pr list --repo camfortin/task-crush --state open --limit 10
```

### View PR Details

```bash
gh pr view PR_NUMBER --repo camfortin/task-crush
```

### List Issues

```bash
gh issue list --repo camfortin/task-crush --state open --limit 10
```

### Create Issue

Always confirm with the user before creating. Include a clear title and description.

```bash
gh issue create --repo camfortin/task-crush \
  --title "Issue title" \
  --body "Description of the issue"
```

### Check CI Status

```bash
gh run list --repo camfortin/task-crush --limit 5
```

### View Recent Commits

```bash
gh api repos/camfortin/task-crush/commits --jq '.[0:5] | .[] | {sha: .sha[0:7], message: .commit.message, author: .commit.author.name, date: .commit.author.date}'
```

### View Workflow Runs

```bash
gh run list --repo camfortin/task-crush --workflow "Process Feedback" --limit 5
```

### Check PR Review Status

```bash
gh pr checks PR_NUMBER --repo camfortin/task-crush
```

## Guidelines

- Default repo is `camfortin/task-crush` unless the user specifies otherwise
- Always confirm before creating issues or PRs
- When listing PRs, show: number, title, author, status
- When listing issues, show: number, title, labels, assignees
- Keep summaries concise for chat
- For CI failures, show the failing step and error summary
