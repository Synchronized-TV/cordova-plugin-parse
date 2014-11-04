
import Foundation
import Parse

@objc protocol SNSUtils {
    class func unlinkUserInBackground(user: PFUser!, block: PFBooleanResultBlock!)
    class func unlinkUserInBackground(user: PFUser!, target: AnyObject!, selector: Selector)
}

@objc(CDVParse) class CDVParse : CDVPlugin {

    // catches FB oauth
    override func handleOpenURL(notification: NSNotification!) {
        super.handleOpenURL(notification);
        var sourceApplication = "test";
        var wasHandled:AnyObject = FBAppCall.handleOpenURL(notification.object as NSURL, sourceApplication:nil, withSession:PFFacebookUtils.session());
        NSLog("wasHandled \(wasHandled)");
    }

    private func getPluginResult(success: Bool, message: String) -> CDVPluginResult {
        NSLog("pluginResult(\(success)): \(message)");
        return CDVPluginResult(status: (success ? CDVCommandStatus_OK : CDVCommandStatus_ERROR), messageAsString: message);
    }

    private func getPluginResult(success: Bool, message: String, data: Dictionary<String, AnyObject>) -> CDVPluginResult {
        NSLog("pluginResult(\(success)): \(message)");
        return CDVPluginResult(status: (success ? CDVCommandStatus_OK : CDVCommandStatus_ERROR), messageAsDictionary: data);
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    // dummy test
    func echo(command: CDVInvokedUrlCommand) {
        var message = command.arguments[0] as String
        message = message.uppercaseString
        var pluginResult = getPluginResult(true, message: message)
        commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }
    
    // setup accounts on startup
    override func pluginInitialize() {
        NSLog("pluginInitialize");

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

        var enableAutomaticUser: AnyObject! = plist.objectForInfoDictionaryKey("ParseEnableAutomaticUser");
        if (enableAutomaticUser===true) {
            PFUser.enableAutomaticUser();
        }

    }
    
    // return user status
    func getStatus(command: CDVInvokedUrlCommand) {
        var currentUser = PFUser.currentUser();
        var userStatus = [
            "isNew": true,
            "isAuthenticated": false,
            "facebook": false,
            "twitter": false,
            "fbId": "",
            "fbName": "",
            "fbEmail": "",
            "twitterHandle": ""
        ];
        if (currentUser != nil) {
            userStatus = [
                "isNew": currentUser.isNew,
                "isAuthenticated": currentUser.isAuthenticated(),
                "facebook": PFFacebookUtils.isLinkedWithUser(currentUser),
                "twitter": PFTwitterUtils.isLinkedWithUser(currentUser),
                "fbId": currentUser["fbId"] as String,
                "fbName": currentUser["fbName"] as String,
                "fbEmail": currentUser["fbEmail"] as String,
                "twitterHandle": currentUser["twitterHandle"] as String
            ];
        }
        var pluginResult = getPluginResult(true, message: "getStatus", data:userStatus)
        commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }
    
    func unlinkFacebook(command: CDVInvokedUrlCommand) {
        var result = self.unlinkNetwork("facebook");
        commandDelegate.sendPluginResult(result, callbackId:command.callbackId)
    }
    
    func unlinkTwitter(command: CDVInvokedUrlCommand) {
        var result = self.unlinkNetwork("twitter");
        commandDelegate.sendPluginResult(result, callbackId:command.callbackId)
    }
    
    private func getNetworkClass(network: String) -> AnyClass {
        var networks: Dictionary<String, AnyClass> = [
            "facebook": PFFacebookUtils.self,
            "twitter": PFTwitterUtils.self
        ];
        return networks[network]!;
    }
    
    private func unlinkNetwork(network: String) -> CDVPluginResult {
        var pluginResult = CDVPluginResult();
        var currentUser = PFUser.currentUser();
        let networkCls: AnyClass = getNetworkClass(network);
        if (networkCls.isLinkedWithUser(currentUser)) {
            networkCls.unlinkUserInBackground(currentUser as PFUser!, {
                (succeeded: Bool, error: NSError!) -> Void in
                if succeeded {
                    pluginResult = self.getPluginResult(true, message: "The user is no longer associated with their \(network) account.");
                } else {
                    pluginResult = self.getPluginResult(false, message: "Cannot unlink user to their \(network) account.");
                }
            })
        } else {
            pluginResult = self.getPluginResult(false, message: "User not linked to \(network)");
        }
        return pluginResult;
    }

    private func loginWith(network: String, permissions: Array<String>=[]) -> CDVPluginResult {
        // handle both FB and Twitter login processes
        // handle existing and new account
        var pluginResult = CDVPluginResult();
        var currentUser = PFUser.currentUser();
        let networkCls: AnyClass = getNetworkClass(network);
        
        // PFUser already exists
        if (currentUser != nil) {
            if (networkCls.isLinkedWithUser(currentUser)) {
                pluginResult = self.getPluginResult(true, message: "user already logged in with \(network)!");
            } else {
                if (network == "facebook") {
                    // facebook needs special permissions
                    PFFacebookUtils.linkUser(currentUser, permissions: permissions as Array, {
                        (succeeded: Bool, error: NSError!) -> Void in
                        if succeeded {
                            // fetch user details with FB api
                            FBRequestConnection.startForMeWithCompletionHandler({connection, result, error in
                                if (error === nil)
                                {
                                    currentUser["fbId"] = result.objectID as String;
                                    currentUser["fbName"] = result.name as String;
                                    currentUser["fbEmail"] = result.email as String;
                                    currentUser.saveEventually()
                                    pluginResult = self.getPluginResult(true, message: "user logged in with \(network)!");
                                } else {
                                    pluginResult = self.getPluginResult(false, message: "Cannot fetch \(network) account details :/");
                                }
                            })
                        } else {
                            pluginResult = self.getPluginResult(false, message: "Error linking \(network) account :/");
                        }
                    })
                } else if (network == "twitter") {
                    PFTwitterUtils.linkUser(currentUser, {
                        (succeeded: Bool, error: NSError!) -> Void in
                        if succeeded {
                            // store twitter handle
                            currentUser["twitterHandle"] = PFTwitterUtils.twitter().screenName;
                            currentUser.saveEventually()
                            pluginResult = self.getPluginResult(true, message: "user logged in with \(network)!");
                        } else {
                            pluginResult = self.getPluginResult(false, message: "Error linking \(network) account :/");
                        }
                    })
                }
           }
            // user not logged, create a new account from FB
        } else {
            if (network == "facebook") {
                // create a new user using FB
                PFFacebookUtils.logInWithPermissions(permissions as Array, {
                    (user: PFUser!, error: NSError!) -> Void in
                    if user == nil {
                        pluginResult = self.getPluginResult(false, message: "Uh oh. The user cancelled the \(network) login.");
                    } else if user.isNew {
                        pluginResult = self.getPluginResult(true, message: "User signed up and logged in through \(network)!");
                    } else {
                        pluginResult = self.getPluginResult(true, message: "User logged in through \(network)!");
                    }
                })
            } else if (network == "twitter") {
                // create a new user using twitter
                PFTwitterUtils.logInWithBlock {
                    (user: PFUser!, error: NSError!) -> Void in
                    if user == nil {
                        pluginResult = self.getPluginResult(false, message: "Uh oh. The user cancelled the \(network) login.");
                    } else if user.isNew {
                        pluginResult = self.getPluginResult(true, message: "User signed up and logged in through \(network)!");
                    } else {
                        pluginResult = self.getPluginResult(true, message: "User logged in through \(network)!");
                    }
                }
            }
        }
        return pluginResult
    }
    
    // start FB login process
    func loginWithFacebook(command: CDVInvokedUrlCommand) {
        var options = command.arguments[0] as [String: AnyObject];
        if (options["permissions"] === nil) {
            options["permissions"] = ["public_profile", "email"];
        }
        var result = self.loginWith("facebook", permissions: options["permissions"] as Array);
        self.commandDelegate.sendPluginResult(result, callbackId:command.callbackId)
    }
    
    // start Twitter login process
    func loginWithTwitter(command: CDVInvokedUrlCommand) {
        var result = self.loginWith("twitter");
        self.commandDelegate.sendPluginResult(result, callbackId:command.callbackId)
    }

    func logout(command: CDVInvokedUrlCommand) {
        var pluginResult = self.getPluginResult(true, message: "user logged out");
        PFUser.logOut();
        self.commandDelegate.sendPluginResult(pluginResult, callbackId:command.callbackId)
    }
    
    
}

