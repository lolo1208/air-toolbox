package app.layers
{
	import app.common.LayerConstants;
	
	import lolo.components.NumberText;

	/**
	 * NumberText 层
	 * @author LOLO
	 */
	public class NumberTextLayer extends LabelLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "numberText";
		
		
		
		public function NumberTextLayer()
		{
			super();
			this.type = LayerConstants.NUMBER_TEXT;
			tipsText = type.charAt().toUpperCase() + type.substr(1);
		}
		
		override protected function createElement():void
		{
			this.element = new NumberText();
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
			
			return props;
		}
		
		
		override public function get changedStyle():Object
		{
			super.changedStyle;
			
			checkStyle("normalColor");
			checkStyle("upColor");
			checkStyle("downColor");
			checkStyle("delay");
			
			return _exportStyle;
		}
		//
	}
}