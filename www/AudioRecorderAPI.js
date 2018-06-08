function AudioRecorderAPI() {
}

// Ning Wei 20180608
// Define default bit rate: 32kbps
AudioRecorderAPI.prototype.DEFAULT_BIT_RATE_KBPS = 32;
// END

// Ning Wei 20180608
// Define default duration: 7 seconds
AudioRecorderAPI.prototype.DEFAULT_DURATION_SECONDS = 7;
// END


AudioRecorderAPI.prototype.record = function (successCallback, errorCallback, duration, bitrate) {
	
	// Ning Wei 20180608
	// Provide default value for both duration and bitrate
	var d = duration ? duration : DEFAULT_DURATION_SECONDS;
	var b = bitrate ? bitrate : DEFAULT_BIT_RATE_KBPS;
	// END

  	cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "record", [d,b]);
};

AudioRecorderAPI.prototype.stop = function (successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "stop", []);
};

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
