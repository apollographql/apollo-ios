//
//  HTTPHeaders.swift
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation


/// An order-preserving and case-insensitive representation of HTTP headers.
public struct HTTPHeaders {
    private var headers = [HTTPHeader]()

    /// Create an empty instance.
    public init() { }

    /// Create an instance from an array of `HTTPHeader`s. Duplicate case-insensitive names are collapsed into the last
    /// name and value encountered.
    public init(_ headers: [HTTPHeader]) {
        self.init()

        headers.forEach { update($0) }
    }

    /// Create an instance from a `[String: String]`. Duplicate case-insensitive names are collapsed into the last name
    /// and value encountered.
    public init(_ dictionary: [String: String]) {
        self.init()

        dictionary.forEach { update(HTTPHeader(name: $0.key, value: $0.value)) }
    }

    /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `HTTPHeader` name.
    ///   - value: The `HTTPHeader value.
    public mutating func add(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
    ///
    /// - Parameter header: The `HTTPHeader` to update or append.
    public mutating func add(_ header: HTTPHeader) {
        update(header)
    }

    /// Case-insensitively updates or appends an `HTTPHeader` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `HTTPHeader` name.
    ///   - value: The `HTTPHeader value.
    public mutating func update(name: String, value: String) {
        update(HTTPHeader(name: name, value: value))
    }

    /// Case-insensitively updates or appends the provided `HTTPHeader` into the instance.
    ///
    /// - Parameter header: The `HTTPHeader` to update or append.
    public mutating func update(_ header: HTTPHeader) {
        guard let index = headers.index(of: header.name) else {
            headers.append(header)
            return
        }

        headers.replaceSubrange(index...index, with: [header])
    }

    /// Case-insensitively removes an `HTTPHeader`, if it exists, from the instance.
    ///
    /// - Parameter name: The name of the `HTTPHeader` to remove.
    public mutating func remove(name: String) {
        guard let index = headers.index(of: name) else { return }

        headers.remove(at: index)
    }

    /// Sort the current instance by header name.
    mutating public func sort() {
        headers.sort { $0.name < $1.name }
    }

    /// Returns an instance sorted by header name.
    ///
    /// - Returns: A copy of the current instance sorted by name.
    public func sorted() -> HTTPHeaders {
        return HTTPHeaders(headers.sorted { $0.name < $1.name })
    }

    /// Case-insensitively find a header's value by name.
    ///
    /// - Parameter name: The name of the header to search for, case-insensitively.
    /// - Returns:        The value of header, if it exists.
    public func value(for name: String) -> String? {
        guard let index = headers.index(of: name) else { return nil }

        return headers[index].value
    }

    /// Case-insensitively access the header with the given name.
    ///
    /// - Parameter name: The name of the header.
    public subscript(_ name: String) -> String? {
        get { return value(for: name) }
        set {
            if let value = newValue {
                update(name: name, value: value)
            } else {
                remove(name: name)
            }
        }
    }

    /// The dictionary representation of all headers.
    ///
    /// This representation does not preserve the current order of the instance.
    public var dictionary: [String: String] {
        let namesAndValues = headers.map { ($0.name, $0.value) }

        return Dictionary(namesAndValues, uniquingKeysWith: { (_, last) in last })
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init()

        elements.forEach { update(name: $0.0, value: $0.1) }
    }
}

extension HTTPHeaders: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.init(elements)
    }
}

extension HTTPHeaders: Sequence {
    public func makeIterator() -> IndexingIterator<Array<HTTPHeader>> {
        return headers.makeIterator()
    }
}

extension HTTPHeaders: Collection {
    public var startIndex: Int {
        return headers.startIndex
    }

    public var endIndex: Int {
        return headers.endIndex
    }

    public subscript(position: Int) -> HTTPHeader {
        return headers[position]
    }

    public func index(after i: Int) -> Int {
        return headers.index(after: i)
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        return headers.map { $0.description }
            .joined(separator: "\n")
    }
}

// MARK: - HTTPHeader

/// A representation of a single HTTP header's name / value pair.
public struct HTTPHeader: Hashable {
    /// Name of the header.
    public let name: String

    /// Value of the header.
    public let value: String

    /// Creates an instance from the given `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The name of the header.
    ///   - value: The value of the header.
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        return "\(name): \(value)"
    }
}

extension HTTPHeader {
    /// Returns a `Content-Disposition` header.
    ///
    /// - Parameter value: The `Content-Disposition` value.
    /// - Returns:         The header.
    public static func contentDisposition(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Content-Disposition", value: value)
    }

    /// Returns a `Content-Type` header.
    ///
    /// - Parameter value: The `Content-Type` value.
    /// - Returns:         The header.
    public static func contentType(_ value: String) -> HTTPHeader {
        return HTTPHeader(name: "Content-Type", value: value)
    }
}

extension Array where Element == HTTPHeader {
    /// Case-insensitively finds the index of an `HTTPHeader` with the provided name, if it exists.
    func index(of name: String) -> Int? {
        let lowercasedName = name.lowercased()
        return firstIndex { $0.name.lowercased() == lowercasedName }
    }
}
