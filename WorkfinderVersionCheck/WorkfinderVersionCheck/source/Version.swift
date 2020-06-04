

struct Version: Comparable {
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major > rhs.major { return false }
        if lhs.major < rhs.major { return true }
        if lhs.minor > rhs.minor { return false }
        if lhs.minor < rhs.minor { return true }
        if lhs.revision > rhs.revision { return false }
        if lhs.revision < rhs.revision { return true }
        return false
    }
    
    var major: Int
    var minor: Int
    var revision: Int
    
    init?(string: String?) {
        guard let string = string else { return nil }
        var components = string.split(separator: ".")
        while components.count < 3 { components.append("0") }
        guard
            let major = Int(components[0]),
            let minor = Int(components[1]),
            let revision = Int(components[2])
            else { return nil }
        self.major = major
        self.minor = minor
        self.revision = revision
    }
    
    init(major: Int, minor: Int, revision: Int) {
        self.major = major
        self.minor = minor
        self.revision = revision
    }
}
