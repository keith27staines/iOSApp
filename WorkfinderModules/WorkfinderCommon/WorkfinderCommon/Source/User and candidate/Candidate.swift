
/// This struct is required because the Candidate isn't of the right shape for creating a candidate. Due to an oddity of the api, candidate's user field is sometimes a uuid and sometimes a json. Use this struct for the json when POSTing to /v3/candidates
public struct CreatableCandidate: Codable {
    public var user: F4SUUID // NB in Candidate, user is a json object, not a uuid
    
    public init(candidate: Candidate, userUuid: F4SUUID) {
        user = userUuid
    }
}

public struct Candidate: Codable, Equatable {
    public var uuid: F4SUUID?
    public var dateOfBirth: String?
    public var employmentSkills: [F4SUUID]?
    public var motivation: String?
    public var experience: String?
    public var guardianEmail: String?
    public var phone: String?
    public var allowedSharingWithEducationInstitution: Bool?
    public var allowedSharingWithEmployers: Bool?
    public var postcode: String?
    public var languages: [String]?
    public var ethnicity: String?
    public var gender: String?
    public var preferSMS: Bool?
    public var educationLevel: String?
    
    public func age(on date: Date = Date()) -> Int? {
        guard let dobString = dateOfBirth,
            let dob = Date.workfinderDateStringToDate(dobString) else {
            return nil
        }
        let dobComponents = Calendar.current.dateComponents([.year, .month, .day], from: dob)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard
            let year = dateComponents.year,
            let month = dateComponents.month,
            let day = dateComponents.day,
            let dobYear = dobComponents.year,
            let dobMonth = dobComponents.month,
            let dobDay = dobComponents.day
            else { return nil }
        let yearDiff = year - dobYear
        let monthDiff = month - dobMonth
        let dayDiff = day - dobDay
        var age: Int = 0
        if monthDiff > 0 {
            age = yearDiff
        } else if monthDiff < 0 {
            age = yearDiff - 1
        } else if dayDiff >= 0 {
            age = yearDiff
        } else {
            age = yearDiff - 1
        }
        return age >= 0 ? age : nil
    }
    
    var userSummary: UserUUID
    
    public init() {
        self.userSummary = UserUUID()
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case dateOfBirth = "date_of_birth"
        case userSummary = "user"
        case guardianEmail = "guardian_email"
        case phone
        case allowedSharingWithEducationInstitution = "has_allowed_sharing_with_educational_institution"
        case allowedSharingWithEmployers = "has_allowed_sharing_with_employers"
        case postcode
        case languages
        case ethnicity
        case gender
        case preferSMS = "prefer_sms"
        case educationLevel = "education_level"
    }
    
    struct UserUUID: Codable, Equatable {
        public var uuid: F4SUUID = ""
    }
}
