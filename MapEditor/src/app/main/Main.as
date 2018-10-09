package app.main
{
	import app.canvasGroup.CanvasGroupView;
	import app.common.AppCommon;
	import app.exportPanel.ExportPanelView;
	import app.layerPanel.LayerPanelView;
	import app.propertiesPanel.PropertiesPanelView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.utils.Helper;
	
	/**
	 * 主界面，入口
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var menuBar:MenuBar;
		public var canvasGroup:CanvasGroupView;
		public var layerPanel:LayerPanelView;
		public var propertiesPanel:PropertiesPanelView;
		
		public var exportPanel:ExportPanelView = new ExportPanelView();
		
		
		[Bindable]
		public var menuData:ArrayCollection;
		
		
		
		public function Main()
		{
			super();
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			AppCommon.app = this;
			resizeHandler();
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("mapEditor", "地图编辑器");
			
			menuData = new ArrayCollection([
				{ label:"文件", children:[{label:"新建"}, {label:"打开源文件"}, {label:"导出"}] },
				{ label:"帮助", children:[{label:"关于"}, {label:"ver: " + Toolbox.version, enabled:false}, {label:"检查更新"}] }
			]);
		}
		
		protected function resizeHandler(event:ResizeEvent=null):void
		{
			if(menuBar == null) return;
			
			menuBar.width = width;
			
			canvasGroup.width = width - 250;
			canvasGroup.height = height - 35;
			
			layerPanel.x = width - 235;
			layerPanel.height = int(height * 0.6);
			
			propertiesPanel.x = layerPanel.x;
			propertiesPanel.y = layerPanel.y + layerPanel.height + 10;
			propertiesPanel.height = height - layerPanel.height - 44;
		}
		
		
		protected function menuBar_itemClickHandler(event:MenuEvent):void
		{
			switch(event.label)
			{
				case "新建": newMap(); break;
				case "打开源文件": Open.start(); break;
				case "导出": exportPanel.show(); break;
				case "关于": Helper.about(); break;
				case "检查更新": Helper.checkUpdate(); break;
			}
		}
		
		
		
		private function newMap():void
		{
			Alert.show("您确定不保存当前编辑的内容，新建一个地图场景吗？", "提示",
				Alert.YES | Alert.NO, this, doNewMap);
		}
		
		private function doNewMap(event:CloseEvent):void
		{
			if(event.detail != Alert.YES) return;
			AppCommon.bgIndex = AppCommon.coverIndex = 0;
			AppCommon.app.layerPanel.bgList.dataProvider = new ArrayList();
			AppCommon.app.layerPanel.coverList.dataProvider = new ArrayList();
			AppCommon.app.canvasGroup.bgC.removeChildren();
			AppCommon.app.canvasGroup.coverC.removeChildren();
			AppCommon.app.canvasGroup.tileC.removeChildren();
		}
		//
	}
}