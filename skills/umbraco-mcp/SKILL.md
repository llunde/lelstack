---
name: umbraco-mcp
description: Create and edit Umbraco CMS structure and content (data types, document and element types, templates, dictionary, media, documents and Block List blocks) through the Umbraco Developer MCP server (@umbraco-cms/mcp-dev). Covers setup, the safe write loop, proven value shapes, known gaps with workarounds, and verifying writes, including uSync exports. Use whenever an agent works on Umbraco through this MCP server.
---

# Umbraco MCP

Verified against: Umbraco CMS 17.7.1, `@umbraco-cms/mcp-dev@lts-17` (17.6.11), uSync 17.4.3, Node 22, Claude Code as the MCP client, on macOS; October–November 2026. Only invariant (not culture-variant) document types were used: culture-variant writes are untested.

- Setup, auth and reconnects: [setup.md](setup.md)
- Input shapes for property values, blocks, domains and media: [value-shapes.md](value-shapes.md)
- Gaps and workarounds, by symptom: [pitfalls.md](pitfalls.md)

## Before the first write
- The MCP server is a required integration: in the autonomous build workflow, record it under Required integrations in `workflow/harness.md` (phases and roles that write through it), so a build stops rather than working around a missing server.
- Confirm the MCP tools exist in **this** agent's session with a read (`get-document-type-root`). An agent started before the server (re)connected never gets them: start a fresh one.
- Get input shapes from the schema tools (`get-data-type-schema`, `get-document-type-schema`). They describe property values, not data type configuration, and can be wrong (pitfalls.md). For configuration, read back an existing or built-in item and copy its shape.

## The write loop
1. **Look.** Check whether the item already exists (`get-document-root`, `get-document-children`, `find-dictionary`). Writes aren't idempotent: a blind retry makes a duplicate.
2. **Write with a merging tool** where one exists:
   - Documents: `update-document-properties`, then `publish-document`. New nodes: `create-and-publish-document`.
   - Blocks: `create-document-block`, `update-block-property`, `delete-document-block`, then `publish-document` (blocks save unpublished).
   - `update-document`, `update-and-publish-document` and `update-media` **replace every value**: send them only a full body you read back first.
   - Types: create, read back with `get-document-type-by-id`, then `update-document-type` with the full body for what create can't set (mandatory flags, descriptions).
3. **Read back** the first item of each kind (`get-document-by-id`, `get-data-type`, `get-media-by-id`) and use it as the pattern for the rest. A success response can hide a dropped value.
4. **Confirm the export** (projects using uSync): the write shows up in `git status` under the uSync folder (Verify). No file: stop and find out why before continuing.
5. **Log every workaround** where the project keeps notes: tool, input, exact error, workaround.

## Order
Media → page tree skeleton → settings that point at pages → page content → publish. Publish parents before children. Create template records with `create-template` (master template and view content) so Umbraco owns the record and writes the file, then edit the view as code.

## When MCP can't do it
Take the narrowest step that works, and log it:
1. Another tool or input shape for the same thing (pitfalls.md lists the proven ones).
2. Content, with uSync: edit the exported content `.config`, import once with `uSync:Settings:ImportAtStartup: "Content"`, restart, confirm through MCP, then set it back to `"None"`. Proven for node names.
3. Structure, with uSync: a hand-written `.config` modelled on an existing one with a new key, imported the same way with `"Settings"`. (unproven)

Views, partials, CSS/JS, C# (startup handlers, content finders) and config files are code, not MCP work.

## Verify
- Read back through MCP, or read the exported uSync file: same persisted data, fewer tokens. For links trust MCP read-back: uSync stores document links as a `udi` with `type: null`.
- Expected uSync output per write (default `v17` folder):

  | Write | Export |
  |---|---|
  | document or element type | `ContentTypes/<alias>.config` |
  | data type | `DataTypes/<name>.config` |
  | template | `Templates/<alias>.config` |
  | dictionary item | `Dictionary/<key>.config` |
  | media type change | `MediaTypes/<alias>.config` changed |
  | document | `Content/<name>.config` |
  | media item | `Media/<name>.config`, plus the file under `wwwroot/media/` |

- Same-name items get a suffixed file name (`<name>_<suffix>.config`): match exports by Key, not by file name. Renames leave `Change="Rename"` markers and deletes `Change="Delete"` markers; commit them as written.
- After deleting a node, grep the uSync folder for its key: only Delete or Rename markers may still hold it (pitfalls.md).
- A fresh database rebuilt from uSync (`uSync:Settings:ImportOnFirstBoot: true`, exports on save) reproduced all structure and content. uSync exports media items but not their files, so commit `wwwroot/media/` if a rebuild must work.
- Render a page that uses each new view: HTTP 200 and the expected content.
