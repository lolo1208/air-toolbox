package app.layers
{
	import app.common.LayerConstants;
	import app.utils.LayerUtil;
	
	import flash.text.TextFieldAutoSize;
	
	import lolo.components.Label;
	
	import toolbox.Toolbox;

	/**
	 * label层
	 * @author LOLO
	 */
	public class LabelLayer extends BaseTextFieldLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "label";
		
		
		
		public function LabelLayer()
		{
			super();
			this.type = LayerConstants.LABEL;
			tipsText = type.charAt().toUpperCase() + type.substr(1);
		}
		
		override protected function createElement():void
		{
			this.element = new Label();
			styleName = STYLE_NAME;
			
			if(!Toolbox.isASProject) {
				LayerUtil.getTextField(this).autoSize = TextFieldAutoSize.LEFT;
				LayerUtil.getTextField(this).multiline = true;
			}
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
			
			checkStyle("moreText");
			
			return _exportStyle;
		}
		//
	}
}