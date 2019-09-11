public typealias CommandClosure = (SwiftHooks, CommandEvent, Command) throws -> Void

public struct Command {
    public let trigger: String
    public let arguments: [CommandArgument]
    public let aliases: [String]
    public let group: String?
    public let permissionChecks: [CommandPermissionChecker]
    public let userInfo: [String: Any]
    public let execute: CommandClosure
    
    public func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws {
        for check in permissionChecks {
            if !check.check(event.user, canUse: self, on: event) {
                throw CommandError.InvalidPermissions
            }
        }
        try execute(hooks, event, self)
    }
}

extension Command: CustomStringConvertible {
    public var description: String {
        return [self.group, self.trigger, self.arguments.compactMap(String.init).joined(separator: " ")].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }
    
    var fullTrigger: String {
        return [self.group, self.trigger].compactMap { $0 }.joined(separator: " ")
    }
}

enum CommandError: Error {
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
        self.user = msg.author
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
