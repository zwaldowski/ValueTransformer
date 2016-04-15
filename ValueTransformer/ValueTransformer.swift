//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public struct ValueTransformer<Value, TransformedValue, Error: ErrorType>: ValueTransformerType {
    private let transformClosure: Value -> Result<TransformedValue, Error>

    public init(transformClosure: Value -> Result<TransformedValue, Error>) {
        self.transformClosure = transformClosure
    }

    public func transform(value: Value) -> Result<TransformedValue, Error> {
        return transformClosure(value)
    }
}

extension ValueTransformer {
    public init<V: ValueTransformerType where V.ValueType == Value, V.TransformedValueType == TransformedValue, V.ErrorType == Error>(_ valueTransformer: V) {
        self.init(transformClosure: { value in
            return valueTransformer.transform(value)
        })
    }
}

// MARK: - Compose

public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformedValueType == W.ValueType, V.ErrorType == W.ErrorType>(left: V, _ right: W) -> ValueTransformer<V.ValueType, W.TransformedValueType, W.ErrorType> {
    return ValueTransformer { value in
        return left.transform(value).flatMap(transform(right))
    }
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformedValueType == W.ValueType, V.ErrorType == W.ErrorType>(lhs: V, rhs: W) -> ValueTransformer<V.ValueType, W.TransformedValueType, W.ErrorType> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.ValueType == W.TransformedValueType, V.ErrorType == W.ErrorType>(lhs: V, rhs: W) -> ValueTransformer<W.ValueType, V.TransformedValueType, V.ErrorType> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.ValueType, V.TransformedValueType?, V.ErrorType> {
    return ValueTransformer { value in
        return valueTransformer.transform(value).map { value in
            return .Some(value)
        }
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V, defaultTransformedValue: V.TransformedValueType) -> ValueTransformer<V.ValueType?, V.TransformedValueType, V.ErrorType> {
    return ValueTransformer { value in
        return value.map(transform(valueTransformer)) ?? Result.Success(defaultTransformedValue)
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.ValueType?, V.TransformedValueType?, V.ErrorType> {
    return lift(lift(valueTransformer), defaultTransformedValue: nil)
}

// MARK: - Lift (Array)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<[V.ValueType], [V.TransformedValueType], V.ErrorType> {
    return ValueTransformer { values in
        return values.reduce(Result.Success([])) { (result, value) in
            return result.flatMap { result in
                return valueTransformer.transform(value).map { value in
                    return result + [ value ]
                }
            }
        }
    }
}
