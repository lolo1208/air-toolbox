package app.layers
{
	import app.common.AppCommon;
	import app.common.LayerConstants;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import lolo.core.Constants;

	/**
	 * H5项目中，touch内容进行滚动的滚动条对应的图层
	 * @author LOLO
	 */
	public class TouchScrollBarLayer extends Layer
	{
		private var _viewableAreaShape:Shape;
		private var _viewableArea:Rectangle;
		
		
		
		public function TouchScrollBarLayer()
		{
			super();
			this.type = LayerConstants.TOUCH_SCROLL_BAR;
		}
		
		
		override protected function createElement():void
		{
			this.element = new TouchScrollBar();
			styleName = defaultStyleName;
			
			_viewableAreaShape = new Shape();
			this.addChildAt(_viewableAreaShape, 0);
		}
		
		
		override public function initProps(jsonStr:String):Object
		{
			if(jsonStr.length == 0) return null;
			
			var propObj:Object = super.initProps(jsonStr);
			
			viewableArea = new Rectangle(
				propObj.viewableArea.x,
				propObj.viewableArea.y,
				propObj.viewableArea.width,
				propObj.viewableArea.height
			);
			scrollBar.update();
			
			return propObj;
		}
		
		override public function initStyle(setter:Boolean=true):void
		{
			super.initStyle(setter);
			setStyleBySN(defaultStyleName, setter);
			scrollBar.update();
		}
		
		
		override public function set styleName(value:String):void
		{
			super.styleName = value;
			scrollBar.update();
		}
		
		
		
		/**
		 * 滚动方向
		 */
		public function set direction(value:String):void
		{
			scrollBar.direction = value;
			AppCommon.controller.updateFrame();
		}
		public function get direction():String { return scrollBar.direction; }
		
		
		public function set size(value:uint):void
		{
			scrollBar.size = value;
			AppCommon.controller.updateFrame();
		}
		public function get size():uint { return scrollBar.size; }
		
		
		public function set enabled(value:Boolean):void { scrollBar.enabled = value; }
		public function get enabled():Boolean { return scrollBar.enabled; }
		
		
		public function set viewableArea(value:Rectangle):void
		{
			_viewableArea = value;
			_viewableAreaShape.graphics.clear();
			_viewableAreaShape.graphics.beginFill(0xFF9900, 0.1);
			_viewableAreaShape.graphics.drawRect(value.x, value.y, value.width, value.height);
			_viewableAreaShape.graphics.endFill();
			
			_viewableAreaShape.graphics.lineStyle(1, 0x666666);
			_viewableAreaShape.graphics.moveTo(value.left, value.top);
			_viewableAreaShape.graphics.lineTo(value.right-1, value.top);
			_viewableAreaShape.graphics.lineTo(value.right-1, value.bottom-1);
			_viewableAreaShape.graphics.lineTo(value.left, value.bottom-1);
			_viewableAreaShape.graphics.lineTo(value.left, value.top);
			
			this.dispatchEvent(new Event(ScrollBarLayer.VIEWABLE_AREA_CHANGED));
		}
		
		public function get viewableArea():Rectangle
		{
			if(_viewableArea == null)
				viewableArea = new Rectangle(_element.x - 105, _element.y, 100, 100);
			return _viewableArea;
		}
		
		
		public function set viewableAreaVisible(value:Boolean):void { _viewableAreaShape.visible = value; }
		
		public function get viewableAreaVisible():Boolean { return _viewableAreaShape.visible; }
		
		
		
		/**
		 * 根据方向，获得现在的默认样式名称
		 */
		private function get defaultStyleName():String
		{
			return scrollBar.direction == Constants.VERTICAL ? "vScrollBar1" : "hScrollBar1";
		}
		
		
		
		override public function canDrag(event:MouseEvent=null):Boolean
		{
			if(event == null) return super.canDrag(event);
			
			var list:Array = stage.getObjectsUnderPoint(new Point(event.stageX, event.stageY));
			
			//鼠标点到了viewableAre
			list.reverse();
			if(list[0] == _viewableAreaShape)
			{
				//下面有图层
				var layer:Layer = list[1].parent as Layer;
				if(layer == null) layer = list[1].parent.parent as Layer;
				if(layer != null) {
					AppCommon.controller.selectLayer(layer);
					return layer.canDrag(event);
				}
				return false;
			}
			
			return super.canDrag(event);
		}
		
		
		
		
		public function get scrollBar():TouchScrollBar { return _element as TouchScrollBar; }
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(!scrollBar.enabled) props.enabled = false;
			
			if(scrollBar.size != 100) props.size = scrollBar.size;
			
			if(scrollBar.direction != Constants.VERTICAL) props.direction = scrollBar.direction;
			
			if(scrollBar.scrollPolicy != Constants.POLICY_AUTO) props.scrollPolicy = scrollBar.scrollPolicy;
			
			if(!scrollBar.bounces) props.bounces = false;
			
			props.viewableArea = {
				x:_viewableArea.x,
				y:_viewableArea.y,
				width:_viewableArea.width,
				height:_viewableArea.height
			};
			
			return props;
		}
		
		
		
		override public function get changedStyle():Object
		{
			super.changedStyle;
			
			checkStyle("thumbSourceName");
			checkStyle("thumbMinSize");
			
			return _exportStyle;
		}
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(viewableAreaVisible) return props;
			
			if(props == null) props = {};
			props.viewableAreaVisible = viewableAreaVisible;
			return props;
		}
		
		//
	}
}