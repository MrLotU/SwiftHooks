public protocol _ExecutableCommand: Commands {
    var help: String { get }
    var name: String { get }
    var group: String? { get }
    var alias: [String] { get }
    var permissionChecks: [CommandPermissionChecker] { get }
    var readableArguments: String? { get }
    var fullTrigger: String { get }
    
    func invoke(on event: CommandEvent, using hooks: SwiftHooks) throws
}

public protocol ExecutableCommand: _ExecutableCommand {
    associatedtype Execute
    var closure: Execute { get }
    
    func copyWith(name: String, group: String?, alias: [String], permissionChecks: [CommandPermissionChecker], closure: Execute) -> Self
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
    
    func alias(_ string: String) -> Self {
        return self.copyWith(name: name, group: group, alias: alias + string, permissionChecks: permissionChecks, closure: closure)
    }
    
    func check(_ c: CommandPermissionChecker) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, permissionChecks: permissionChecks + c, closure: closure)
    }
    
    func group(_ group: String) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: closure)
    }
    
    func execute(_ c: Execute) -> Self {
        return self.copyWith(name: name, group: group, alias: alias, permissionChecks: permissionChecks, closure: c)
    }

    func executables() -> [_ExecutableCommand] {
        return [self]
    }
}

internal extension Array {
    static func + (_ lhs: Self, _ rhs: Element) -> Self {
        var new = lhs
        new.append(rhs)
        return new
    }
}
