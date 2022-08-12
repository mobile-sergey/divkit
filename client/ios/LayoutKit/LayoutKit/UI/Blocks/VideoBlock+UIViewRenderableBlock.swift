// Copyright 2022 Yandex LLC. All rights reserved.

import AVFoundation
import Foundation
import UIKit

import CommonCore

extension VideoBlock {
  public static func makeBlockView() -> BlockView {
    VideoBlockView()
  }

  public func canConfigureBlockView(_ view: BlockView) -> Bool {
    view is VideoBlockView
  }

  public func configureBlockView(
    _ view: BlockView,
    observer _: ElementStateObserver?,
    overscrollDelegate _: ScrollDelegate?,
    renderingDelegate _: RenderingDelegate?
  ) {
    let videoView = view as! VideoBlockView
    if videoView.videoAssetHolder?.url != videoAssetHolder.url {
      videoView.videoAssetHolder = videoAssetHolder
    }
  }
}

private final class VideoBlockView: BlockView {
  var videoAssetHolder: VideoBlock.VideoAssetHolder! {
    didSet {
      configurePlayer(with: videoAssetHolder.playerItem)
    }
  }

  init() {
    super.init(frame: .zero)
    playerLayer.player = avPlayer
    playerLayer.videoGravity = .resizeAspectFill
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let avPlayer = AVQueuePlayer()
  private var playerLooper: AVPlayerLooper?

  private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

  override static var layerClass: AnyClass { AVPlayerLayer.self }

  func onVisibleBoundsChanged(from _: CGRect, to _: CGRect) {}

  let effectiveBackgroundColor: UIColor? = nil

  private func configurePlayer(with playerItem: AVPlayerItem) {
    avPlayer.removeAllItems()
    playerLooper = AVPlayerLooper(player: avPlayer, templateItem: playerItem)
    avPlayer.play()
  }
}
