/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// Inline elements that should be rendered with a customtag.
public struct CustomTag: InlineMarkup, InlineContainer {
    
    public var _data: _MarkupData
    init(_ raw: RawMarkup) throws {
        guard case .customtag = raw.data else {
            throw RawMarkup.Error.concreteConversionError(from: raw, to: CustomTag.self)
        }
        let absoluteRaw = AbsoluteRawMarkup(markup: raw, metadata: MarkupMetadata(id: .newRoot(), indexInParent: 0))
        self.init(_MarkupData(absoluteRaw))
    }
    init(_ data: _MarkupData) {
        self._data = data
    }
}

// MARK: - Public API

public extension CustomTag {
    // MARK: BasicInlineContainer

    init<Children>(tagName: String = "", content: String = "", _ children: Children) where Children : Sequence, Children.Element == InlineMarkup {
        try! self.init(.customtag(tagName: tagName, content: content, parsedRange: nil, children.map { $0.raw.markup }))
    }

    var tagName: String {
        get {
            guard case let .customtag(tagName, _) = _data.raw.markup.data else {
                fatalError("\(self) markup wrapped unexpected \(_data.raw)")
            }
            return tagName
        }
        set {
            _data = _data.replacingSelf(.customtag(tagName: newValue, content: content, parsedRange: nil, _data.raw.markup.copyChildren()))
        }
    }
    
    var content: String {
        get {
            guard case let .customtag(_, content) = _data.raw.markup.data else {
                fatalError("\(self) markup wrapped unexpected \(_data.raw)")
            }
            return content
        }
        set {
            _data = _data.replacingSelf(.customtag(tagName: tagName, content: newValue, parsedRange: nil, _data.raw.markup.copyChildren()))
        }
    }

    // MARK: PlainTextConvertibleMarkup

    var plainText: String {
        let childrenPlainText = children.compactMap {
            return ($0 as? InlineMarkup)?.plainText
        }.joined()
        return "<\(tagName.uppercased()) \(childrenPlainText)/>"
    }

    // MARK: Visitation

    func accept<V: MarkupVisitor>(_ visitor: inout V) -> V.Result {
        return visitor.visitCustomTag(self)
    }
}
