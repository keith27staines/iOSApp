
class PhoneNumberValidator {
    
    init() {}
    
    func validate(number: String) -> Bool {
        let detector: NSDataDetector
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        } catch { return false }
        
        let matches = detector.matches(in: number, options: [], range: NSMakeRange(0, number.count))
        guard let res = matches.first else { return false }
        return res.resultType == .phoneNumber &&
            res.range.location == 0 &&
            res.range.length == number.count
    }
}
