import Foundation

/// High-level lock implementation using fast unfair lock whenever available and `NSLock` on older systems. Doesn't do anything special 
/// besides reducing boilerplate. Below example is a general purpose use with `defer` and mixed atomic and non-atomic code.
///
///     func method() {
///         var isLocked: Bool = self.lock.lock()
///         defer { self.lock.unlock(isLocked) }
///         if !condition { return }
///         // Atomic code…
///         self.lock.unlock(&isLocked)
///         // Non-atomic code…
///     }
///
/// Unfair lock is much faster, spin locks are deprecated and unsafe, see https://gist.github.com/steipete/36350a8a60693d440954b95ea6cbbafc.
final public class Lock
{
    deinit {
        if #available(macOS 10.12, *) {
            let primitive: os_unfair_lock_t = self.primitive as! os_unfair_lock_t
            primitive.deinitialize(count: 1)
            primitive.deallocate()
        }
    }

    public init() {
        if #available(macOS 10.12, *) {
            let primitive: os_unfair_lock_t = os_unfair_lock_t.allocate(capacity: 1)
            primitive.initialize(to: os_unfair_lock())
            self.primitive = primitive
        } else {
            self.primitive = NSLock()
        }
    }

    /// Stores primitive lock reference, either `NSLock` or `os_unfair_lock_t`.
    private let primitive: Any

    /// Perform locked atomic block operation with optional returned value.  
    @discardableResult public func atomic<T>(_ block: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try block()
    }

    /// Locks the lock with optional lock instruction specifying if the lock should be locked. It can be
    /// passed in when locally storing the lock state to avoid boilerplate `if isLocked` checks.
    /// - parameter lock: If `true` locks the lock, does nothing otherwise.
    /// - returns: `true` if locked, `false` if not.
    @discardableResult public func lock(_ lock: Bool = true) -> Bool {
        if #available(macOS 10.12, *) {
            if lock { os_unfair_lock_lock(self.primitive as! os_unfair_lock_t) }
        } else {
            if lock { (self.primitive as! NSLock).lock() }
        }
        return lock
    }

    /// Locks the lock with updatable `inout` state argument.
    /// - parameter isLocked: Specifies whether lock is currently locked in which case does nothing, otherwise
    ///   locks the lock and updates the value.
    /// - returns: `true` if locked, `false` if not.
    @discardableResult public func lock(_ isLocked: inout Bool) -> Bool {
        if isLocked == false { isLocked = !self.lock() }
        return isLocked
    }

    /// Unlocks the lock with optional unlock instruction specifying if the lock should be unlocked. It can be
    /// passed in when locally storing the lock state to avoid boilerplate `if isLocked` checks.
    /// - parameter unlock: If `true` unlocks the lock, does nothing otherwise.
    /// - returns: `true` if locked, `false` if not.
    @discardableResult public func unlock(_ unlock: Bool = true) -> Bool {
        if #available(macOS 10.12, *) {
            if unlock { os_unfair_lock_unlock(self.primitive as! os_unfair_lock_t) }
        } else {
            if unlock { (self.primitive as! NSLock).unlock() }
        }
        return unlock
    }

    /// Unlocks the lock with updatable `inout` state argument.
    /// - parameter isLocked: Specifies whether lock is currently locked in which case unlocks it and updates
    ///   the value, otherwise does nothing.
    /// - returns: `true` if locked, `false` if not.
    @discardableResult public func unlock(_ isLocked: inout Bool) -> Bool {
        if isLocked == true { isLocked = !self.unlock() }
        return isLocked
    }
}