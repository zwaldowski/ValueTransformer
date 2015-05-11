//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public protocol ValueTransformerType {
    typealias Value
    typealias TransformResult: ResultType

    func transform(value: Value) -> TransformResult
}

// MARK: - Basics

@availability(*, introduced=1.0, deprecated=2.1, message="Use valueTransformer.transform(value).")
public func transform<V: ValueTransformerType>(valueTransformer: V, value: V.Value) -> V.TransformResult {
    return valueTransformer.transform(value)
}

public func transform<V: ValueTransformerType>(valueTransformer: V) -> V.Value -> V.TransformResult {
    return { value in
        valueTransformer.transform(value)
    }
}
