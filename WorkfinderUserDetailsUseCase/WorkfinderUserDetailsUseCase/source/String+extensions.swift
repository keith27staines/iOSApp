import Foundation

extension String {
    func isEmail() -> Bool {
        let regexOptions: NSRegularExpression.Options? = NSRegularExpression.Options.caseInsensitive
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: "^[\\w!#$%&'*+\\-/=?\\^_`{|}~]+(\\.[\\w!#$%&'*+\\-/=?\\^_`{|}~]+)*@((([\\w]+([\\-\\w])*\\.)+[a-zA-Z]{2,4})|(([0-9]{1,3}\\.){3}[0-9]{1,3}))$", options: regexOptions!)
        } catch _ as NSError {
            regex = nil
        }
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
}

