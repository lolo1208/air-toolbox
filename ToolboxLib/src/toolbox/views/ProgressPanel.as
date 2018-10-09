package toolbox.views
{
	import flash.events.Event;
	
	import mx.controls.ProgressBar;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Panel;
	
	import toolbox.Toolbox;
	
	
	/**
	 * 进度面板
	 * @author LOLO
	 */
	public class ProgressPanel extends Panel
	{
		public var progressBar:ProgressBar;
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			
		}
		
		
		/**
		 * 显示面板
		 */
		public function show(total:Number=0, value:Number=0, label:String=""):void
		{
			if(!this.parent) {
				PopUpManager.addPopUp(this, Toolbox.app, true);
				stage_resizeHandler();
			}
			Toolbox.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			
			if(total == 0) total = progressBar.maximum;
			progressBar.setProgress(value, total);
			progressBar.label = label;
		}
		
		
		private function stage_resizeHandler(event:Event=null):void
		{
			this.x = Toolbox.app.stage.stageWidth - width >> 1;
			this.y = Toolbox.app.stage.stageHeight - height >> 1;
		}
		
		
		
		/**
		 * 隐藏面板
		 */
		public function hide():void
		{
			if(this.parent) PopUpManager.removePopUp(this);
			Toolbox.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
		}
		
		/**
		 * 进度递增一次
		 */
		public function addProgress():void
		{
			progressBar.setProgress(progressBar.value + 1, progressBar.maximum);
		}
		
		
		
		/**
		 * 是否有操作正在进行中
		 * @return 
		 */
		public function get running():Boolean { return parent != null; }
		//
	}
}