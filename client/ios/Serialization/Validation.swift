// Copyright 2017 Yandex LLC. All rights reserved.

import CoreFoundation
import Foundation

public protocol ValueValidator {
  associatedtype T
  func isValid(_ value: T) -> Bool
}

public protocol ArrayValueValidator: ValueValidator {
  var isPartialDeserializationAllowed: Bool { get }
}

public class AnyValueValidator<T>: ValueValidator {
  private let validate: (T) -> Bool

  public init<Validator: ValueValidator>(_ wrapped: Validator) where Validator.T == T {
    validate = wrapped.isValid
  }

  public init(isValid: @escaping (T) -> Bool) {
    validate = isValid
  }

  public func isValid(_ value: T) -> Bool {
    validate(value)
  }
}

public final class AnyArrayValueValidator<U>: AnyValueValidator<[U]>, ArrayValueValidator {
  public let isPartialDeserializationAllowed: Bool

  public init(
    arrayValidator: @escaping ([U]) -> Bool,
    isPartialDeserializationAllowed: Bool
  ) {
    self.isPartialDeserializationAllowed = isPartialDeserializationAllowed
    super.init(isValid: arrayValidator)
  }
}

private func alwaysTrueValidator<T>() -> ((T) -> Bool) {
  return { _ in true }
}

public func makeCFStringValidator(minLength: Int) -> AnyValueValidator<CFString> {
  AnyValueValidator(isValid: { CFStringGetLength($0) >= minLength })
}

private func isStringValid(
  _ str: String,
  minLength: Int = 0,
  regex: String? = nil
) -> Bool {
  guard str.count >= minLength else {
    return false
  }

  return regex.map { (try? str.matchesPattern($0)) ?? true } ?? true
}

public func makeStringValidator(
  minLength: Int = 0,
  regex: String? = nil
) -> AnyValueValidator<String> {
  let isValid: (String) -> Bool = { str in
    isStringValid(str, minLength: minLength, regex: regex)
  }
  return AnyValueValidator(isValid: isValid)
}

public func makeURLValidator(schemes: [String]) -> AnyValueValidator<URL> {
  AnyValueValidator(isValid: { $0.scheme.map(schemes.contains) ?? false })
}

public func makeValueValidator<T>(
  valueValidator: @escaping (T) -> Bool
) -> AnyValueValidator<T> {
  AnyValueValidator(isValid: valueValidator)
}

public func makeNoOpValueValidator<T>() -> AnyValueValidator<T> {
  AnyValueValidator(isValid: alwaysTrueValidator())
}

public func makeArrayValidator<T>(minItems: Int) -> AnyArrayValueValidator<T> {
  AnyArrayValueValidator(
    arrayValidator: { $0.count >= minItems },
    isPartialDeserializationAllowed: true
  )
}

public func makeStrictArrayValidator<T>(minItems: Int) -> AnyArrayValueValidator<T> {
  AnyArrayValueValidator(
    arrayValidator: { $0.count >= minItems },
    isPartialDeserializationAllowed: false
  )
}

public func makeNoOpArrayValidator<T>() -> AnyArrayValueValidator<T> {
  AnyArrayValueValidator(
    arrayValidator: alwaysTrueValidator(),
    isPartialDeserializationAllowed: true
  )
}
