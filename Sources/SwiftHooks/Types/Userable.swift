public protocol Userable: Codable {
    func asBaseUser() -> BaseUser
}

public struct BaseUser {
    var id: IDable
    var mention: String
    
    public init(id: IDable, mention: String) {
        self.id = id
        self.mention = mention
    }
}
