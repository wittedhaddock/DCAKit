//
//  AutolayoutTests.swift
//  DCAKit
//
//  Created by Drew Crawford on 8/23/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

import XCTest
import DCAKit

class AutolayoutTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testMatches() {
        let superview = UIView(frame: CGRectMake(0, 0, 100, 100))
        let view = UIView(frame:CGRectMake(0, 0, 10, 10))
        superview.addSubview(view)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: nil, metrics: nil, views: ["v":view]) as [NSLayoutConstraint]
        XCTAssertEqual(constraints.count, 2, "Unexpected constraints")
        superview.addConstraints(constraints)
        
        let array1 = superview.constraintsImpactingView()
        XCTAssertTrue(contains(array1,constraints[0]), "Missing constraint")
        XCTAssertTrue(contains(array1,constraints[1]), "Missing constraint")
        
        let array2 = view.constraintsImpactingView()
        XCTAssertTrue(contains(array2,constraints[0]), "Missing constraint")
        XCTAssertTrue(contains(array2,constraints[1]), "Missing constraint")
        

        
    }
    
    func testConstrainBeyondTop() {
        let superview = UIView(frame:CGRectMake(0, 0, 100, 100))
        superview.constrainToSize(superview.frame.size)
        let view = UIView(frame: CGRectMake(0, 0, 10, 10))
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        superview.addSubview(view)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: nil, metrics: nil, views: ["v":view]) as [NSLayoutConstraint]
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: nil, metrics: nil, views: ["v":view]) as [NSLayoutConstraint]
        XCTAssertEqual(constraints.count, 2, "Unexpected constraints")
        superview.addConstraints(constraints)
        superview.addConstraints(vConstraints)
        superview.layoutNOW()

        view.constrainBeyondSuperview(.Top)
        superview.layoutNOW()
        println(view.frame)
        println(superview.frame)
        XCTAssertEqual(view.frame.origin.y, -100, "Unexpected frame")

    }
    
    func testConstrainBeyondBottom(){
        let superview = UIView(frame:CGRectMake(0, 0, 100, 100))
        superview.constrainToSize(superview.frame.size)
        let view = UIView(frame: CGRectMake(0, 0, 10, 10))
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        superview.addSubview(view)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[v]|", options: nil, metrics: nil, views: ["v":view]) as [NSLayoutConstraint]
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[v]|", options: nil, metrics: nil, views: ["v":view]) as [NSLayoutConstraint]
        XCTAssertEqual(constraints.count, 2, "Unexpected constraints")
        superview.addConstraints(constraints)
        superview.addConstraints(vConstraints)
        superview.layoutNOW()
        
        view.constrainBeyondSuperview(.Bottom)
        superview.layoutNOW()
        println(view.frame)
        println(superview.frame)
        XCTAssertEqual(view.frame.origin.y, 100, "Unexpected frame")

    }

}
