/// Base plugin type. Used for array storage.
public protocol _Plugin { }

/// A `Plugin` contains `Commands` and `Listeners`, usually grouped by purpose and can be registered to the main `SwiftHooks` class.
///
///     class MyPlugin: Plugin {
///         var commands: some Commands {
///             Command("ping")
///                 .execute { (hooks, event) in
///                     event.message.reply("Pong!")
///             }
///         }
///
///         var listeners: some EventListeners {
///             Listener(Global.messageCreate) { event, message in
///                 print("Message: \(message.content)")
///             }
///         }
///     }
public protocol Plugin: _Plugin {
    associatedtype C: Commands
    associatedtype L: EventListeners
    
    /// Commands in this `Plugin`. Use `Group` to group commands together.
    var commands: Self.C { get }
    /// Listeners in this `Plugin`. Use `Listeners` to group listeners together.
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
