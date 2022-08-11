//
//  BasicViewController.swift
//  PanModal
//
//  Created by Stephen Sowole on 2/26/19.
//  Copyright © 2019 PanModal. All rights reserved.
//


import UIKit


class SimplePanViewController: UIViewController ,PanModalPresentable {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    
    //MARK: PanModalPresentable
    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(200)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var transitionDuration: Double {
        return 0.3
    }
    
    var cornerRadius: CGFloat {
        return 15
    }
    
    var panModalBackgroundColor: UIColor {
        UIColor.black.withAlphaComponent(0.25)
    }
}
