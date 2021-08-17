**CLASS**

# `SSLSecurity`

```swift
open class SSLSecurity : SSLTrustValidator
```

## Properties
### `validatedDN`

```swift
public var validatedDN = true
```

### `validateEntireChain`

```swift
public var validateEntireChain = true
```

## Methods
### `init(usePublicKeys:)`

```swift
public convenience init(usePublicKeys: Bool = false)
```

Use certs from main app bundle

- parameter usePublicKeys: is to specific if the publicKeys or certificates should be used for SSL pinning validation

- returns: a representation security object to be used with

#### Parameters

| Name | Description |
| ---- | ----------- |
| usePublicKeys | is to specific if the publicKeys or certificates should be used for SSL pinning validation |

### `init(certs:usePublicKeys:)`

```swift
public init(certs: [SSLCert], usePublicKeys: Bool)
```

Designated init

- parameter certs: is the certificates or public keys to use
- parameter usePublicKeys: is to specific if the publicKeys or certificates should be used for SSL pinning validation

- returns: a representation security object to be used with

#### Parameters

| Name | Description |
| ---- | ----------- |
| certs | is the certificates or public keys to use |
| usePublicKeys | is to specific if the publicKeys or certificates should be used for SSL pinning validation |

### `isValid(_:domain:)`

```swift
open func isValid(_ trust: SecTrust, domain: String?) -> Bool
```

Valid the trust and domain name.

- parameter trust: is the serverTrust to validate
- parameter domain: is the CN domain to validate

- returns: if the key was successfully validated

#### Parameters

| Name | Description |
| ---- | ----------- |
| trust | is the serverTrust to validate |
| domain | is the CN domain to validate |

### `extractPublicKey(_:)`

```swift
public func extractPublicKey(_ data: Data) -> SecKey?
```

Get the public key from a certificate data

- parameter data: is the certificate to pull the public key from

- returns: a public key

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | is the certificate to pull the public key from |

### `extractPublicKey(_:policy:)`

```swift
public func extractPublicKey(_ cert: SecCertificate, policy: SecPolicy) -> SecKey?
```

Get the public key from a certificate

- parameter data: is the certificate to pull the public key from

- returns: a public key

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | is the certificate to pull the public key from |

### `certificateChain(_:)`

```swift
public func certificateChain(_ trust: SecTrust) -> [Data]
```

Get the certificate chain for the trust

- parameter trust: is the trust to lookup the certificate chain for

- returns: the certificate chain for the trust

#### Parameters

| Name | Description |
| ---- | ----------- |
| trust | is the trust to lookup the certificate chain for |

### `publicKeyChain(_:)`

```swift
public func publicKeyChain(_ trust: SecTrust) -> [SecKey]
```

Get the public key chain for the trust

- parameter trust: is the trust to lookup the certificate chain and extract the public keys

- returns: the public keys from the certifcate chain for the trust

#### Parameters

| Name | Description |
| ---- | ----------- |
| trust | is the trust to lookup the certificate chain and extract the public keys |