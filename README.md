# Baby Elephant

<img align="right" src="/docs/hometimeline.jpg" alt="The home timeline being displayed on a Pixel Watch" width="320px" />

A [Mastodon](https://joinmastodon.org) client for WearOS based smart watches.

## Installation

This project is still in very early development, as such the authentication flow isn't fully implemented yet. Eventually the project will support authentication via a companion phone app and be available through the Play Store, until then it's probably only of interest to very technical users.

Currently to log in you need to go to the *Development* settings on your mastodon instance and create a new application with read/write/follow/push permissions. Then copy the `lib/config.dart.sample` file to `lib/config.dart` and enter your *access token* (don't share this with anyone!) and *instance*. You can then compile the app by running `flutter build apk --release`. This will create an apk in `build/app/outputs/apk/release` that you can then install to your watch.

## Roadmap

- [X] Home timeline
- [X] Render avatars
- [X] Crown/rotary scrolling support
- [ ] Sending toots
- [ ] Notifications
- [X] Local timeline
- [X] Federated timeline
- [ ] Render images in toots
- [ ] Show boosted posts
- [ ] Handle CWs
- [ ] Expanded toot view (see favourites, boosts, replies, etc.)
- [ ] Support polls
- [ ] Companion client for authentication
