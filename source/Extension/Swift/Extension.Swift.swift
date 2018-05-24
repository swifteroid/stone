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
    public func lowercasedFirst() -> String { return self.isEmpty ? self : self[...self.startIndex].lowercased() + self[self.index(after: self.startIndex)...] }
    public func uppercasedFirst() -> String { return self.isEmpty ? self : self[...self.startIndex].uppercased() + self[self.index(after: self.startIndex)...] }
}

extension Array
{
    public mutating func drain() -> [Element] {
        let elements: [Element] = self
        self.removeAll()
        return elements
    }
}

extension Dictionary
{
    public static func +(lhs: Dictionary, rhs: Dictionary) -> Dictionary {
        return rhs.reduce(into: lhs, { $0[$1.key] = $1.value })
    }
}

/// Array.remove()
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
}

extension Array
{
    @discardableResult public mutating func removeFirst(where predicate: (Element) -> Bool) -> Element? {
        for i in 0 ..< self.count {
            let element: Element = self[i]
            if predicate(element) {
                self.remove(at: i)
                return element
            }
        }
        return nil
    }
}

extension Array
{
    @discardableResult public mutating func popFirst() -> Element? {
        return self.isEmpty ? nil : self.removeFirst()
    }
}

/// Array.recursiveFlatMap()
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

/// Returning assignment operator to provide a much-missed feature of other languages, where assigned value
/// is returned and can be further operated upon, like `if (x =-> y) == nil { throw Error.nil }`.
infix operator =->: AssignmentPrecedence

public func =-><T>(lhs: inout T, rhs: T) -> T {
    lhs = rhs
    return lhs
}