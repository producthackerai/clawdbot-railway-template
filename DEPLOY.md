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
