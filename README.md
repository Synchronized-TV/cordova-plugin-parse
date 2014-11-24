# cordova-parse plugin

Using swift language and iOS>=7.0 only at the moment.

Provides basic native functionnalities (login, signup...) and returns the sessionToken so you can also use the plain Parse javascript SDK if needed.

## Installation

Install the plugin :

`cordova plugin add https://github.com/Synchronized-TV/synchronized.cordova.parse.git`

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

 - add this to "Objective-C Bridging header" : `$(PROJECT_NAME)/Plugins/synchronized.cordova.parse/Bridging-Header.h`
 - add this to "Runpath search paths" : `$(inherited) @executable_path/Frameworks`

## Usage

#### `cordova.plugins.Parse.getStatus()`

retrieve user status (associations, stored informations...).
this method always refreshes parse data (`refresh` API call).

```js
{
    "isNew": false
    "twitter": true,
    "facebook": true,
    "isAuthenticated": true
}
```

Additional user informations will be added to this object for authenticated users :
 - sessionToken
 - applications keys needed for the client side (extracted from the project plist file)
 - some basic social networks data if any (name, email...)
 - custom user values added via `setUserKey()`


#### `cordova.plugins.Parse.signUp(email, password)`

Create a new Parse account

#### `cordova.plugins.Parse.logIn(email, password)`

Login a Parse account

#### `cordova.plugins.Parse.resetPassword(email)`

Launch a password recovery process

#### `cordova.plugins.Parse.loginWithFacebook(options)`

FB login.

default options = `{permissions: ["public_profile", "email"]}`

#### `cordova.plugins.Parse.loginWithTwitter()`

Twitter login

#### `cordova.plugins.Parse.unlinkFacebook()`

de-associate from FB

#### `cordova.plugins.Parse.unlinkTwitter()`

de-associate from twitter

#### `cordova.plugins.Parse.logout()`

logout Parse user

#### `cordova.plugins.Parse.setUserKey(key, value)`

Saves data in the given key (string only at the moment)

## Twitter

#### `cordova.plugins.Parse.twitter.retweet(tweetId)`

Retweet a given tweet

#### `cordova.plugins.Parse.twitter.cancelRetweet(tweetId)`

Cancel a given status

#### `cordova.plugins.Parse.twitter.favorite(tweetId)`

Favorite a given tweet

#### `cordova.plugins.Parse.twitter.cancelFavorite(tweetId)`

Cancel a given favorite


## Troubleshooting

 - Make sure `Parse.swift` is included in your "Build phases/Compile sources" section
 - Make sure the frameworks are included in your "Build phases/Link binaries" section
 - Error on `pluginInitialize` : ensure you added the custom plist entries

## Licence MIT

Code distributed under MIT licence. Contributions welcome.
