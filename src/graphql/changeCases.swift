import Foundation

extension String {
  public func firstLowercased() -> String {
    prefix(1).lowercased() + dropFirst()
  }
  public func firstUppercased() -> String {
    prefix(1).uppercased() + dropFirst()
  }
}

// This is a method that mimics https://github.com/blakeembrey/change-case/blob/master/packages/pascal-case/src/index.ts
// https://github.com/apollographql/apollo-tooling/blob/master/packages/apollo-codegen-swift/src/codeGeneration.ts uses
// this method for operation class name, hence, without it, we may end up with mismatch class names.

extension String {
  public func pascalCase() -> String {
    let input = self
    let camelCase1 = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])
    let camelCase2 = try! NSRegularExpression(pattern: "([A-Z])([A-Z][a-z])", options: [])
    let textRange = NSRange(input.startIndex..<input.endIndex, in: input)
    var breakpoints = [String.Index]()
    let camelCase1Matches = camelCase1.matches(in: input, options: [], range: textRange)
    for match in camelCase1Matches {
      let range = Range(match.range(at: 1), in: input)!
      breakpoints.append(range.upperBound)
    }
    let camelCase2Matches = camelCase2.matches(in: input, options: [], range: textRange)
    for match in camelCase2Matches {
      let range = Range(match.range(at: 1), in: input)!
      breakpoints.append(range.upperBound)
    }
    breakpoints.sort(by: <)
    var sequences = [String]()
    for (i, breakpoint) in breakpoints.enumerated() {
      if i == 0 {
        sequences.append(String(input[input.startIndex..<breakpoint]))
      } else {
        sequences.append(String(input[breakpoints[i - 1]..<breakpoint]))
      }
    }
    if let last = breakpoints.last {
      sequences.append(String(input[last..<input.endIndex]))
    } else {
      sequences.append(input)
    }
    let stripCase = try! NSRegularExpression(pattern: "[^A-Za-z0-9]+", options: [])
    // This mimics: https://github.com/blakeembrey/change-case/blob/master/packages/no-case/src/index.ts#L19
    let finalSequences: [String] = sequences.flatMap({ input -> [String] in
      let range = NSRange(input.startIndex..<input.endIndex, in: input)
      let matches = stripCase.matches(in: input, options: [], range: range)
      var substrings = [String]()
      var lastUpperBound: String.Index? = nil
      for match in matches {
        let range = Range(match.range(at: 0), in: input)!
        if let lastUpperBound = lastUpperBound {
          substrings.append(String(input[lastUpperBound..<range.lowerBound]))
        } else {
          substrings.append(String(input[input.startIndex..<range.lowerBound]))
        }
        lastUpperBound = range.upperBound
      }
      if let last = matches.last {
        let range = Range(last.range(at: 0), in: input)!
        substrings.append(String(input[range.upperBound..<input.endIndex]))
      } else {
        substrings.append(input)
      }
      return substrings
    }).filter { $0.count > 0 }
    // This mimics: https://github.com/blakeembrey/change-case/blob/master/packages/pascal-case/src/index.ts#L18
    let composedString = finalSequences.enumerated().map({ (i, sequence) -> String in
      let prefix = sequence.prefix(1)
      let dropFirstLowercased = sequence.dropFirst().lowercased()
      if i > 0 && prefix >= "0" && prefix <= "9" {
        return "_" + prefix + dropFirstLowercased
      }
      return prefix.uppercased() + dropFirstLowercased
    }).joined(separator: "")
    // Final part, mimics: https://github.com/apollographql/apollo-tooling/blob/master/packages/apollo-codegen-swift/src/helpers.ts#L420
    // Skips prefix _ and suffix _ (don't remove these)
    var finalComposedString = composedString
    if let firstIndex = (input.firstIndex { $0 != "_" }) {
      finalComposedString = input[input.startIndex..<firstIndex] + finalComposedString
    }
    if let lastIndex = (input.lastIndex { $0 != "_" }) {
      finalComposedString += input[input.index(after: lastIndex)..<input.endIndex]
    }
    return finalComposedString
  }
}

extension String {
  // This is a method that mimics https://github.com/blakeembrey/change-case/blob/master/packages/camel-case/src/index.ts
  public func camelCase() -> String {
    let input = self
    let camelCase1 = try! NSRegularExpression(pattern: "([a-z0-9])([A-Z])", options: [])
    let camelCase2 = try! NSRegularExpression(pattern: "([A-Z])([A-Z][a-z])", options: [])
    let textRange = NSRange(input.startIndex..<input.endIndex, in: input)
    var breakpoints = [String.Index]()
    let camelCase1Matches = camelCase1.matches(in: input, options: [], range: textRange)
    for match in camelCase1Matches {
      let range = Range(match.range(at: 1), in: input)!
      breakpoints.append(range.upperBound)
    }
    let camelCase2Matches = camelCase2.matches(in: input, options: [], range: textRange)
    for match in camelCase2Matches {
      let range = Range(match.range(at: 1), in: input)!
      breakpoints.append(range.upperBound)
    }
    breakpoints.sort(by: <)
    var sequences = [String]()
    for (i, breakpoint) in breakpoints.enumerated() {
      if i == 0 {
        sequences.append(String(input[input.startIndex..<breakpoint]))
      } else {
        sequences.append(String(input[breakpoints[i - 1]..<breakpoint]))
      }
    }
    if let last = breakpoints.last {
      sequences.append(String(input[last..<input.endIndex]))
    } else {
      sequences.append(input)
    }
    let stripCase = try! NSRegularExpression(pattern: "[^A-Za-z0-9]+", options: [])
    // This mimics: https://github.com/blakeembrey/change-case/blob/master/packages/no-case/src/index.ts#L19
    let finalSequences: [String] = sequences.flatMap({ input -> [String] in
      let range = NSRange(input.startIndex..<input.endIndex, in: input)
      let matches = stripCase.matches(in: input, options: [], range: range)
      var substrings = [String]()
      var lastUpperBound: String.Index? = nil
      for match in matches {
        let range = Range(match.range(at: 0), in: input)!
        if let lastUpperBound = lastUpperBound {
          substrings.append(String(input[lastUpperBound..<range.lowerBound]))
        } else {
          substrings.append(String(input[input.startIndex..<range.lowerBound]))
        }
        lastUpperBound = range.upperBound
      }
      if let last = matches.last {
        let range = Range(last.range(at: 0), in: input)!
        substrings.append(String(input[range.upperBound..<input.endIndex]))
      } else {
        substrings.append(input)
      }
      return substrings
    }).filter { $0.count > 0 }
    // This mimics: https://github.com/blakeembrey/change-case/blob/master/packages/camel-case/src/index.ts#L11
    let composedString = finalSequences.enumerated().map({ (i, sequence) -> String in
      if i == 0 {
        return sequence.lowercased()
      }
      let prefix = sequence.prefix(1)
      let dropFirstLowercased = sequence.dropFirst().lowercased()
      if i > 0 && prefix >= "0" && prefix <= "9" {
        return "_" + prefix + dropFirstLowercased
      }
      return prefix.uppercased() + dropFirstLowercased
    }).joined(separator: "")
    // Final part, mimics: https://github.com/apollographql/apollo-tooling/blob/master/packages/apollo-codegen-swift/src/helpers.ts#L420
    // Skips prefix _ and suffix _ (don't remove these)
    var finalComposedString = composedString
    if let firstIndex = (input.firstIndex { $0 != "_" }) {
      finalComposedString = input[input.startIndex..<firstIndex] + finalComposedString
    }
    if let lastIndex = (input.lastIndex { $0 != "_" }) {
      finalComposedString += input[input.index(after: lastIndex)..<input.endIndex]
    }
    return finalComposedString
  }
}
