package app.layers
{
	import app.common.LayerConstants;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	/**
	 * ScrollList 层
	 * @author LOLO
	 */
	public class ScrollListLayer extends ListLayer
	{
		/**图层类型*/
		private static const LAYER_TYPE:String = "ScrollList";
		
		/**对应的滚动条组件*/
		protected var _scrollBarLayer:*;
		
		private var _elementMask:Shape;
		
		
		
		public function ScrollListLayer()
		{
			super();
			this.type = LayerConstants.SCROLL_LIST;
		}
		
		
		override protected function createElement():void
		{
			this.element = new MovieClip();
			
			_elementMask = new Shape();
			this.addChild(_elementMask);
		}
		
		
		
		/**
		 * 滚动条的显示区域有改变
		 * @param event
		 */
		private function scrollBar_viewableAreaChangedHandler(event:Event=null):void
		{
			super.x = _scrollBarLayer.viewableArea.x;
			super.y = _scrollBarLayer.viewableArea.y;
			
			_element.mask = _elementMask;
			_elementMask.graphics.clear();
			_elementMask.graphics.beginFill(0);
			_elementMask.graphics.drawRect(
				_scrollBarLayer.viewableArea.x,
				_scrollBarLayer.viewableArea.y,
				_scrollBarLayer.viewableArea.width,
				_scrollBarLayer.viewableArea.height
			);
			_elementMask.graphics.endFill();
			
			update();
		}
		
		
		override protected function prerender():void
		{
			if(_scrollBarLayer == null || _itemLayer == null) {
				super.prerender();
				return;
			}
			
			var or:uint = _rowCount;
			var oc:uint = _columnCount;
			_columnCount = Math.ceil(_scrollBarLayer.viewableArea.width / (_itemLayer.itemWidth + _horizontalGap));
			_rowCount = Math.ceil(_scrollBarLayer.viewableArea.height / (_itemLayer.itemHeight + _verticalGap));
			_columnCount = Math.min(_columnCount, oc);
			_rowCount = Math.min(_rowCount, or);
			
			super.prerender();
			
			_rowCount = or;
			_columnCount = oc;
		}
		
		
		
		public function set scrollBarLayer(value:*):void
		{
			if(_scrollBarLayer != null) {
				_scrollBarLayer.removeEventListener(ScrollBarLayer.VIEWABLE_AREA_CHANGED, scrollBar_viewableAreaChangedHandler);
			}
			
			_scrollBarLayer = value;
			if(_scrollBarLayer != null) {
				_scrollBarLayer.addEventListener(ScrollBarLayer.VIEWABLE_AREA_CHANGED, scrollBar_viewableAreaChangedHandler);
				scrollBar_viewableAreaChangedHandler();
			}
			else {
				_elementMask.graphics.clear();
				_element.mask = null;
				update();
			}
		}
		
		public function get scrollBarLayer():* { return _scrollBarLayer; }
		
		public function get scrollBarID():String
		{
			if(_scrollBarLayer == null) return null;
			if(_scrollBarLayer.id == "") return null;
			return _scrollBarLayer.id;
		}
		
		
		
		override public function set x(value:Number):void
		{
			if(_scrollBarLayer == null) super.x = value;
		}
		
		override public function set y(value:Number):void
		{
			if(_scrollBarLayer == null) super.y = value;
		}
		
		
		
		override public function get bounds():Rectangle
		{
			var bounds:Rectangle = super.bounds;
			if(_scrollBarLayer != null)
			{
				var rect:Rectangle = _scrollBarLayer.viewableArea;
				if(bounds.width > rect.width)
					bounds.width = rect.width - (bounds.x - rect.x);
				
				if(bounds.height > rect.height)
					bounds.height = rect.height - (bounds.y - rect.y);
			}
			return bounds;
		}
		
		
		
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(scrollBarID == null) return props;
			
			if(props == null) props = {};
			props.scrollBar = scrollBarID;
			return props;
		}
		//
	}
}