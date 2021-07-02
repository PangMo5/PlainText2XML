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
    var cancellables = Set<AnyCancellable>()
    var text = ""

    @Published
    var visibleItemList = [String]()
    fileprivate var itemList = [URL]()
    var currentURL: URL?

    @Published
    var currentPath = ""
    @Published
    var regex = ""

    let xml = XML(.element(named: "Title", text: "Titlasde"),
                  .element(named: "Summary", text: "Summaray"))

    init() {
        $regex
            .dropFirst()
            .sink(receiveValue: filterItems(with:))
            .store(in: &cancellables)
        
        $currentPath
            .dropFirst()
            .sink(receiveValue: {
                self.currentURL = URL(fileURLWithPath: $0)
                self.loadFilesInPath()
            })
            .store(in: &cancellables)
    }

    func selectDirectory() {
        let dialog = NSOpenPanel()

        dialog.title = "Choose single directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true

        guard dialog.runModal() == NSApplication.ModalResponse.OK,
              let result = dialog.url else { return }

        currentPath = result.path
    }

    fileprivate func loadFilesInPath() {
        itemList = []
        guard let url = currentURL,
              let pathURLs = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { return }
        searchAllItems(in: pathURLs)
        filterItems(with: regex)
    }

    fileprivate func searchAllItems(in urls: [URL]) {
        urls.forEach { url in
            guard url.isDirectory else {
                itemList.append(url)
                return
            }
            guard let pathURLs = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else { return }
            searchAllItems(in: pathURLs)
        }
    }

    fileprivate func filterItems(with regex: String) {
        if regex.isEmpty {
            visibleItemList = itemList.map(\.path)
        } else {
            visibleItemList = itemList.map(\.path).filter {
                $0.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
            }
        }
    }
}
