
public struct Candidate: Codable {
    public var uuid: F4SUUID?
    public var dateOfBirth: String?
    public var employmentSkills: [F4SUUID]?
    public var motivation: String?
    public var experience: String?
    public var fullName: String { self.userSummary.full_name }
    public var guardianEmail: String?
    public var phone: String?
    public var allowedSharingWithEducationInstitution: Bool?
    public var allowedSharingWithEmployers: Bool?
    
    public func age(on date: Date = Date()) -> Int? {
        guard let dobString = dateOfBirth, let dob = Date.workfinderDateStringToDate(dobString) else {
            return nil
        }
        return Calendar.current.dateComponents([.year], from: dob, to: date).year!
    }
    
    var userSummary: UserSummary
    
    public init() {
        self.userSummary = UserSummary()
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case dateOfBirth = "date_of_birth"
        case userSummary = "user"
        case guardianEmail = "guardian_email"
        case phone
        case allowedSharingWithEducationInstitution = "has_allowed_sharing_with_educational_institution"
        case allowedSharingWithEmployers = "has_allowed_sharing_with_employers"
    }
    
    struct UserSummary: Codable {
        public var uuid: F4SUUID = ""
        public var full_name: String = ""
    }
}
