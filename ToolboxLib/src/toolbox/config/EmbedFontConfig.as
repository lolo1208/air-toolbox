package toolbox.config
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.display.BaseTextField;
	
	import toolbox.Toolbox;

	
	/**
	 * 加载和解析嵌入文本配置文件
	 * @author LOLO
	 */
	public class EmbedFontConfig
	{
		/**加载和解析完成时的回调*/
		public static var callback:Function;
		/**加载好的配置文件*/
		public static var config:XML;
		
		/**临时变量保存列表*/
		private static var _tempDic:Dictionary = new Dictionary();
		/**用于加载配置文件*/
		private static var _loader:URLLoader;
		
		
		
		/**
		 * 加载配置文件
		 */
		public static function load(callback:Function=null):void
		{
			//H5项目没有嵌入字体
			if(!Toolbox.isASProject) {
				if(callback != null) callback();
				return;
			}
			
			EmbedFontConfig.callback = callback;
			Toolbox.progressPanel.show(0, 0, "刷新 EmbedFontConfig.xml");
			
			if(_loader == null) {
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, completeHandler);
			}
			_loader.load(new URLRequest(Toolbox.resRootDir + "xml/core/EmbedFontConfig.xml"));
		}
		
		
		/**
		 * 加载配置文件完成
		 * @param event
		 */
		private static function completeHandler(event:Event):void
		{
			config = XML(_loader.data);
			BaseTextField.initialize(config);
			Common.stage.addEventListener(Event.ENTER_FRAME, callTheCallback);
			
			var children:XMLList = config.item;
			for each(var item:XML in children)
			{
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler);
				urlLoader.load(new URLRequest(Common.getResUrl(String(item.@url))));
				_tempDic[urlLoader] = true;
			}
		}
		
		
		
		/**
		 * 加载嵌入字体swf文件完成
		 * @param event
		 */
		private static function urlLoader_completeHandler(event:Event):void
		{
			var urlLoader:URLLoader = event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, urlLoader_completeHandler);
			delete _tempDic[urlLoader];
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.allowLoadBytesCodeExecution = true;
			loaderContext.applicationDomain = ApplicationDomain.currentDomain;
			loader.loadBytes(urlLoader.data, loaderContext);
			_tempDic[loader] = true;
		}
		
		
		/**
		 * 加载嵌入字体swf ByteArray完成
		 * @param event
		 */
		private static function loader_completeHandler(event:Event):void
		{
			var loader:Loader = (event.target as LoaderInfo).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_completeHandler);
			delete _tempDic[loader];
			loader.unloadAndStop();
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