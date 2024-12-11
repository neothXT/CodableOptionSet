import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(EasilyCodableOptionSetMacros)
import EasilyCodableOptionSetMacros

let testMacros: [String: Macro.Type] = [
    "EasilyCodableOptionSet": EasilyCodableOptionSetMacro.self,
]
#endif

final class CodableOptionSetTests: XCTestCase {
    func testMacro() throws {
        #if canImport(EasilyCodableOptionSetMacros)
        assertMacroExpansion(
            """
            @EasilyCodableOptionSet struct MyOptionSet: OptionSet {
                var rawValue: Int
                static let optionOne = MyOptionSet(rawValue: 1 << 0)
                static let optionTwo: MyOptionSet = .init(rawValue: 1 << 1)
                static let optionThree: MyOptionSet = MyOptionSet(rawValue: 1 << 2)
            
                init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            """,
            expandedSource: #"""
            struct MyOptionSet: OptionSet {
                var rawValue: Int
                static let optionOne = MyOptionSet(rawValue: 1 << 0)
                static let optionTwo: MyOptionSet = .init(rawValue: 1 << 1)
                static let optionThree: MyOptionSet = MyOptionSet(rawValue: 1 << 2)
            
                init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            
            extension MyOptionSet: Codable {
                private static let mapping: [String: MyOptionSet] = [
                    "optionOne": .optionOne,
                    "optionTwo": .optionTwo,
                    "optionThree": .optionThree
                ]

                init(from decoder: Decoder) throws {
                    var container = try decoder.unkeyedContainer()
                    var result: MyOptionSet = []
                    while !container.isAtEnd {
                        let optionName = try container.decode(String.self)
                        guard let opt = Self.mapping[optionName] else {
                            let context = DecodingError.Context(
                                codingPath: decoder.codingPath,
                                debugDescription: "Option not recognised: \(optionName)"
                            )
                            throw DecodingError.typeMismatch(String.self, context)
                        }
                        result.insert(opt)
                    }
                    self = result
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()

                    let optionsRaw: [String]
                    optionsRaw = Self.mapping
                    .compactMap {
                        self.contains($0.value) ? $0.key : nil
                    }
                    try container.encode(contentsOf: optionsRaw)
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroAlt() throws {
        #if canImport(EasilyCodableOptionSetMacros)
        assertMacroExpansion(
            """
            @EasilyCodableOptionSet struct MyOptionSet: OptionSet {
                var rawValue: Int
                static let optionOne = MyOptionSet(rawValue: 1 << 0)
                static let optionTwo: MyOptionSet = .init(rawValue: 1 << 1)
                static let optionThree: MyOptionSet = MyOptionSet(rawValue: 1 << 2)
                static let all: MyOptionSet = [.optionOne, .optionTwo, .optionThree]
                        
                init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            """,
            expandedSource: #"""
            struct MyOptionSet: OptionSet {
                var rawValue: Int
                static let optionOne = MyOptionSet(rawValue: 1 << 0)
                static let optionTwo: MyOptionSet = .init(rawValue: 1 << 1)
                static let optionThree: MyOptionSet = MyOptionSet(rawValue: 1 << 2)
                static let all: MyOptionSet = [.optionOne, .optionTwo, .optionThree]
                        
                init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }
            
            extension MyOptionSet: Codable {
                private static let mapping: [String: MyOptionSet] = [
                    "optionOne": .optionOne,
                    "optionTwo": .optionTwo,
                    "optionThree": .optionThree,
                    "all": .all
                ]

                init(from decoder: Decoder) throws {
                    var container = try decoder.unkeyedContainer()
                    var result: MyOptionSet = []
                    while !container.isAtEnd {
                        let optionName = try container.decode(String.self)
                        guard let opt = Self.mapping[optionName] else {
                            let context = DecodingError.Context(
                                codingPath: decoder.codingPath,
                                debugDescription: "Option not recognised: \(optionName)"
                            )
                            throw DecodingError.typeMismatch(String.self, context)
                        }
                        result.insert(opt)
                    }
                    self = result
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()

                    let optionsRaw: [String]
                    if self == .all {
                        optionsRaw = ["all"]
                    } else {
                        optionsRaw = Self.mapping
                    .filter {
                            $0.key != "all"
                        }
                        .compactMap {
                            self.contains($0.value) ? $0.key : nil
                        }
                    }
                    try container.encode(contentsOf: optionsRaw)
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
