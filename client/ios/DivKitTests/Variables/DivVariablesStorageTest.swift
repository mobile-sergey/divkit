// Copyright 2022 Yandex LLC. All rights reserved.

@testable import DivKit

import XCTest

import CommonCore

final class DivVariablesStorageTest: XCTestCase {
  private let storage = DivVariablesStorage()
  private let disposePool = AutodisposePool()

  private var event: DivVariablesStorage.ChangeEvent?

  override func setUp() {
    storage.changeEvents
      .addObserver { [unowned self] in self.event = $0 }
      .dispose(in: disposePool)
  }

  func test_makeVariables_ReturnsVariablesByCardId() {
    storage.set(cardId: cardId, variables: variables)

    let anotherVariables: DivVariables = [
      "string_var": .string("another value"),
      "int_var": .integer(200),
    ]
    storage.set(cardId: "another_card", variables: anotherVariables)

    XCTAssertEqual(variables, storage.makeVariables(for: cardId))
    XCTAssertEqual(anotherVariables, storage.makeVariables(for: "another_card"))
  }

  func test_makeVariables_ReturnsNilForUnknownCardId() {
    storage.set(cardId: cardId, variables: variables)

    XCTAssertEqual([:], storage.makeVariables(for: "unknown"))
  }

  func test_makeVariables_MergesGlobalVariables() {
    let globalVariables: DivVariables = [
      "global_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: false)
    storage.set(cardId: cardId, variables: variables)

    XCTAssertEqual(globalVariables + variables, storage.makeVariables(for: cardId))
  }

  func test_set_RewritesLocalVariables() {
    storage.set(cardId: cardId, variables: variables)

    let newVariables: DivVariables = [
      "string_var": .string("new value"),
      "int_var": .integer(200),
    ]
    storage.set(cardId: cardId, variables: newVariables)

    XCTAssertEqual(newVariables, makeVariables())
  }

  func test_LocalVaraibleShadowsGlobalVariable_LocalsSetAfterGlobals() {
    let globalVariables: DivVariables = [
      "string_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: false)
    storage.set(cardId: cardId, variables: variables)

    XCTAssertEqual(.string("value"), makeVariables()["string_var"])
  }

  func test_LocalVaraibleShadowsGlobalVariable_LocalsSetBeforeGlobals() {
    storage.set(cardId: cardId, variables: variables)

    let globalVariables: DivVariables = [
      "string_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: false)

    XCTAssertEqual(.string("value"), makeVariables()["string_var"])
  }

  func test_update_UpdatesStringVariable() {
    storage.set(cardId: cardId, variables: variables)
    storage.update(cardId: cardId, name: "string_var", value: "new value")

    XCTAssertEqual(.string("new value"), makeVariables()["string_var"])
  }

  func test_update_UpdatesNumberVariable() {
    storage.set(cardId: cardId, variables: variables)
    storage.update(cardId: cardId, name: "number_var", value: "234.567")

    XCTAssertEqual(.number(234.567), makeVariables()["number_var"])
  }

  func test_update_DoesNothing_ForUnknownVariable() {
    storage.update(cardId: cardId, name: "string_var", value: "new value")

    XCTAssertEqual([:], makeVariables())
  }

  func test_update_DoesNothing_ForInvalidValue() {
    storage.set(cardId: cardId, variables: variables)
    storage.update(cardId: cardId, name: "int_var", value: "not a number")

    XCTAssertEqual(variables, makeVariables())
  }

  func test_update_SendsUpdateEvent() {
    storage.set(cardId: cardId, variables: variables)
    storage.update(cardId: cardId, name: "string_var", value: "new value")

    XCTAssertEqual(.local(cardId, ["string_var"]), event?.kind)
    XCTAssertEqual(variables, event?.variables.old.makeVariables(for: cardId))
    XCTAssertEqual(makeVariables(), event?.variables.new.makeVariables(for: cardId))
  }

  func test_set_SendsUpdateEvent() {
    storage.set(cardId: cardId, variables: variables)
    XCTAssertEqual(.local(cardId, Set(variables.keys)), event?.kind)
  }

  func test_update_DoesNotSendUpdateEventForSameValue() {
    storage.set(cardId: cardId, variables: variables)
    event = nil
    storage.update(cardId: cardId, name: "string_var", value: "value")

    XCTAssertNil(event)
  }

  func test_update_UpdatesGlobalVariable() {
    let globalVariables: DivVariables = [
      "global_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: false)

    storage.update(cardId: cardId, name: "global_var", value: "new value")

    XCTAssertEqual(.string("new value"), makeVariables()["global_var"])
  }

  func test_update_DoesNotUpdateShadowedGlobalVariable() {
    let globalVariables: DivVariables = [
      "string_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: false)
    storage.set(cardId: cardId, variables: variables)

    storage.update(cardId: cardId, name: "string_var", value: "new value")

    XCTAssertEqual(.string("global value"), makeVariables(cardId: "unknown")["string_var"])
  }

  func test_update_UpdatesShadowedInAnotherCardGlobalVariable() {
    let globalVariables: DivVariables = [
      "string_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: false)
    storage.set(cardId: cardId, variables: variables)

    storage.update(cardId: "another_card", name: "string_var", value: "new value")

    XCTAssertEqual(.string("new value"), makeVariables(cardId: "another_card")["string_var"])
  }

  func test_setGlobalVariables_SendsUpdateEvent() {
    let globalVariables: DivVariables = [
      "global_var": .string("global value"),
    ]
    storage.set(variables: globalVariables, triggerUpdate: true)

    XCTAssertEqual(.global(["global_var"]), event?.kind)
    XCTAssertEqual([:], event?.variables.old.global)
    XCTAssertEqual(globalVariables, event?.variables.new.global)
  }

  func test_setGlobalVariables_SendsUpdateEvent_ForUpdatedVariablesOnly() {
    storage.set(variables: variables, triggerUpdate: false)

    var newVariables = variables
    newVariables["string_var"] = .string("new value")
    newVariables["int_var"] = .integer(200)
    storage.set(variables: newVariables, triggerUpdate: true)

    XCTAssertEqual(.global(["string_var", "int_var"]), event?.kind)
    XCTAssertEqual(variables, event?.variables.old.global)
    XCTAssertEqual(newVariables, event?.variables.new.global)
  }

  func test_setGlobalVariables_DoesNotSendUpdateEvent_WhenTriggerUpdateIsFalse() {
    storage.set(variables: variables, triggerUpdate: false)

    XCTAssertNil(event)
  }

  private func makeVariables(cardId: DivCardID = cardId) -> DivVariables {
    storage.makeVariables(for: cardId)
  }
}

private let cardId = DivCardID(rawValue: "test_card")

private let variables: DivVariables = [
  "string_var": .string("value"),
  "int_var": .integer(100),
  "number_var": .number(123.34),
  "bool_var": .bool(true),
  "url_var": .url(URL(string: "https://test.url")!),
]
