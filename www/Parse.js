var exec = require("cordova/exec");

var Parse = function(){};


Parse.prototype.getStatus = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "getStatus", []);
};

Parse.prototype.loginWithFacebook = function (options, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "loginWithFacebook", [options]);
};

Parse.prototype.loginWithTwitter = function (successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "loginWithTwitter", []);
};

Parse.prototype.logIn = function (email, password, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "logIn", [email, password]);
};

Parse.prototype.signUp = function (email, password, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "signUp", [email, password]);
};

Parse.prototype.resetPassword = function (email, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "resetPassword", [email]);
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

Parse.prototype.setUserKey = function(key, value, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "setUserKey", [key, value]);
};

Parse.prototype.twitter = {};

Parse.prototype.twitter.retweet = function(tweetId, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "twitterRetweet", [tweetId]);
};

Parse.prototype.twitter.cancelRetweet = function(tweetId, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "twitterCancelRetweet", [tweetId]);
};

Parse.prototype.twitter.favorite = function(tweetId, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "twitterFavorite", [tweetId]);
};

Parse.prototype.twitter.cancelFavorite = function(tweetId, successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "Parse", "twitterCancelFavorite", [tweetId]);
};

module.exports = new Parse();
