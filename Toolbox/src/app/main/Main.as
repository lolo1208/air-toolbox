package app.main
{
	import app.common.AppCommon;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import lolo.utils.ExternalUtil;
	
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.data.SharedData;
	
	/**
	 * 主界面，入口
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var uiPackagerBtn:Button;
		public var aniPackagerBtn:Button;
		public var skinEditorBtn:Button;
		public var uiEditorBtn:Button;
		public var ldToolBtn:Button;
		public var batchToolBtn:Button;
		public var mapEditorBtn:Button;
		
		public var apiBtn:Button;
		public var versionText:Label;
		
		
		
		
		public function Main()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			AppCommon.app = this;
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("toolbox", "工具箱2.0");
			Toolbox.initToolbox();
			
			Toolbox.progressPanel.show(AppCommon.UPDATE_SERVER_LIST.length, 0, "正在检查更新...");
			Updater.getInstance().getUpdateInfo();
			
			versionText.text = "ver: " + Toolbox.version;
		}
		
		
		
		protected function toolBtn_clickHandler(event:MouseEvent):void
		{
			var tool:String;
			switch(event.target)
			{
				case uiPackagerBtn: tool = "uiPackager"; break;
				case aniPackagerBtn: tool = "animationPackager"; break;
				case skinEditorBtn: tool = "skinEditor"; break;
				case uiEditorBtn: tool = "uiEditor"; break;
				case ldToolBtn: tool = "ldTool"; break;
				case batchToolBtn: tool = "batchTool"; break;
				case mapEditorBtn: tool = "mapEditor"; break;
			}
			
			if(!Updater.getInstance().checkUpdate(tool))
			{
				var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				npsi.executable = new File(SharedData.data[tool].path);
				new NativeProcess().start(npsi);
			}
		}
		
		
		
		
		protected function apiBtn_clickHandler(event:MouseEvent):void
		{
			ExternalUtil.openWindow(Updater.getInstance().updateServer + "api.html");
		}
		//
	}
}