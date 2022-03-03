**CLASS**

# `SSLClientCertificate`

```swift
public class SSLClientCertificate
```

## Methods
### `init(pkcs12Path:password:)`

```swift
public convenience init(pkcs12Path: String, password: String) throws
```

Convenience init.
- parameter pkcs12Path: Path to pkcs12 file containing private key and X.509 ceritifacte (.p12)
- parameter password: file password, see **kSecImportExportPassphrase**

#### Parameters

| Name | Description |
| ---- | ----------- |
| pkcs12Path | Path to pkcs12 file containing private key and X.509 ceritifacte (.p12) |
| password | file password, see  |

### `init(identity:identityCertificate:)`

```swift
public init(identity: SecIdentity, identityCertificate: SecCertificate)
```

Designated init. For more information, see SSLSetCertificate() in Security/SecureTransport.h.
- parameter identity: SecIdentityRef, see **kCFStreamSSLCertificates**
- parameter identityCertificate: CFArray of SecCertificateRefs, see **kCFStreamSSLCertificates**

#### Parameters

| Name | Description |
| ---- | ----------- |
| identity | SecIdentityRef, see  |
| identityCertificate | CFArray of SecCertificateRefs, see  |

### `init(pkcs12Url:password:)`

```swift
public convenience init(pkcs12Url: URL, password: String) throws
```

Convenience init.
- parameter pkcs12Url: URL to pkcs12 file containing private key and X.509 ceritifacte (.p12)
- parameter password: file password, see **kSecImportExportPassphrase**

#### Parameters

| Name | Description |
| ---- | ----------- |
| pkcs12Url | URL to pkcs12 file containing private key and X.509 ceritifacte (.p12) |
| password | file password, see  |

### `init(pkcs12Url:importOptions:)`

```swift
public init(pkcs12Url: URL, importOptions: CFDictionary) throws
```

Designated init.
- parameter pkcs12Url: URL to pkcs12 file containing private key and X.509 ceritifacte (.p12)
- parameter importOptions: A dictionary containing import options. A
kSecImportExportPassphrase entry is required at minimum. Only password-based
PKCS12 blobs are currently supported. See **SecImportExport.h**

#### Parameters

| Name | Description |
| ---- | ----------- |
| pkcs12Url | URL to pkcs12 file containing private key and X.509 ceritifacte (.p12) |
| importOptions | A dictionary containing import options. A kSecImportExportPassphrase entry is required at minimum. Only password-based PKCS12 blobs are currently supported. See  |