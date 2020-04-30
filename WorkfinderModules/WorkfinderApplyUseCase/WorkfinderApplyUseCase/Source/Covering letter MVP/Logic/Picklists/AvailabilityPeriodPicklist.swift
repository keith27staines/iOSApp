import WorkfinderCommon
import WorkfinderServices

public class AvailabilityPeriodPicklist: HardCodedPicklist {
    public init(networkConfig: NetworkConfig) {
        super.init(type: .availabilityPeriod, maximumPicks: 2, networkConfig: networkConfig)
        items = [
            PicklistItemJson(uuid: "startDate", value: ""),
            PicklistItemJson(uuid: "endDate", value: "")
        ]
    }
}
