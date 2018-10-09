package app.main
{
	import app.common.AppCommon;
	import app.exportGroup.ExportGroup;
	import app.fileGroup.FileGroup;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import lolo.core.Common;
	import lolo.data.LRUCache;
	import lolo.display.Animation;
	import lolo.display.BitmapSprite;
	
	import mx.collections.ArrayCollection;
	import mx.controls.MenuBar;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.utils.Helper;
	
	/**
	 * 动画打包
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var menuBar:MenuBar;
		public var fileGroup:FileGroup;
		public var exportGroup:ExportGroup;
		public var changeInfoPanel:ChangeInfoPanel;
		public var previewPanel:PreviewPanel;
		
		[Bindable]
		public var menuData:ArrayCollection;
		
		
		
		public function Main()
		{
			super();
			AppCommon.app = this;
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			this.removeElement(changeInfoPanel);
			this.removeElement(previewPanel);
		}
		
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("ldTool", "文件包工具");
			
			menuData = new ArrayCollection([
				{ label:"文件", children:[
					{label:"重置打开类型"},
					{label:"打开文件"},
					{label:"导出"}
				]},
				{ label:"项目", children:[
					{label:"设置"}
				]},
				{ label:"帮助", children:[
					{label:"关于"},
					{label:"ver: " + Toolbox.version, enabled:false},
					{label:"检查更新"}
				]}
			]);
			
			Common.stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUpHandler);
			
			
			//初始化 AS3 core 框架相关
			BitmapSprite.cache = new LRUCache();
			BitmapSprite.cache.maxMemorySize = 999 * 1024 * 1024;
			BitmapSprite.config = new Dictionary();
			
			Animation.cache = new LRUCache();
			Animation.cache.maxMemorySize = 999 * 1024 * 1024;
			Animation.config = new Dictionary();
		}
		
		private function stage_keyUpHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.ENTER:
					if(changeInfoPanel.parent != null) changeInfoPanel.submt();
					break;
			}
		}
		
		protected function menuBar_itemClickHandler(event:MenuEvent):void
		{
			switch(event.label)
			{
				case "重置打开类型": fileGroup.resetType(); break;
				case "打开文件": fileGroup.openFile(); break;
				case "导出": exportGroup.export(); break;
				case "设置": Toolbox.settingsPanel.show(); break;
				case "关于": Helper.about(); break;
				case "检查更新": Helper.checkUpdate(); break;
			}
		}
		
		
		
		//
	}
}