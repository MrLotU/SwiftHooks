import SwiftHooksDiscord
import Foundation

let swiftHooks = SwiftHooks()

try swiftHooks.hook(DiscordHook.self, DiscordHookOptions(token: ""))

swiftHooks.listen(for: Event.messageCreate) { message in
    print("Message listener: " + message.content)
}

swiftHooks.listen(for: Event.guildCreate) { (guild) in
    print("Guild thing \(guild.name)")
}

try swiftHooks.command("test") { (hooks, event, command) in
    event.message.reply("Test successful!")
    print("Triggering test command!")
}

print(swiftHooks.globalListeners)
print(swiftHooks.hooks)

class MyPlugin: Plugin {
    
    @CCommand("ping")
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
        var id: IDable = "123"
        
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
        return M(channel: C(), content: "!ping", author: U()) as? T
    }
}

let discordHook = swiftHooks.hooks.compactMap {
    $0 as? DiscordHook
}.first!

print(discordHook.discordListeners)

let event = DiscordEvent._guildCreate
let mEvent = DiscordEvent._messageCreate

discordHook.dispatchEvent(event, with: TempPayload(), raw: Data())
discordHook.dispatchEvent(mEvent, with: MessagePayload(), raw: Data())
