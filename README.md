# xBot: The bot with no name

### Installation

If you don't have Vapor installed:
```
brew tap vapor/tap
brew install vapor/tap/vapor
```

If you have Vapor installed and need to update:
```
brew upgrade vapor
```

Once Vapor is installed, navigate to repository location and run:
```
vapor fetch
```

Then run:
```
vapor xcode
```

### Secrets

You'll need to provide your bot API key to start receiving messages. Additionally, for slash commands to be validated, you'll need to provide your Slack signing secret. Both of these can be obtained from api.slack.com/apps. The application reads the secrets from the environment, so they can be provided by standard environment setup patterns in different deployments, but for development the secrets are read from an untracked `secrets.json` file that should be placed in the root of the repository. **note: _never_ commit these secrets**

The file should contain the following:

```
{
    "BotUserAPIKey" : "xoxb-<other-letters-and-numbers>",
    "SlackRequestSigningSecret" : "<signing-secret-here>",
    "OnTapSecret" : "<ontap-secret-here>"
}
```
