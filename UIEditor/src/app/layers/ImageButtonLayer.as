package app.layers
{
	import app.common.LayerConstants;
	
	import flash.events.MouseEvent;
	
	import lolo.components.ImageButton;

	/**
	 * ImageButton 层
	 * @author LOLO
	 */
	public class ImageButtonLayer extends BaseButtonLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "imageButton1";
		
		
		
		public function ImageButtonLayer()
		{
			super();
			this.type = LayerConstants.IMAGE_BUTTON;
		}
		
		
		override protected function createElement():void
		{
			this.element = new ImageButton();
			this.element.addEventListener(MouseEvent.CLICK, stopImmediatePropagation, false, 1);
			styleName = STYLE_NAME;
		}
		
		
		override public function initStyle(setter:Boolean=true):void
		{
			super.initStyle(setter);
			setStyleBySN(STYLE_NAME, setter);
		}
		
		
		
		
		override public function get changedStyle():Object
		{
			super.changedStyle;
			
			checkStyle("autoSize");
			checkStyle("minWidth");
			checkStyle("maxWidth");
			checkStyle("minHeight");
			checkStyle("maxHeight");
			
			checkStyle("imagePaddingTop");
			checkStyle("imagePaddingBottom");
			checkStyle("imagePaddingLeft");
			checkStyle("imagePaddingRight");
			checkStyle("imageHorizontalAlign");
			checkStyle("imageVerticalAlign");
			
			checkStyle("imagePrefix");
			
			return _exportStyle;
		}
		//
	}
}