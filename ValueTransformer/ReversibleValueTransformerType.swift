//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public protocol ReversibleValueTransformerType: ValueTransformerType {
    func reverseTransform(transformedValue: TransformedValue) throws -> OriginalValue
}

// MARK: - Basics

@available(*, introduced=1.0, deprecated=2.1, message="Use valueTransformer.reverseTransform(transformedValue).")
public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, transformedValue: V.TransformedValue) throws -> V.OriginalValue {
    return try reversibleValueTransformer.reverseTransform(transformedValue)
}

public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> V.TransformedValue throws -> V.OriginalValue {
    return reversibleValueTransformer.reverseTransform
}
