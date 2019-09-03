import Foundation
let bundle = Bundle(identifier: "com.f4s.WorkfinderApplyUseCase")!

public class WorkfinderApplyUseCase {
    
    let coverLetterStoryboard = UIStoryboard(name: "EditCoverLetter", bundle: bundle)
    
    public enum StoryboardViewController: String {
        case editCoverLetter
    }
    
    public init() {}
    
    public func instantiateViewController(type: StoryboardViewController) -> UIViewController {
        switch type {
        case .editCoverLetter:
            return coverLetterStoryboard.instantiateViewController(withIdentifier: "EditCoverLetterCtrl") as! EditCoverLetterViewController
        }
        
    }
}
