# ToDo App 1.1.2

ToDo App is a mobile application developed with Starling Framework and FeathersUI. It showcases how to use Firebase services with ActionScript to create simple and secure CRUD system.

It shows how to use the following Firebase features:

* GET, POST, DELETE and PATCH requests to the Firebase Database (JSON)
* User Auth with Email and Password
* User account management (update email, password, recover password and deletion of account)

This app also has some extra features:

* Managing the logged in user profile with a Profile Manager class
* Managing the Firebase response errors with a Responses class
* RoundedRect with a Scale9Grid
* Mail app-like ItemRenderer
* Material Design custom theme
* Multi DPI development

## Dependencies

* [Starling Framework 2.1](http://gamua.com/starling/)
* [Feathers UI 3.2.0](https://feathersui.com/)
* [Adobe AIR 25](http://www.adobe.com/devnet/air/air-sdk-download.html)

To compile this application you require to provide your own Firebase API key which can be obtained for free on the Firebase developer console (see below), this project only works with Firebase V3 and its newer console located at https://console.firebase.google.com/ 

## What is Firebase?

Firebase is a set of tools and services that are designed to ease the development of server side infrastructure for apps and games. You can easily and securely save and retrieve data from the cloud.

It also offers a user management service which allows your users to register an account in your app and have personalized experiences.
In this app the users can generate private to do's lists that they only can access.

## Firebase Rules

The following rules are used for this app:

```json
{
  "rules": {
    "todos": {
      "$uid": {
        ".indexOn": ["due_date"],
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    }
  }
}
```

These rules mean the following:

There's a main node named `todos`, inside that node each user will have their own node which only they will be able to read and write.
We add a index to the `due_date` value so we can sort our lists by it.

Follow these steps to locate your API Key:

1. Login to the [Firebase console](https://console.firebase.google.com/) and select a project or create a new one.
2. In the project home page you will be prompted to add Firebase to `Android`, `iOS` or `Web`.
3. Select `Web`, a popup will appear.
4. Copy the `apiKey` from the JavaScript code block.
5. Open the `Firebase.as` file and set your variables and constants accordingly.

Don't forget to enable Email and Password authentication from the Auth section in the Firebase console.

## Preview

[![Watch on Youtube](http://i.imgur.com/T1irUWs.png)](https://www.youtube.com/watch?v=WDFwFJYTU9k)

## Download

You can test this app by downloading it directly from Google Play.

[![Download](http://i.imgur.com/He0deVa.png)](https://play.google.com/store/apps/details?id=air.im.phantom.todo)