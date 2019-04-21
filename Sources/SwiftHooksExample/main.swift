import SwiftHooksDiscord
import Foundation
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

struct TempPayload: Payload {
    func getData<T>(_ type: T.Type, from: Data) -> T? {
        return Guild("test") as! T
    }
}

struct MessagePayload: Payload {
    struct C: Channelable {
        func send(_ msg: String) { }
        
        var mention: String = ""
    }
    struct U: Userable {
        struct StringID: IDable {
            func asInt() -> Int? {
                return nil
            }
            func asString() -> String? {
                return "123"
            }
        }
        var id: IDable = StringID()
        
        var mention: String = ""
    }
    struct M: Messageable {
        var channel: Channelable
        var content: String
        var author: Userable
        
        func reply(_ content: String) { }
        
        func edit(_ content: String) { }
        
        func delete() { }
    }
    func getData<T>(_ type: T.Type, from: Data) -> T? {
        return M(channel: C(), content: "Some cool content! Woah!", author: U()) as! T
    }
}

let discordHook = swiftHooks.hooks.compactMap {
    $0 as? DiscordHook
    }.first!

let event = DiscordEvent._guildCreate
let mEvent = GlobalEvent._messageCreate

discordHook.dispatchEvent(event, with: TempPayload(), raw: Data())
discordHook.dispatchEvent(mEvent, with: MessagePayload(), raw: Data())
