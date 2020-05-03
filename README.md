<p align="center">
    <img src="https://user-images.githubusercontent.com/18392003/80610769-08499e00-8a3a-11ea-830e-ad1ab4552164.png"
    width=80%
    alt="SwiftHooks">
</p>

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://github.com/MrLotU/SwiftHooks/actions">
        <img src="https://github.com/MrLotU/SwiftHooks/workflows/test/badge.svg" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.2-brightgreen.svg" alt="Swift 5.2">
    </a>
    <a href="https://twitter.com/LotUDev">
        <img src="https://img.shields.io/badge/twitter-LotUDev-5AA9E7.svg" alt="Twitter">
    </a>
</p>

<br>

SwiftHooks is a modular event-driven programming framework for Swift, that allows you to listen for both generic and specific events, with a builtin command system. All with a SwiftUI inspired API design.

SwiftHooks is built on a couple of core concepts/types:
- Hooks: A `Hook` within SwiftHooks is a backend implementation emitting events. For example [Discord](https://github.com/MrLotU/SwiftHooksDiscord), Slack or GitHub
- SwiftHooks: This is the main class that acts as a traffic control and connection hub of sorts. `Hooks` and `Plugins` are both connected to the main `SwiftHooks` class.
- Plugins: A `Plugin` contains `Commands` and `Listeners`, usually grouped by purpose and can be registered to the main `SwiftHooks` class.
- Commands: A `Command` is a specific function to be executed on specific message events. For example `/ping`.
- Listeners: A `Listener` defines a callback for certain events. For example `messageCreate` or `messageUpdate`.

---

Hooks are simple in architecture. They need the ability to:
- Boot and connect to their specific backend.
- Have listeners attached to them.
- Emit events back to the main `SwiftHooks` instance.

The emitting back to `SwiftHooks` is important for so called "Global" events. Global events are generic events that can be emitted by multiple backends. A great example of this is `messageCreate`, supported by Discord, Slack, GitHub and loads more. This allows you to create one listener that acts on multiple platforms.

# Installation

SwiftHooks is available through SPM. To include it in your project add the following dependency to your `Package.swift`:

```swift
    .package(url: "https://github.com/MrLotU/SwiftHooks.git", from: "1.0.0-alpha")
```
# Usage

For a full example see the [Example repository](https://github.com/MrLotU/SwiftHooksExample).

To get started create an instance of `SwiftHooks`.
```swift
let swiftHooks = SwiftHooks()
```

After that, attach your first hook:
```swift
swiftHooks.hook(DiscordHook.self, DiscordHookOptions(token: "discord_token"))
```

This will set up your system to connect to Discord, and stream events to your program.

To add listeners and commands, create a pluign:
```swift
class MyPlugin: Plugin {
    
    var commands: some Commands {
        Group {
            Command("echo")
                .arg(String?.self, named: "content")
                .execute { (hooks, event, content) in
                    event.message.reply(content ?? "No content provided")    
            }

            Command("ping")
                .execute { (hooks, event) in
                    event.message.reply("Pong!")    
            }
        }
    }

    var listeners: some EventListeners {
        Listeners {
            Listener(Discord.guildCreate) { event, guild in
                print("""
                    Succesfully loaded \(guild.name).
                    It has \(guild.members.count) members and \(guild.channels.count) channels.
                    """)
            }

            GlobalListener(Global.messageCreate) { event, message in
                print("Message: \(message.content)")
            }
        }
    }
}
```

For a more complex Plugin example check the [Example repository](https://github.com/MrLotU/SwiftHooksExample).

After your plugin is created, register it to the system and run.
```swift
try swiftHooks.register(MyPlugin())

try swiftHooks.run()
```
Calling `swiftHooks.run()` will block the main thread and run forever.

# Contributing

All contributions are most welcome!

If you think of some cool new feature that should be included, please [create an issue](https://github.com/MrLotU/SwiftHooks/issues/new/choose). Or, if you want to implement it yourself, [fork this repo](https://github.com/MrLotU/SwiftHooks/fork) and submit a PR!

If you find a bug or have issues, please [create an issue](https://github.com/MrLotU/SwiftHooks/issues/new/choose) explaining your problems, and include as much information as possible, so it's easier to reproduce & investigate (Framework, OS and Swift version, terminal output, etc.)
