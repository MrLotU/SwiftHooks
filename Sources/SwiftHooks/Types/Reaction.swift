/// Reactions that can be added to messages.
/// Usually in the form of emoji, either custom or Unicode.
public protocol Reactionable: PayloadType {
    /// User that added the reaction
    var gUser: Userable { get }
    /// Reaction representation as string
    ///
    /// Can be either Unicode or a custom format
    var content: String { get }
}
