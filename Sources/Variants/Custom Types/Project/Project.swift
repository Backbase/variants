//
// Created by Balazs Toth on 25/10/2020.
// Copyright © 2020. All rights reserved.
// 

import Foundation

protocol Project {
    func initialize(verbose: Bool) throws
    func setup(spec: String, skipFastlane: Bool, verbose: Bool) throws
    func `switch`(to variant: String, spec: String, verbose: Bool) throws
}

struct SetupOptions {
    let spec: String
    let skipFastlane: Bool
    let verbose: Bool
}
