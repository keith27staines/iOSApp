import WorkfinderCommon
import WorkfinderServices

public class AvailabilityPeriodPicklist: HardCodedPicklist {
    public init(networkConfig: NetworkConfig) {
        let type = PicklistType.availabilityPeriod
        super.init(type: type, networkConfig: networkConfig)
        items = [
            PicklistItemJson(uuid: "startDate", value: ""),
            PicklistItemJson(uuid: "endDate", value: "")
        ]
    }
}
