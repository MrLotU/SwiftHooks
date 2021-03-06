import NIO
import struct Dispatch.DispatchTime
import Logging
import Metrics

extension Userable {
    var prefix: String {
        return mention + " "
    }
}

extension SwiftHooks {
    func handleMessage(_ message: Messageable, from h: _Hook, on eventLoop: EventLoop) {
        let p: String?
        switch self.config.commands.prefix {
        case .mention: p = h.user?.prefix
        case .string(let s): p = s
        }
        guard let prefix = p, config.commands.enabled, message.content.starts(with: prefix) else { return }
        let foundCommands = self.findCommands(for: message, withPrefix: prefix)
        
        foundCommands.forEach { (command) in
            guard command.hookWhitelist.isEmpty || command.hookWhitelist.contains(h.id) else { return }
            let event = CommandEvent(hooks: self, cmd: command, msg: message, prefix: prefix, for: h, on: eventLoop)
            EventLoopFuture<Bool>.whenAllSucceed(command.permissionChecks.map({ check in
                check.check(message.gAuthor, canUse: command, on: event)
            }), on: eventLoop)
            .flatMapErrorThrowing { e in
                event.logger.error("\(e)")
                return [false]
            }
            .map { cs -> Void in
                guard cs.allSatisfy({ bool in bool }) else {
                    return event.message.error(CommandError.InvalidPermissions, on: command)
                }
                
                event.logger.debug("Invoking command")
                event.logger.trace("Full message: \(message.content)")
                let timer = Timer(label: "command_duration", dimensions: [("command", command.fullTrigger)])
                let start = DispatchTime.now().uptimeNanoseconds
                command.invoke(on: event)
                    .flatMapErrorThrowing({ (e) in
                        event.message.error(e, on: command)
                        throw e
                    })
                    .whenComplete { result in
                        let delta = DispatchTime.now().uptimeNanoseconds - start
                        timer.recordNanoseconds(delta)
                        switch result {
                        case .success(_):
                            event.logger.debug("Command succesfully invoked.")
                            Counter(label: "command_finish", dimensions: [("command", command.fullTrigger), ("status", "success")]).increment()
                        case .failure(let e):
                            event.logger.error("\(e.localizedDescription)")
                            Counter(label: "command_finish", dimensions: [("command", command.fullTrigger), ("status", "failure")]).increment()
                        }
                }
            }
            .whenComplete { _ in }
        }
    }
    
    func findCommands(for message: Messageable, withPrefix prefix: String) -> [_ExecutableCommand] {
        return self.commands.compactMap { return message.content.starts(with: prefix + $0.fullTrigger) ? $0 : nil }
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
    /// EventLoop this Command runs on.
    public let eventLoop: EventLoop
    
    /// Create a new `CommandEvent`
    ///
    /// - parameters:
    ///     - hooks: `SwiftHooks` instance dispatching this command.
    ///     - cmd: Command this event is wrapping.
    ///     - msg: Message that executed the command.
    ///     - h: `_Hook` that originally dispatched this command.
    public init(hooks: SwiftHooks, cmd: _ExecutableCommand, msg: Messageable, prefix: String, for h: _Hook, on loop: EventLoop) {
        self.logger = Logger(label: "SwiftHooks.Command")
        self.hooks = hooks
        self.user = msg.gAuthor
        self.message = msg
        let prefixEnd = msg.content.index(msg.content.startIndex, offsetBy: prefix.count)
        let content = msg.content.replacingCharacters(in: msg.content.startIndex..<prefixEnd, with: "")
        var comps = content.split(separator: " ")
        let hasGroup = cmd.group != nil
        var name = "\(comps.removeFirst())"
        if hasGroup {
            name += " \(comps.removeFirst())"
        }
        self.name = name
        self.args = comps.map(String.init)
        self.hook = h
        self.eventLoop = loop
        self.logger[metadataKey: "command"] = "\(cmd.fullTrigger)"
    }
}
