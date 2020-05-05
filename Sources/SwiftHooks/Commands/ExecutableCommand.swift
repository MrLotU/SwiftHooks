/// Base `ExecutableCommand`
public protocol _ExecutableCommand: Commands {
    /// Help description of the command. Used to explain usage to users.
    var help: String { get }
    /// Name of the command. Primary trigger.
    var name: String { get }
    /// Optional group of the command. If set primary triggre will become `group name`
    var group: String? { get }
    /// List of aliases. Secondary triggers for command.
    var alias: [String] { get }
    /// Hook whitelist. Commands will only get executed if message is sent from hooks in this list.
    ///
    /// Leave empty to whitelist all hooks.
    var hookWhitelist: [HookID] { get }
    /// Permission checks to run before command logic is executed.
    var permissionChecks: [CommandPermissionChecker] { get }
    /// Arguments for this command to be used in `help`.
    var readableArguments: String? { get }
    /// Combination of `name` or `alias` and `group`
    var fullTrigger: String { get }
    
    /// Validates if a command is valid. See also: `CommandError`
    func validate() throws
    /// Invokes a command on given event.
    func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws
}

/// Base `ExecutableCommand`
public protocol ExecutableCommand: _ExecutableCommand {
    /// Closure type this command will execute.
    associatedtype Execute
    /// Closure to execute when command is invoked.
    var closure: Execute { get }
    
    /// Used for FunctionBuilder Copy On Write.
    func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: Execute) -> Self
}

public extension ExecutableCommand {
    /// Human readable string of arguments required for this command.
    ///
    ///     command.readableArguments // "<a:Int> <b:Int> [c:String]"
    var readableArguments: String? { return nil }
    
    /// Trigger of the command.
    ///
    /// Synonym for `ExecutableCommand.name`
    var trigger: String { name }
    
    /// Human readable help string explaining command usage.
    var help: String {
        [group, name, readableArguments].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var fullTrigger: String {
        [group, trigger].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Adds a hook to the whitelist.
    ///
    /// See `hookWhitelist`
    ///
    /// - parameters:
    ///     - hook: HookID to whitelist.
    func onHook(_ hook: HookID) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist + hook, permissionChecks: permissionChecks, closure: closure)
    }
    
    /// Adds an alias to this command.
    ///
    /// See `alias`
    ///
    /// - parameters:
    ///     - string: Alias to add.
    func alias(_ string: String) -> Self {
        return self.copyWith(name: name, group: group, alias: alias + string, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure)
    }
    
    /// Adds a check to this command.
    ///
    /// See `permissionChecks`
    ///
    /// - parameters:
    ///     - c: Check to add.
    func check(_ c: CommandPermissionChecker) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks + c, closure: closure)
    }
    
    /// Sets the group of this command.
    ///
    /// See `group`
    ///
    /// - parameters:
    ///     - group: Group to add.
    func group(_ group: String) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure)
    }
    
    /// Sets the closure of this command.
    ///
    /// See `closure`
    ///
    /// - parameters:
    ///      - c: Closure to execute
    func execute(_ c: Execute) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: c)
    }

    func executables() -> [_ExecutableCommand] {
        return alias.reduce(into: [self]) {
            $0.append(self.copyWith(name: $1, group: group, alias: [], hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure))
        }
    }
}

extension Array where Element == _ExecutableCommand {
    func validate() throws {
        try self.forEach { try $0.validate() }
    }
}

internal extension Array {
    static func + (_ lhs: Self, _ rhs: Element) -> Self {
        var new = lhs
        new.append(rhs)
        return new
    }
}
