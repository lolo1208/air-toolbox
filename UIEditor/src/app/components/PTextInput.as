package app.components
{
	import app.common.AppCommon;
	
	import flash.events.FocusEvent;
	
	import spark.components.TextInput;
	
	/**
	 * 属性输入文本框
	 * @author LOLO
	 */
	public class PTextInput extends TextInput
	{
		
		public function PTextInput()
		{
			super();
		}
		
		
		override public function set editable(value:Boolean):void
		{
			super.editable = value;
			this.setStyle("color", value ? 0 : 0x999999);
		}
		
		
		
		override protected function focusInHandler(event:FocusEvent):void
		{
			AppCommon.keyboardUsing = true;
			super.focusInHandler(event);
		}
		
		
		override protected function focusOutHandler(event:FocusEvent):void
		{
			AppCommon.keyboardUsing = false;
			super.focusOutHandler(event);
		}
		//
	}
}