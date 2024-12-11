# CodableOptionSet
CodableOptionSet allows you to easily make your OptionSets conform to Codable and automatically cover `init(from decoder: Decoder)` and `encode(to encoder: Encoder)` for you.
All you need to do is to add `@EasilyCodableOptionSet` to your OptionSet.

## Installation

CodableOptionSet is currently available only via SPM (Swift Package Manager)

## Basic Usage

```Swift
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
```

And that's it. Enjoy :)
