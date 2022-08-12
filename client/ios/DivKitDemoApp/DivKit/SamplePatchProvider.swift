import Foundation

import CommonCore
import DivKit
import Networking

struct SamplePatchProvider: DivPatchProvider {
  private let downloader: DivPatchDownloader

  init() {
    self.downloader = DivPatchDownloader(
      requestPerformer: URLRequestPerformer(urlTransform: nil)
    )
  }

  func getPatch(url: URL, completion: @escaping DivPatchProviderCompletion) {
    if url.scheme == "local" {
      completion(parsePatch(fileName: url.host ?? ""))
    } else {
      downloader.getPatch(url: url, completion: completion)
    }
  }

  func cancelRequests() {
    downloader.cancelRequests()
  }

  private func parsePatch(fileName: String) -> Result<DivPatch, Error> {
    let url = Bundle.main.url(
      forResource: fileName,
      withExtension: "json",
      subdirectory: "\(FolderNames.samples)/\(FolderNames.patches)"
    )!
    do {
      let data = try Data(contentsOf: url)
      let patch = try parseDivPatch(data)
      return .success(patch)
    } catch {
      return .failure(error)
    }
  }
}
