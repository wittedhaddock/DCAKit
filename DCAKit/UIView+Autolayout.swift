//
//  UIView+Autolayout.swift
//  DCAKit
//
//  Created by Drew Crawford on 8/23/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

import Foundation

extension Array {
    func atMostOne() -> T? {
        if (self.count==0) { return nil }
        assert(self.count==1);
        return self[0]
    }
}

extension NSLayoutAttribute {

    /* This returns the dimension (width or height) that is associated with the attribute. */
    var dimensionAttribute : NSLayoutAttribute {
        get {
            switch(self) {
                case .Top:
                    return .Height;
                case .Bottom:
                    return .Height;
                case .Left:
                    return .Width;
                case .Right:
                    return .Width;
                case .Leading:
                    return .Width
                case .Trailing:
                    return .Width
                case .Width:
                    return .Width
                case .Height:
                    return .Height
                case .CenterX:
                    return .Width;
                case .CenterY:
                    return .Height;
                case .LeftMargin:
                    return .Width;
                case .RightMargin:
                    return .Width
                case .TopMargin:
                    return .Height
                case .BottomMargin:
                    return .Height
                case .LeadingMargin:
                    return .Width
                case .TrailingMargin:
                    return .Width
                case .CenterXWithinMargins:
                    return .Width
                case .CenterYWithinMargins:
                    return .Height
                default:
                    abort()
            }
        }
    }
/** For bottom returns top, etc. */
    var opposite : NSLayoutAttribute {
        get {
            switch(self) {
                case .Top:
                    return .Bottom;
                case .Bottom:
                    return .Top;
                case .Left:
                    return .Right;
                case .Right:
                    return .Left;
                case .Leading:
                    return .Trailing
                case .Trailing:
                    return .Leading
                case .Width:
                    return .Height
                case .Height:
                    return .Width
                case .CenterX:
                    return .CenterY;
                case .CenterY:
                    return .CenterX;
                case .LeftMargin:
                    return .RightMargin;
                case .RightMargin:
                    return .LeftMargin
                case .TopMargin:
                    return .BottomMargin
                case .BottomMargin:
                    return .TopMargin
                case .LeadingMargin:
                    return .TrailingMargin
                case .TrailingMargin:
                    return .LeadingMargin
                case .CenterXWithinMargins:
                    return .CenterYWithinMargins
                case .CenterYWithinMargins:
                    return .CenterXWithinMargins
                default:
                    abort()
            }
        }
    }
}

public extension NSLayoutConstraint {
    public func matches(view: UIView) -> Bool {
        return (self.firstItem as UIView?) == view || (self.secondItem as UIView?) == view
    }
    public func matches(view:UIView, attribute:NSLayoutAttribute) -> Bool {
        return (self.firstItem as UIView?) == view && self.firstAttribute==attribute ||
        (self.secondItem as UIView?) == view && self.secondAttribute==attribute
    }
}

public extension UIView {
/** Returns those constraints directly affecting (impacting) the view (e.g. in the view or its superview) */
    public func constraintsImpactingView() -> [NSLayoutConstraint] {
        var j:[NSLayoutConstraint] = []
        if let superview = self.superview? {
            j = (superview.constraints() as [NSLayoutConstraint]).filter({x in x.matches(self)})
        }

        let k : Array<NSLayoutConstraint> = (self.constraints() as Array<NSLayoutConstraint>).filter({x in x.matches(self)})
        return  k + j
    }

    public func constraintsImpactingView(attribute: NSLayoutAttribute) ->[NSLayoutConstraint] {
        return self.constraintsImpactingView().filter({x in x.matches(self,attribute: attribute)})
    }

    public func removeConstraintFromSelfOrSuperview(constraint: NSLayoutConstraint) {
        if contains(self.constraints() as [NSLayoutConstraint],constraint) {
            self.removeConstraint(constraint)
        }
        else if (self.superview != nil && contains(self.superview!.constraints() as [NSLayoutConstraint],constraint)) {
            self.superview?.removeConstraint(constraint)
        }
    }

    
    public  func constrainToSize(size: CGSize) {
        assert(self.constraints().count==0,"Not implemented")
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[view(==\(frame.size.width))]", options: nil, metrics: nil, views: ["view":self])
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(==\(frame.size.height))]", options: nil, metrics: nil, views: ["view":self])
        self.addConstraints(horizontalConstraints)
        self.addConstraints(verticalConstraints)

    }

/** Constrains the function beyond (outside) the superview in the specified direction).
Note that the view must have a clean layout, since this function relies on the width/height of the receiver */
    public func constrainBeyondSuperview(inDirection: NSLayoutAttribute) {
        if let oldConstraint = self.constraintsImpactingView(inDirection).atMostOne() {
            self.removeConstraintFromSelfOrSuperview(oldConstraint)
        }
        var offset : CGFloat = 0.0
        //so the problem is as follows.  If the view is pinned, say, to top and bottom, and we adjust the top, then height will change.
        //remove a constraint matching the oppsite
        for constraint in self.constraintsImpactingView(inDirection.opposite) {
            self.removeConstraintFromSelfOrSuperview(constraint)
        }

        switch(inDirection.dimensionAttribute) {
            case .Width:
                offset = self.frame.size.width

                
            case .Height:
                offset = self.frame.size.height
            default:
                assert(false,"Autolayout error")
        }
        //add a fixed constraint for new dimension
        self.addConstraint(NSLayoutConstraint(item: self, attribute: inDirection.dimensionAttribute, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute , multiplier: 1.0, constant: offset))
        let constraint = NSLayoutConstraint(item: superview, attribute: inDirection, relatedBy: .Equal, toItem: self, attribute: inDirection, multiplier: 1.0, constant: offset)
        superview!.addConstraint(constraint)
        assert(contains(superview!.constraints() as [NSLayoutConstraint],constraint),"Constraint not added?")
        println(self.constraintsImpactingView())

    }

    public func layoutNOW() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}