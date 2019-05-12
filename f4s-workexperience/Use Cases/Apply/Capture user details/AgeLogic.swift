import Foundation

/// AgeLogic encapsulates desicions made about the user based on their date of birth
class AgeLogic {
    var dateOfBirth: Date?
    lazy var dateOfBirthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMMM yyyy"
        return df
    }()
    
    init() {}
    
    var isAgeTooYoungToApply: Bool { return age < 13 }
    var isConsentRequired: Bool { return age >= 13 && age < 16 }
    
    var age: Int {
        guard let dob = dateOfBirth else { return 0 }
        let currentdate = NSDate()
        let calendar = NSCalendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: currentdate as Date)
        let age = ageComponents.year!
        return age
    }
    
    var dateOfBirthText: String? {
        guard let dob = dateOfBirth else { return nil }
        return dateOfBirthFormatter.string(from: dob)
    }
    
    func defaultDateOfBirth(_ today: Date = Date()) -> Date {
        let calendar = NSCalendar.current
        var dateComponents = calendar.dateComponents([.year], from: today)
        dateComponents.year = dateComponents.year! - 16
        dateComponents.month = 1
        dateComponents.day = 1
        return calendar.date(from: dateComponents)!
    }
}
