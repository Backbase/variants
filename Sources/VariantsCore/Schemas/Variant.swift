//
//  Variants
//
//  Copyright (c) Backbase B.V. - https://www.backbase.com
//  Created by Oleg Baidalka on 31.03.2022.
//

import Foundation

public protocol Variant: Codable {
    var title: String { get }
}
