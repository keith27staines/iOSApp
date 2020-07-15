
import WorkfinderCommon

public class DraftPlacementPreparationLogic {
    var draft = Placement()
    func update(associationUuid: F4SUUID) { draft.associationUuid = associationUuid}
    func update(candidateUuid: F4SUUID) { draft.candidateUuid = candidateUuid }
    func update(coverletter: String) {
        draft.coverLetterString = coverletter
    }
    func update(picklists: PicklistsDictionary) {
        
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
    }
}
