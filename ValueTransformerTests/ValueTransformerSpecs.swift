//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import Result
import ValueTransformer

struct ValueTransformers {
    static let string = ValueTransformer<String, Int> { value in
        guard let value = Int(value) else {
            throw NSError(domain: "ValueTransformer", code: 0, userInfo: nil)
        }
        return value
    }

    static let int = ValueTransformer<Int, String> { value in
        String(value)
    }
}

class ValueTransformerSpecs: QuickSpec {
    override func spec() {
        describe("A ValueTransformer") {
            let valueTransformer = ValueTransformers.string

            it("should transform a value") {
                let result = try? valueTransformer.transform("1")

                expect(result) == 1
            }

            it("should fail if its value transformation fails") {
                let result = try? valueTransformer.transform("2.5")

                expect(result).to(beNil())
            }
        }

        describe("Composed value transformes") {
            let valueTransformer = ValueTransformers.string >>> ValueTransformers.int

            it("should transform a value") {
                let result = try? valueTransformer.transform("3")

                expect(result) == "3"
            }

            it("should fail if any of its value transformation fails") {
                let result = try? valueTransformer.transform("3.5")

                expect(result).to(beNil())
            }
        }

        describe("Lifted value transformers") {
            context("with optional value") {
                let valueTransformer: ValueTransformer<String?, Int> = lift(ValueTransformers.string, defaultTransformedValue: 0)

                context("if given some value") {
                    it("should transform a value") {
                        let result = try? valueTransformer.transform("4")

                        expect(result) == 4
                    }

                    it("should fail if its value transformation fails") {
                        let result = try? valueTransformer.transform("4.5")

                        expect(result).to(beNil())
                    }
                }

                context("if not given some value") {
                    it("should transform to the default transformed value") {
                        let result = try? valueTransformer.transform(nil)

                        expect(result) == 0
                    }
                }
            }

            context("with optional transformed value") {
                let valueTransformer: ValueTransformer<String, Int?> = lift(ValueTransformers.string)

                it("should transform a value") {
                    let result = try? valueTransformer.transform("5")

                    expect(result!) == 5
                }

                it("should fail if its value transformation fails") {
                    let result = try? valueTransformer.transform("5.5")

                    expect(result).to(beNil())
                }
            }

            context("with optional value and transformed value") {
                let valueTransformer: ValueTransformer<String?, Int?> = lift(ValueTransformers.string)

                context("if given some value") {
                    it("should transform a value") {
                        let result = try? valueTransformer.transform("6")

                        expect(result!) == 6
                    }

                    it("should fail if its value transformation fails") {
                        let result = try? valueTransformer.transform("6.5")

                        expect(result).to(beNil())
                    }
                }

                context("if not given some value") {
                    it("should transform to nil") {
                        let result = try? valueTransformer.transform(nil)

                        expect(result!).to(beNil())
                    }
                }
            }

            context("with array value and transformed value") {
                let valueTransformer: ValueTransformer<[String], [Int]> = lift(ValueTransformers.string)

                it("should transform a value") {
                    let result = try? valueTransformer.transform([ "7", "8" ])

                    expect(result) == [ 7, 8 ]
                }

                it("should fail if any of its value transformation fails") {
                    let result = try? valueTransformer.transform([ "9", "9.5" ])

                    expect(result).to(beNil())
                }
            }
        }
    }
}
