// Copyright 2022 Yandex LLC. All rights reserved.

import CoreGraphics
import Foundation

import LayoutKit

extension Binding where T: AdditiveArithmetic & CustomStringConvertible {
  static var zero: Binding<T> {
    self.init(
      name: "zero",
      getValue: { _ in .zero },
      userInterfaceActionFactory: { _, _ in nil }
    )
  }

  init(context: DivBlockModelingContext, name: String) {
    self.init(
      name: name,
      getValue: { context.expressionResolver.getVariableValue(name: $0) ?? .zero },
      userInterfaceActionFactory: { name, value in
        URL(string: "div-action://set_variable?name=\(name)&value=\(value.description)").flatMap {
          DivAction(logId: "binding", url: .value($0))
        }?.uiAction(context: context.actionContext)
      }
    )
  }
}
