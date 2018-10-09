package app.canvasGroup
{
	import app.common.AppCommon;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import lolo.effects.AsEffect;
	import lolo.rpg.RpgUtil;
	import lolo.rpg.map.MapInfo;
	
	/**
	 * 区块
	 * @author LOLO
	 */
	public class Tile extends Sprite
	{
		private static var _featureInfo:Dictionary = new Dictionary();
		
		private var _text:TextField;
		private var _showType:int = 2;
		
		public var point:Point;
		public var tileWidth:uint;
		public var tileHeight:uint;
		public var staggered:Boolean;
		public var mapWidth:uint;
		public var mapHeight:uint;
		
		/**特性索引*/
		public var index:int = -1;
		
		
		/**是否可通行*/
		private var _canPass:Boolean = true;
		/**是否被遮挡*/
		private var _cover:Boolean;
		/**区块的特性*/
		private var _feature:String = null;
		
		
		
		/**
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 */
		public function Tile(x:int, y:int, width:uint, height:uint, staggered:Boolean, mapWidth:uint, mapHeight:uint)
		{
			super();
			this.cacheAsBitmap = true;
			tileWidth = width;
			tileHeight = height;
			point = new Point(x, y);
			this.staggered = staggered;
			this.mapWidth = mapWidth;
			this.mapHeight = mapHeight;
			
			var info:MapInfo = new MapInfo({ tileWidth:width, tileHeight:height, mapWidth:mapWidth, mapHeight:mapHeight, staggered:staggered });
			var p:Point = new Point(x, y);
			p = RpgUtil.getTileCenter(p, info);
			this.x = p.x - width / 2;
			this.y = p.y - height / 2;
			
			if(this.x < 0 || this.x > mapWidth - tileWidth || this.y < 0 || this.y > mapHeight - tileHeight) _canPass = false;
			
			_text = new TextField();
			_text.defaultTextFormat = new TextFormat("宋体", 12, 0xFFFFFF);
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.selectable = _text.mouseEnabled = _text.mouseWheelEnabled = false;
			_text.filters = [AsEffect.getStrokeFilter(0x302010)];
			
			draw();
		}
		

		public function draw(color:uint=0xFFFFFF, alpha:Number=0.01, width:int=0, height:int=0):void
		{
			if(!_canPass) {
				if(alpha != 1) {//特殊效果
					color = 0xFF0000;
					alpha = 0.3;
				}
			}
			else if(_cover) {
				if(alpha != 1) {
					color = 0xFFFFFF;
					alpha = 0.3;
				}
			}
			
			if(width == 0) width = tileWidth;
			if(height == 0) height = tileHeight;
			graphics.clear();
			graphics.beginFill(color, alpha);
			graphics.lineStyle(1, 0x00CC00, 0.3);
			graphics.moveTo(0, height / 2);
			graphics.lineTo(width / 2, 0);
			graphics.lineTo(width, height / 2);
			graphics.lineTo(width / 2, height);
			graphics.lineTo(0 , height / 2);
			graphics.endFill();
			
			if(_feature != null) {
				if(alpha != 1) {
					color = getFeatureInfo(_feature).color;
					alpha = 0.3;
				}
				
				graphics.lineStyle(0, color, 0.3);
				graphics.beginFill(color, alpha);
				graphics.drawCircle(width / 2, height / 2, Math.min(width, height) * 0.3);
			}
		}
		
		
		
		/**
		 * 显示类型
		 * @param value [ 1:坐标, 2:特性, 3:特性索引 ]
		 */
		public function set showType(value:int):void
		{
			_showType = value;
			switch(value)
			{
				case 1:
					_text.text = point.x + "," + point.y;
					break;
				case 2:
					_text.text = (_feature != null) ? _feature : "";
					break;
				case 3:
					_text.text = (_feature != null) ? index.toString() : "";
					break;
			}
			
			if(_text.text == "") {
				if(_text.parent != null) this.removeChild(_text);
			}
			else {
				_text.x = tileWidth - _text.textWidth >> 1;
				_text.y = tileHeight - _text.textHeight >> 1;
				if(_text.parent == null) this.addChild(_text);
			}
		}
		
		public function get showType():int { return _showType; }
		
		
		
		
		/**
		 * 是否可通行
		 */
		public function set canPass(value:Boolean):void
		{
			_canPass = value;
			draw();
		}
		public function get canPass():Boolean { return _canPass; }
		
		
		/**
		 * 是否被遮挡
		 */
		public function set cover(value:Boolean):void
		{
			_cover = value;
			draw();
		}
		public function get cover():Boolean { return _cover; }
		
		
		/**
		 * 特性
		 */
		public function set feature(value:String):void
		{
			removeFeature(this, _feature);
			
			_feature = value;
			index = -1;
			draw();
			
			if(_feature != null) {
				setIndex(getFeatureInfo(_feature).index);
			}
			showType = _showType;
		}
		
		public function get feature():String { return _feature; }
		
		
		public function setIndex(index:int):void
		{
			setFeatureIndex(this, _feature, index);
		}
		
		
		
		
		
		/**
		 * 获取特性信息
		 * @param feature
		 * @return { color:随机生成的颜色, index:最新的索引（数组末尾） }
		 */
		private function getFeatureInfo(feature:String):Object
		{
			if(_featureInfo[feature] == null) {
				var color:String = "0x";
				color += (Math.random() * 2 > 1) ? uint(Math.random() * 100 + 155).toString(16) : "00";
				color += (Math.random() * 2 > 1) ? uint(Math.random() * 100 + 155).toString(16) : "00";
				color += (Math.random() * 2 > 1) ? uint(Math.random() * 100 + 155).toString(16) : "00";
				_featureInfo[feature] = { color:uint(color), list:[] };
			}
			
			return {
				color	: _featureInfo[feature].color,
				index	: _featureInfo[feature].list.length
			};
		}
		
		
		public static function setFeatureIndex(tile:Tile, feature:String, index:uint):void
		{
			if(_featureInfo[feature] == null) return;
			
			var i:int;
			var list:Array = _featureInfo[feature].list;
			for(i = 0; i < list.length; i++) {
				if(list[i] == tile) {
					list.splice(i, 1);
					break;
				}
			}
			list.splice(index, 0, tile);
			
			for(i = 0; i < list.length; i++) {
				if(list[i] == null) {
					list.splice(i, 1);
					i--;
				}
			}
			
			for(i = 0; i < list.length; i++) {
				list[i].index = i;
				list[i].showType = list[i].showType;
				AppCommon.app.propertiesPanel.refrsh(list[i]);
			}
		}
		
		
		public static function removeFeature(tile:Tile, feature:String):void
		{
			if(_featureInfo[feature] == null) return;
			var i:int;
			var list:Array = _featureInfo[feature].list;
			
			for(i = 0; i < list.length; i++) {
				if(list[i] == tile) {
					list.splice(i, 1);
					break;
				}
			}
			
			for(i = 0; i < list.length; i++) {
				list[i].index = i;
				list[i].showType = list[i].showType;
				AppCommon.app.propertiesPanel.refrsh(list[i]);
			}
		}
		
		
		public static function clearFeatureInfo():void
		{
			_featureInfo = new Dictionary();
		}
	//
	}
}