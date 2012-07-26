package
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.messaging.AbstractConsumer;
	
	public dynamic class SpreadsheetResultSet extends Proxy
	{
		private var _email:String; 
		private var _password:String; 
		private var _key:String; 
		private var _callback:Function; 
		
		private var _index:int = 0; 
		private var _array:Array; 
		
		protected var spreadsheetLoader:URLLoader; 
		protected const phpProxyURL:String = "http://127.0.0.1/2012.July/ReaderGoogleSpreadsheetsFromFlash/reader.php"; 
		
		public function SpreadsheetResultSet(email:String, password:String, key:String, callback:Function = null)
		{
			_email = email; 
			_password = password; 
			_key = key; 
			_callback = callback; 
					
			spreadsheetLoader = new URLLoader(); 
			spreadsheetLoader.addEventListener(Event.COMPLETE, onLoadCompleted); 
			spreadsheetLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			spreadsheetLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			var request:URLRequest = new URLRequest(phpProxyURL);
			var requestVars:URLVariables = new URLVariables();
			requestVars.email = _email;
			requestVars.password = _password; 
			requestVars.key = _key; 
			request.data = requestVars; 
			request.method = URLRequestMethod.POST; 
			spreadsheetLoader.load(request); 
		} 
		
		override flash_proxy function callProperty(name:*, ...rest):*
		{
			return _array[name].apply(_array, rest);  
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return _array[name]; 
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			_array[name] = value; 
		}
		
		protected function onIOError(evt:IOErrorEvent)
		{
			trace("-----------> IOError occured!!!! " + evt.toString()); 
		}
		
		protected function onLoadCompleted(evt:Event)
		{
			trace("Get Spreadsheet Successfully." + spreadsheetLoader.data);
			try {
				_array = com.adobe.serialization.json.JSON.decode(spreadsheetLoader.data) as Array;
			} catch (err:Error) {
				trace("Can't parse As Json data" + err.toString());
				return; 
			}
			
			// call Callback.
			if (_callback != null) {
				_callback(this); 
			}

		}
		
		protected function onSecurityError(evt:Event)
		{
			trace("-----------> SecurityError occured!!!! " + evt.toString());
		}
		
		public function hasNext():Boolean
		{
			return (_index < _array.length); 
		}
		
		public function next():*
		{
			return _array[_index++];
		}
		
		public function clear():void
		{
			_index = 0; 
		}
	}
}