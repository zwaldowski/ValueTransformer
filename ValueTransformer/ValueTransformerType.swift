//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

public protocol ValueTransformerType {
    typealias OriginalValue
    typealias TransformedValue

    func transform(value: OriginalValue) throws -> TransformedValue
}

// MARK: - Basics

@available(*, unavailable, message="Use the 'transform(_:)' method on the transformer.")
public func transform<V: ValueTransformerType>(valueTransformer: V, value: V.OriginalValue) throws -> V.TransformedValue {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="Use the 'transform(_:)' method on the transformer.")
public func transform<V: ValueTransformerType>(valueTransformer: V) -> V.OriginalValue throws -> V.TransformedValue {
    fatalError("unavailable function can't be called")
}
