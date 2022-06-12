//
//  FileManager-DocumentsDirectory.swift
//  77-HotProspects
//
//  Created by Michael & Diana Pascucci on 5/25/22.
//

import SwiftUI

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
