import WorkfinderCommon
import WorkfinderServices

public class TextblockPicklist: HardCodedPicklist {
    public override init(type: PicklistType, networkConfig: NetworkConfig) {
        super.init(type: type, networkConfig: networkConfig)
        items = [ PicklistItemJson(uuid: "text", value: "text") ]
    }
}
