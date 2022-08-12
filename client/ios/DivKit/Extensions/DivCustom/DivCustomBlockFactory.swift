// Copyright 2021 Yandex LLC. All rights reserved.

import LayoutKit

public protocol DivCustomBlockFactory {
  func makeBlock(data: DivCustomData, context: DivBlockModelingContext) -> Block
}

public struct EmptyDivCustomBlockFactory: DivCustomBlockFactory {
  public init() {}

  public func makeBlock(data: DivCustomData, context _: DivBlockModelingContext) -> Block {
    DivKitLogger.error("No block factory for DivCustom: \(data.name)")
    return SeparatorBlock()
  }
}
