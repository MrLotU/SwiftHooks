extension SwiftHooks {
    func handleMessage(_ message: Messageable) {
        let foundCommands = self.findCommands(for: message)
        
        foundCommands.forEach { (command) in
            let event = CommandEvent(hooks: self, cmd: command, msg: message)
            
            do {
                try command.invoke(on: event, using: self)
            } catch CommandError.ArgumentNotFound(let arg) {
                event.message.reply("Missing argument \(arg)!")
            } catch CommandError.ArgumentCanNotConsume {
                event.message.reply("Too many arguments!")
            } catch CommandError.InvalidPermissions {
                event.message.reply("Invalid permissions!")
            } catch CommandError.UnableToConvertArgument(let arg, let type) {
                event.message.reply("Error converting \(arg) to \(type)")
            } catch {
                event.message.reply("Something went wrong!")
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func findCommands(for message: Messageable) -> [Command] {
        return self.commands.compactMap { return message.content.starts(with: "!" + $0.fullTrigger) ? $0 : nil }
    }
}

public enum CommandError: Error {
    case InvalidPermissions
    case ArgumentCanNotConsume
    case UnableToConvertArgument(String, String)
    case ArgumentNotFound(String)
    case CommandRedeclaration
}

public struct CommandEvent {
    public let hooks: SwiftHooks
    public let user: Userable
    public let args: [String]
    public let message: Messageable
    public let name: String
    
    public init(hooks: SwiftHooks, cmd: Command, msg: Messageable) {
        self.hooks = hooks
        self.user = msg.gAuthor
        self.message = msg
        var comps = msg.content.split(separator: " ")
        let hasGroup = cmd.group != nil
        var name = "\(comps.removeFirst())"
        if hasGroup {
            name += " \(comps.removeFirst())"
        }
        self.name = name
        self.args = comps.map(String.init)
    }
}
