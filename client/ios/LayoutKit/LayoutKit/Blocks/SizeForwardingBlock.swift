// Copyright 2021 Yandex LLC. All rights reserved.

import CoreGraphics

import CommonCore

public protocol SizeForwardingBlock: Block {
  var sizeProvider: Block { get }
}

extension SizeForwardingBlock {
  public var isVerticallyResizable: Bool { sizeProvider.isVerticallyResizable }
  public var isHorizontallyResizable: Bool { sizeProvider.isHorizontallyResizable }

  public var isVerticallyConstrained: Bool { sizeProvider.isVerticallyConstrained }
  public var isHorizontallyConstrained: Bool { sizeProvider.isHorizontallyConstrained }

  public var intrinsicContentWidth: CGFloat {
    sizeProvider.intrinsicContentWidth
  }

  public func intrinsicContentHeight(forWidth width: CGFloat) -> CGFloat {
    sizeProvider.intrinsicContentHeight(forWidth: width)
  }

  public var widthOfHorizontallyNonResizableBlock: CGFloat {
    sizeProvider.widthOfHorizontallyNonResizableBlock
  }

  public func heightOfVerticallyNonResizableBlock(forWidth width: CGFloat) -> CGFloat {
    sizeProvider.heightOfVerticallyNonResizableBlock(forWidth: width)
  }

  public var weightOfVerticallyResizableBlock: LayoutTrait.Weight {
    sizeProvider.weightOfVerticallyResizableBlock
  }

  public var weightOfHorizontallyResizableBlock: LayoutTrait.Weight {
    sizeProvider.weightOfHorizontallyResizableBlock
  }
}
