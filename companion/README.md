# Vogteren - the Keeper

An AI game master that lives in the server. It reads chat from `latest.log`,
thinks with Claude, and acts on the world through `rcon-cli` inside the server
container: it greets players, answers when addressed, hides real treasure
chests behind riddles, runs "bring X to my chest" quests with actual chest
verification, and hands out rewards.

## Design

```
latest.log --tail--> keeper.py --Claude (tool loop)--> docker exec <container> rcon-cli <cmd>
                        |__ journal.json  (quests + treasure coordinates persist here)
```

- **Credential-blind**: RCON is reached via `docker exec ... rcon-cli`, which
  reads its own config inside the container. No RCON password is handled.
- **Guard-railed**: commands are checked against an allowlist (chat, blocks,
  items, effects, sounds, weather, tp) and a blocklist (`op`, `ban`, `stop`,
  `whitelist`, `gamemode`, `execute`, ...). The model cannot administrate.
- **Rate-limited**: hourly API-call cap plus per-call spacing, greeting
  cooldowns, and rare spontaneous events.
- **Dry-run by default**: without `ANTHROPIC_API_KEY` it only logs what it
  would have reacted to.

## Install (host running the server container)

```bash
mkdir -p ~/minecraft-companion && cd ~/minecraft-companion
# copy keeper.py, requirements.txt, .env.example, minecraft-companion.service here
python3 -m venv venv && venv/bin/pip install -r requirements.txt
cp .env.example .env   # then edit: API key, log path, player notes
mkdir -p ~/.config/systemd/user
cp minecraft-companion.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now minecraft-companion
journalctl --user -u minecraft-companion -f
```

`loginctl enable-linger <user>` keeps it running after logout/reboot.

## Talk to it

Say any trigger word in chat (default: `keeper`, `vogter`, `vogteren`):

> keeper, hide a treasure for me!

Test without joining the game (requires `KEEPER_ALLOW_SERVER_CHAT=true`):

```bash
docker exec minecraft-server rcon-cli "say keeper hello"
```
