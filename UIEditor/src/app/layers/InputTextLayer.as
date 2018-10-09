package app.layers
{
	import app.common.LayerConstants;
	
	import lolo.components.InputText;

	/**
	 * InputText 层
	 * @author LOLO
	 */
	public class InputTextLayer extends BaseTextFieldLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "inputText";
		
		
		
		public function InputTextLayer()
		{
			super();
			this.type = LayerConstants.INPUT_TEXT;
			tipsText = type.charAt().toUpperCase() + type.substr(1);
		}
		
		override protected function createElement():void
		{
			this.element = new InputText();
			styleName = STYLE_NAME;
		}
		
		
		override public function initStyle(setter:Boolean=true):void
		{
			super.initStyle(setter);
			setStyleBySN(STYLE_NAME, setter);
		}
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(props.styleName == STYLE_NAME) {
				delete props.styleName;
			}
			
			if(textField.autoSize != "none"){
				props.autoSize = textField.autoSize;
			}
			else {
				delete props.autoSize;
			}
			
			return props;
		}
		//
	}
}