extension SwiftHooks {
    func handleMessage(_ message: Messageable, from h: _Hook) {
        guard config.commands.enabled else { return }
        let foundCommands = self.findCommands(for: message)
        
        foundCommands.forEach { (command) in
            let event = CommandEvent(hooks: self, cmd: command, msg: message, for: h)
            
            do {
                try command.invoke(on: event, using: self)
            } catch let e {
                event.message.error(e, on: command)
                self.logger.error("\(e.localizedDescription)")
            }
        }
    }
    
    func findCommands(for message: Messageable) -> [_ExecutableCommand] {
        return self.commands.compactMap { return message.content.starts(with: self.config.commands.prefix + $0.fullTrigger) ? $0 : nil }
    }
}

public enum CommandError: Error {
    case InvalidPermissions
    case ConsumingArgumentIsNotLast(String)
    case ArgumentCanNotConsume(String)
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
    public let hook: _Hook
    
    public init(hooks: SwiftHooks, cmd: _ExecutableCommand, msg: Messageable, for h: _Hook) {
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
        self.hook = h
    }
}
