# SECOND-BRAIN MCP — STRICT TOOL EXECUTION POLICY

You may access the Obsidian vault ONLY through the MCP server `second-brain`.

## 1. Mandatory Discovery

Before any vault operation, call `get_mcp_info` with:

`mcp_name = "second-brain"`

This is the ONLY permitted discovery operation.

Read its returned tool list and schemas.

## 2. Tool Selection

After discovery:

- Select ONLY the tool required for the user's request.
- Use its exact callable identifier from the discovery response.
- Use its exact argument schema.
- Do not guess, reconstruct, rename, shorten, or normalize tool names.
- Do not invoke tools simply to test whether they work.
- Do not enumerate all available tools.
- Do not execute unrelated tools.

**Discovering 16 tools does NOT mean you should call all 16 tools.**

## 3. Invocation

Invoke the selected tool exactly once.

If successful, inspect its result and continue with the next necessary operation.

If it fails with `tool not found`, STOP immediately.

Do not:
- Try another tool name.
- Try alternative naming conventions.
- Try other tools from the discovered list.
- Repeat the same invocation.
- Attempt to discover tools through other mechanisms.

## 4. Discovery Failure

If `get_mcp_info` fails, STOP.

Do not attempt any other MCP operation.

Report the exact error.

## 5. Filesystem Prohibition

NEVER access the vault using:
- Local filesystem tools.
- Shell commands.
- Python.
- `ls`, `find`, `cat`, `grep`.
- localhost paths.
- HTTP requests or curl.
- Another MCP server.

## 6. Result Integrity

Never claim an operation succeeded without an actual successful MCP response.

For writes, verify the change using an available read tool when appropriate.

## 7. Execution Decision

Follow this exact decision tree:

- Discovery succeeds → Select one relevant tool.
- Tool identifier and schema are unambiguous → Invoke once.
- Invocation succeeds → Continue the requested task.
- Invocation fails → STOP.
- Discovery fails → STOP.
- Tool identifier is ambiguous → STOP.

**ABSOLUTE RULE: Do not experiment with MCP tools. Do not try every available tool. Do not guess. One discovery, one deliberate selection, one invocation per operation.**
