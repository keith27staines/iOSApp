struct CompanyTileViewData {
    var companyName: String
    var logoUrlString: String?
    
    init() {
        self.companyName = "unnamed company"
    }
    
    init(companyJson: CompanyJson) {
        self.companyName = companyJson.name ?? "unnamed company"
        self.logoUrlString = companyJson.logoUrlString
    }
}
