function AudioRecorderAPI() {
}

// Ning Wei 20180608
// Define qLevel const
AudioRecorderAPI.prototype.QUALITY_LEVEL_HIGH = 0;
AudioRecorderAPI.prototype.QUALITY_LEVEL_LOW = 100;
// END

// Ning Wei 20180608
// Define default duration: 7 seconds
AudioRecorderAPI.prototype.DEFAULT_DURATION_SECONDS = 7;
// END


AudioRecorderAPI.prototype.record = function (successCallback, errorCallback, duration, qLevel) {
	
	// Ning Wei 20180608
	// Provide default value for both duration and qlevel
	var d = duration ? duration : DEFAULT_DURATION_SECONDS;
	var q = qLevel ? qLevel : QUALITY_LEVEL_HIGH;
	// END

  	cordova.exec(successCallback, errorCallback, "AudioRecorderAPI", "record", [d,q]);
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
