package toolbox.config
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import lolo.core.Common;
	
	import toolbox.Toolbox;

	
	
	/**
	 * 加载和解析语言包配置文件
	 * @author LOLO
	 */
	public class LanguageConfig
	{
		/**加载和解析完成时的回调*/
		public static var callback:Function;
		
		
		/**用于加载语言包配置文件*/
		private static var _loader:URLLoader;
		
		
		
		
		/**
		 * 加载配置文件
		 */
		public static function load(callback:Function=null):void
		{
			LanguageConfig.callback = callback;
			Toolbox.progressPanel.show(0, 0, "刷新语言包");
			
			if(_loader == null) {
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, completeHandler);
			}
			
			var path:String = Toolbox.isASProject ? "xml/core/Language.xml" : "json/core/Language.json";
			_loader.load(new URLRequest(Toolbox.resRootDir + path));
		}
		
		
		/**
		 * 加载配置文件完成
		 * @param event
		 */
		private static function completeHandler(event:Event):void
		{
			var xml:XML;
			if(Toolbox.isASProject)
			{
				xml = XML(_loader.data);
			}
			else
			{
				xml = <config/>;
				var obj:Object = JSON.parse(_loader.data);
				for(var id:String in obj)
				{
					xml.appendChild(XML(
						'<item id="' + id + '"><![CDATA[' + obj[id] + ']]></item>'
					));
				}
			}
			
			Common.language.initialize(xml);
			Common.stage.addEventListener(Event.ENTER_FRAME, callTheCallback);
		}
		
		
		
		/**
		 * 调用回调
		 * @param event
		 */
		private static function callTheCallback(event:Event):void
		{
			Common.stage.removeEventListener(Event.ENTER_FRAME, callTheCallback);
			Toolbox.progressPanel.hide();
			
			if(callback != null) {
				callback();
				callback = null;
			}
		}
		//
	}
}