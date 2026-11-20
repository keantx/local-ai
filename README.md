# Local AI
Run a local LLM stack with minimal to none manual work. Dockerized solution for running Ollama models through Litellm, accessible via Open WebUI.

## Features
- **Zero Configuration**: Pre-configured Docker Compose, Automated LiteLLM first user onboarding plus virtual Key setup
- **Model Flexibility**: Works with any Ollama model (should be)
- **Open WebUI**: Accessible via Open WebUI
- **WSL2 Support**: Tested on WSL2

## Prerequisites
1. **Docker** installed and running
2. **Ollama** installed with default settings:
   - Running on port `11434`
   - Pull your preferred model (e.g., `ollama pull qwen3.5:9b`)

I personally run ubuntu WSL2 with docker desktop integration  
Ollama should run metal

## Usage
```bash
# Start the stack, -d is for detached, -f not detached
./scripts/start.sh -f

# Stop and clean up
./scripts/destroy.sh
```

### Port Mapping
- **Open WebUI**: http://localhost:3000
- **LiteLLM API**: http://localhost:4000 (configured for Ollama)

---

## Architecture

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│  Open WebUI │◄────►│   Litellm   │◄────►│    Ollama   │
│     (3000)  │      │  API (4000) │      │  (11434)    │
└─────────────┘      └─────────────┘      └─────────────┘
       ▲                   ▲                     ▲
       │                   │                     │
       ▼                   ▼                     ▼
   Web Browser         Postgres DB          Model Server
```

## Environment Variables (auto-generated)

The `start.sh` script creates a `.env` file with secure secrets:

| Variable | Purpose | Default/Generation |
|----------|---------|-------------------|
| `LITELLM_MASTER_KEY` | Litellm API key | Random 32-char hex |
| `LITELLM_SALT_KEY` | Hashing salt for keys | Random 32-char hex |
| `POSTGRES_PASSWORD` | Database password | Random 32-char hex |
| `ADMIN_USER_ID` | WebUI admin user | "admin"  |
| `ADMIN_EMAIL` | Admin email | "admin@local.dev" |
| `ADMIN_PASSWORD` | Admin password | Auto-generated secure string |
| `WEBUI_SECRET_KEY` | Open WebUI secret | Random 32-char hex |
| `OPENWEBUI_LITELLM_KEY` | API key for Ollama integration | Random 24-char hex |
| `LITELLM_BIND` | Litellm bind address | Defaults to localhost |
| `LITELLM_PORT` | Litellm port | Default: 4000 |
| `POSTGRES_USER` | Database user | "litellm" |

## Model Configuration

Edit `config/litellm_config.yaml` to add or modify models:

```yaml
model_list:
  - model_name: qwen3.5:9b
    litellm_params:
      model: ollama_chat/qwen3.5:9b
      api_base: http://host.docker.internal:11434

general_settings:
  disable_env_credential_login: true
```

---

### Access Open WebUI / LiteLLM
1. Navigate to http://localhost:3000 or http://localhost:4000/ui
2. Login with admin credentials in your .env
---

## Scripts

| Script | Description |
|--------|-------------|
| `start.sh` | Starts all services, generates `.env` if needed |
| `destroy.sh` | Stops and removes all containers/volumes |
| `litellm-init.sh` | Initializes Litellm admin credentials (internal) |

## License

MIT License - Use freely for personal and commercial projects
