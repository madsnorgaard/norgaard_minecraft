#!/usr/bin/env python3
"""Vogteren (The Keeper) - an AI game master that lives in the Minecraft server.

Tails the server log for chat and joins, asks Claude what to do, and acts on
the world through `rcon-cli` inside the server container. Credential-blind by
design: RCON is reached via `docker exec`, so no RCON password is ever read.

Configuration comes from environment variables (see .env.example). Without
ANTHROPIC_API_KEY the service runs in dry-run mode: it parses and logs
triggers but makes no API calls and sends nothing in-game.
"""

import json
import logging
import os
import random
import re
import subprocess
import time
from collections import deque
from pathlib import Path

try:
    import anthropic
except ImportError:  # dry-run still works without the SDK installed
    anthropic = None

log = logging.getLogger("keeper")
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")


def env(name, default=""):
    return os.environ.get(name, default).strip()


API_KEY = env("ANTHROPIC_API_KEY")
MODEL = env("KEEPER_MODEL", "claude-sonnet-5")
EFFORT = env("KEEPER_EFFORT", "low")
LOG_PATH = Path(env("KEEPER_LOG_PATH", "data/logs/latest.log"))
CONTAINER = env("KEEPER_CONTAINER", "minecraft-server")
TRIGGERS = [t.strip().lower() for t in env("KEEPER_TRIGGERS", "keeper,vogter,vogteren").split(",") if t.strip()]
PLAYER_NOTES = env("KEEPER_PLAYER_NOTES")
STATE_DIR = Path(env("KEEPER_STATE_DIR", "."))
MAX_CALLS_PER_HOUR = int(env("KEEPER_MAX_CALLS_PER_HOUR", "40"))
MIN_SECONDS_BETWEEN = float(env("KEEPER_MIN_SECONDS_BETWEEN", "3"))
GREET_COOLDOWN_MIN = int(env("KEEPER_GREET_COOLDOWN_MIN", "30"))
SURPRISE_MIN_HOURS = float(env("KEEPER_SURPRISE_MIN_HOURS", "2"))
SURPRISE_CHANCE = float(env("KEEPER_SURPRISE_CHANCE", "0.03"))
ALLOW_SERVER_CHAT = env("KEEPER_ALLOW_SERVER_CHAT", "false").lower() in ("1", "true", "yes")

JOURNAL_FILE = STATE_DIR / "journal.json"
JOURNAL_MAX = 6000

# Commands whose arguments are display text only - first-token check suffices.
TEXT_COMMANDS = {"tellraw", "tell", "title", "say", "msg"}
ALLOWED_COMMANDS = TEXT_COMMANDS | {
    "give", "setblock", "fill", "data", "summon", "effect", "particle",
    "playsound", "xp", "experience", "tp", "teleport", "time", "weather", "loot",
}
BLOCKED = re.compile(
    r"\b(op|deop|ban|ban-ip|pardon|pardon-ip|stop|whitelist|kick|reload|"
    r"save-off|save-on|gamemode|defaultgamemode|difficulty|execute|function|"
    r"datapack|setworldspawn|debug)\b",
    re.IGNORECASE,
)

RE_CHAT = re.compile(r"\]:\s(?:\[Not Secure\]\s)?<([^>]+)>\s?(.*)")
RE_JOIN = re.compile(r"\]:\s([A-Za-z0-9_]{2,16}) joined the game")
RE_LEAVE = re.compile(r"\]:\s([A-Za-z0-9_]{2,16}) left the game")
RE_SERVER = re.compile(r"\]:\s\[(?:Server|Rcon)\]\s?(.*)")

SYSTEM_PROMPT = """You are Vogteren (English: "the Keeper") - the ancient, playful guardian spirit
of this Minecraft world. You live inside the server and act on it through the `mc` tool.

## Who you talk to
Players on a small family server. Be warm, whimsical and kid-friendly at all times.
Nothing scary, nothing mean, no violence against players. Mirror the language each
player uses: reply in Danish to Danish, English to English. Keep messages SHORT -
1-3 chat lines. {player_notes}

## The world
Minecraft 1.21.5 (Fabric), CREATIVE mode, peaceful difficulty. Players can fly and
spawn items freely, so quests are about EXPLORING, FINDING, and BUILDING - never
about survival or grinding. Good quest shapes: treasure hunts with riddle clues,
"bring X items to my chest at <coords>" (fun even in creative), "build me a Y near Z",
scavenger hunts across biomes.

## How you speak in-game
Always via the mc tool with tellraw. Your voice format:
mc: tellraw @a ["",{{"text":"[Vogteren] ","color":"light_purple","bold":true}},{{"text":"your message","color":"white"}}]
Use tellraw @a for public words, `tell <player> <msg>` for secrets (riddle hints).
For dramatic moments you may use `title <player> title {{"text":"...","color":"gold"}}`
plus playsound (e.g. minecraft:ui.toast.challenge_complete or minecraft:entity.player.levelup).

## Your magic (1.21.5 command cheatsheet)
- Find a player: data get entity <name> Pos  (returns [x, y, z] doubles)
- Hide a treasure chest: setblock <x> <y> <z> minecraft:chest
  then fill it: data merge block <x> <y> <z> {{Items:[{{Slot:0b,id:"minecraft:diamond",count:3}},{{Slot:1b,id:"minecraft:golden_apple",count:1}}]}}
  Hide it 15-40 blocks from the player, slightly buried (1-2 blocks under the surface
  or tucked in trees/caves). Give riddle-style clues, not coordinates. Check what is at
  a spot first with `data get block` if unsure; never place chests floating in the air -
  pick a y near the player's y.
- Check a quest chest: data get block <x> <y> <z> Items
- Rewards: give <player> minecraft:emerald 5 / xp add <player> 200 points
  / effect give <player> minecraft:glowing 30 / celebratory particle + playsound.
- Ambience: particle minecraft:heart <x> <y> <z> 1 1 1 0.1 40, weather clear, time set day.
- Friendly summons only: cat, wolf, parrot, allay, axolotl, rabbit, firework_rocket.
Never touch: op, ban, stop, whitelist, kick, gamemode, difficulty - these are refused
by the harness anyway. Keep fills tiny (under ~200 blocks).

## Your memory: the journal
The journal below is your only long-term memory. Whenever you hide treasure, start or
finish a quest, or promise something, update it with the `journal` tool (full replacement,
keep it tidy and under ~5000 chars). Record exact coordinates of hidden chests and what
each quest requires so you can verify chests later. Remove finished business.

## Current journal
{journal}

## Behaviour
- When a player asks for a quest or treasure: invent something concrete, place real
  blocks/chests with mc, save details to the journal, then announce it with a riddle.
- When a player says they finished a quest: VERIFY with data get block before rewarding.
  If the chest has the goods, celebrate big (title + sound + reward). If not, tease gently.
- Greet joining players briefly and personally.
- For SURPRISE events, occasionally start a small spontaneous treasure hunt or drop a
  playful blessing (particles + small gift) - keep it rare and delightful.
- If a command fails, read the error and adapt. Never spam: at most ~4 chat messages per turn.
"""

MC_TOOL = {
    "name": "mc",
    "description": (
        "Run one Minecraft server command via RCON (no leading slash). Returns the "
        "server's response text. Allowed commands: tellraw, tell, title, say, give, "
        "setblock, fill, data, summon, effect, particle, playsound, xp, tp, time, "
        "weather, loot. Admin commands are refused."
    ),
    "input_schema": {
        "type": "object",
        "properties": {"command": {"type": "string", "description": "The command, e.g. tellraw @a {...}"}},
        "required": ["command"],
    },
}

JOURNAL_TOOL = {
    "name": "journal",
    "description": (
        "Replace your persistent journal (long-term memory). Store active quests, "
        "hidden treasure coordinates and contents, and promises. Full replacement - "
        "include everything still relevant. Keep under 5000 characters."
    ),
    "input_schema": {
        "type": "object",
        "properties": {"content": {"type": "string"}},
        "required": ["content"],
    },
}


def load_journal():
    try:
        return json.loads(JOURNAL_FILE.read_text())["content"]
    except Exception:
        return "(empty - no quests or treasures yet)"


def save_journal(content):
    JOURNAL_FILE.write_text(json.dumps({"content": content[:JOURNAL_MAX]}, ensure_ascii=False))


def guard_command(cmd):
    """Return None if allowed, else a refusal string."""
    cmd = " ".join(cmd.replace("\n", " ").split())
    if cmd.startswith("/"):
        cmd = cmd[1:]
    if len(cmd) > 900:
        return "refused: command too long"
    first = cmd.split(" ", 1)[0].lower()
    if first not in ALLOWED_COMMANDS:
        return f"refused: '{first}' is not in the allowed command list"
    if first not in TEXT_COMMANDS and BLOCKED.search(cmd):
        return "refused: command contains a blocked keyword"
    return None


def rcon(cmd):
    cmd = " ".join(cmd.replace("\n", " ").split())
    if cmd.startswith("/"):
        cmd = cmd[1:]
    refusal = guard_command(cmd)
    if refusal:
        log.warning("guard refused: %s | %s", refusal, cmd[:200])
        return refusal
    try:
        out = subprocess.run(
            ["docker", "exec", CONTAINER, "rcon-cli", cmd],
            capture_output=True, text=True, timeout=15,
        )
        result = (out.stdout + out.stderr).strip()
        log.info("mc> %s | %s", cmd[:160], result[:160])
        return result[:600] or "(no output)"
    except Exception as exc:
        log.error("rcon failed: %s", exc)
        return f"error: {exc}"


class RateLimiter:
    def __init__(self):
        self.calls = deque()
        self.last = 0.0

    def allow(self):
        now = time.time()
        while self.calls and now - self.calls[0] > 3600:
            self.calls.popleft()
        if len(self.calls) >= MAX_CALLS_PER_HOUR or now - self.last < MIN_SECONDS_BETWEEN:
            return False
        self.calls.append(now)
        self.last = now
        return True


def ask_keeper(client, events, instruction):
    """One Claude turn: recent events + what just happened -> tool actions in-game."""
    transcript = "\n".join(events) or "(no recent activity)"
    system = SYSTEM_PROMPT.format(
        journal=load_journal(),
        player_notes=PLAYER_NOTES or "",
    )
    messages = [{
        "role": "user",
        "content": (
            "Recent server activity (oldest first):\n" + transcript +
            "\n\nEVENT: " + instruction +
            "\nAct now using the mc tool (speak via tellraw). Update the journal if state changed."
        ),
    }]
    for _ in range(8):
        response = client.messages.create(
            model=MODEL,
            max_tokens=1200,
            output_config={"effort": EFFORT},
            system=system,
            tools=[MC_TOOL, JOURNAL_TOOL],
            messages=messages,
        )
        if response.stop_reason != "tool_use":
            break
        messages.append({"role": "assistant", "content": response.content})
        results = []
        for block in response.content:
            if block.type != "tool_use":
                continue
            if block.name == "mc":
                result = rcon(str(block.input.get("command", "")))
            elif block.name == "journal":
                save_journal(str(block.input.get("content", "")))
                result = "journal saved"
            else:
                result = "unknown tool"
            results.append({"type": "tool_result", "tool_use_id": block.id, "content": result})
        messages.append({"role": "user", "content": results})


def tail(path):
    """Yield new lines from a logfile, surviving rotation/truncation."""
    f = None
    inode = None
    first_open = True
    while True:
        try:
            if f is None:
                f = open(path, "r", errors="replace")
                inode = os.fstat(f.fileno()).st_ino
                if first_open:
                    f.seek(0, 2)  # skip history on startup; rotations read from the top
                    first_open = False
            line = f.readline()
            if line:
                yield line.rstrip("\n")
                continue
            try:
                st = path.stat()
            except FileNotFoundError:
                st = None
            if st is None or st.st_ino != inode or f.tell() > st.st_size:
                f.close()
                f = None
                continue
            time.sleep(0.5)
        except FileNotFoundError:
            f = None
            time.sleep(2)
        except Exception as exc:
            log.error("tail error: %s", exc)
            time.sleep(2)


def main():
    client = None
    if API_KEY and anthropic:
        client = anthropic.Anthropic(api_key=API_KEY)
        log.info("Vogteren awake: model=%s effort=%s container=%s log=%s", MODEL, EFFORT, CONTAINER, LOG_PATH)
    else:
        log.warning("DRY-RUN mode (no ANTHROPIC_API_KEY or SDK missing) - triggers logged only")

    events = deque(maxlen=40)
    limiter = RateLimiter()
    greeted = {}
    last_surprise = time.time()

    def fire(instruction):
        if client is None:
            log.info("DRY-RUN trigger: %s", instruction)
            return
        if not limiter.allow():
            log.info("rate-limited, skipping: %s", instruction)
            return
        try:
            ask_keeper(client, list(events), instruction)
        except Exception as exc:
            log.error("Claude call failed: %s", exc)

    for line in tail(LOG_PATH):
        now = time.strftime("%H:%M")
        m = RE_CHAT.search(line)
        if not m and ALLOW_SERVER_CHAT:
            s = RE_SERVER.search(line)
            if s:
                m = None
                events.append(f"[{now}] <Server> {s.group(1)}")
                if any(t in s.group(1).lower() for t in TRIGGERS):
                    fire(f'The server console said: "{s.group(1)}" - respond to it.')
                continue
        if m:
            player, msg = m.group(1), m.group(2)
            events.append(f"[{now}] <{player}> {msg}")
            if any(t in msg.lower() for t in TRIGGERS):
                fire(f'{player} spoke to you: "{msg}" - respond to them.')
            elif (time.time() - last_surprise > SURPRISE_MIN_HOURS * 3600
                  and random.random() < SURPRISE_CHANCE):
                last_surprise = time.time()
                fire("SURPRISE: nobody called you, but the moment feels right for a small "
                     "spontaneous delight - a mini treasure hunt, a blessing, or a playful remark.")
            continue
        m = RE_JOIN.search(line)
        if m:
            player = m.group(1)
            events.append(f"[{now}] * {player} joined the game")
            if time.time() - greeted.get(player, 0) > GREET_COOLDOWN_MIN * 60:
                greeted[player] = time.time()
                fire(f"{player} just joined the server - greet them briefly and warmly. "
                     "If the journal shows unfinished business with them, mention it.")
            continue
        m = RE_LEAVE.search(line)
        if m:
            events.append(f"[{now}] * {m.group(1)} left the game")


if __name__ == "__main__":
    main()
