---
title: 7. Enable authentication
---

In this section, you'll add the ability to log in to the example server and obtain a token that your client can use to make identified requests.

> **Note**: The way you log in to this particular server might differ from the way you log in with your own server. Login is often handled by _middleware_, or a layer totally separate from GraphQL.
> 
> Regardless of how you obtain the token from your server, you'll usually send it back to the server the same way as demonstrated in the next part of this tutorial.

## Create a login mutation

A **mutation** is an operation that changes state on your server. In this case, the mutation changes back-end state by creating a session tied to a particular user of your client.

Open [your Sandbox Explorer](https://studio.apollographql.com/sandbox/explorer?endpoint=https%3A%2F%2Fapollo-fullstack-tutorial.herokuapp.com) and click on the plus symbol to add a new tab. Next, click on the Schema icon to get back to looking at your schema, and select "Mutation" to look at your list of mutations: 

<img alt="The list of available mutations" class="screenshot" src="images/sandbox_schema_mutations.png"/>

Scroll down to take a look at the `login` mutation: 

<img alt="The definition of login in the schema" class="screenshot" src="images/schema_login_definition.png"/>

Click the play button to the right to open that mutation in the Explorer tab. When it opens, click the plus sign to add the operation: 

<img alt="The login mutation after initially being added" class="screenshot" src="images/explorer_added_login_mutation.png"/>

Explorer tries to be helpful by adding the word `Mutation` after the word `Login`, but the iOS SDK also does that for you - so you'd wind up with a `LoginMutationMutation`. Rename the operation `Login` instead: 

<img alt="The renamed operation" class="screenshot" src="images/explorer_login_mutation_rename.png"/>

Notice that there are no brackets after the call to the `login` mutation - this is because the type returned by this mutation is `String`, which is known as a **scalar type**. This means it won't have properties the way an object would, so you don't need to specify what properties you want returned to you. 

You'll also notice that `email` wasn't automatically added as an argument even though it doesn't seem to have a default value: That's because `email` is of type `String` - which remember, in GraphQL, means that it's **not** required (although obviously you won't get too far without it).  

Click the plus sign next to the `email` argument to have that argument added: 

<img alt="The operation with the email argument" class="screenshot" src="images/explorer_login_email_added.png"/>

You'll also notice that Explorer has added a variable to your "Variables" section to match the login email. 

Click the Submit Operation button your mutation. You'll see that  since you sent `null` for the email address, you get back `null` for the login: 

<img alt="Results of passing a null email" class="screenshot" src="images/login_mutation_null.png"/>

Now, replace `null` in the Query Variables section with an actual email address:

```json:title=(Sandbox%20Explorer)
{ "loginEmail": "me@example.com" }
```

Press the Submit Operation button, and this time you'll get an actual response:

<img alt="Results of passing an actual email" class="screenshot" src="images/login_mutation_email.png"/>

Next, copy the operation, either manually or using the meatball menu's "Copy operation" option. 

Open Xcode, create a new empty file named `Login.graphql`, and paste the operation into it. Build your project to make sure the codegen adds the mutation to your `API.swift` file.

## Define login logic

Now it's time to hook everything up. Below your `IBAction` methods, add a new function to enable the submit button and change its title based on whether it's enabled:

```swift:title=LoginViewController.swift
private func enableSubmitButton(_ isEnabled: Bool) {
  self.submitButton.isEnabled = isEnabled
  if isEnabled {
    self.submitButton.setTitle("Submit", for: .normal)
  } else {
    self.submitButton.setTitle("Submitting...", for: .normal)
  }
}
```

Next, add basic email validation to help make sure that the String you'll be passing through to the server might be an email address (a production app would of course validate more thoroughly):

```swift:title=LoginViewController.swift
private func validate(email: String) -> Bool {
  return email.contains("@")
}
```

Now add a `viewDidLoad` override that clears the text in the error label and enables the submit button:

```swift:title=LoginViewController.swift
override func viewDidLoad() {
  super.viewDidLoad()
  self.errorLabel.text = nil
  self.enableSubmitButton(true)
}
```

Next, you need to store the login credential that's returned by the server. Login credentials should always be stored in the Keychain, but interacting with it directly is challenging, so you'll be using the `KeychainSwift` library which has already been added as a Swift Package to this project.

At the top of `LoginViewController.swift`, import the library you just added:

```swift:title=LoginViewController.swift
import KeychainSwift
```

Next, add a `static let` that will give you a value you can use to query the keychain for a login token: 

```swift:title=LoginViewController.swift
static let loginKeychainKey = "login"
```

Because this is a `static let`, you can use it outside instances of `LoginViewController`. 

Now add some validation to the `submitTapped` button to make sure the String you're going to send as an email is non-null and passes your local validation:

```swift:title=LoginViewController.swift
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

Now that you have a non-null and valid `email` variable, you can use it to log in. Still in `submitTapped`, add a call to perform the login mutation:

```swift:title=LoginViewController.swift
 Network.shared.apollo.perform(mutation: LoginMutation(email: email)) { [weak self] result in
  defer {
    self?.enableSubmitButton(true)
  }

  switch result {
  case .success(let graphQLResult):
    if let token = graphQLResult.data?.login {
      let keychain = KeychainSwift()
      keychain.set(token, forKey: LoginViewController.loginKeychainKey)
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

With this code, once you log in successfully, the `LoginViewController` will automatically dismiss. This will send you back to the `DetailViewController`. 

## Display the login screen

Now, it's time to show the login view controller whenever someone attempts to book a trip without being logged in.

At the top of `DetailViewController.swift`, import the `KeychainSwift` library:

```swift:title=DetailViewController.swift
import KeychainSwift
```

Then, add a new method to determine whether the user is currently logged in: 

```swift:title=DetailViewController.swift
private func isLoggedIn() -> Bool {
  let keychain = KeychainSwift()
  return keychain.get(LoginViewController.loginKeychainKey) != nil
}
```

Then, add a new method to determine what to do when the "Book now!" button is tapped:


```swift:title=DetailViewController.swift
@IBAction private func bookOrCancelTapped() {
  guard self.isLoggedIn() else {
    self.performSegue(withIdentifier: "showLogin", sender: self)
    return
  }
    
  guard let launch = self.launch else {
    // We don't have enough information yet to know
    // if we're booking or cancelling, bail.
    return
  }
    
  if launch.isBooked {
    print("Cancel trip!")
  } else {
    print("Book trip!")
  }
}
```

In your storyboard, hook this method up to the `bookOrCancel` button you set up earlier. 

Build and run the application. Now when you tap the "Book now!" button, the `LoginViewController` will appear. Use it to log yourself in.

When the `DetailViewController` reappears, if you tap the "Book now!" button again, you'll see the print statement you added logging happily to the console:

<img alt="Console with book trip printed out" class="screenshot" src="images/book_trip_printout.png"/>

In the next step, you'll [use your login token in a mutation to book yourself a trip](./tutorial-mutations)!
