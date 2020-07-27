
import WorkfinderCommon

public class DraftPlacementPreparer {
    
    public var draft: Placement
    
    public init() {
        draft = Placement()
    }
    
    @discardableResult
    public func update(associationUuid: F4SUUID?) -> Placement {
        draft.associationUuid = associationUuid
        return draft
    }
    
    @discardableResult
    public func update(associatedProject: F4SUUID?) -> Placement {
        draft.associatedProject = associatedProject
        return draft
    }
    
    @discardableResult
    public func update(candidateUuid: F4SUUID?) -> Placement {
        draft.candidateUuid = candidateUuid
        return draft
    }
    
    @discardableResult
    public func update(coverletter: String) -> Placement {
        draft.coverLetterString = coverletter
        return draft
    }
    
    @discardableResult
    public func update(picklists: PicklistsDictionary) -> Placement {
        for type in PicklistType.allCases {
            let selectedItems = picklists[type]?.selectedItems
            let firstItem = selectedItems?.first
            switch type {
            case .year: draft.yearOfStudy = PlacementOtherableFact(item: firstItem)
            case .subject: draft.subject = PlacementOtherableFact(item: firstItem)
            case .project: draft.project = PlacementOtherableFact(item: firstItem)
            case .institutions: draft.institution = firstItem?.uuid
            case .placementType: draft.placementType = firstItem?.uuid
            case .duration: draft.duration = firstItem?.uuid
            case .motivation: draft.motivation = firstItem?.value
            case .experience: draft.experience = firstItem?.value
            case .attributes:
                draft.personalAttributes = selectedItems?.compactMap({ (item) -> F4SUUID? in
                    return item.uuid
                })
            case .skills:
                draft.skills = selectedItems?.compactMap({ (item) -> F4SUUID? in
                    return item.uuid
                })
            case .availabilityPeriod:
                let lower = selectedItems?[0].value
                let upper = selectedItems?[1].value
                draft.availability = PlacementAvailability(lower: lower, upper: upper)
            }
        }
        return draft
    }
}

