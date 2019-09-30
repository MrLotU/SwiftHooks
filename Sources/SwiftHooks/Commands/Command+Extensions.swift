public extension Command {
//    convenience init(wrappedValue c: @escaping CommandClosure, _ name: String) {
//        self.init(wrappedValue: c, name, [], group: nil, aliases: [], permChecks: [], userInfo: [:])
//    }
//    
//    convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument]) {
//        self.init(wrappedValue: c, name, args, group: nil, aliases: [], permChecks: [], userInfo: [:])
//    }
//
//    convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?) {
//        self.init(wrappedValue: c, name, args, group: group, aliases: [], permChecks: [], userInfo: [:])
//    }
//
//    convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?, aliases: [String]) {
//        self.init(wrappedValue: c, name, args, group: nil, aliases: aliases, permChecks: [], userInfo: [:])
//    }
//
//    convenience init(wrappedValue c: @escaping CommandClosure, _ name: String, _ args: [CommandArgument], group: String?, aliases: [String], permChecks: [CommandPermissionChecker]) {
//        self.init(wrappedValue: c, name, args, group: nil, aliases: aliases, permChecks: permChecks, userInfo: [:])
//    }
}

extension Command {
    public var description: String {
        return [self.group, self.trigger, self.arguments.compactMap(String.init).joined(separator: " ")].compactMap { $0 }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }
    
    var trigger: String {
        return self.name
    }
    
    var fullTrigger: String {
        return [self.group, self.trigger].compactMap { $0 }.joined(separator: " ")
    }
}
