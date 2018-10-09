package toolbox.views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Panel;
	import spark.components.RadioButtonGroup;
	
	import toolbox.Toolbox;
	import toolbox.data.SharedData;
	
	
	/**
	 * 设置面板
	 * @author LOLO
	 */
	public class SettingsPanel extends Panel
	{
		public var appType:RadioButtonGroup;
		public var appTypeEnabled:Boolean = false;
		
		
		public function SettingsPanel():void
		{
			if(SharedData.data.settings == null)
			{
				SharedData.data.settings = {
					appType	: 1
				};
				SharedData.save();
			}
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			appType.enabled = appTypeEnabled;
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
			
			
			appType.selectedValue = SharedData.data.settings.appType;
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			this.x = Toolbox.app.stage.stageWidth - width >> 1;
			this.y = Toolbox.app.stage.stageHeight - height >> 1;
		}
		
		
		
		/**
		 * 点击保存按钮
		 * @param event
		 */
		protected function saveBtn_clickHandler(event:MouseEvent):void
		{
			if(this.parent) PopUpManager.removePopUp(this);
			Toolbox.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			
			SharedData.data.settings.appType = appType.selectedValue;
			SharedData.save();
		}
		//
	}
}