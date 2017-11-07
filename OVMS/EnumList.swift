public indirect enum List<Element> {
    case empty
    case node(Element, List)

    init() { self = .empty }
    init(_ x: Element) { self = .node(x, .empty) }

    public var isEmpty: Bool {
        switch self {
        case .empty: return true
        case _: return false
        }
    }

    public func peek() -> Element? {
        guard case let .node(x, _) = self else { return nil }
        return x
    }

    public mutating func pop() -> Element? {
        guard case let .node(x, next) = self else { return nil }
        self = next
        return x
    }
}

// FIFO stuff
extension List {
    public func appended(_ x: Element) -> List {
        guard case let .node(y, n) = self else { return List(x) }
        return .node(y, n.appended(x))
    }

    public mutating func append(_ x: Element) {
        self = self.appended(x)
    }
}

extension List: CustomStringConvertible {
    public var description: String {
        guard case .node(let x, var current) = self else { return "[]" }
        var string = "[\(x)"
        while case let .node(y, next) = current {
            string += ", \(y)"
            current = next
        }
        return string + "]"
    }
}
