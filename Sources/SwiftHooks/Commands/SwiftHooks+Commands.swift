import Logging
import Metrics

extension SwiftHooks {
    func handleMessage(_ message: Messageable, from h: _Hook) {
        guard config.commands.enabled, message.content.starts(with: self.config.commands.prefix) else { return }
        let foundCommands = self.findCommands(for: message)
        
        foundCommands.forEach { (command) in
            guard command.hookWhitelist.isEmpty || command.hookWhitelist.contains(h.id) else { return }
            let event = CommandEvent(hooks: self, cmd: command, msg: message, for: h)
            
            do {
                event.logger.debug("Invoking command")
                event.logger.trace("Full message: \(message.content)")
                try Timer.measure(label: "command_duration", dimensions: [("command", command.fullTrigger)]) {
                    try command.invoke(on: event, using: self)
                }
                event.logger.debug("Command succesfully invoked.")
            } catch let e {
                event.message.error(e, on: command)
                event.logger.error("\(e.localizedDescription)")
                Counter(label: "command_failure", dimensions: [("command", command.fullTrigger)]).increment()
            }
            Counter(label: "command_success", dimensions: [("command", command.fullTrigger)]).increment()
        }
    }
    
    func findCommands(for message: Messageable) -> [_ExecutableCommand] {
        return self.commands.compactMap { return message.content.starts(with: self.config.commands.prefix + $0.fullTrigger) ? $0 : nil }
    }
}

public enum CommandError: Error {
    case InvalidPermissions
    case ConsumingArgumentIsNotLast(String)
    case UnableToConvertArgument(String, String)
    case ArgumentNotFound(String)
    
    public var localizedDescription: String {
         switch self {
         case .ArgumentNotFound(let arg):
            return "Missing argument: \(arg)"
         case .InvalidPermissions:
            return "Invalid permissions!"
         case .UnableToConvertArgument(let arg, let type):
            return "Error converting \(arg) to \(type)"
         case .ConsumingArgumentIsNotLast(let arg):
            return "Consuming argument \(arg) is not the last one in the argument chain."
        }
    }
}

public struct CommandEvent {
    public let hooks: SwiftHooks
    public let user: Userable
    public let args: [String]
    public let message: Messageable
    public let name: String
    public let hook: _Hook
    public private(set) var logger: Logger
    
    public init(hooks: SwiftHooks, cmd: _ExecutableCommand, msg: Messageable, for h: _Hook) {
        self.logger = Logger(label: "SwiftHooks.Command")
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
        self.logger[metadataKey: "command"] = "\(cmd.fullTrigger)"
    }
}
