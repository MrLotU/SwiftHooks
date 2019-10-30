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
    
    @Listener(GlobalEvent.messageCreate)
    var messageListener = { message in
        print(message.content)
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
        
        func asBaseChannel() -> BaseChannel {
            BaseChannel(mention: mention)
        }
    }
    struct U: Userable {
        var id: IDable {
            return "abc"
        }
        
        var mention: String = ""
        func asBaseUser() -> BaseUser {
            BaseUser(id: id, mention: mention)
        }
    }
    struct M: Messageable {
        static var concreteType: Decodable.Type = M.self
        var channel: C
        var content: String
        var author: U
        
        func reply(_ content: String) { }
        
        func edit(_ content: String) { }
        
        func delete() { }
        
        func asBaseMessage() -> BaseMessage {
            return BaseMessage(channel: channel.asBaseChannel(), content: self.content, author: author.asBaseUser())
        }
    }
    func getData<T>(_ type: T.Type, from: Data) -> T? {
        return M(channel: C(), content: "!ping", author: U()).asBaseMessage() as? T
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
