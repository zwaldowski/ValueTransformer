//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import Lustre
import ValueTransformer

struct ValueTransformers {
    static let string = ValueTransformer<String, AnyResult<Int>> { value in
        if let value = value.toInt() {
            return success(value)
        } else {
            return failure(NSError())
        }
    }

    static let int = ValueTransformer<Int, AnyResult<String>> { value in
        return success(String(value))
    }
}

class ValueTransformerSpecs: QuickSpec {
    override func spec() {
        describe("A ValueTransformer") {
            let valueTransformer = ValueTransformers.string

            it("should transform a value") {
                let result = valueTransformer.transform("1")

                expect(result.value).to(equal(1))
            }

            it("should fail if its value transformation fails") {
                let result = valueTransformer.transform("2.5")

                expect(result.value).to(beNil())
            }
        }

        describe("Composed value transformes") {
            let valueTransformer = ValueTransformers.string >>> ValueTransformers.int

            it("should transform a value") {
                let result = valueTransformer.transform("3")

                expect(result.value).to(equal("3"))
            }

            it("should fail if any of its value transformation fails") {
                let result = valueTransformer.transform("3.5")

                expect(result.value).to(beNil())
            }
        }

        describe("Lifted value transformers") {
            context("with optional value") {
                let valueTransformer: ValueTransformer<String?, AnyResult<Int>> = lift(ValueTransformers.string, defaultTransformedValue: 0)

                context("if given some value") {
                    it("should transform a value") {
                        let result = valueTransformer.transform("4")

                        expect(result.value).to(equal(4))
                    }

                    it("should fail if its value transformation fails") {
                        let result = valueTransformer.transform("4.5")

                        expect(result.value).to(beNil())
                    }
                }

                context("if not given some value") {
                    it("should transform to the default transformed value") {
                        let result = valueTransformer.transform(nil)

                        expect(result.value).to(equal(0))
                    }
                }
            }

            context("with optional transformed value") {
                let valueTransformer: ValueTransformer<String, AnyResult<Int?>> = lift(ValueTransformers.string)

                it("should transform a value") {
                    let result = valueTransformer.transform("5")

                    expect(result.value!).to(equal(5))
                }

                it("should fail if its value transformation fails") {
                    let result = valueTransformer.transform("5.5")

                    expect(result.value).to(beNil())
                }
            }

            context("with optional value and transformed value") {
                let valueTransformer: ValueTransformer<String?, AnyResult<Int?>> = lift(ValueTransformers.string)

                context("if given some value") {
                    it("should transform a value") {
                        let result = valueTransformer.transform("6")

                        expect(result.value!).to(equal(6))
                    }

                    it("should fail if its value transformation fails") {
                        let result = valueTransformer.transform("6.5")

                        expect(result.value).to(beNil())
                    }
                }

                context("if not given some value") {
                    it("should transform to nil") {
                        let result = valueTransformer.transform(nil)

                        expect(result.value!).to(beNil())
                    }
                }
            }

            context("with array value and transformed value") {
                let valueTransformer: ValueTransformer<[String], AnyResult<[Int]>> = lift(ValueTransformers.string)

                it("should transform a value") {
                    let result = valueTransformer.transform([ "7", "8" ])

                    expect(result.value).to(equal([ 7, 8 ]))
                }

                it("should fail if any of its value transformation fails") {
                    let result = valueTransformer.transform([ "9", "9.5" ])

                    expect(result.value).to(beNil())
                }
            }
        }
    }
}
