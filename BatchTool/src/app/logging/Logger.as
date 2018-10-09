package app.logging
{
	import flash.events.MouseEvent;
	
	import mx.controls.HTML;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.Panel;
	
	import toolbox.Toolbox;
	
	/**
	 * 日志面板
	 * @author LOLO
	 */
	public class Logger extends Panel
	{
		public var html:HTML;
		public var closeBtn:Button;
		
		
		
		public function Logger()
		{
			super();
		}
		
		
		
		public function addLog(log:String,
							   color:uint=0x666666,
							   size:int=12,
							   font:String="微软雅黑"
		):void
		{
			
			var text:String = html.htmlText;
			if(text == null) text = "";
			
			text += '<p style="margin:5px auto; color:#' + color.toString(16) + '; font-family:' + font +'; font-size:' + size + '">';
			text += log + "</p>";
			
			html.htmlText = text;
		}
		
		
		protected function html_updateCompleteHandler(event:FlexEvent):void
		{
			html.verticalScrollPosition = html.maxVerticalScrollPosition;
		}
		
		
		
		public function addErrorLog(log:String):void
		{
			addLog(log, 0xCC3333, 14);
		}
		
		public function addSuccLog(log:String):void
		{
			addLog(log, 0x33CC33, 14);
		}
		
		
		
		/**
		 * 显示面板
		 */
		public function show(title:String):void
		{
			if(!this.parent) {
				PopUpManager.addPopUp(this, Toolbox.app, true);
				
				this.width = int(Toolbox.stage.stageWidth * 0.6);
				this.height = int(Toolbox.stage.stageHeight * 0.8);
				closeBtn.x = this.width - 27;
				html.width = this.width - 22;
				html.height = this.height - 52;
				this.x = Toolbox.stage.stageWidth - this.width >> 1;
				this.y = Toolbox.stage.stageHeight - this.height >> 1;
			}
			
			this.title = title;
		}
		
		
		/**
		 * 隐藏面板
		 */
		public function hide():void
		{
			if(this.parent) PopUpManager.removePopUp(this);
		}
		
		
		
		
		protected function closeBtn_clickHandler(event:MouseEvent):void
		{
			hide();
		}
		
		
		
		
		public function clear():void
		{
			html.htmlText = null;
		}
		//
	}
}