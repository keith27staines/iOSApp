import Foundation
import WorkfinderCommon

let __bundle = Bundle(identifier: "com.f4s.WorkfinderUserDetailsUseCase")!
var __environment: EnvironmentType = .production

public class WorkfinderUserDetailsUseCase {

    public init(environmentType: EnvironmentType) {
        __environment = environmentType
    }
}
