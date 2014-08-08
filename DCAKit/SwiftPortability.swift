//
//  SwiftPortability.swift
//  DCAKit
//
//  Created by Drew Crawford on 8/8/14.
//  Copyright (c) 2014 DrewCrawfordApps. All rights reserved.
//

import Foundation
public extension Unmanaged {
    public var foundationConstantAsString: String {
        get {
            return self.takeUnretainedValue() as NSString;
        }
    }
}