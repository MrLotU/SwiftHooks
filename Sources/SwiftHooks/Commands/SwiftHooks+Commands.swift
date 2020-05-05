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

/// Errors thrown from command invocations or pre-checking.
public enum CommandError: Error {
    /// User executing this command does not have the required permissions.
    ///
    /// Thrown from `CommandPermissionChecker`
    case InvalidPermissions
    /// Development error. Consuming arguments should always appear last in the argument chain.
    ///
    /// Thrown at `SwiftHooks.register(_ plugin:)` time.
    case ConsumingArgumentIsNotLast(String)
    /// Invalid argument passed on command invocation.
    ///
    /// Thrown from argument decoding.
    case UnableToConvertArgument(String, String)
    /// Invalid or too few arguments passed on command invocation.
    ///
    /// Thrown from argument decoding
    case ArgumentNotFound(String)
    
    /// Retrieve the localized description for this error.
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

/// Event passed in to a command closure containing required data.
public struct CommandEvent {
    /// Refference to `SwiftHooks` instance dispatching this command.
    public let hooks: SwiftHooks
    /// User that executed the command. Can be downcast to backend specific type.
    public let user: Userable
    /// String arguments passed in to the command. All space separated strings after the commands trigger.
    public let args: [String]
    /// Message that executed the command.
    public let message: Messageable
    /// Full trigger of the command. Either name or name and group.
    public let name: String
    /// Hook that originally dispatched this command. Can be downcast to backend specific type.
    public let hook: _Hook
    /// Command specific logger. Has command trigger set as command metadata by default.
    public private(set) var logger: Logger
    
    /// Create a new `CommandEvent`
    ///
    /// - parameters:
    ///     - hooks: `SwiftHooks` instance dispatching this command.
    ///     - cmd: Command this event is wrapping.
    ///     - msg: Message that executed the command.
    ///     - h: `_Hook` that originally dispatched this command.
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
