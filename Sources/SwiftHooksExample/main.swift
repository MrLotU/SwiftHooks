import SwiftHooksDiscord
import Foundation

let swiftHooks = SwiftHooks()

try swiftHooks.hook(DiscordHook.self, DiscordHookOptions(token: ""))

print(swiftHooks.globalListeners)
print(swiftHooks.hooks)

class MyPlugin: Plugin {
    
    @Command("ping")
    var closure = { (hooks, event, command) in
        print("Ping succeed!")
    }
    
    @Listener(DiscordEvent.guildCreate)
    var guildListener = { guild in
        print("Other guild thing \(guild.name)")
    }
}

swiftHooks.register(MyPlugin())

print(swiftHooks.commands)
print(swiftHooks.globalListeners)

struct TempPayload: Payload {
    func getData<T>(_ type: T.Type, from: Data) -> T? {
        return Guild("Guild") as? T
    }
}

struct MessagePayload: Payload {
    struct C: Channelable {
        func send(_ msg: String) { }
        
        var mention: String = ""
    }
    struct U: Userable {
        var id: IDable {
            return _id
        }
        let _id: String = "abc"
        
        var mention: String = ""
    }
    struct M: Messageable {
        var channel: Channelable {
            return c
        }
        let c: C
        var content: String
        var author: Userable {
            return a
        }
        let a: U
        
        func reply(_ content: String) { }
        
        func edit(_ content: String) { }
        
        func delete() { }
    }
    func getData<T>(_ type: T.Type, from: Data) -> T? {
        return M(c: C(), content: "!ping", a: U()) as? T
    }
}

let discordHook = swiftHooks.hooks.compactMap {
    $0 as? DiscordHook
}.first!

print(discordHook.discordListeners)

let event = DiscordEvent._guildCreate
let mEvent = GlobalEvent._messageCreate

discordHook.dispatchEvent(event, with: TempPayload(), raw: Data())
discordHook.dispatchEvent(mEvent, with: MessagePayload(), raw: Data())
