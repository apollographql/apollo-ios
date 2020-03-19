**CLASS**

# `EnumGenerator`

```swift
public class EnumGenerator
```

## Properties
### `enumTemplate`

```swift
open var enumTemplate = """
{% if enumType.description != "" %}/// {{ enumType.description }}
{% endif %}{{ modifier }}enum {{ enumType.name }}: RawRepresentable, Codable, Equatable, Hashable, CaseIterable {
  {{ modifier }}typealias RawValue = String

  {% for case in cases %}{% if case.isDeprecated %}@available(*, deprecated, message: "Deprecated in schema")
  {% endif %}{% if case.description != "" %}/// {{ case.description }}
  {% endif %}case {{ case.nameVariableDeclaration }}
  {% endfor %}/// An {{ enumType.name }} type not defined at the time this enum was generated
  case __unknown(String)

  {{ modifier }}var rawValue: String {
    switch self {
    {% for case in cases %}case .{{ case.nameUsage }}: return "{{ case.name }}"
    {% endfor %}case .__unknown(let value): return value
    }
  }

  {{ modifier }}init(rawValue: String) {
    switch rawValue {
    {% for case in cases %}case "{{ case.name }}": self = .{{ case.nameUsage }}
    {% endfor %}default: self = .__unknown(rawValue)
    }
  }

  {{ modifier }}static var allCases: [{{ enumType.name }}] {
    [{% for case in cases %}
      .{{ case.nameUsage }},{% endfor %}
    ]
  }
}
"""
```

> A stencil template to use to render enums.
>
> Variable to allow custom modifications, but MODIFY AT YOUR OWN RISK.

## Methods
### `init()`

```swift
public init()
```

> Designated initializer
