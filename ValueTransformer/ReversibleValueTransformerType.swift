//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public protocol ReversibleValueTransformerType {
    typealias ForwardTransformResult: ResultType
    typealias ReverseTransformResult: ResultType
    
    func forwardTransform(transformedValue: ReverseTransformResult.Value) -> ForwardTransformResult
    func reverseTransform(transformedValue: ForwardTransformResult.Value) -> ReverseTransformResult
}

// MARK: - Basics

public func forward<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ValueTransformer<V.ReverseTransformResult.Value, V.ForwardTransformResult> {
    return ValueTransformer(transformClosure: forwardTransform(reversibleValueTransformer))
}

public func forwardTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> V.ReverseTransformResult.Value -> V.ForwardTransformResult {
    return { transformedValue in
        reversibleValueTransformer.forwardTransform(transformedValue)
    }
}

public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> V.ForwardTransformResult.Value -> V.ReverseTransformResult {
    return { transformedValue in
        reversibleValueTransformer.reverseTransform(transformedValue)
    }
}
