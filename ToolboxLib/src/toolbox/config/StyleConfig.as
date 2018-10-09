package toolbox.config
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import lolo.core.Common;
	
	import toolbox.Toolbox;
	
	
	/**
	 * 加载和解析样式配置文件
	 * @author LOLO
	 */
	public class StyleConfig
	{
		
		/**加载和解析完成时的回调*/
		public static var callback:Function;
		/**加载好的配置文件*/
		public static var config:XML;
		
		
		/**用于加载配置文件*/
		private static var _loader:URLLoader;
		
		
		
		
		/**
		 * 加载配置文件
		 */
		public static function load(callback:Function=null):void
		{
			StyleConfig.callback = callback;
			Toolbox.progressPanel.show(0, 0, "刷新样式列表");
			
			if(_loader == null) {
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, completeHandler);
			}
			var path:String = Toolbox.isASProject
				? "xml/core/Style.xml"
				: "json/core/Style.json"
			_loader.load(new URLRequest(Toolbox.resRootDir + path));
		}
		
		
		/**
		 * 加载配置文件完成
		 * @param event
		 */
		private static function completeHandler(event:Event):void
		{
			if(Toolbox.isASProject)
			{
				config = new XML(_loader.data);
			}
			else
			{
				config = <config/>;
				var obj:Object = JSON.parse(_loader.data);
				for(var name:String in obj)
				{
					config.appendChild(XML(
						"<style name='" + name + "' style='" + JSON.stringify(obj[name]) + "' />"
					));
				}
			}
			
			Common.config.initStyleConfig(config);
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