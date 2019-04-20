import SwiftHooksDiscord
import Logging

//LoggingSystem.bootstrap()

let swiftHooks = SwiftHooks()

try swiftHooks.hook(DiscordHook.self, DiscordHookOptions(token: ""))

swiftHooks.listen(for: GlobalEvent.messageCreate) { message in
    print(message.content)
}

swiftHooks.listen(for: DiscordEvent.guildCreate) { (guild) in
    print(guild.name)
}

print(swiftHooks.globalListeners)
print(swiftHooks.hooks)
