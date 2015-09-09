# Slack plugin for Discourse
[Slack] plugin for [Discourse]. Displays member and channel information from Slack in a header dropdown in Discourse.

[slack]: https://slack.com/
[discourse]: http://www.discourse.org/

## Features
- Shows button with Slack member count in header.
- Button opens dropdown with list of members and respective channels.
- Information is refreshed periodically (configurable). 
- Optionally show away members.
- Optionally display a link to the Slack domain.

## How to install
Follow the guide on how to [Install a Plugin][plugin] for Discourse but add this repository URL instead.

Request a [Slack authentication token][auth]. You will need it for the settings.

Then go to Admin > Plugins and choose Slack settings:
- *slack_endpoint*: the URL to the Slack Web API endpoint
- *slack_token*: Slack authentication token
- *slack_interval*: the interval between information refreshes in milliseconds
- *slack_link*: whether to display a link back to the Slack team
- *slack_away*: whether to display away members

[plugin]: https://meta.discourse.org/t/install-a-plugin/19157
[auth]: https://api.slack.com/web#authentication
