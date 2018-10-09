package app.exportPanel
{
	import app.main.Export;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import lolo.data.SO;
	
	import mx.managers.PopUpManager;
	
	import spark.components.Panel;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	
	import toolbox.Toolbox;
	
	/**
	 * 导出面板
	 * @author LOLO
	 */
	public class ExportPanel extends Panel
	{
		public var appType:RadioButtonGroup;
		public var cwText:TextInput;
		public var chText:TextInput;
		public var twText:TextInput;
		public var thText:TextInput;
		
		
		public function ExportPanel()
		{
			super();
		}
		
		
		
		
		protected function exportBtn_clickHandler(event:MouseEvent):void
		{
			SO.data.mapEditorSetting = {};
			SO.data.mapEditorSetting.appType = Export.appType = int(appType.selectedValue);
			SO.data.mapEditorSetting.chunkWidth = Export.chunkWidth = uint(cwText.text);
			SO.data.mapEditorSetting.chunkHeight = Export.chunkHeight = uint(chText.text);
			SO.data.mapEditorSetting.thumbnailWidth = Export.thumbnailWidth = uint(twText.text);
			SO.data.mapEditorSetting.thumbnailHeight = Export.thumbnailHeight = uint(thText.text);
			SO.save();
			Export.start();
			this.hide();
		}
		
		
		protected function closeBtn_clickHandler(event:MouseEvent):void
		{
			this.hide();
		}
		
		
		
		/**
		 * 显示面板
		 */
		public function show():void
		{
			if(!this.parent) {
				PopUpManager.addPopUp(this, Toolbox.app, true);
				stage_resizeHandler();
			}
			Toolbox.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			
			
			if(SO.data.mapEditorSetting != null)
			{
				appType.selectedValue = SO.data.mapEditorSetting.appType;
				cwText.text = SO.data.mapEditorSetting.chunkWidth;
				chText.text = SO.data.mapEditorSetting.chunkHeight;
				twText.text = SO.data.mapEditorSetting.thumbnailWidth;
				thText.text = SO.data.mapEditorSetting.thumbnailHeight;
			}
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			this.x = Toolbox.stage.stageWidth - width >> 1;
			this.y = Toolbox.stage.stageHeight - height >> 1;
		}
		
		
		/**
		 * 隐藏面板
		 */
		public function hide():void
		{
			if(this.parent) PopUpManager.removePopUp(this);
			Toolbox.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
		}
		//
	}
}