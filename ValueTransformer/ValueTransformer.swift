//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public struct ValueTransformer<Input, Result: ResultType>: ValueTransformerType {
    private let transformClosure: Input -> Result

    public init(transformClosure: Input -> Result) {
        self.transformClosure = transformClosure
    }

    public func transform(value: Input) -> Result {
        return transformClosure(value)
    }
}

extension ValueTransformer {
    public init<V: ValueTransformerType where V.Input == Input, V.TransformResult.Value == Result.Value>(_ valueTransformer: V) {
        self.init(transformClosure: { value in
            valueTransformer.transform(value).map { $0 }
        })
    }
}

