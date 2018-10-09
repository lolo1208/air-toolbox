package app.controls
{
	import app.common.AppCommon;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;

	/**
	 * 重载配置文件控制器
	 * @author LOLO
	 */
	public class Reload
	{
		/**用于加载配置文件*/
		private static var _configLoader:URLLoader;
		/**弹出提示回调*/
		private static var _alertCallback:Function;
		
		
		
		
		/**
		 * 重载当前打开的配置文件
		 */
		public static function reload():void
		{
			if(!AppCommon.controller.configOpened) return;
			
			if(_configLoader == null) {
				_configLoader = new URLLoader();
				_configLoader.addEventListener(Event.COMPLETE, configLoader_completeHandler);
			}
			
			_configLoader.load(new URLRequest(AppCommon.controller.configPath));
		}
		
		
		private static function configLoader_completeHandler(event:Event):void
		{
			var selectedIndex:uint = AppCommon.canvas.containerTB.selectedIndex;
			var config:XML = new XML(_configLoader.data);
			AppCommon.controller.openConfig(AppCommon.controller.configPath, config);
			AppCommon.canvas.containerTB.selectedIndex = selectedIndex;
		}
		
		
		
		/**
		 * 弹出重载提示
		 * @param action 要执行的动作
		 * @param callback 弹出提示框关闭时的回调，会传递一个Boolean参数，表示是否同意执行动作
		 * @param isReload [ true:重载当前配置文件, false:关闭当前配置文件 ]
		 */
		public static function alert(action:String, callback:Function, isReload:Boolean=true):void
		{
			_alertCallback = callback;
			
			if(AppCommon.controller.configOpened)
			{
				Alert.show(action + " 会 ["
					+ (isReload ? "重载" : "关闭")
					+ "] 当前正在编辑的配置文件，如果您还有 [未保存] 的改动，将会 [丢失]。\n请慎重！！！\n\n" +
					"　　　　　　旁友，侬确定要这么做吗？\n\n", "重要提示！",
					Alert.YES|Alert.NO, null, alert_closeHandler
				);
			}
			else {
				alert_closeHandler();
			}
		}
		
		private static function alert_closeHandler(event:CloseEvent=null):void
		{
			if(_alertCallback != null) {
				_alertCallback(event == null || event.detail == Alert.YES);
				_alertCallback = null;
			}
		}
		
		//
	}
}