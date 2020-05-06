import WorkfinderCommon
import WorkfinderServices

public class TextblockPicklist: HardCodedPicklist {
    public init(type: PicklistType, networkConfig: NetworkConfig) {
        super.init(type: type, otherItem: nil, maximumPicks: 1, networkConfig: networkConfig)
        items = [
            PicklistItemJson(uuid: "text", value: "text")
        ]
    }
}
