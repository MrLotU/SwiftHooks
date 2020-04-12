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
    let _commands: Commands
    
    public let name: String?
    
    public func executables() -> [_ExecutableCommand] {
        return _commands.executables()
    }
    
    public func group(_ group: String) -> Group {
        if let n = name {
            return .init("\(n) \(group)", commands: _commands)
        } else {
            return .init(group, commands: _commands)
        }
    }
    
    private init(_ name: String?, commands: Commands) {
        self.name = name
        if let n = name {
            self._commands = commands.group(n)
        } else {
            self._commands = commands
        }
    }

    public init(_ name: String? = nil, @CommandBuilder commands: () -> Commands) {
        self.name = name
        if let n = name {
            self._commands = commands().group(n)
        } else {
            self._commands = commands()
        }
        print(type(of: _commands))
    }
}
