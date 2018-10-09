package app.main
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import toolbox.Toolbox;
	import toolbox.data.SharedData;

	/**
	 * 更新管理器
	 * @author LOLO
	 */
	public class Updater
	{
		private static var _instance:Updater;
		
		/**用于加载version.xml*/
		private var _verLoader:URLLoader;
		/**更新服务器地址*/
		private var _updateServer:String;
		/**解析好的工具对应的版本和安装信息列表*/
		private var _infoList:Dictionary;
		
		/**用于下载工具*/
		private var _toolLoader:URLLoader;
		
		/**当前正在更新的工具的信息*/
		private var _toolInfo:Object;
		
		
		
		/**
		 * 获取实例
		 */
		public static function getInstance():Updater
		{
			if(_instance == null) _instance = new Updater();
			return _instance;
		}
		
		
		
		public function Updater()
		{
			_verLoader = new URLLoader();
			_verLoader.addEventListener(Event.COMPLETE, verLoader_eventHandler);
			_verLoader.addEventListener(IOErrorEvent.IO_ERROR, verLoader_eventHandler);
			_verLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, verLoader_eventHandler);
		}
		
		
		/**
		 * 获取更新信息
		 */
		public function getUpdateInfo():void
		{
			if(AppCommon.UPDATE_SERVER_LIST.length > 0) {
				Toolbox.progressPanel.addProgress();
				_updateServer = AppCommon.UPDATE_SERVER_LIST.shift();
				_verLoader.load(new URLRequest(_updateServer + "version.xml"));
			}
			else {
				Toolbox.progressPanel.hide();
				Alert.show("连接更新服务器失败！\n这将会导致工具箱无法更新和安装新工具！", "重要提示");
			}
		}
		
		
		/**
		 * 加载版本信息
		 * @param evnet
		 */
		private function verLoader_eventHandler(event:Event):void
		{
			if(event.type == Event.COMPLETE)
			{
				try {
					var children:XMLList = XML(_verLoader.data).children();
				}
				catch(error:Error)
				{
					getUpdateInfo();
					return;
				}
				
				_infoList = new Dictionary();
				for each(var item:XML in children)
				{
					_infoList[String(item.name())] = {
						version	: String(item.@version),
						url		: String(item.@url).replace(/\[host\]/g, _updateServer)
					};
				}
				
				Toolbox.progressPanel.hide();
				checkUpdate("toolbox");
			}
			else
			{
				getUpdateInfo();
			}
		}
		
		
		
		/**
		 * 检查指定工具是否有更新
		 * @param tool
		 */
		public function checkUpdate(tool:String):Boolean
		{
			if(_toolLoader == null) {
				_toolLoader = new URLLoader();
				_toolLoader.addEventListener(Event.COMPLETE, toolLoader_eventHandler);
				_toolLoader.addEventListener(ProgressEvent.PROGRESS, toolLoader_eventHandler);
				_toolLoader.addEventListener(IOErrorEvent.IO_ERROR, toolLoader_eventHandler);
				_toolLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, toolLoader_eventHandler);
				_toolLoader.dataFormat = URLLoaderDataFormat.BINARY;
			}
			
			_toolInfo = SharedData.data[tool];
			var title:String;
			if(_toolInfo == null) {
				title = "正在下载新工具";
			}
			else if(_infoList != null && _toolInfo.version != _infoList[tool].version) {
				title = _toolInfo.name + "有更新，正在下载最新版本";
			}
			
			if(title != null)
			{
				Toolbox.progressPanel.show(0, 0, title);
				_toolLoader.load(new URLRequest(_infoList[tool].url));
				return true;
			}
			return false;
		}
		
		
		
		
		/**
		 * 下载工具
		 * @param event
		 */
		private function toolLoader_eventHandler(event:Event):void
		{
			if(event.type == Event.COMPLETE)
			{
				if(_toolInfo == null) _toolInfo = { tool:new Date().time };
				//保存到本地
				var file:File = new File(Toolbox.updatePath + _toolInfo.tool + ".exe");
				var fs:FileStream = new FileStream();
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(_toolLoader.data);
				fs.close();
				
				Toolbox.progressPanel.hide();
				Alert.show("安装时，如果 [替换] 按钮为禁用状态（提示正在运行），请勿关闭安装程序，稍候几秒即可..", "重要提示",
					4, null, updateAlertCloseHandler);
			}
			else if(event.type == ProgressEvent.PROGRESS)
			{
				Toolbox.progressPanel.show(
					_toolLoader.bytesTotal, _toolLoader.bytesLoaded,
					Toolbox.progressPanel.progressBar.label
				);
			}
			else
			{
				Toolbox.progressPanel.hide();
				Alert.show("下载工具失败！！\n请确认网络连接正常后再重试！", "提示");
			}
		}
		
		
		
		private function updateAlertCloseHandler(event:CloseEvent):void
		{
			//启动该程序
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File(Toolbox.updatePath + _toolInfo.tool + ".exe");
			new NativeProcess().start(npsi);
			
			//杀掉对应的进程
			if(_toolInfo.name != null) {
				var args:Vector.<String> = new Vector.<String>();
				args.push("/F");
				args.push("/IM");
				args.push(_toolInfo.name + ".exe");
				npsi = new NativeProcessStartupInfo();
				npsi.executable = new File("C:/Windows/System32/taskkill.exe");
				npsi.arguments = args;
				new NativeProcess().start(npsi);
			}
			
			//杀掉工具箱进程，为了读取新的版本号
			args = new Vector.<String>();
			args.push("/F");
			args.push("/IM");
			args.push(SharedData.data["toolbox"].name + ".exe");
			npsi = new NativeProcessStartupInfo();
			npsi.executable = new File("C:/Windows/System32/taskkill.exe");
			npsi.arguments = args;
			new NativeProcess().start(npsi);
		}
		
		
		
		/**
		 * 更新服务器地址
		 */
		public function get updateServer():String
		{
			return _updateServer;
		}
		//
	}
}