public protocol IDable: Codable {
    func asString() -> String?
    func asInt() -> Int?
}

extension String: IDable {
    public func asString() -> String? {
        return self
    }
    public func asInt() -> Int? {
        return Int(self)
    }
}
