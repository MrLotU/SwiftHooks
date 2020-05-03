public protocol _ExecutableCommand: Commands {
    var help: String { get }
    var name: String { get }
    var group: String? { get }
    var alias: [String] { get }
    var hookWhitelist: [HookID] { get }
    var permissionChecks: [CommandPermissionChecker] { get }
    var readableArguments: String? { get }
    var fullTrigger: String { get }
    
    func validate() throws
    func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws
}

public protocol ExecutableCommand: _ExecutableCommand {
    associatedtype Execute
    var closure: Execute { get }
    
    func copyWith(name: String, group: String?, alias: [String], hookWhitelist: [HookID], permissionChecks: [CommandPermissionChecker], closure: Execute) -> Self
}

public extension ExecutableCommand {
    var readableArguments: String? { return nil }
    var trigger: String { name }
    
    var help: String {
        [group, name, readableArguments].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var fullTrigger: String {
        [group, trigger].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func onHook(_ hook: HookID) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist + hook, permissionChecks: permissionChecks, closure: closure)
    }
    
    func alias(_ string: String) -> Self {
        return self.copyWith(name: name, group: group, alias: alias + string, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure)
    }
    
    func check(_ c: CommandPermissionChecker) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks + c, closure: closure)
    }
    
    func group(_ group: String) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: closure)
    }
    
    func execute(_ c: Execute) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, hookWhitelist: hookWhitelist, permissionChecks: permissionChecks, closure: c)
    }

    func executables() -> [_ExecutableCommand] {
        return [self]
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
