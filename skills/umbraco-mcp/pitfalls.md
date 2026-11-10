# Umbraco MCP: pitfalls

Each was hit at least once on the versions in SKILL.md, unless marked (unproven).

| Symptom | Cause | Workaround |
|---|---|---|
| Element or document type created without mandatory flags or property descriptions, and no error | the create tools have no input for them | read back with `get-document-type-by-id`, set them, send the full body to `update-document-type` |
| `400 Invalid property type alias` (`InvalidPropertyTypeAlias`) on a property alias `name` | Umbraco reserves it (clashes with the item's own Name) | use another alias, e.g. `<thing>Name` |
| `400 Field '…' contains query parameter characters ('?' or '&')` for a document name or dictionary translation | the MCP SDK's input sanitizer rejects `?` and `&` in tool input (media property values such as alt text are accepted) | dictionary: store the text without the character and add it in the view. Names: create without it, then edit `NodeName` in the exported content file and import once (SKILL.md, When MCP can't do it) |
| Can't edit a node whose name has `?` | `update-document`, `update-and-publish-document`, `update-document-name` and the create tools send the name back through the sanitizer | `update-document-properties` + `publish-document` work, because they take the name from a GET. `update-block-property` and `create-document-block` should too (unproven: read in the source only). After the first block write, check the name still has its `?` |
| Values gone after `update-media` (e.g. empty `umbracoFile`, the file still on disk), `update-document` or `update-and-publish-document` | these replace all values; anything left out is cleared | read back first and send every value, or use `update-document-properties` for documents |
| Multinode treepicker write returns 500 `Unknown entity type "content"` | the schema's enum says `content`, but Umbraco wants `document` | `type: "document"` |
| Multi URL picker reports success but stores `"url": null`; renders an empty `href` | short shape `{name, url}`, or a null `type` | send the full external shape (value-shapes.md) |
| Publish fails with `ContentInvalid` on a dropdown | a single dropdown value sent as a string | send an array, `["<value>"]` |
| Media item's stored file loses its extension | Umbraco builds the file name from the media name and cuts it at the first `.` | no dots in media names; use `-` |
| `get-data-type-schema` gives no help with configuration | it describes the property value, not data type config | copy config from a read-back (value-shapes.md) |
| After renaming and then deleting a node, uSync still holds old exports (content, and domain files for the node) next to the Delete marker | uSync writes the marker to a new file and leaves the old ones; MCP has no clean export | remove the stale untracked files by hand, keep the markers, then grep for the deleted key (SKILL.md, Verify) |
| MCP calls return 401 after a database reset (two of three resets) | the server's session token is stale | reconnect the server; start fresh agents (setup.md) |
| A sub-agent has no MCP tools while others do | it started before the server (re)connected | start a new agent after the reconnect |
| `create-document-block` result not on the site | blocks save unpublished | `publish-document` after block writes |
