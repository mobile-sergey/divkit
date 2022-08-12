// Copyright 2021 Yandex LLC. All rights reserved.
// Based on https://github.com/mohn93/AdvancedPageControl

import UIKit

import CommonCore

final class PageIndicatorView: UIView {
  var currentIndexPosition: CGFloat {
    get {
      contentLayer.currentIndexPosition
    }
    set {
      contentLayer.currentIndexPosition = newValue
      setNeedsDisplay()
    }
  }

  var numberOfPages: Int {
    get {
      contentLayer.numberOfPages
    }
    set {
      contentLayer.numberOfPages = newValue
      setNeedsDisplay()
    }
  }

  var configuration: PageIndicatorConfiguration {
    get {
      contentLayer.configuration
    }
    set {
      contentLayer.configuration = newValue
      setNeedsDisplay()
    }
  }

  private var contentLayer: ScrollPageIndicatorLayer {
    layer as! ScrollPageIndicatorLayer
  }

  override class var layerClass: AnyClass { ScrollPageIndicatorLayer.self }

  init() {
    super.init(frame: .zero)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    backgroundColor = .clear
  }

  override func draw(_: CGRect) {
    // overriden draw is required for redrawing of layer
  }
}
