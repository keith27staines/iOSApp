import WorkfinderCommon

struct CompanyTileViewData {
    var companyName: String
    var logoUrlString: String?
    var industry: String?
    var uuid: String
    
    init() {
        self.uuid = UUID().uuidString
        self.companyName = "unnamed company"
    }
    
    init(companyJson: CompanyJson) {
        self.uuid = companyJson.uuid!
        self.companyName = companyJson.name ?? "unnamed company"
        self.logoUrlString = companyJson.logo
        self.industry = companyJson.industries?.first?.name
    }
}
