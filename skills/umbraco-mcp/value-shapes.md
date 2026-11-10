# Umbraco MCP: value shapes

Input shapes that worked, with read-back and publish. `<…>` are placeholders. Generate every key with a UUID tool (`uuidgen`, or `python3 -c 'import uuid; print(uuid.uuid4())'`), never by hand: hand-made keys risk silent duplicates.

## Publishing
- Invariant document: `publish-document {id, data: {publishSchedules: [{culture: null}]}}`.

## Block List
- Append a block:
  ```
  create-document-block {documentId, propertyAlias: "<blockListAlias>", contentTypeKey: "<element type key>",
    placement: {position: "append"}, properties: [{alias, value}]}
  ```
  then `publish-document`. The block saves unpublished.
- Insert next to a sibling: `placement: {position: "after" | "before", contentKey: "<sibling contentKey>"}`. Read the order back.
- Nested Block List (a block property that is itself a Block List): pass the whole value in object form, leave out unset properties, read it back, then publish:
  ```
  {layout: {"Umbraco.BlockList": [{contentKey, settingsKey: null}]},
   contentData: [{key: <contentKey>, contentTypeKey, values: [{alias, value, culture: null, segment: null, editorAlias: null}]}],
   settingsData: [],
   expose: [{contentKey, culture: null, segment: null}]}
  ```

## Property values
| Editor | Value |
|---|---|
| Rich text (in a block) | a plain HTML string, `"<p>…</p>"`; stored as `{markup, blocks}` |
| Media picker (image) | `[{key: "<new uuid>", mediaKey, mediaTypeAlias: "Image", crops: [], focalPoint: null}]` |
| Multi URL picker, document | `[{name, type: "document", unique: "<document key>"}]` |
| Multi URL picker, external | `[{name, type: "external", unique: null, url, target: null, queryString: null, culture: null}]`, always the full shape (pitfalls.md) |
| Multinode treepicker | `[{type: "document", unique: "<document key>"}]`, not the schema's `"content"` |
| Dropdown (`Umbraco.DropDown.Flexible`, single) | an array, `["<value>"]` |

## Data type configuration
- `values: [{alias, value}]`, as uSync stores it. Copy the aliases from a read-back of a similar built-in data type.
- Block List: `blocks: [{contentElementTypeKey, label}]`, `validationLimit: {min}` (`max` not exercised).
- Treepicker dynamic root nests under the start node: `startNode: {…, dynamicRoot: {originAlias: "Root", querySteps: []}}`.

## Domains and culture
- Site hostnames: `put-document-domains` with the hostnames and their culture, then `publish-document`. (unproven: hostnames were set up before MCP was used)
- Culture for a subtree without a hostname: `put-document-domains` with `defaultIsoCode` set and `domains` empty. The node and its subtree render in that culture.

## Media
- Upload with `create-media-multiple` from files in a folder listed in `UMBRACO_ALLOWED_MEDIA_PATHS` (setup.md).
- Set extra properties with `update-media` and the **full** `values`, including `umbracoFile` (`src`, `width`, `height`, `bytes`, `extension`, `focalPoint`) read back first (pitfalls.md).
- Before deleting a media item, check `get-media-by-id-referenced-by` returns nothing.
