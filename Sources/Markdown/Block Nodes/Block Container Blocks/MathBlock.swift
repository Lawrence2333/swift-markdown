// A Match Block
public struct MathBlock: BlockMarkup, BasicBlockContainer {
    public var _data: _MarkupData
    init(_ raw: RawMarkup) throws {
        guard case .customBlock = raw.data else {
            throw RawMarkup.Error.concreteConversionError(from: raw, to: MathBlock.self)
        }
        let absoluteRaw = AbsoluteRawMarkup(markup: raw, metadata: MarkupMetadata(id: .newRoot(), indexInParent: 0))
        self.init(_MarkupData(absoluteRaw))
    }
    
    init(_ data: _MarkupData) {
        self._data = data
    }
}

// MARK: - Public API

public extension MathBlock {

    // TODO: not quite sure about these 2 initilizers, upper one is required by protocol, lower one seems useful

    public init<Children>(_ children: Children) where Children : Sequence, Children.Element == any BlockMarkup {
        try! self.init(.mathBlock(parsedRange: nil, math: "", children.map { $0.raw.markup }))
    }

    init(_ math: String) {
        try! self.init(RawMarkup.mathBlock(parsedRange: nil, math: math, []))
    }

    /// The raw text representing the code of this block.
    var math: String {
        get {
            guard case let .mathBlock(math) = _data.raw.markup.data else {
                fatalError("\(self) markup wrapped unexpected \(_data.raw)")
            }
            return math
        }
        set {
            _data = _data.replacingSelf(.mathBlock(parsedRange: nil, math: newValue, children.map { $0.raw.markup }))
        }
    }

    // MARK: Visitation

    func accept<V: MarkupVisitor>(_ visitor: inout V) -> V.Result {
        return visitor.visitMathBlock(self)
    }
}
