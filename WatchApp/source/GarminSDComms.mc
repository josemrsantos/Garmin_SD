using Toybox.Communications as Comm;


class GarminSDComms {
  var listener;
  var mAccelHandler = null;
  var serverUrl = "http:192.168.43.1:8080";

  function initialize(accelHandler) {
    listener = new CommListener();
    mAccelHandler = accelHandler;
  }

  function onStart() {
    Comm.registerForPhoneAppMessages(method(:onMessageReceived));
    Comm.transmit("Hello World.", null, listener);

  }

  function sendAccelData() {
    var dataObj = mAccelHandler.getDataJson();
    
    // FIXME - THIS CRASHED WITH OUT OF MEMORY ERROR AFTER 5 or 10 minutes.
    // Comm.transmit(dataObj,null,listener);

    // Try makeWebRequest instead to see if that avoids the memory leak
    /*Comm.makeWebRequest(
			serverUrl+"/data",
			{"dataObj"=>dataObj},
			{
			  :method => Communications.HTTP_REQUEST_METHOD_POST,
			    :headers => {
			    "Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
			  }
			},
			method(:onReceive));
    */
    Comm.transmit(dataObj,null,listener);
  }

  function sendSettings() {
    var dataObj = mAccelHandler.getSettingsJson();
    System.println("sendSettings() - dataObj="+dataObj);
    /*Comm.makeWebRequest(
			serverUrl+"/settings",
			{"dataObj"=>dataObj},
			{
			  :method => Communications.HTTP_REQUEST_METHOD_POST,
			    :headers => {
			    "Content-Type" => Comm.REQUEST_CONTENT_TYPE_URL_ENCODED
			  }
			},
			method(:onReceive));    
    */
    Comm.transmit(dataObj,null,listener);
  }

  // Receive the data from the web request
  function onReceive(responseCode, data) {
    if (responseCode == 200) {
      System.println("onReceive() success - data ="+data);
      //System.println(data);
      if (data.equals("sendSettings")) {
	System.println("Sending Settings");
	sendSettings();
      }
    } else {
      System.println("onReceive() Failue - code =");
      System.println(responseCode);
      System.println(responseCode.toString());
      System.println(data);
    }
  }
  


  function onMessageReceived(msg) {
    var i;
    System.print("GarminSdApp.onMessageReceived - ");
    System.println(msg.data.toString());
  }
  
  /////////////////////////////////////////////////////////////////////
  // Connection listener class that is used to log success and failure
  // of message transmissions.
  class CommListener extends Comm.ConnectionListener {
    function initialize() {
      Comm.ConnectionListener.initialize();
    }
    
    function onComplete() {
      System.println("Transmit Complete");
    }
    
    function onError() {
      System.println("Transmit Failed");
    }
  }

}
