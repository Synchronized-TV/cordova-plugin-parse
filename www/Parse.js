
var exec = require("cordova/exec");

var Parse = function(){};

Parse.prototype.echo = function (message, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "echo", [message]);
};

Parse.prototype.getStatus = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "getStatus", []);
};

Parse.prototype.loginWithFacebook = function (options, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "loginWithFacebook", [options]);
};

Parse.prototype.loginWithTwitter = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "loginWithTwitter", []);
};

Parse.prototype.logout = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "logout", []);
};

Parse.prototype.unlinkFacebook = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "unlinkFacebook", []);
};

Parse.prototype.unlinkTwitter = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "unlinkTwitter", []);
};


module.exports = new Parse();
