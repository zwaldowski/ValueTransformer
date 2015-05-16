//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public protocol ValueTransformerType {
    typealias Input
    typealias TransformResult: ResultType

    func transform(value: Input) -> TransformResult
}

// MARK: - Basics

public func transform<V: ValueTransformerType>(valueTransformer: V) -> V.Input -> V.TransformResult {
    return { value in
        valueTransformer.transform(value)
    }
}
