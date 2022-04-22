//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Abdoelrhman Eaita on 17/09/2021.
//

import Foundation

@testable import VariantsCore

struct MockVerboseLogger: VerboseLogger {
    var verbose: Bool
    
    var showTimestamp: Bool
}
