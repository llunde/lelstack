# Umbraco MCP: setup

Local development setup that worked with a local Umbraco 17 site on HTTPS. Credentials stay in a gitignored env file; never commit or log them.

## Server registration
Register the server with the MCP client (for Claude Code: `.mcp.json` in the repo root). The same command and env work in any client that starts stdio servers.

```json
{
  "mcpServers": {
    "umbraco": {
      "command": "sh",
      "args": ["-c", ". \"$HOME/.nvm/nvm.sh\" && nvm use --silent 22 && exec npx -y @umbraco-cms/mcp-dev@lts-17"],
      "env": {
        "NODE_ENV": "production",
        "NODE_EXTRA_CA_CERTS": "${HOME}/.aspnet/dev-certs/localhost.pem"
      }
    }
  }
}
```

- The package needs Node 22+. The server talks over stdout, so anything else printed there breaks it: keep nvm `--silent`.
- Pin the dist-tag to the CMS major (`lts-17` for Umbraco 17) and record the resolved version.
- `NODE_ENV=production`: without it the MCP SDK turns off TLS certificate checks (read in the SDK source; not tested the other way).
- The token endpoint only accepts HTTPS, and Node doesn't read the macOS keychain, so point Node at an exported copy of the ASP.NET dev certificate. Export again whenever `dotnet dev-certs` renews it:

  ```sh
  security find-certificate -c localhost -p > ~/.aspnet/dev-certs/localhost.pem
  ```

## Env file
The server reads a `.env` in its working directory (the repo root) on start. Keep it gitignored, one `KEY=VALUE` per line, no inline `#` comments.

| Key | Value |
|---|---|
| `UMBRACO_CLIENT_ID` | the API user's client ID |
| `UMBRACO_CLIENT_SECRET` | its secret |
| `UMBRACO_BASE_URL` | the backoffice's HTTPS base URL |
| `UMBRACO_INCLUDE_TOOL_COLLECTIONS` | collections to expose. Enough for structure and content: `document,document-blueprint,document-type,data-type,media,media-type,language,culture,template,dictionary,temporary-file` (`dictionary` for dictionary items, `temporary-file` for uploads) |
| `UMBRACO_ALLOWED_MEDIA_PATHS` | absolute folder(s) the server may upload files from |

After changing the file, reconnect the server (Claude Code: `/mcp`). Only agents started after the reconnect see the tools.

## API user
- The server authenticates as a backoffice **API user** with client credentials. Put it in **Administrators**: creating document and data types needs it (Editors lacks those permissions per Umbraco's defaults; not tested here).
- The enabled collections had no tool that shows the current user's groups, so confirm the group by hand once.
- In the backoffice: Users → Create → API user, then add client credentials with the client ID and secret from `.env`. If adding them is rejected, the client ID may already belong to another API user.

## Surviving a database reset
The API user lives in the database, so a reset removes it. A Development-only startup handler can recreate it (proven over three full resets):
- An `INotificationAsyncHandler<UmbracoApplicationStartedNotification>`, registered in an `IComposer`, that runs only when `IHostEnvironment.IsDevelopment()` and `IRuntimeState.Level == RuntimeLevel.Run`.
- It reads the client ID and secret from the same `.env` and skips with a warning if either is missing.
- It looks up the client with `IBackOfficeUserClientCredentialsManager.FindUserAsync`. If the user isn't found, it reuses a user with the same e-mail via `IUserService.GetByEmail`, and only creates one (`UserKind.Api`, admin group) if there is none. Without that reuse, a failed credentials save leaves a user that blocks every later create as a duplicate.
- It saves the credentials with `SaveAsync`, wraps everything in try/catch so startup never fails, and logs the outcome without the secret.

After the reset and first boot, MCP calls can return **401** because the server's session token is stale (two of three resets). Reconnect the server and use agents started after that.
