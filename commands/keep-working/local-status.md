# Keep Working — Local AI Status

Check the status of LocalAI integration in the current Keep Working session.

## Usage
```
/keep-working:local-status
```

## Procedure

### 1. Check Gateway Health

```bash
curl -s http://localhost:5577/health
```

Report: Gateway status (ok/unreachable), model info

### 2. Read Local Stats

Read `.keep-working/config.json` and extract the `local` section.

### 3. Present Status

```
LocalAI Integration
━━━━━━━━━━━━━━━━━━
Mode:        [off / assist / full]
Gateway:     [ok / unreachable] (http://localhost:5577)
Model:       localai-coder (Qwen2.5-Coder-7B)

Session Stats
━━━━━━━━━━━━
Local completions:  [N]
Paid completions:   [N]
Parked tasks:       [N]
Escalations:        [N]
Estimated savings:  [X]%
```

### 4. If Mode is Off

If local mode is "off", suggest:
"LocalAI is not active. Start a new session with `local:assist` or `local:full` to enable it."
