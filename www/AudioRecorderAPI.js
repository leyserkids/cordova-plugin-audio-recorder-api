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
AudioRecorderAPI.prototype.PERMISSION_GRANTED = 1000;
AudioRecorderAPI.prototype.PERMISSION_DENIED = 1001;
AudioRecorderAPI.prototype.PERMISSION_UNDETERMIN = 1002;

AudioRecorderAPI.prototype.checkPermission = function (successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "checkPermission", []);
};
// END

// Ning Wei 20180903
// New function for retrieving duration
AudioRecorderAPI.prototype.getDuration = function (filePath, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "getDuration", [filePath]);
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