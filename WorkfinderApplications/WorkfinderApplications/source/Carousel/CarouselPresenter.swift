//
//  CarouselPresenter.swift
//  WorkfinderApplications
//
//  Created by Keith on 10/09/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import WorkfinderUI

//class CarouselPresenter {
//    
//    
//    
//    private (set) var items = [CarouselTilePresenterProtocol]() {
//        didSet {
//            currentIndex = numberOfItems == 0 ? nil : 0
//        }
//    }
//    
//    var numberOfItems: Int { items.count }
//    var currentIndex: Int?
//    var title: String?
//    
//    var isLeftPositionStepperEnabled: Bool { currentIndex ?? -1 > 0 }
//    var isRightPositionStepperEnabled: Bool { currentIndex ?? 0 < numberOfItems - 1 }
//    
//    var positionString: String {
//        guard let currentIndex = currentIndex else { return "" }
//        return "\(currentIndex + 1) of \(numberOfItems)"
//    }
//    
//    func itemPresenterForIndex(_ index: Int) -> CarouselTilePresenterProtocol {
//        items[index]
//    }
//    
//    init(title: String, items: [CarouselTilePresenter]) {
//        self.title = title
//        self.items = items
//    }
//
//}
