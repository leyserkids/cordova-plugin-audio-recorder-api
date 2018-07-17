cordova.define("cordova-plugin-audio-recorder-api.AudioRecorderAPI", function(require, exports, module) {

function AudioRecorderAPI() {
}

AudioRecorderAPI.prototype.record = function (successCallback, errorCallback, duration, bitrate) {
	
	// Ning Wei 20180608
	// Provide default value for both duration and bitrate
	var d = duration ? duration : 7; // 7 secs
	var b = bitrate ? bitrate : 32; // 32kbps
	// END

  	cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "record", [d,b]);
};

AudioRecorderAPI.prototype.stop = function (successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "stop", []);
};
               
// Ning Wei 20180717
// New function for checking permission
AudioRecorderAPI.prototype.checkPermission = function (successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "checkPermission", []);
};
// END

AudioRecorderAPI.prototype.playback = function (successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "playback", []);
};

AudioRecorderAPI.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }
  window.plugins.audioRecorderAPI = new AudioRecorderAPI();
  return window.plugins.audioRecorderAPI;
};

cordova.addConstructor(AudioRecorderAPI.install);
});
