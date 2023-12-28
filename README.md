# Baby Elephant
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-2-orange.svg?style=flat-square)](#contributors) [![Powered by mastodon_api](https://img.shields.io/badge/Powered%20by-mastodon_api-00acee.svg?style=flat-square)](https://github.com/mastodon-dart/mastodon-api)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

<img align="right" src="/docs/hometimeline.jpg" alt="The home timeline being displayed on a Pixel Watch" width="320px" />

A [Mastodon](https://joinmastodon.org) client for WearOS based smartwatches.

## Installation

This project is still in very early development, as such the authentication flow isn't fully implemented yet. Eventually the project will support authentication via a companion phone app and be available through the Play Store, until then it's probably only of interest to very technical users.

Currently to log in you need to go to the *Development* settings on your mastodon instance and create a new application with read/write/follow/push permissions. Then copy the `lib/config.dart.sample` file to `lib/config.dart` and enter your *access token* (don't share this with anyone!) and *instance*. You can then compile the app by running `flutter build apk --release`. This will create an apk in `build/app/outputs/apk/release` that you can then install to your watch.

## Roadmap

- [X] Home timeline
- [X] Render avatars
- [X] Crown/rotary scrolling support
- [X] Sending toots
- [ ] Notifications
- [X] Local timeline
- [X] Federated timeline
- [X] Render images in toots
- [X] Show boosted posts
- [X] Handle CWs
- [ ] Expanded toot view (see favourites, boosts, replies, etc.)
- [ ] Sending replies
- [ ] Support polls
- [ ] Companion client for authentication

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Elleo"><img src="https://avatars.githubusercontent.com/u/59350?v=4?s=100" width="100px;" alt="Mike Sheldon"/><br /><sub><b>Mike Sheldon</b></sub></a><br /><a href="https://github.com/Elleo/baby_elephant/commits?author=Elleo" title="Code">💻</a> <a href="#design-Elleo" title="Design">🎨</a> <a href="#ideas-Elleo" title="Ideas, Planning, & Feedback">🤔</a> <a href="#platform-Elleo" title="Packaging/porting to new platform">📦</a> <a href="#projectManagement-Elleo" title="Project Management">📆</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://kyleharrington.com"><img src="https://avatars.githubusercontent.com/u/400105?v=4?s=100" width="100px;" alt="Kyle I S Harrington"/><br /><sub><b>Kyle I S Harrington</b></sub></a><br /><a href="https://github.com/Elleo/baby_elephant/commits?author=kephale" title="Code">💻</a> <a href="#ideas-kephale" title="Ideas, Planning, & Feedback">🤔</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
