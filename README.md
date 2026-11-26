# Local AI

A Docker Compose stack for using Ollama and OpenRouter models through LiteLLM and Open WebUI. An optional filesystem MCP service connects Open WebUI to an Obsidian second-brain vault.

## Pre-requisites / requirements to run

- Docker Engine with the Docker Compose plugin, running on the host.
- Bash and OpenSSL to run the setup scripts. The scripts are Bash scripts; on Windows, use WSL with Docker Desktop integration.
- For local models: Ollama running on the host at port `11434`, with the models in `config/litellm_config.yaml` pulled. The current local models are `gpt-oss:20b` and `qwen3.5:9b`.
- For the OpenRouter model: an OpenRouter API key. This is optional if you only use local models.
- For second-brain access: an Obsidian vault directory accessible to Docker, and its host path configured as `SECOND_BRAIN_PATH`.

The Compose configuration reaches host Ollama through `host.docker.internal`. Docker Desktop provides this on supported platforms; on Linux, verify that it resolves inside the containers.

## How to run / usage

From the repository root, start the stack:

```bash
./scripts/start.sh
```

The script creates `scripts/.env` with generated credentials and empty optional API key values when they are missing, then runs Docker Compose. The default mode is foreground. Use `-d` for detached mode, `-f` to explicitly use foreground mode, or `-r` to recreate LiteLLM and Open WebUI:

```bash
./scripts/start.sh -d
./scripts/start.sh -r
```

Open WebUI at <http://localhost:3000>. LiteLLM is at <http://localhost:4000>; its health endpoint is <http://localhost:4000/health/liveliness>.

To stop the stack while preserving its database and WebUI data, use Ctrl+C in foreground mode or run `docker compose --env-file scripts/.env -f compose/docker-compose.yml down` from the repository root.

`./scripts/destroy.sh` removes the Compose named volumes and `scripts/.env`. This deletes LiteLLM's PostgreSQL data, Open WebUI data, generated credentials, and local configuration in that env file. Back up anything you need first.

The first run generates LiteLLM and WebUI credentials in `scripts/.env`. Keep this file private; it is ignored by Git. Open WebUI authentication is disabled in the current Compose configuration, so anyone with access to the WebUI can use it.

## How to modify / enable the second-brain setup

Second-brain support is optional and is currently commented out in the configuration. Enable it by updating these files:

1. In `compose/docker-compose.yml`, uncomment the `second-brain-mcp` service near the top. It runs the filesystem MCP server and mounts the host vault directory at `/vault` in the container. The `litellm` service already declares a dependency on `second-brain-mcp`, so enable the service before starting Compose.
2. In `config/litellm_config.yaml`, uncomment the `mcp_servers` block that registers `second_brain` at `http://second-brain-mcp:3001/mcp`.
3. Set `SECOND_BRAIN_PATH` in `scripts/.env` to the absolute host path of your vault. The provided `scripts/start-personal.sh` initializes this value for its configured WSL path; edit that script's `add_if_missing SECOND_BRAIN_PATH` line if your vault is elsewhere. The regular `scripts/start.sh` does not currently set this variable.
4. Start or restart the stack. Open WebUI's `TOOL_SERVER_CONNECTIONS` setting in Compose is already configured to connect to the `second_brain` MCP server through LiteLLM. Its current access grant is read-only.

The path must be valid from Docker's point of view, not merely from inside the container. In WSL, use the Linux path to the mounted Windows directory, such as `/mnt/c/...`.

Other useful configuration locations:

- `config/litellm_config.yaml`: model definitions, fallback routing, and MCP registration.
- `compose/docker-compose.yml`: services, ports, environment, volume mounts, and WebUI MCP connection.
- `config/SYSTEM_PROMPTS.txt` and `config/custom_callbacks.py`: experimental system-prompt injection. This hook is marked as not working yet; its prompt mount and model-name mapping need verification before relying on it.
- `scripts/start.sh` and `scripts/start-personal.sh`: startup and environment file initialization.

To add or change a model, edit `model_list` in `config/litellm_config.yaml`. For local Ollama models, use the `ollama_chat/<model>` provider name and the configured host API base, then ensure the model is available in Ollama.

See [LICENSE](LICENSE) for license information.
