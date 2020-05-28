
//let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
//let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
//let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
//let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

let __emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

public extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
}
