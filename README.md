# cordova-parse plugin

Using swift language and iOS>=7.0 only at the moment.


## Installation 

Install the plugin :

`cordova plugin add https://github.com/Synchronized-TV/tv.synchronized.cordova.parse.git`

Add to your `*.plist` and edit values :

```xml
<key>ParseApplicationId</key>
<string>xxxxxxxx</string>
<key>ParseClientKey</key>
<string>yyyyyyy</string>
<key>ParseEnableAutomaticUser</key>
<false/>
<key>TwitterConsumerKey</key>
<string>yyyyyyy</string>
<key>TwitterConsumerSecret</key>
<string>yyyyyyy</string>
<key>FacebookAppID</key>
<string>xxxxxxxx</string>
<key>FacebookDisplayName</key>
<string>App Name</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbyyyyyyy</string>
    </array>
  </dict>
</array>
```

Add this to your app delegate : 

```c
#import <ParseFacebookUtils/PFFacebookUtils.h>

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
```

In "Build Settings" :

 - add this to "Objective-C Bridging header" : `$(PROJECT_NAME)/Plugins/tv.synchronized.cordova.parse/Bridging-Header.h`
 - add this to "Runpath search paths" : `$(inherited) @executable_path/Frameworks`

## Usage

### `cordova.plugins.Parse.getStatus()`

retrieve user status (associations, stored informations...)

```
{
    "twitter":true,
    "fbId":"291401187735862",
    "twitterHandle":"revolunet",
    "isNew":false,
    "fbName":"Julien Bouquillon",
    "fbEmail":"julien@bouquillon.com",
    "isAuthenticated":true,
    "facebook":true}
}
```

### `cordova.plugins.Parse.signUp(email, password)`

Create a new Parse account

### `cordova.plugins.Parse.logIn(email, password)`

Login a Parse account

### `cordova.plugins.Parse.resetPassword(email)`

Launch a password recovery process

### `cordova.plugins.Parse.loginWithFacebook(options)`

FB login.

default options = `{permissions: ["public_profile", "email"]}`

### `cordova.plugins.Parse.loginWithTwitter()`

Twitter login

### `cordova.plugins.Parse.unlinkFacebook()`

de-associate from FB

### `cordova.plugins.Parse.unlinkTwitter()`

de-associate from twitter

### `cordova.plugins.Parse.logout()`

logout Parse user

### `cordova.plugins.Parse.setUserKey(key, value)`

Saves data in the given key (string only at the moment)

## Troubleshooting

 - Make sure `Parse.swift` is included in your "Build phases/Compile sources" section
 - Make sure the frameworks are included in your "Build phases/Link binaries" section
 - Error on `pluginInitialize` : ensure you added the custom plist entries
