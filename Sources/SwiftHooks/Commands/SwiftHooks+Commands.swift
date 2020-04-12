fileprivate extension Messageable {
    func error(_ message: String) {
        let msg = "<:redtick:502702620595453952> " + message
        self.reply(msg)
    }
}

extension SwiftHooks {
    func handleMessage(_ message: Messageable) {
        let foundCommands = self.findCommands(for: message)
        
        foundCommands.forEach { (command) in
            let event = CommandEvent(hooks: self, cmd: command, msg: message)
            
            do {
                try command.invoke(on: event, using: self)
            } catch CommandError.ArgumentNotFound(let arg) {
                event.message.error("Missing argument: \(arg)")
            } catch CommandError.ArgumentCanNotConsume {
                event.message.error("Too many arguments!")
            } catch CommandError.InvalidPermissions {
                event.message.error("Invalid permissions!")
            } catch CommandError.UnableToConvertArgument(let arg, let type) {
                event.message.error("Error converting `\(arg)` to `\(type)`")
            } catch {
                event.message.error("Something went wrong!")
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    func findCommands(for message: Messageable) -> [_ExecutableCommand] {
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
    
    public init(hooks: SwiftHooks, cmd: _ExecutableCommand, msg: Messageable) {
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
