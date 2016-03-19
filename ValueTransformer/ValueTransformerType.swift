//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public protocol ValueTransformerType {
    typealias OriginalValue
    typealias TransformedValue

    func transform(value: OriginalValue) throws -> TransformedValue
}

// MARK: - Basics

@available(*, introduced=1.0, deprecated=2.1, message="Use valueTransformer.transform(value).")
public func transform<V: ValueTransformerType>(valueTransformer: V, value: V.OriginalValue) throws -> V.TransformedValue {
    return try valueTransformer.transform(value)
}

public func transform<V: ValueTransformerType>(valueTransformer: V) -> V.OriginalValue throws -> V.TransformedValue {
    return valueTransformer.transform
}
