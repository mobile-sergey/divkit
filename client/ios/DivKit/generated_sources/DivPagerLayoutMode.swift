// Generated code. Do not modify.

import CoreFoundation
import Foundation

import CommonCore
import Serialization
import TemplatesSupport

public enum DivPagerLayoutMode {
  case divPageSize(DivPageSize)
  case divNeighbourPageSize(DivNeighbourPageSize)

  public var value: Serializable {
    switch self {
    case let .divPageSize(value):
      return value
    case let .divNeighbourPageSize(value):
      return value
    }
  }
}

#if DEBUG
extension DivPagerLayoutMode: Equatable {
  public static func ==(lhs: DivPagerLayoutMode, rhs: DivPagerLayoutMode) -> Bool {
    switch (lhs, rhs) {
    case let (.divPageSize(l), .divPageSize(r)):
      return l == r
    case let (.divNeighbourPageSize(l), .divNeighbourPageSize(r)):
      return l == r
    default:
      return false
    }
  }
}
#endif

extension DivPagerLayoutMode: Serializable {
  public func toDictionary() -> [String: ValidSerializationValue] {
    value.toDictionary()
  }
}
