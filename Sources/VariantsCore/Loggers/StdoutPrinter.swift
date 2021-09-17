//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Giuseppe Deraco
//

import Foundation

public class StdoutPrinter {
    static let shared = StdoutPrinter()
    private var stdoutTextOutputStream = StandardOutputStream()
    
    func print(item: String) {
        Swift.print(item, to: &stdoutTextOutputStream)
    }
}
