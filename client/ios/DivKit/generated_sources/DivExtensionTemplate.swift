// Generated code. Do not modify.

import CoreFoundation
import Foundation

import CommonCore
import Serialization
import TemplatesSupport

public final class DivExtensionTemplate: TemplateValue, TemplateDeserializable {
  public let id: Field<String>? // at least 1 char
  public let params: Field<[String: Any]>?

  public convenience init(dictionary: [String: Any], templateToType _: TemplateToType) throws {
    do {
      self.init(
        id: try dictionary.getOptionalField("id"),
        params: try dictionary.getOptionalField("params")
      )
    } catch let DeserializationError.invalidFieldRepresentation(
      field: field,
      representation: representation
    ) {
      throw DeserializationError.invalidFieldRepresentation(
        field: "div-extension_template." + field,
        representation: representation
      )
    }
  }

  init(
    id: Field<String>? = nil,
    params: Field<[String: Any]>? = nil
  ) {
    self.id = id
    self.params = params
  }

  private static func resolveOnlyLinks(
    context: Context,
    parent: DivExtensionTemplate?
  ) -> DeserializationResult<DivExtension> {
    let idValue = parent?.id?
      .resolveValue(context: context, validator: ResolvedValue.idValidator) ?? .noValue
    let paramsValue = parent?.params?.resolveOptionalValue(
      context: context,
      validator: ResolvedValue.paramsValidator
    ) ?? .noValue
    var errors = mergeErrors(
      idValue.errorsOrWarnings?.map { .right($0.asError(deserializing: "id", level: .error)) },
      paramsValue.errorsOrWarnings?
        .map { .right($0.asError(deserializing: "params", level: .warning)) }
    )
    if case .noValue = idValue {
      errors
        .append(.right(FieldError(fieldName: "id", level: .error, error: .requiredFieldIsMissing)))
    }
    guard
      let idNonNil = idValue.value
    else {
      return .failure(NonEmptyArray(errors)!)
    }
    let result = DivExtension(
      id: idNonNil,
      params: paramsValue.value
    )
    return errors
      .isEmpty ? .success(result) : .partialSuccess(result, warnings: NonEmptyArray(errors)!)
  }

  public static func resolveValue(
    context: Context,
    parent: DivExtensionTemplate?,
    useOnlyLinks: Bool
  ) -> DeserializationResult<DivExtension> {
    if useOnlyLinks {
      return resolveOnlyLinks(context: context, parent: parent)
    }
    var idValue: DeserializationResult<String> = parent?.id?
      .value(validatedBy: ResolvedValue.idValidator) ?? .noValue
    var paramsValue: DeserializationResult<[String: Any]> = parent?.params?
      .value(validatedBy: ResolvedValue.paramsValidator) ?? .noValue
    context.templateData.forEach { key, __dictValue in
      switch key {
      case "id":
        idValue = deserialize(__dictValue, validator: ResolvedValue.idValidator)
          .merged(with: idValue)
      case "params":
        paramsValue = deserialize(__dictValue, validator: ResolvedValue.paramsValidator)
          .merged(with: paramsValue)
      case parent?.id?.link:
        idValue = idValue
          .merged(with: deserialize(__dictValue, validator: ResolvedValue.idValidator))
      case parent?.params?.link:
        paramsValue = paramsValue
          .merged(with: deserialize(__dictValue, validator: ResolvedValue.paramsValidator))
      default: break
      }
    }
    var errors = mergeErrors(
      idValue.errorsOrWarnings?
        .map { Either.right($0.asError(deserializing: "id", level: .error)) },
      paramsValue.errorsOrWarnings?
        .map { Either.right($0.asError(deserializing: "params", level: .warning)) }
    )
    if case .noValue = idValue {
      errors
        .append(.right(FieldError(fieldName: "id", level: .error, error: .requiredFieldIsMissing)))
    }
    guard
      let idNonNil = idValue.value
    else {
      return .failure(NonEmptyArray(errors)!)
    }
    let result = DivExtension(
      id: idNonNil,
      params: paramsValue.value
    )
    return errors
      .isEmpty ? .success(result) : .partialSuccess(result, warnings: NonEmptyArray(errors)!)
  }

  private func mergedWithParent(templates _: Templates) throws -> DivExtensionTemplate {
    self
  }

  public func resolveParent(templates: Templates) throws -> DivExtensionTemplate {
    try mergedWithParent(templates: templates)
  }
}
