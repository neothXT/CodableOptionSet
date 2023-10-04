// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces extends OptionSet to conform to Codable (Encodable & Decodable) protocol
@attached(extension, conformances: Codable, names: named(init), named(encode), named(mapping))
public macro CodableOptionSet() = #externalMacro(module: "CodableOptionSetMacros", type: "CodableOptionSetMacro")
