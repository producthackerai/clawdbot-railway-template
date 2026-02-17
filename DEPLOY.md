# OpenClaw Railway Deployment Guide

## Prerequisites

1. Railway account with existing project (where HiveForge MCP runs)
2. GitHub account for the forked template repo
3. Telegram bot token (from @BotFather)
4. Anthropic API key

## Architecture

```
User (Telegram / Slack)
        │
        ▼
┌──────────────────────────────────┐
│  OpenClaw Gateway (Railway)      │
│  Port: Railway-injected          │
│  Volume: /data                   │
│  ├─ LLMs: Claude (Anthropic)    │
│  ├─ Custom skills (curl → HTTP)  │
│  └─ AGENTS.md personality        │
└───────────┬──────────────────────┘
            │ Railway private network
            ▼
┌──────────────────────────────────┐
│  HiveForge MCP REST API         │
│  hiveforge-mcp.railway.internal  │
│  ├─ TaskCrush (direct Supabase) │
│  ├─ Tao Data (HTTP proxy)       │
│  └─ BlankSlate (HTTP proxy)     │
└──────────────────────────────────┘
```

## Environment Variables

### OpenClaw Service

**Required:**

| Variable | Value | Notes |
|----------|-------|-------|
| `SETUP_PASSWORD` | Generate a strong password | Protects /setup wizard |
| `ANTHROPIC_API_KEY` | Your Anthropic key | Primary LLM |
| `HIVEFORGE_API_URL` | `http://hiveforge-mcp.railway.internal:8080` | Internal network |
| `HIVEFORGE_SERVICE_KEY` | Same key configured in HiveForge MCP | Inter-service auth |
| `OPENCLAW_STATE_DIR` | `/data/.openclaw` | Persistent state |
| `OPENCLAW_WORKSPACE_DIR` | `/data/workspace` | Skills + personality |
| `OPENCLAW_PUBLIC_PORT` | `8080` | Advertised in UI only |

**CRITICAL: Do NOT set `PORT` manually.** Railway injects `PORT` at runtime. Hardcoding it causes 502 errors.

**Messaging Channels:**

| Variable | Value | When |
|----------|-------|------|
| `TELEGRAM_BOT_TOKEN` | From @BotFather | Phase 1 |
| `SLACK_APP_TOKEN` | `xapp-...` from Slack | Future |
| `SLACK_BOT_TOKEN` | `xoxb-...` from Slack | Future |

### HiveForge MCP Service

| Variable | Value |
|----------|-------|
| `HIVEFORGE_SERVICE_KEY` | Same key as above |
| `TASKCRUSH_SUPABASE_URL` | `https://tdjyqykkngyflqkjuzai.supabase.co` |
| `TASKCRUSH_SUPABASE_SERVICE_KEY` | Supabase service role JWT |
| `OPENCLAW_TASKCRUSH_USER_ID` | UUID of the TaskCrush user to operate as |
| `OPENCLAW_DEFAULT_WORKSPACE` | `personal` |
| `OPENCLAW_TAODATA_API_KEY` | Tao Data API key (ingest scope) |
| `BLANKSLATE_BASE_URL` | `https://blankslate-production.up.railway.app` |

## Set Up Telegram

1. Message `@BotFather` on Telegram
2. Send `/newbot`
3. Name: `TaskCrush Assistant`
4. Username: Something like `taskcrush_bot`
5. Copy the bot token → set as `TELEGRAM_BOT_TOKEN`
6. Get your Telegram user ID via `@userinfobot`
7. Redeploy the OpenClaw service

The bot uses long-polling by default — no webhook URL needed.

## Actual Deployment Info

| Item | Value |
|------|-------|
| Railway project | `producthacker` |
| Service name | `openclaw` |
| Public URL | `https://openclaw-production-a365.up.railway.app` |
| Setup wizard | `https://openclaw-production-a365.up.railway.app/setup` |
| GitHub repo | `producthackerai/clawdbot-railway-template` |

## Verification

```bash
# 1. Service is running
curl https://openclaw-production-a365.up.railway.app/healthz

# 2. HiveForge reachable (from within Railway)
curl -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  $HIVEFORGE_API_URL/api/v1/openclaw/status

# 3. Task listing works
curl -H "Authorization: Bearer $HIVEFORGE_SERVICE_KEY" \
  $HIVEFORGE_API_URL/api/v1/openclaw/tasks?workspace=personal
```

Then test messaging:
- Send "hi" to the Telegram bot
- Ask "list my tasks" to verify HiveForge integration
- Ask "create a task called Test OpenClaw" to verify write access

## MCP Connection Status

| Service | Status | Auth Method |
|---------|--------|-------------|
| TaskCrush | Connected | Direct Supabase (service role) |
| Tao Data | Connected | API key (ingest scope) |
| BlankSlate | Connected | HTTP proxy (read-only) |
| HornetHive | Not connected | Needs API key + deployed service |

## Troubleshooting

**Bot doesn't respond:**
- Check Railway logs for the openclaw service
- Verify `TELEGRAM_BOT_TOKEN` is correct
- Check if the bot is running: `curl https://<domain>/healthz`

**502 errors:**
- Check if `PORT` is manually set — delete it, let Railway inject it
- Check Railway logs for startup errors

**"HiveForge not reachable" in logs:**
- Ensure both services are in the same Railway project
- Check `HIVEFORGE_API_URL` uses `.railway.internal` domain
- Verify HiveForge MCP service is running

**Skills not working:**
- SSH into Railway container: check `/data/workspace/skills/`
- Verify start.sh copied files correctly
- Check OpenClaw logs for skill loading errors

## Estimated Costs

| Item | Monthly |
|------|---------|
| Railway (OpenClaw service) | $5-10 |
| Claude API (Haiku + Sonnet) | $10-30 |
| **Total** | **$15-45** |

## Hardening & Operational Excellence

### DECISIONS.md Gate

All cron jobs and autonomous actions check `workspace/DECISIONS.md` before executing. This is the single most important human override mechanism.

**To pause an automation:**
Message the bot: "Edit DECISIONS.md and add a hold for morning brief"
Or SSH into the container and edit `/data/workspace/DECISIONS.md` directly.

**Example hold:**
```markdown
## Holds
- HOLD: morning brief — paused until Monday 2026-02-17
```

The bot will read DECISIONS.md before every cron execution and skip held actions.

### Model Cascade

Main agent runs on Sonnet 4.5 for the best balance of quality and cost. Sub-agents use Haiku 4.5.

| Task Type | Model | Cost (per MTok) |
|-----------|-------|-----------------|
| Sub-agent lookups, data gathering | Haiku 4.5 | $0.80 in / $4 out |
| **Main agent conversations + tool use** | **Sonnet 4.5** | **$3 in / $15 out** |

**Why Sonnet over Opus?** Sonnet 4.5 handles tool use, task management, and conversations excellently at 5x lower cost. Opus is only needed for deep multi-step reasoning — not typical assistant workloads.

### Registering Cron Jobs

After deployment, message the bot on Telegram to register cron jobs:

```
Register a cron job:
- Name: morning-brief
- Schedule: 0 12 * * 1-5
- Delivery: announce
- Description: Morning brief with tasks, goals, pipeline, and GitHub activity

Register a cron job:
- Name: nightly-cleanup
- Schedule: 0 5 * * *
- Delivery: none
- Description: Flag stuck tasks, check failed builds, log anomalies

Register a cron job:
- Name: log-rotation
- Schedule: 30 5 * * *
- Delivery: none
- Description: Review sessions, update MEMORY.md, prune stale entries
```

Verify with: "List my cron jobs"

### Two-Tier Memory

- **MEMORY.md** — Persistent operational memory. Survives deploys (no-clobber in start.sh). Updated nightly by log rotation cron.
- **Session logs** — Transient. Cleared on restart. Used for immediate context.

### No-Clobber Files

`start.sh` preserves these files across deploys:
- `DECISIONS.md` — Human overrides persist
- `MEMORY.md` — Operational memory persists

All other workspace files (AGENTS.md, SOUL.md) are overwritten on deploy to pick up latest changes.

## Multi-Instance / Persona System

### How It Works

The `OPENCLAW_PERSONA` env var controls which personality and configuration each instance uses.
All instances share the same Docker image but can have different identities, API docs, and skills.

```
clawdbot-railway-template/
├── Dockerfile            ← Shared (one image for all bots)
├── start.sh              ← Shared (reads OPENCLAW_PERSONA at boot)
├── src/                  ← Shared gateway code
├── skills/               ← Shared skills (copied to all bots)
├── workspace/            ← Shared defaults
│   ├── AGENTS.md         ← Default API docs (overridden by persona)
│   ├── SOUL.md           ← Default identity (overridden by persona)
│   ├── DECISIONS.md      ← No-clobber seed
│   └── MEMORY.md         ← No-clobber seed
└── bots/                 ← Per-bot overrides
    ├── producthacker/
    │   ├── workspace/    ← SOUL.md, AGENTS.md (optional)
    │   └── skills/       ← (optional) PH-specific skills
    ├── cam/
    │   ├── workspace/    ← Cam's SOUL.md, AGENTS.md (optional)
    │   └── skills/       ← (optional) Cam-specific skills
    └── jody/
        ├── workspace/    ← Jody's SOUL.md, AGENTS.md (optional)
        └── skills/       ← (optional) Jody-specific skills
```

### Boot Sequence

1. `start.sh` syncs shared `workspace/*.md` → `/data/workspace/` (overwrites all except no-clobber)
2. `start.sh` syncs shared `skills/` → `/data/workspace/skills/`
3. If `OPENCLAW_PERSONA` is set, files from `bots/$PERSONA/workspace/` override shared defaults
4. If persona has a `bots/$PERSONA/skills/` directory, those skills are merged into the shared skills dir
5. DECISIONS.md and MEMORY.md are never overwritten if they already exist on the volume

### Adding a New Persona

1. Create `bots/<name>/workspace/SOUL.md` with the desired identity
2. Optionally add `AGENTS.md` for custom API docs or `skills/` for persona-specific skills
3. Set `OPENCLAW_PERSONA=<name>` on the Railway service
4. Redeploy — persona files override shared defaults on boot

### Railway Watch Paths (Selective Redeployment)

Each service only watches its own bot directory. Shared code changes require manual redeploy per service.

| Service | Watch Paths |
|---------|-------------|
| `openclaw` | `bots/producthacker/**` |
| `openclaw-cam` | `bots/cam/**` |
| `openclaw-jody` | `bots/jody/**` |

Push to `bots/cam/` → only Cam's service redeploys.
Push to `src/` or `start.sh` → nothing auto-deploys (manually redeploy each when ready).

### Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `OPENCLAW_PERSONA` | `producthacker` | Which persona directory to use |
