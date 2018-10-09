package app.layers
{
	import app.common.LayerConstants;
	
	import flash.events.MouseEvent;
	
	import lolo.components.CheckBox;

	/**
	 * CheckBox 层
	 * @author LOLO
	 */
	public class CheckBoxLayer extends ButtonLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "checkBox1";
		
		
		
		
		public function CheckBoxLayer()
		{
			super();
			this.type = LayerConstants.CHECK_BOX;
			button.label = type.charAt().toUpperCase() + type.substr(1);
		}
		
		
		override protected function createElement():void
		{
			this.element = new CheckBox();
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