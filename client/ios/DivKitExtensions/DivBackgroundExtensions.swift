// Copyright 2022 Yandex LLC. All rights reserved.

import Foundation

import DivKit

extension DivBackground {
  func makeImageURL(with expressionResolver: ExpressionResolver) -> URL? {
    switch self {
    case let .divImageBackground(imageBackground):
      return imageBackground.resolveImageUrl(expressionResolver)
    case .divGradientBackground, .divSolidBackground:
      return nil
    }
  }
}
