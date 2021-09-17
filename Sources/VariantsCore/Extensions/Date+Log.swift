//
//  Date+Log.swift
//  VariantsCoreTests
//
//  Created by Abdoelrhman Eaita on 17/09/2021.
//

import Foundation

extension Date {
    func logTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}
