

class Filter {
    var type: FilterTypeProtocol
    var isSelected: Bool = false
    
    init(type: FilterTypeProtocol) {
        self.type = type
    }
}

