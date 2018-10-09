package app.layers
{
	import app.common.AppCommon;
	import app.common.LayerConstants;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import lolo.utils.optimize.PrerenderScheduler;
	
	
	/**
	 * List 层
	 * @author LOLO
	 */
	public class ListLayer extends Layer
	{
		/**子项的渲染 XML Layer*/
		protected var _itemLayer:ContainerLayer;
		
		/**水平方向子项间的像素间隔*/
		protected var _horizontalGap:int = 0;
		/**垂直方向子项间的像素间隔*/
		protected var _verticalGap:int = 0;
		/**列数（默认值：3）*/
		protected var _columnCount:uint = 3;
		/**行数（默认值：3）*/
		protected var _rowCount:uint = 3;
		
		
		
		public function ListLayer()
		{
			super();
			this.type = LayerConstants.LIST;
		}
		
		
		override protected function createElement():void
		{
			this.element = new MovieClip();
		}
		
		
		override public function initProps(jsonStr:String):Object
		{
			if(jsonStr.length == 0) return null;
			
			var propObj:Object = super.initProps(jsonStr);
			if(propObj.horizontalGap != null) _horizontalGap = propObj.horizontalGap;
			if(propObj.verticalGap != null) _verticalGap = propObj.verticalGap;
			if(propObj.columnCount != null) _columnCount = propObj.columnCount;
			if(propObj.rowCount != null) _rowCount = propObj.rowCount;
			
			return propObj;
		}
		
		
		
		
		override public function update():void
		{
			PrerenderScheduler.addCallback(prerender);
		}
		
		
		/**
		 * 即将进入渲染时的回调
		 */
		protected function prerender():void
		{
			PrerenderScheduler.removeCallback(prerender);
			
			var c:Sprite = this.element as Sprite;
			c.removeChildren();
			
			if(_itemLayer == null) {
				AppCommon.controller.updateFrame();
				return;
			}
			
			var rect:Rectangle = _itemLayer.element.getBounds(_itemLayer.element);
			if(rect.width == 0) rect.width = 1;
			if(rect.height == 0) rect.height = 1;
			var bitmapData:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
			bitmapData.draw(_itemLayer.element, new Matrix(1, 0, 0, 1, -rect.x, -rect.y));
			
			//数量太多，无法渲染
			var or:uint = _rowCount;
			var oc:uint = _columnCount;
			if(_rowCount > 50) _rowCount = 50;
			if(_columnCount > 50) _columnCount = 50;
			
			//根据数据显示（创建）子项
			var length:uint = _rowCount * _columnCount;
			for(var i:int = 0; i < length; i++)
			{
				var item:Bitmap = new Bitmap(bitmapData);
				item.x = i % _columnCount * (_itemLayer.itemWidth + _horizontalGap) + rect.x;
				item.y = Math.floor(i / _columnCount) * (_itemLayer.itemHeight + _verticalGap) + rect.y;
				c.addChild(item);
			}
			
			_rowCount = or;
			_columnCount = oc;
			
			AppCommon.controller.updateFrame();
		}
		
		
		
		
		public function set itemLayer(value:ContainerLayer):void
		{
			_itemLayer = value;
			update();
		}
		public function get itemLayer():ContainerLayer { return _itemLayer; }
		
		
		public function get itemID():String
		{
			if(_itemLayer == null) return null;
			if(_itemLayer.id == "") return null;
			return _itemLayer.id;
		}
		
		
		public function set horizontalGap(value:int):void
		{
			_horizontalGap = value;
			update();
		}
		public function get horizontalGap():int { return _horizontalGap; }
		
		
		public function set verticalGap(value:int):void
		{
			_verticalGap = value;
			update();
		}
		public function get verticalGap():int { return _verticalGap; }
		
		
		public function set rowCount(value:uint):void
		{
			_rowCount = value;
			update();
		}
		public function get rowCount():uint { return _rowCount; }
		
		
		public function set columnCount(value:uint):void
		{
			_columnCount = value;
			update();
		}
		public function get columnCount():uint { return _columnCount; }
		
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(_horizontalGap != 0) props.horizontalGap = _horizontalGap;
			if(_verticalGap != 0) props.verticalGap = _verticalGap;
			
			if(_columnCount != 3) props.columnCount = _columnCount;
			if(_rowCount != 3) props.rowCount = _rowCount;
			
			return props;
		}
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(itemID == null) return props;
			
			if(props == null) props = {};
			props.item = itemID;
			return props;
		}
		//
	}
}