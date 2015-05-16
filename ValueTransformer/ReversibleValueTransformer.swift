//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Lustre

public struct ReversibleValueTransformer<ForwardResult: ResultType, ReverseResult: ResultType>: ReversibleValueTransformerType {
    public typealias ForwardInput = ReverseResult.Value
    public typealias ReverseInput = ForwardResult.Value
    
    private let transformClosure: ForwardInput -> ForwardResult
    private let reverseTransformClosure: ReverseInput -> ReverseResult

    public init(transformClosure: ForwardInput -> ForwardResult, reverseTransformClosure: ReverseInput -> ReverseResult) {
        self.transformClosure = transformClosure
        self.reverseTransformClosure = reverseTransformClosure
    }
    
    public func transform(value: ForwardInput) -> ForwardResult {
        return transformClosure(value)
    }
    
    public func forwardTransform(value: ForwardInput) -> ForwardResult {
        return transformClosure(value)
    }

    public func reverseTransform(transformedValue: ReverseInput) -> ReverseResult {
        return reverseTransformClosure(transformedValue)
    }
}
