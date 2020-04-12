public protocol Commands {
    func executables() -> [_ExecutableCommand]
    
    func group(_ group: String) -> Self
}

public struct NoCommands: Commands {
    public func executables() -> [_ExecutableCommand] {
        return []
    }
    
    public func group(_ group: String) -> NoCommands {
        return self
    }
}

public struct Group: Commands {
    let commands: Commands
    
    public let name: String?
    
    public func executables() -> [_ExecutableCommand] {
        return commands.executables()
    }
    
    public func group(_ group: String) -> Group {
        return self
    }
    
    private init(_ name: String?, commands: Commands) {
        self.name = name
        if let n = name {
            self.commands = commands.group(n)
        } else {
            self.commands = commands
        }
    }

    public init(_ name: String? = nil, @CommandBuilder commands: () -> Commands) {
        self.name = name
        if let n = name {
            self.commands = commands().group(n)
        } else {
            self.commands = commands()
        }
    }
}
