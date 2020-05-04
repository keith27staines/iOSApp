import WorkfinderCommon
import WorkfinderServices

public class TextblockPicklist: HardCodedPicklist {
    let placeholder: String
    public init(type: PicklistType, placeholder: String, networkConfig: NetworkConfig) {
        self.placeholder = placeholder
        super.init(type: type, maximumPicks: 1, networkConfig: networkConfig)
        items = [
            PicklistItemJson(uuid: "text", value: "text")
        ]
    }
}
