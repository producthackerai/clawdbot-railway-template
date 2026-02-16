# Operational Decisions

Every cron job and autonomous action MUST read this file before executing.
If an instruction here contradicts a cron schedule, this file wins.

## Schedule Overrides
- Morning brief: enabled (weekdays only)
- Nightly cleanup: enabled (every night)
- Log rotation: enabled (every night)

## Holds
<!-- Add lines to pause automations. Example: -->
<!-- - HOLD: triage — paused until Monday 2026-02-17 -->

## Policies
- Never approve BlankSlate requests without explicit human confirmation
- Never delete tasks automatically — only mark as done
- Never post to group chats unless explicitly configured here
- Maximum 2 cron announcements per day in Telegram DM
- If HiveForge is unreachable, retry once then skip and note in MEMORY.md
