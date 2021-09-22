//
//  InterviewsJson.swift
//  WorkfinderServices
//
//  Created by Keith on 02/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

public struct InterviewJson: Codable {
    public var id: Int?
    public var uuid: String?
    public var placement: PlacementJson?
    public var status: String?
    public var candidate: Int?
    public var reasonDisqualified: String?
    public var offerMessage: String?
    public var meetingLink: String?
    public var additionalOfferNote: String?
    public var offerStartDate: String?
    public var offerEndDate: String?
    public var interviewDates: [InterviewDateJson]?
    
    public var selectedInterviewDate: InterviewDateJson? {
        interviewDates?.first { $0.status == "selected" }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case placement
        case status
        case candidate
        case reasonDisqualified = "reason_disqualified"
        case offerMessage = "offer_message"
        case meetingLink = "meeting_link"
        case additionalOfferNote = "additional_offer_note"
        case offerStartDate = "offer_starting_date"
        case offerEndDate = "offer_end_date"
        case interviewDates = "interview_dates"
    }
    
    public struct InterviewDateJson: Codable, Equatable {
        private static var dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.timeStyle = .none
            df.dateFormat = "dd MMM yyyy"
            return df
        }()
        
        private static var timeFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            return df
        }()
        
        public var localDateString: String {
            guard let localDate = localDate else { return ""}
            return Self.dateFormatter.string(from: localDate)
        }
        
        public var localStartToEndTimeString: String {
            guard let startDate = localDate, let duration = duration else { return ""}
            let endDate = startDate.addingTimeInterval(Double(60 * duration))
            let startString = Self.timeFormatter.string(from: startDate)
            let endString = Self.timeFormatter.string(from: endDate)
            return "\(startString) - \(endString)"
        }
        
        public var localDateTimeDurationString: String {
            "\(localDateString), \(localStartToEndTimeString)"
        }

        public var localDate: Date? { Date.dateFromRfc3339(string: dateTime ?? "") }
        
        public var id: Int?
        public var dateTime: String?
        public var timeString: String?
        public var interview: Int?
        public var status: String?
        public var duration: Int?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case dateTime = "date_time"
            case interview
            case status
            case duration
            case timeString = "time_str"
        }
    }
    
    public struct PlacementJson: Codable {
        public var id: Int?
        public var uuid: String?
        public var associatedProject: ProjectJson?
        public var association: AssociationJson?
        
        public var createdAt: String?
        public var endDate: String?
        public var offerNotes: String?
        public var offeredDuration: Int?
        public var reasonDeclinedOther: String?
        public var reasonDeclined: String?
        public var reasonWithdrawnOther: String?
        public var reasonWithdrawn: String?
        public var startDate: String?
        public var status: String?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case uuid
            case associatedProject = "associated_project"
            case association
            case createdAt = "created_at"
            case endDate = "end_date"
            case offerNotes = "offer_notes"
            case offeredDuration = "offered_duration"
            case reasonDeclinedOther = "reason_declined_other"
            case reasonDeclined = "reason_declined"
            case reasonWithdrawn = "reason_withdrawn"
            case reasonWithdrawnOther = "reason_withdrawn_other"
            case startDate = "start_date"
            case status
        }
        
        public struct ProjectJson: Codable {
            public var uuid: String?
            public var aboutCandidate: String?
            public var additionalComments: String?
            public var applicationCount: Int?
            public var association: String?
            public var candidateActivities: [String]?
            public var candidatesRequested: String?
            public var createdAt: String?
            public var description: String?
            public var duration: String?
            public var employmentType: String?
            public var hostActivities: [String]?
            public var isPaid: Bool?
            public var isRemote: Bool?
            public var minimumEducation: String?
            public var name: String?
            public var promoteOnHomePage: Bool?
            public var roleType: String?
            public var salary: Int?
            public var skillsAcquired: [String]?
            public var startDate: String?
            public var endDate: String?
            public var status: String?
            public var type: String?
            public var voluntaryReason: String?
            public var isCandidateLocationRequired: Bool?
            
            private enum CodingKeys: String, CodingKey {
                case uuid
                case aboutCandidate = "about_candidate"
                case additionalComments = "additional_comments"
                case applicationCount = "application_count"
                case association
                case candidateActivities = "candidate_activities"
                case candidatesRequested = "candidates_requested"
                case createdAt = "created_at"
                case description
                case duration
                case employmentType = "employment_type"
                case hostActivities = "host_activities"
                case isPaid = "is_paid"
                case isRemote = "is_remote"
                case minimumEducation = "minimum_education"
                case name
                case promoteOnHomePage = "promote_on_home_page"
                case roleType = "role_type"
                case skillsAcquired = "skills_acquired"
                case startDate = "start_date"
                case endDate = "end_date"
                case status
                case type
                case voluntaryReason = "voluntary_reason"
                case isCandidateLocationRequired = "is_candidate_location_required"
            }
        }
        
        public struct AssociationJson: Codable {
            public var host: HostJson?
            public var location: LocationJson?
        }
        
        public struct HostJson: Codable {
            public var uuid: String?
            public var emails: [String]?
            public var fullname: String?
            public var photo: String?
            
            private enum CodingKeys: String, CodingKey {
                case uuid
                case emails
                case fullname = "full_name"
                case photo
            }
        }
        
        public struct LocationJson: Codable {
            public var uuid: String?
            public var company: CompanyJson?
            public var addressUnit: String?
            public var addressBuilding: String?
            public var addressStreet: String?
            public var addressCity: String?
            public var addressRegion: String?
            public var addressCountry: Country?
            public var addressPostcode: String?
            
            public struct Country: Codable {
                var name: String?
                var code: String?
            }
            
            private enum CodingKeys: String, CodingKey {
                case uuid
                case company
                case addressUnit = "address_unit"
                case addressBuilding = "address_building"
                case addressStreet = "address_street"
                case addressCity = "address_city"
                case addressRegion = "address_region"
                case addressCountry = "address_country"
                case addressPostcode = "address_postcode"
            }
        }
        
        public struct CompanyJson: Codable {
            public var uuid: String?
            public var name: String?
            public var logo: String?
            public var industries: [String?]
        }

    }
}


/*
 {
   "id": 0,
   "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
   "placement": {
     "id": 0,
     "associated_project": {
       "about_candidate": "string",
       "additional_comments": "string",
       "application_count": 0,
       "association": "string",
       "candidate_activities": [
         "string"
       ],
       "candidates_requested": "string",
       "created_at": "2021-09-01T13:10:52.807Z",
       "description": "string",
       "duration": "string",
       "employment_type": "Full-time",
       "host_activities": [
         "string"
       ],
       "is_paid": true,
       "is_remote": true,
       "minimum_education": "GC",
       "name": "string",
       "promote_on_home_page": true,
       "role_type": "Short Project",
       "salary": 0,
       "skills_acquired": [
         "string"
       ],
       "start_date": "2021-09-01",
       "end_date": "2021-09-01",
       "status": "string",
       "type": "Creative Digital Marketing",
       "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
       "voluntary_reason": "string",
       "is_candidate_location_required": true
     },
     "association": {
       "host": {
         "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
         "emails": [
           "user@example.com"
         ],
         "full_name": "string",
         "photo": "string"
       },
       "location": {
         "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
         "company": {
           "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
           "name": "string",
           "logo": "string",
           "industries": [
             "A",
             ""
           ]
         },
         "address_unit": "string",
         "address_building": "string",
         "address_street": "string",
         "address_city": "string",
         "address_region": "string",
         "address_country": "string",
         "address_postcode": "string"
       }
     },
     "created_at": "2021-09-01T13:10:52.807Z",
     "end_date": "2021-09-01",
     "offer_notes": "string",
     "offered_duration": 0,
     "reason_declined_other": "string",
     "reason_declined": "I have selected another candidate for this position",
     "reason_withdrawn_other": "string",
     "reason_withdrawn": "I have another offer",
     "start_date": "2021-09-01",
     "status": "string",
     "uuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
   },
   "status": "open",
   "candidate": 0,
   "reason_disqualified": "string",
   "offer_message": "string",
   "meeting_link": "string",
   "additional_offer_note": "string",
   "offer_starting_date": "2021-09-01T13:10:52.807Z",
   "offer_end_date": "2021-09-01T13:10:52.807Z",
   "interview_dates": [
     {
       "id": 0,
       "date_time": "2021-09-01T13:10:52.807Z",
       "interview": 0,
       "status": "open",
       "duration": 0
     }
   ]
 }
 */
