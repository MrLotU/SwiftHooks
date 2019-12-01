import SwiftHooksDiscord
import Foundation
import Logging

let swiftHooks = SwiftHooks()

try swiftHooks.hook(DiscordHook.self, DiscordHookOptions(token: ""))

//print(swiftHooks.globalListeners)
//print(swiftHooks.hooks)

class MyPlugin: Plugin {
    
    @Command("ping")
    var closure = { (hooks, event, command) in
        print("Ping succeed!")
    }
    
    @Listener(DiscordEvent.guildCreate)
    var guildListener = { guild in
        print("Other guild thing \(guild.name)")
    }
    
    @Listener(DiscordEvent.messageCreate)
    var messageListener = { message in
        print("Discord: \(message.content)")
    }
    
    @GlobalListener(GlobalEvent.messageCreate)
    var globalMessageListener = { message in
        print("Global: \(message.content)")
    }
}

swiftHooks.register(MyPlugin())

//print(swiftHooks.commands)
//print(swiftHooks.globalListeners)

//swiftHooks.logger.logLevel = .trace

try swiftHooks.run()
