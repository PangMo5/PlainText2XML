//
//  ContentViewModel.swift
//  XMLConverter
//
//  Created by PangMo5 on 2021/07/02.
//

import AppKit
import Combine
import Foundation
import Plot

final class ContentViewModel: ObservableObject {
    var text = ""

    @Published
    var itemList = [String]()
    @Published
    var currentPath = ""

    let xml = XML(.element(named: "Title", text: "Titlasde"),
                  .element(named: "Summary", text: "Summaray"))

    func selectDirectory() {
        let dialog = NSOpenPanel()

        dialog.title = "Choose single directory | Our Code World"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url

            if result != nil {
                currentPath = result?.path ?? ""

                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}
