//
//  UIView+Autolayout.swift
//  DCAKit
//
//  Created by Drew Crawford on 8/23/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

import Foundation
public extension NSLayoutConstraint {
    public func matches(view: UIView) -> Bool {
        return (self.firstItem as UIView) == view || (self.secondItem as UIView) == view
    }
}

public extension UIView {
    public func constraintsAffectingView() -> NSArray {
        let j: Array? = self.superview?.constraints().filter({x in x.matches(self)})
        let k : Array = self.constraints().filter({x in x.matches(self)})
        return  k + (j ?? [])
    }
}