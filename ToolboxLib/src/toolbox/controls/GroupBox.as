package toolbox.controls
{
	import mx.events.FlexEvent;
	
	import spark.components.BorderContainer;
	import spark.components.Label;
	
	public class GroupBox extends BorderContainer
	{
		private var _titleText:Label;
		
		
		public function GroupBox()
		{
			super();
			this.setStyle("borderColor", 0xD0D0BF);
			titleBgColor = 0xFFFFFF;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
			_titleText.setStyle("color", 0x0046D5);
			_titleText.x = 8;
			_titleText.y = -7;
			this.addElement(_titleText);
		}
		
		
		public function set title(value:String):void
		{
			if(_titleText == null) _titleText = new Label();
			_titleText.text = value;
		}
		
		public function get title():String
		{
			return _titleText.text;
		}
		
		
		public function set titleBgColor(value:uint):void
		{
			if(_titleText == null) _titleText = new Label();
			_titleText.opaqueBackground = value;
		}
		
		public function get titleBgColor():uint
		{
			return uint(_titleText.opaqueBackground);
		}
		//
	}
}