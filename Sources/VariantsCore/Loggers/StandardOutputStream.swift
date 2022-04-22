//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Abdoelrhman Eaita on 17/09/2021.
//

import Foundation

struct StandardOutputStream: TextOutputStream {
    let fileHandler: FileHandle
    func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            fileHandler.write(data)
        }
    }
}
