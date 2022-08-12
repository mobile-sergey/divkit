// Copyright (C) 2018 Yandex LLC. All rights reserved.
// Author: Slava Mirgorod <sl0nius@yandex-team.ru>

import Foundation

import CommonCore

public protocol BlockError: Error {
  var errorMessage: NonEmptyString { get }
  var userInfo: [String: String] { get }
}

// Workaround for swift compiler bug, when protocol is not conforming parent protocol
public func modifyError<T: Error, R>(
  _ modificator: (BlockError) -> T,
  _ block: () throws -> R
) throws -> R {
  do {
    return try block()
  } catch let e as BlockError {
    throw modificator(e)
  }
}

extension BlockError {
  public var userInfo: [String: String] { [:] }
}
