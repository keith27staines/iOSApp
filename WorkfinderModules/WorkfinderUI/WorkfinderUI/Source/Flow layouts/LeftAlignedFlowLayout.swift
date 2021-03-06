
import UIKit

public class LeftAlignedFlowLayout: UICollectionViewFlowLayout {

//    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attributes = super.layoutAttributesForElements(in: rect)
//
//        var leftMargin = sectionInset.left
//        var maxY: CGFloat = -1.0
//        attributes?.forEach { layoutAttribute in
//            if layoutAttribute.frame.origin.y >= maxY {
//                leftMargin = sectionInset.left
//            }
//
//            layoutAttribute.frame.origin.x = leftMargin
//
//            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
//            maxY = max(layoutAttribute.frame.maxY , maxY)
//        }
//
//        return attributes
//    }
    
    public override func layoutAttributesForElements(
                      in rect: CGRect)->[UICollectionViewLayoutAttributes]? {
        
        guard let att = super.layoutAttributesForElements(in: rect) else { return [] }
        var x: CGFloat = sectionInset.left
        var y: CGFloat = -1.0
        
        for a in att {
            if a.representedElementCategory != .cell { continue }
            
            if a.frame.origin.y >= y { x = sectionInset.left }
            
            a.frame.origin.x = x
            x += a.frame.width + minimumInteritemSpacing
            
            y = a.frame.maxY
        }
        return att
    }
}
