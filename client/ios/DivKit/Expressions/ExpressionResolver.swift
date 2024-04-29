import Foundation

import CommonCorePublic

public typealias ExpressionErrorTracker = (ExpressionError) -> Void

public final class ExpressionResolver {
  public typealias VariableTracker = (Set<DivVariableName>) -> Void

  private let functionsProvider: FunctionsProvider
  private let errorTracker: ExpressionErrorTracker

  init(
    functionsProvider: FunctionsProvider,
    errorTracker: @escaping ExpressionErrorTracker
  ) {
    self.functionsProvider = functionsProvider
    self.errorTracker = errorTracker
  }

  public init(
    variables: DivVariables,
    persistentValuesStorage: DivPersistentValuesStorage,
    errorTracker: ExpressionErrorTracker? = nil,
    variableTracker: @escaping VariableTracker = { _ in }
  ) {
    self.functionsProvider = FunctionsProvider(
      variableValueProvider: {
        let variableName = DivVariableName(rawValue: $0)
        variableTracker([variableName])
        return variables[variableName]?.typedValue()
      },
      persistentValuesStorage: persistentValuesStorage
    )
    self.errorTracker = { errorTracker?($0) }
  }

  public func resolveString(_ expression: String) -> String? {
    resolveString(expression, initializer: { $0 })
  }

  public func resolveColor(_ expression: String) -> Color? {
    resolveString(expression, initializer: Color.color(withHexString:))
  }

  public func resolveUrl(_ expression: String) -> URL? {
    resolveString(expression, initializer: URL.init(string:))
  }

  public func resolveEnum<T: RawRepresentable>(
    _ expression: String
  ) -> T? where T.RawValue == String {
    resolveString(expression, initializer: T.init(rawValue:))
  }

  public func resolveNumeric<T>(_ expression: String) -> T? {
    if let link = ExpressionLink<T>(rawValue: expression) {
      return resolveNumeric(.link(link))
    }
    return nil
  }

  func resolveString<T>(
    _ expression: Expression<T>?,
    initializer: (String) -> T? = { $0 }
  ) -> T? {
    switch expression {
    case let .value(value):
      resolveEscaping(value)
    case let .link(link):
      evaluateString(link: link, initializer: initializer)
    case .none:
      nil
    }
  }

  func resolveEnum<T: RawRepresentable>(
    _ expression: Expression<T>?
  ) -> T? where T.RawValue == String {
    resolveString(expression, initializer: T.init(rawValue:))
  }

  func resolveColor(
    _ expression: Expression<Color>?
  ) -> Color? {
    resolveString(expression, initializer: Color.color(withHexString:))
  }

  func resolveUrl(
    _ expression: Expression<URL>?
  ) -> URL? {
    resolveString(expression, initializer: URL.init(string:))
  }

  func resolveNumeric<T>(
    _ expression: Expression<T>?
  ) -> T? {
    switch expression {
    case let .value(value):
      value
    case let .link(link):
      evaluateSingleItem(link: link)
    case .none:
      nil
    }
  }

  func resolveArray(
    _ expression: Expression<[Any]>?
  ) -> [Any]? {
    switch expression {
    case let .value(value):
      value
    case let .link(link):
      evaluateSingleItem(link: link)
    case .none:
      nil
    }
  }

  func resolveDict(
    _ expression: Expression<[String: Any]>?
  ) -> [String: Any]? {
    switch expression {
    case let .value(value):
      value
    case let .link(link):
      evaluateSingleItem(link: link)
    case .none:
      nil
    }
  }

  private func resolveEscaping<T>(_ value: T?) -> T? {
    guard var value = value as? String, value.contains("\\") else {
      return value
    }

    var index = value.startIndex
    let escapingValues = ["@{", "'", "\\"]

    while index < value.endIndex {
      if value[index] == "\\" {
        let nextIndex = value.index(index, offsetBy: 1)
        let next = value[nextIndex...]

        if let escaped = escapingValues.first(where: { next.starts(with: $0) }) {
          let distance = value.distance(from: value.startIndex, to: index)
          value.remove(at: index)
          index = value.index(value.startIndex, offsetBy: distance + escaped.count)
        } else {
          if next.isEmpty {
            errorTracker(ExpressionError("Error tokenizing '\(value)'.", expression: value))
          } else {
            errorTracker(ExpressionError("Incorrect string escape", expression: value))
          }
          return nil
        }
      } else {
        index = value.index(after: index)
      }
    }

    return value as? T
  }

  private func evaluateSingleItem<T>(link: ExpressionLink<T>) -> T? {
    guard link.items.count == 1, let item = link.items.first else {
      errorTracker(ExpressionError("Single expression expected", expression: link.rawValue))
      return nil
    }
    switch item {
    case let .calcExpression(expression):
      do {
        return try validatedValue(value: evaluate(expression), link: link)
      } catch {
        errorTracker(ExpressionError(error.localizedDescription, expression: link.rawValue))
        return nil
      }
    case let .nestedExpression(nestedLink):
      if let expressionString = evaluateString(link: nestedLink),
         let link = ExpressionLink<T>(
           rawValue: "@{\(expressionString)}",
           validator: link.validator,
           errorTracker: errorTracker,
           resolveNested: false
         ) {
        return evaluateSingleItem(link: link)
      }
      return nil
    case .string:
      errorTracker(ExpressionError("Expression expected", expression: link.rawValue))
      return nil
    }
  }

  private func evaluateString<T>(
    link: ExpressionLink<T>,
    initializer: (String) -> T? = { $0 }
  ) -> T? {
    var stringValue = ""
    for item in link.items {
      switch item {
      case let .calcExpression(expression):
        do {
          stringValue += try evaluate(expression)
        } catch {
          errorTracker(ExpressionError(error.localizedDescription, expression: link.rawValue))
          return nil
        }
      case let .string(value):
        stringValue += value
      case let .nestedExpression(nestedLink):
        if let expressionString = evaluateString(link: nestedLink) {
          let link = ExpressionLink<String>(
            rawValue: "@{\(expressionString)}",
            errorTracker: errorTracker,
            resolveNested: false
          )
          if let link, let value = evaluateString(link: link) {
            stringValue += value
          }
        }
      }
    }
    guard let result = initializer(stringValue) else {
      errorTracker(
        ExpressionError(
          "Failed to initalize \(T.self) from string value: \(stringValue)",
          expression: link.rawValue
        )
      )
      return nil
    }
    return validatedValue(value: result, link: link)
  }

  private func evaluate<T>(_ expression: CalcExpression) throws -> T {
    let value = try expression.evaluate(evaluators: functionsProvider.evaluators)
    if let castedValue: T = ExpressionValueConverter.cast(value) {
      return castedValue
    }
    throw CalcExpression.Error.message(
      "Result type \(Swift.type(of: value)) is not compatible with expected type \(T.self)"
    )
  }

  private func validatedValue<T>(
    value: T?,
    link: ExpressionLink<T>
  ) -> T? {
    if let validator = link.validator, let value {
      if validator.isValid(value) {
        return value
      } else {
        errorTracker(
          ExpressionError("Failed to validate value: \(value)", expression: link.rawValue)
        )
        return nil
      }
    }
    return value
  }

  private func resolveString<T>(
    _ expression: String,
    initializer: (String) -> T?
  ) -> T? {
    if let link = ExpressionLink<T>(rawValue: expression) {
      return evaluateString(link: link, initializer: initializer)
    }
    return initializer(expression)
  }
}
