// Copyright 2021 Yandex LLC. All rights reserved.

public struct Duration: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Equatable {
  public let value: Double

  public init(_ value: Double) {
    precondition(value > 0, "Duration must be positive number")
    self.value = value
  }

  public init(floatLiteral value: Double) {
    self.init(value)
  }

  public init(integerLiteral value: IntegerLiteralType) {
    self.init(Double(value))
  }
}
