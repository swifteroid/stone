import Foundation

/// `AnyObject` married `Equatable`… 💏 `NSObject` does it out of the box, no reason why other classes shouldn't, imho. At least on
/// practice this always comes in handy.
public protocol Identifiable: class, Hashable
{
}

extension Identifiable
{
    public var hashValue: Int { return ObjectIdentifier(self).hashValue }
    public static func ==(lhs: Self, rhs: Self) -> Bool { return lhs === rhs }
}