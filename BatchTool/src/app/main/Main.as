package app.main
{
	import app.common.AppCommon;
	import app.dbdMerger.DbdMergerView;
	import app.ldExport.LdExportView;
	import app.ldUpdate.LdUpdateView;
	import app.logging.LoggerView;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	
	import spark.components.WindowedApplication;
	
	import toolbox.Toolbox;
	import toolbox.utils.Helper;
	
	/**
	 * 批处理工具
	 * @author LOLO
	 */
	public class Main extends WindowedApplication
	{
		public var logger:LoggerView;
		public var ldUpdate:LdUpdateView;
		public var ldExport:LdExportView;
		public var dbdMerger:DbdMergerView;
		
		[Bindable]
		public var menuData:ArrayCollection;
		
		
		
		public function Main()
		{
			super();
			AppCommon.app = this;
		}
		
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			this.removeElement(logger);
		}
		
		
		
		protected function addedToStageHandler(event:Event):void
		{
			Toolbox.initialize(this, stage);
			Toolbox.setToolInfo("batchTool", "批处理工具");
			
			menuData = new ArrayCollection([
				{ label:"项目", children:[
					{label:"切换项目"},
					{type:"separator"},
					{label:"设置"}
				]},
				{ label:"帮助", children:[
					{label:"关于"},
					{label:"ver: " + Toolbox.version, enabled:false},
					{label:"检查更新"}
				]}
			]);
			
			ldUpdate.init();
			ldExport.init();
			dbdMerger.init();
			Toolbox.projectPanel.refresh();
		}
		
		
		
		protected function menuBar_itemClickHandler(event:MenuEvent):void
		{
			switch(event.label)
			{
				case "切换项目": Toolbox.projectPanel.choose(); break;
				case "设置": Toolbox.settingsPanel.show(); break;
				case "关于": Helper.about(); break;
				case "检查更新": Helper.checkUpdate(); break;
			}
		}
		
		
		//
	}
}