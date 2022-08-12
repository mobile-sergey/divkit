// Copyright 2022 Yandex LLC. All rights reserved.

import CoreGraphics

import CommonCore
import LayoutKit

extension DivSizeUnit {
  func makeScaledValue(_ value: Int) -> CGFloat {
    CGFloat(value) / scale
  }

  func makeScaledValue(_ value: Double) -> CGFloat {
    CGFloat(value) / scale
  }

  private var scale: CGFloat {
    switch self {
    case .px:
      return PlatformDescription.screenScale()
    case .dp, .sp:
      return 1
    }
  }
}
