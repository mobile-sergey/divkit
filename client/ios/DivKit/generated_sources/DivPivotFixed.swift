// Generated code. Do not modify.

import CoreFoundation
import Foundation

import CommonCore
import Serialization
import TemplatesSupport

public final class DivPivotFixed {
  public static let type: String = "pivot-fixed"
  public let unit: Expression<DivSizeUnit> // default value: dp
  public let value: Expression<Int>?

  public func resolveUnit(_ resolver: ExpressionResolver) -> DivSizeUnit {
    resolver
      .resolveStringBasedValue(expression: unit, initializer: DivSizeUnit.init(rawValue:)) ??
      DivSizeUnit.dp
  }

  public func resolveValue(_ resolver: ExpressionResolver) -> Int? {
    resolver.resolveNumericValue(expression: value)
  }

  static let unitValidator: AnyValueValidator<DivSizeUnit> =
    makeNoOpValueValidator()

  init(
    unit: Expression<DivSizeUnit>? = nil,
    value: Expression<Int>? = nil
  ) {
    self.unit = unit ?? .value(.dp)
    self.value = value
  }
}

#if DEBUG
extension DivPivotFixed: Equatable {
  public static func ==(lhs: DivPivotFixed, rhs: DivPivotFixed) -> Bool {
    guard
      lhs.unit == rhs.unit,
      lhs.value == rhs.value
    else {
      return false
    }
    return true
  }
}
#endif

extension DivPivotFixed: Serializable {
  public func toDictionary() -> [String: ValidSerializationValue] {
    var result: [String: ValidSerializationValue] = [:]
    result["type"] = Self.type
    result["unit"] = unit.toValidSerializationValue()
    result["value"] = value?.toValidSerializationValue()
    return result
  }
}
