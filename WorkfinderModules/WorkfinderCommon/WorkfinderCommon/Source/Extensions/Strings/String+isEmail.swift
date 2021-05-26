
//let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
//let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
//let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
//let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

let __emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)

let __ukPostcodeRegex = "GIR[ ]?0AA|((AB|AL|B|BA|BB|BD|BH|BL|BN|BR|BS|BT|CA|CB|CF|CH|CM|CO|CR|CT|CV|CW|DA|DD|DE|DG|DH|DL|DN|DT|DY|E|EC|EH|EN|EX|FK|FY|G|GL|GY|GU|HA|HD|HG|HP|HR|HS|HU|HX|IG|IM|IP|IV|JE|KA|KT|KW|KY|L|LA|LD|LE|LL|LN|LS|LU|M|ME|MK|ML|N|NE|NG|NN|NP|NR|NW|OL|OX|PA|PE|PH|PL|PO|PR|RG|RH|RM|S|SA|SE|SG|SK|SL|SM|SN|SO|SP|SR|SS|ST|SW|SY|TA|TD|TF|TN|TQ|TR|TS|TW|UB|W|WA|WC|WD|WF|WN|WR|WS|WV|YO|ZE)(\\d[\\dA-Z]?[ ]?\\d[ABD-HJLN-UW-Z]{2}))|BFPO[ ]?\\d{1,4}"

let __ukPostcodePredicate = NSPredicate(format: "SELF MATCHES %@", __ukPostcodeRegex)


public extension String {
    func isEmail() -> Bool {
        return __emailPredicate.evaluate(with: self)
    }
}

public extension String {
    func isUKPostcode() -> Bool {
        __ukPostcodePredicate.evaluate(with: self)
    }
}

public extension String {
    func isPhoneNumber() -> Bool {
        let trimmedSelf = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let detector: NSDataDetector
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        } catch { return false }
        
        let matches = detector.matches(in: trimmedSelf, options: [], range: NSMakeRange(0, trimmedSelf.count))
        guard let res = matches.first else { return false }
        return res.resultType == .phoneNumber &&
            res.range.location == 0 &&
            res.range.length == trimmedSelf.count
    }
}

public extension String {
    func isValidFullname() -> Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).count > 2
    }
    
    var isValidNameComponent: Bool {
        return true
    }
}
