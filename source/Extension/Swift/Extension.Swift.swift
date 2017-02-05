import Foundation

extension Bool
{
    public init(_ value: Int) {
        self = value == 1
    }
}

extension Int
{
    public init(_ value: Bool) {
        self = value ? 1 : 0
    }
}

extension String
{
    public var lowerCaseFirstString: String {

        // Todo: there's no need to convert to `NSString`, but it sometimes crashes with AppCode
        // todo: in a fucking mysterious way. Try again in a few months.

        if let string: NSString = self as NSString?, string.length > 0 {
            return string.substring(to: 1).lowercased() + string.substring(from: 1)
        } else {
            return self
        }
    }

    public var upperCaseFirstString: String {

        // Todo: there's no need to convert to `NSString`, but it sometimes crashes with AppCode
        // todo: in a fucking mysterious way. Try again in a few months.

        if let string: NSString = self as NSString?, string.length > 0 {
            return string.substring(to: 1).uppercased() + string.substring(from: 1)
        } else {
            return self
        }
    }
}

extension Array
{
    public var empty: Bool {
        return self.isEmpty
    }

    public var filled: Bool {
        return !self.isEmpty
    }

    public mutating func drain() -> [Element] {
        let elements: [Element] = self
        self.removeAll()
        return elements
    }
}

// MARK: dictionary

extension Dictionary
{
    public var empty: Bool {
        return self.isEmpty
    }

    public var filled: Bool {
        return !self.isEmpty
    }
}

public func +<K, V>(lhs: [K: V], rhs: [K: V]) -> [K: V] {
    var lhs: [K: V] = lhs
    for (key, value) in rhs {
        lhs[key] = value
    }
    return lhs
}

// MARK: Array.remove()

extension Array where Element: Equatable
{
    @discardableResult public mutating func remove(element: Element, first: Bool = false) -> [Element] {
        return self.remove(elements: [element], first: first)
    }

    @discardableResult public mutating func remove(elements: [Element], first: Bool = false) -> [Element] {
        let filter: [Element] = elements
        let all: Bool = !first
        var array: [Element] = []
        var removed: [Element] = []

        for element in self {
            if (all || !removed.contains(element)) && filter.contains(element) {
                removed.append(element)
            } else {
                array.append(element)
            }
        }

        self = array
        return removed
    }

    @discardableResult public mutating func removeFirst(_ filter: (Element) -> Bool) -> Element? {
        for (i, element) in self.enumerated() {
            if filter(element) {
                self.remove(at: i)
                return element
            }
        }
        return nil
    }
}

// Array.recursiveFlatMap()

extension Array
{
    @discardableResult public func flatMap(_ transform: (Element) -> [Element], depth: Int) -> [Element] {
        var flatArray: [Element] = []

        for element in self {
            flatArray += [element] + (depth == 0 ? [] : transform(element).flatMap(transform, depth: depth > 0 ? depth - 1 : depth))
        }

        return flatArray
    }
}

infix operator ≡: AssignmentPrecedence

public func ≡<T>(lhs: inout T, rhs: T) -> T {
    lhs = rhs
    return lhs
}