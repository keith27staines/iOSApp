import WorkfinderCommon
import WorkfinderServices

public class UniversityYearPicklist: HardCodedPicklist {
    
    public init(networkConfig: NetworkConfig) {
        super.init(type: .year, maximumPicks: 1, networkConfig: networkConfig)
        items = [
            PicklistItemJson(uuid: "1", value: "Year 1"),
            PicklistItemJson(uuid: "2", value: "Year 2"),
            PicklistItemJson(uuid: "3", value: "Year 3"),
            PicklistItemJson(uuid: "4", value: "Year 4"),
        ]
    }
}
