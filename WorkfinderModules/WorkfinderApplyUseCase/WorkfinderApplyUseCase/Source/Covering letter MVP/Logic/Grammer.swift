
import Foundation


public class Grammar {
    
    func commaSeparatedList(strings: [String]) -> String {
        if strings.count == 0 { return "" }
        if strings.count == 1 { return strings[0] }
        if strings.count == 2 {return "\(strings[0]) and \(strings[1])"}
        var list = String()
        for i in 0..<strings.count - 2 {
            list = list + strings[i] + ", "
        }
        list += "\(strings[strings.count-2]), and \(strings.last!)"
        return list
        
    }
    
}
