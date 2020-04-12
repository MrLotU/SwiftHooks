public protocol _Plugin { }

public protocol Plugin: _Plugin {
    associatedtype C: Commands
    associatedtype L: EventListeners
    
    var commands: Self.C { get }
    var listeners: Self.L { get }
}

public extension Plugin {
    var commands: some Commands {
        NoCommands()
    }
    
    var listeners: some EventListeners {
        NoListeners()
    }
}
