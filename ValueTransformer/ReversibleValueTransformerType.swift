//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public protocol ReversibleValueTransformerType: ValueTransformerType {
    typealias ReverseTransformResult: ResultType
    
    func reverseTransform(transformedValue: TransformResult.Value) -> ReverseTransformResult
}

// MARK: - Basics

@availability(*, introduced=1.0, deprecated=2.1, message="Use valueTransformer.reverseTransform(transformedValue).")
public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, transformedValue: V.TransformResult.Value) -> V.ReverseTransformResult {
    return reversibleValueTransformer.reverseTransform(transformedValue)
}

public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> V.TransformResult.Value -> V.ReverseTransformResult {
    return { transformedValue in
        reversibleValueTransformer.reverseTransform(transformedValue)
    }
}
