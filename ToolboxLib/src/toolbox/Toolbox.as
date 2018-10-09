package toolbox
{
	import flash.display.Stage;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import lolo.core.Common;
	import lolo.ui.Console;
	import lolo.ui.Stats;
	import lolo.utils.StringUtil;
	
	import spark.components.WindowedApplication;
	
	import toolbox.data.SharedData;
	import toolbox.views.ProgressPanelView;
	import toolbox.views.ProjectPanelView;
	import toolbox.views.SettingsPanelView;

	public class Toolbox
	{
		/**对当前程序的引用*/
		public static var app:WindowedApplication;
		/**当前程序的版本号*/
		public static var version:String;
		/**当前程序的产出文档目录*/
		public static var docPath:String
		/**当前工具（aniPackager、mapEditor 等）*/
		public static var currentTool:String;
		
		/**对舞台的引用*/
		public static var stage:Stage;
		
		/**进度面板*/
		public static var progressPanel:ProgressPanelView;
		/**设置面板*/
		public static var settingsPanel:SettingsPanelView;
		/**项目面板*/
		public static var projectPanel:ProjectPanelView;
		
		
		
		
		/**
		 * 初始化
		 * @param app
		 * @param stage
		 */
		public static function initialize(app:WindowedApplication, stage:Stage):void
		{
			Toolbox.app = app;
			progressPanel = new ProgressPanelView();
			settingsPanel = new SettingsPanelView();
			projectPanel = new ProjectPanelView();
			
			if(SharedData.data.resRootDirHistorys == null)
				SharedData.data.resRootDirHistorys = [];
			
			namespace ns = "http://ns.adobe.com/air/application/3.5";
			use namespace ns;
			Toolbox.version = app.nativeApplication.applicationDescriptor.versionNumber;
			
			Common.stage = Toolbox.stage = stage;
			Console.getInstance().container = stage;
			Stats.getInstance().container = stage;
			
			app.nativeWindow.x = Capabilities.screenResolutionX - app.nativeWindow.width >> 1;
			app.nativeWindow.y = Capabilities.screenResolutionY - app.nativeWindow.height - 40 >> 1;
		}
		
		
		
		/**
		 * 初始化工具箱（工具箱启动时调用，其他程序不调用）
		 */
		public static function initToolbox():void
		{
			var path:String = StringUtil.backslashToSlash(File.applicationDirectory.nativePath);
			SharedData.data.binPath = path + "/bin/";
			SharedData.data.updatePath = path + "/update/";
			SharedData.data.explorerPath = "C:/Windows/explorer.exe";
			SharedData.save();
		}
		
		
		
		/**
		 * 设置工具的信息
		 * @param tool
		 * @param name
		 */
		public static function setToolInfo(tool:String, name:String):void
		{
			if(SharedData.data[tool] == null) SharedData.data[tool] = {};
			SharedData.data[tool].tool = tool;
			SharedData.data[tool].version = version;
			SharedData.data[tool].name = name;
			SharedData.data[tool].path = StringUtil.backslashToSlash(
				File.applicationDirectory.nativePath + "/" + name + ".exe");
			SharedData.save();
			
			Toolbox.docPath = StringUtil.backslashToSlash(File.documentsDirectory.nativePath)
				+ "/LoloToolbox/" + tool + "/";
			
			currentTool = tool;
		}
		
		
		
		
		
		/**其他应用程序目录*/
		public static function get binPath():String { return SharedData.data.binPath; }
		
		
		/**更新安装包存储目录*/
		public static function get updatePath():String { return SharedData.data.updatePath; }
		
		
		/**项目资源库根目录，例如：res/zh_CN*/
		public static function set resRootDir(value:String):void
		{
			value = StringUtil.backslashToSlash(value);
			if(value.charAt(value.length - 1) != "/") value += "/";
			SharedData.data.resRootDir = value;
			
			var list:Array = SharedData.data.resRootDirHistorys;
			var index:int = list.indexOf(value);
			if(index != -1) list.splice(index, 1);
			list.splice(0, 0, value);
			
			SharedData.save();
		}
		public static function get resRootDir():String { return SharedData.data.resRootDir; }
		
		
		
		/**explorer路径*/
		public static function get explorerPath():String { return SharedData.data.explorerPath; }
		
		
		/**pngquant路径*/
		public static function get pngquantPath():String { return binPath + "pngquant/pngquant.exe"; }
		
		
		/**是否为ActionScript项目*/
		public static function get isASProject():Boolean { return SharedData.data.settings.appType == 1; }
		//
	}
}