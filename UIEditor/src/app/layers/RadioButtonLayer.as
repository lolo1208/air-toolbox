package app.layers
{
	import app.common.LayerConstants;
	
	import flash.events.MouseEvent;
	
	import lolo.components.RadioButton;

	/**
	 * CheckBox 层
	 * @author LOLO
	 */
	public class RadioButtonLayer extends CheckBoxLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "radioButton1";
		
		
		
		public function RadioButtonLayer()
		{
			super();
			this.type = LayerConstants.RADIO_BUTTON;
			button.label = type.charAt().toUpperCase() + type.substr(1);
		}
		
		
		override protected function createElement():void
		{
			this.element = new RadioButton();
			this.element.addEventListener(MouseEvent.CLICK, stopImmediatePropagation, false, 1);
			
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
			
			/*
			//按钮不能去除默认样式名称，正式项目中需要依此初始化
			if(props.styleName == STYLE_NAME) {
				delete props.styleName;
			}
			*/
			
			return props;
		}
		//
	}
}