
var exec = require("cordova/exec");

var Parse = function(){};

Parse.prototype.echo = function (message, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "echo", [message]);
};

Parse.prototype.status = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "status", []);
};

Parse.prototype.loginWithFacebook = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "loginWithFacebook", []);
};

Parse.prototype.loginWithTwitter = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "loginWithTwitter", []);
};

Parse.prototype.logout = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "logout", []);
};
/*
getLoginStatus
PFUser *currentUser = [PFUser currentUser];
loginWithFacebook
loginWithTwitter
loginWithEmail

*/

module.exports = new Parse();
