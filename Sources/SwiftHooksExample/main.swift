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
    
    @Listener(DiscordEvent.messageCreate)
    var messageListener = { message in
        print(message.content)
    }
    
//    @Listener(M)
}

swiftHooks.register(MyPlugin())

print(swiftHooks.commands)
print(swiftHooks.globalListeners)

//struct TempPayload: Payload {
//    func getData<T>(_ type: T.Type, from: Data) -> T? {
//        return Guild("Guild") as? T
//    }
//}

struct MessagePayload {
    struct C: Channelable {
        func send(_ msg: String) { }
        
        var mention: String = ""
    }
    struct U: Userable {
        var id: IDable {
            return "abc"
        }
        
        var mention: String = ""
    }
    struct M: Messageable {
        static var concreteType: Decodable.Type = M.self
        var _channel: C
        var channel: Channelable { _channel }
        var content: String
        var _author: U
        var author: Userable { _author }
        
        func reply(_ content: String) { }
        
        func edit(_ content: String) { }
        
        func delete() { }
        
        public init?(_ data: Data) {
            self._author = U()
            self.content = "!ping"
            self._channel = C()
        }
    }
}

let discordHook = swiftHooks.hooks.compactMap {
    $0 as? DiscordHook
}.first!

print(discordHook.discordListeners)

let event = DiscordEvent._guildCreate
let mEvent = DiscordEvent._messageCreate
//let mEvent = GlobalEvent._messageCreate

discordHook.dispatchEvent(event, with: Data())
discordHook.dispatchEvent(mEvent, with: Data())
