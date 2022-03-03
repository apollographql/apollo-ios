**CLASS**

# `SSLCert`

```swift
open class SSLCert
```

## Methods
### `init(data:)`

```swift
public init(data: Data)
```

Designated init for certificates

- parameter data: is the binary data of the certificate

- returns: a representation security object to be used with

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | is the binary data of the certificate |

### `init(key:)`

```swift
public init(key: SecKey)
```

Designated init for public keys

- parameter key: is the public key to be used

- returns: a representation security object to be used with

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | is the public key to be used |