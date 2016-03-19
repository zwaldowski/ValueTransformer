//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

public protocol ReversibleValueTransformerType: ValueTransformerType {
    func reverseTransform(transformedValue: TransformedValue) throws -> OriginalValue
}

// MARK: - Basics

@available(*, unavailable, message="Use the 'reverseTransform(_:)' method on the transformer.")
public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, transformedValue: V.TransformedValue) throws -> V.OriginalValue {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="Use the 'reverseTransform(_:)' method on the transformer.")
public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> V.TransformedValue throws -> V.OriginalValue {
    fatalError("unavailable function can't be called")
}
