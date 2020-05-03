import NIO

/// A generic message used in `GlobalEvent`s.
public protocol Messageable: PayloadType {
    /// Channel this message was sent in. Can be downcast to backend specific type.
    var gChannel: Channelable { get }
    /// Content of the message.
    var content: String { get }
    /// Author of the message. Can be downcast to the backend specific type.
    var gAuthor: Userable { get }
        
    /// Send a message back to the received message.
    ///
    ///     let message: Messageable = ... // !ping
    ///     mesasge.reply("Pong!")
    ///
    /// - parameters:
    ///     - content: Content to reply with.
    /// - returns: The created message.
    @discardableResult
    func reply(_ content: String) -> EventLoopFuture<Messageable>
    
    /// Update a message to new content.
    ///
    ///     let message: Messageable = ... // This message will self destruct.
    ///     message.edit("Self destruct complete.")
    ///
    /// - parameters:
    ///     - content: Content to update the message to.
    /// - returns: The updated message.
    @discardableResult
    func edit(_ content: String) -> EventLoopFuture<Messageable>
    
    /// Deletes the message.
    @discardableResult
    func delete() -> EventLoopFuture<Void>
    
    /// Sends an error that occured on a command.
    ///
    /// Override this to add custom formatting to error messages.
    /// A default implementation is supplied.
    ///
    /// - parameters:
    ///     - error: The error that occured. Usually a `CommandError`.
    ///     - command: The command that the error occured on.
    func error(_ error: Error, on command: _ExecutableCommand)
}

public extension Messageable {
    func error(_ error: Error, on command: _ExecutableCommand) {
        switch error {
        case CommandError.ArgumentNotFound(let arg):
            self.reply("Missing argument: \(arg)\nUsage: \(command.help)")
        case CommandError.InvalidPermissions:
           self.reply("Invalid permissions!\nUsage: \(command.help)")
        case CommandError.UnableToConvertArgument(let arg, let type):
           self.reply("Error converting \(arg) to \(type)\nUsage: \(command.help)")
        default:
           self.reply("Something went wrong!\nUsage: \(command.help)")
       }
    }
}
