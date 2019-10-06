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
