//
//  ContentViewModel.swift
//  XMLConverter
//
//  Created by PangMo5 on 2021/07/02.
//

import AEXML
import AppKit
import Combine
import Defaults
import Foundation

struct ConvertModel {
    var key: String
    var value: String
}

struct Field: Hashable, Codable, Defaults.Serializable {
    var before: String
    var xml: String
}

final class ContentViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    fileprivate var itemList = [URL]()

    @Published
    var visibleItemList = [String]()
    var currentURL: URL?

    @Published
    var currentPath = ""
    @Published
    var regex = ""

    @Published
    var fieldList = [Field]() {
        didSet {
            Defaults[.fields] = fieldList
        }
    }

    @Published
    var beforeFieldText = ""
    @Published
    var xmlFieldText = ""
    @Published
    var isSameField = false
    @Published
    var elementSeperatorText = ""
    @Published
    var arraySeperatorText = ""
    @Published
    var seperatorText = ""
    @Published
    var envelopeText = ""

    @Published
    var isEmptyFieldTexts = false

    init() {
        self.fieldList = Defaults[.fields]

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

        Publishers.CombineLatest($beforeFieldText.map(\.isEmpty),
                                 $xmlFieldText.map(\.isEmpty))
            .map { $0.0 || $0.1 }
            .assign(to: \.isEmptyFieldTexts, on: self)
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

    func addField() {
        fieldList.append(.init(before: beforeFieldText, xml: xmlFieldText))
        beforeFieldText = ""
        xmlFieldText = ""
    }

    func removeField(with field: Field) {
        fieldList.removeAll(where: { $0 == field })
    }

    func convertToXML() {
        visibleItemList.forEach { path in
            let url = URL(fileURLWithPath: path)
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { return }
            let xml = AEXMLDocument()
            let elements = text.components(separatedBy: elementSeperatorText)
            let convertList = elements.map { element -> ConvertModel in
                let componentedValue = element.components(separatedBy: seperatorText)
                return ConvertModel(key: componentedValue.first ?? "Unknown", value: componentedValue.last ?? "Unknown")
            }
            // Parsing

            let attributes = ["xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd": "http://www.w3.org/2001/XMLSchema"]
            let envelope = xml.addChild(name: envelopeText, attributes: attributes)

            convertList.forEach { convert in
                if isSameField {
                    envelope.addChild(name: convert.key, value: convert.value)
                } else if let key = fieldList.filter({ convert.key == $0.before }).first?.xml {
                    envelope.addChild(name: key, value: convert.value)
                }
            }

            let saveURL = url.deletingPathExtension().appendingPathExtension("xml")
            try? xml.xml.write(to: saveURL, atomically: false, encoding: .utf8)
        }
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
