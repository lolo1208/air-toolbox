package app.layers
{
	import app.common.LayerConstants;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import lolo.utils.StringUtil;

	/**
	 * ModalBackground 图层
	 * @author LOLO
	 */
	public class ModalBackgroundLayer extends Layer
	{
		private var _color:uint = 0x0;
		
		
		public function ModalBackgroundLayer()
		{
			super();
			this.type = LayerConstants.MODAL_BACKGROUND;
			
			alpha = 0.1;
			render();
		}
		
		
		override protected function createElement():void
		{
			this.element = new Sprite();
		}
		
		
		private function render():void
		{
			(element as Sprite).graphics.clear();
			(element as Sprite).graphics.beginFill(_color);
			(element as Sprite).graphics.drawRect(-500, -300, 2000, 1200);
			(element as Sprite).graphics.endFill();
		}
		
		
		
		public function set color(value:uint):void
		{
			_color = value;
			render();
		}
		public function get color():uint { return _color; }
		
		
		
		override public function set x(value:Number):void {}
		override public function set y(value:Number):void {}
		
		override public function canDrag(event:MouseEvent=null):Boolean { return false; }
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(_alpha != 0.1) {
				props.alpha = _alpha;
			}
			else {
				delete props.alpha;
			}
			
			if(_color != 0x0) {
				props.color = StringUtil.getColorString(_color);
			}
			
			return props;
		}
		//
	}
}