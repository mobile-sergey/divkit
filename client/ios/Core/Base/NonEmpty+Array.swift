// Copyright 2019 Yandex LLC. All rights reserved.

public typealias NonEmptyArray<Element> = NonEmpty<[Element]>

extension NonEmpty {
  public init?<E>(_ array: C) where C == [E] {
    guard let head = array.first else {
      return nil
    }
    self.init(head, Array(array.dropFirst()))
  }

  public func asArray() -> [C.Element] {
    Array(self)
  }
}
