package toolbox.config
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import lolo.core.Common;
	
	import toolbox.Toolbox;
	
	
	/**
	 * 加载和解析皮肤配置文件
	 * @author LOLO
	 */
	public class SkinConfig
	{
		/**加载和解析完成时的回调*/
		public static var callback:Function;
		/**配置文件对应的皮肤列表*/
		public static var skinList:Array;
		
		
		/**用于加载配置文件*/
		private static var _loader:URLLoader;
		
		
		
		
		/**
		 * 加载配置文件
		 */
		public static function load(callback:Function=null):void
		{
			SkinConfig.callback = callback;
			Toolbox.progressPanel.show(0, 0, "刷新皮肤列表");
			
			if(_loader == null) {
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, completeHandler);
			}
			var path:String = Toolbox.isASProject ? "xml/core/Skin.xml" : "json/core/Skin.json";
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
				xml = new XML(_loader.data);
			}
			else
			{
				//将JSON转成XML，以便调用Common.config.initSkinConfig()方法
				xml = <config/>;
				var obj:Object = JSON.parse(_loader.data);
				for(var name:String in obj)
				{
					var objItem:Object = obj[name];
					var itemXml:XML = XML("<" + name + "/>");
					if(objItem.up != null) itemXml.@up = objItem.up;
					if(objItem.over != null) itemXml.@over = objItem.over;
					if(objItem.down != null) itemXml.@down = objItem.down;
					if(objItem.disabled != null) itemXml.@disabled = objItem.disabled;
					if(objItem.selectedUp != null) itemXml.@selectedUp = objItem.selectedUp;
					if(objItem.selectedOver != null) itemXml.@selectedOver = objItem.selectedOver;
					if(objItem.selectedDown != null) itemXml.@selectedDown = objItem.selectedDown;
					if(objItem.selectedDisabled != null) itemXml.@selectedDisabled = objItem.selectedDisabled;
					xml.appendChild(itemXml);
				}
			}
			
			Common.config.initSkinConfig(xml);
			
			skinList = [];
			var children:XMLList = xml.children();
			for each(var item:XML in children)
			{
				var arr:Array = [];
				var attributes:XMLList = item.@*;
				for(var i:int=0; i < attributes.length(); i++)
				{
					arr.push({
						state		: String(attributes[i].name()), 
						sourceName	: String(attributes[i])
					});
				}
				skinList.push({
					name	: String(item.name()),
					skins	: arr
				});
			}
			skinList.sortOn("name");
			
			
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