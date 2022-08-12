// Generated code. Do not modify.

import CoreFoundation
import Foundation

import CommonCore
import Serialization
import TemplatesSupport

public final class EntityWithArray {
  public static let type: String = "entity_with_array"
  public let array: [Entity] // at least 1 elements

  static let arrayValidator: AnyArrayValueValidator<Entity> =
    makeArrayValidator(minItems: 1)

  init(array: [Entity]) {
    self.array = array
  }
}

#if DEBUG
extension EntityWithArray: Equatable {
  public static func ==(lhs: EntityWithArray, rhs: EntityWithArray) -> Bool {
    guard
      lhs.array == rhs.array
    else {
      return false
    }
    return true
  }
}
#endif
