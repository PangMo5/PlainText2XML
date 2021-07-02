//
//  URL++.swift
//  XMLConverter
//
//  Created by PangMo5 on 2021/07/02.
//

import Foundation

extension URL {
    var isDirectory: Bool {
       return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
