
import Foundation
import class Foundation.NSSet
import class Foundation.NSMutableString
@testable import class Foundation.NSString

public var x = 0
public var y: UInt = 0

public enum Choice {
  case yes, no, maybeSo
}

// public typealias Callback = () -> Void

// public typealias Pair<T> = (T, T)

public func blah() -> NSString {
  let str = "abc"
  let mut = NSMutableString()
  mut.append(str)
  return mut
}

public func blah2() -> Choice {
  return .yes
}

public func blah3() -> NSString {
  let str = "abc"
  let mut = NSMutableString()
  mut.append(str)
  return mut
}