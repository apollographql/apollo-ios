---
title: Authentication and Headers
---

In this section, you'll log in to the server and learn how to send a token back to the server with your requests. 

> **Note**: The way you login with this particular server may be very different from the way you login with your own server - login is often handled by _middleware_, or a layer totally separate from GraphQL. However you get the token you send, you'll be sending it back to the server the same way. 

## Creating a login mutation


```graphql
mutation Login($email: String) {
  login(email: $email)
}
```

One thing to watch out for: `$email` is a `String` rather than a `String!`, meaning it's legal to pass it a `null` value. However, if you do, you won't get very far. In the Query Variables section,

```json
{ "email": null }
```

![](images/login_mutation_null.png)


```json
{ "email": "your@email.com" }
```

![](images/login_mutation_email.png)

Create a new empty file, and name it `Login.graphql`


## Creating the `LoginViewController`

**File > New > File... > Swift File**, and name it **LoginViewController.swift**.

Add a library called [keychain-swift](https://github.com/evgenyneu/keychain-swift)

```
https://github.com/evgenyneu/keychain-swift.git
```

```swift
@IBOutlet private var emailTextField: UITextField!
@IBOutlet private var errorLabel: UILabel!
@IBOutlet private var submitButton: UIButton!
```

```swift
@IBAction private func submitTapped() {
}
```


```swift
private func enableSubmitButton(_ isEnabled: Bool) {
  self.submitButton.isEnabled = isEnabled
    if isEnabled {
      self.submitButton.setTitle("Submit", for: .normal)
    } else {
      self.submitButton.setTitle("Submitting...", for: .normal)
    }
}
```

```swift
private func validate(email: String) -> Bool {
  return email.contains("@")
}
```


```swift
override func viewDidLoad() {
  super.viewDidLoad()
  self.errorLabel.text = nil
  self.enableSubmitButton(true)
}
```

```    
@IBAction private func cancelTapped() {
  self.dismiss(animated: true)
}
```

In `submitTapped`:

```swift
self.errorLabel.text = nil
self.enableSubmitButton(false)

guard let email = self.emailTextField.text else {
  self.errorLabel.text = "Please enter an email address."
  self.enableSubmitButton(true)
  return
}

guard self.validate(email: email) else {
  self.errorLabel.text = "Please enter a valid email."
  self.enableSubmitButton(true)
  return
}
```

under that

```swift
 Network.shared.apollo.perform(mutation: LoginMutation(email: email)) { [weak self] result in
  defer {
    self?.enableSubmitButton(true)
  }

  switch result {
  case .success(let graphQLResult):
    if let token = graphQLResult.data?.login {
      let keychain = KeychainSwift()
      keychain.set(token, forKey: "login")
      self?.dismiss(animated: true)
    }

    if let errors = graphQLResult.errors {
      print("Errors from server: \(errors)")
    }
  case .failure(let error):
    print("Error: \(error)")
  }
}
```

In **DetailViewController.swift**


```swift
private func isLoggedIn() -> Bool {
let keychain = KeychainSwift()
return keychain.get("login") != nil
}
```



## Summary

Next, you'll [use your login token in a mutation to actually book yourself a flight](./tutorial-mutations)!