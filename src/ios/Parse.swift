
import Foundation
import Parse

@objc(CDVParse) class CDVParse : CDVPlugin {

    // catches FB oauth
    override func handleOpenURL(notification: NSNotification!) {
        var sourceApplication = "test";
        var wasHandled:Bool = FBAppCall.handleOpenURL(notification.object as NSURL, sourceApplication:nil);
        NSLog("wasHandled %@", wasHandled);
    }
    

    func applicationDidBecomeActive(application: UIApplication) {
      FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    // dummy test
    func echo(command: CDVInvokedUrlCommand) {
        var message = command.arguments[0] as String
        
        message = message.uppercaseString
        
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: message)
        commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }

    // setup accounts on startup
    override func pluginInitialize() {
        NSLog("pluginInitialize")
        super.pluginInitialize()

        var plist = NSBundle.mainBundle();

        Parse.setApplicationId(
            plist.objectForInfoDictionaryKey("ParseApplicationId") as String,
            clientKey: plist.objectForInfoDictionaryKey("ParseClientKey") as String
        )
        PFFacebookUtils.initializeFacebook()

        PFTwitterUtils.initializeWithConsumerKey(
            plist.objectForInfoDictionaryKey("TwitterConsumerKey") as String,
            consumerSecret: plist.objectForInfoDictionaryKey("TwitterConsumerSecret") as String
        )

        PFUser.enableAutomaticUser()

        var defaultACL = PFACL()

        // If you would like all objects to be private by default, remove this line.
        defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)

    }

    // return user status
    func status(command: CDVInvokedUrlCommand) {
        var currentUser = PFUser.currentUser();

        var userStatus = [
            "isNew": currentUser.isNew,
            "isAuthenticated": currentUser.isAuthenticated(),
            "facebook": PFFacebookUtils.isLinkedWithUser(currentUser),
            "twitter": PFTwitterUtils.isLinkedWithUser(currentUser),
        ];
        NSLog("%@", currentUser);
//        NSLog("%@", currentUser.email );
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsDictionary: userStatus)
        commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }

    // start FB login process
    func loginWithFacebook(command: CDVInvokedUrlCommand) {

        var permissions = ["public_profile", "email"];
        var pluginResult = CDVPluginResult();
        var currentUser = PFUser.currentUser();
        if (PFFacebookUtils.isLinkedWithUser(currentUser)) {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "user already logged in with Facebook!");
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        } else {
            NSLog("link FB account")
            PFFacebookUtils.linkUser(currentUser, permissions:permissions, {
                (succeeded: Bool, error: NSError!) -> Void in
                NSLog("link FB account result")
                if succeeded {
                    currentUser = PFUser.currentUser();
                    NSLog("facebook OK %@", currentUser);
                    NSLog("Woohoo, user logged in with Facebook!")

                    
                    FBRequestConnection.startForMeWithCompletionHandler({connection, result, error in
                        if (error === nil)
                        {
                            NSLog("Fetched FB details")
                            currentUser["fbId"] = result.objectID as String;
                            currentUser["fbName"] = result.name as String;
                            currentUser["fbEmail"] = result.email as String;
                            currentUser.saveEventually()
                            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "user logged in with Facebook!");
                        }
                        else
                        {
                            NSLog("Error fetching FB details")
                            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsString: "Cannot fetch Facebook account details :/");
                        }
                    })
                } else {
                    NSLog("Error linking Facebook account :/")
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsString: "Error linking Facebook account :/");
                }
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        }

    }

    // start Twitter login process
    func loginWithTwitter(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult();
        var currentUser = PFUser.currentUser()
        if (PFTwitterUtils.isLinkedWithUser(currentUser)) {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "user already logged in with Twitter!");
            self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
        } else {
            PFTwitterUtils.linkUser(currentUser, {
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    currentUser = PFUser.currentUser();
                    NSLog("twitter OK %@", currentUser);
                    NSLog("Woohoo, user logged in with Twitter!")
                    NSLog("%@", PFTwitterUtils.twitter());
                    NSLog("%@", PFTwitterUtils.twitter().screenName);
                    currentUser["twitterHandle"] = PFTwitterUtils.twitter().screenName;
                    currentUser.saveEventually()
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "user logged in with Twitter!");
                } else {
                    NSLog("Error linking Twitter account :/")
                    pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsString: "Error linking Twitter account :/");
                }
                self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
            })
        }
    }

    func logout(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult();
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: "user logged out");
        PFUser.logOut();
        self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }


}

func application(application: UIApplication,
    openURL url: NSURL,
    sourceApplication: String,
    annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication,
            withSession:PFFacebookUtils.session())
}

func applicationDidBecomeActive(application: UIApplication) {
    FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
}
