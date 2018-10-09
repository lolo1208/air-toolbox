package app.propertiesPanel
{
	import app.canvasGroup.Tile;
	
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import lolo.utils.Validator;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.RadioButtonGroup;
	import spark.components.TextInput;
	import spark.components.VGroup;
	import spark.events.TextOperationEvent;
	
	/**
	 * 属性面板
	 * @author LOLO
	 */
	public class PropertiesPanel extends Panel
	{
		public var listVG:VGroup;
		
		public var nameGroup:Group;
		public var nameText:Label;
		
		public var xyGroup:Group;
		public var xText:TextInput;
		public var yText:TextInput;
		
		public var whGroup:Group;
		public var widthText:TextInput;
		public var heightText:TextInput;
		
		public var pointGroup:Group;
		public var pointText:Label;
		
		public var typeGroup:Group;
		public var typeRG:RadioButtonGroup;
		
		public var featureGroup:Group;
		public var featureText:TextInput;
		public var indexText:TextInput;
		
		
		/**当前显示属性的元件*/
		private var _currentElement:Sprite;
		
		
		
		public function PropertiesPanel()
		{
			super();
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			this.setStyle("dropShadowVisible", false);
			listVG.removeAllElements();
		}
		
		
		
		
		/**
		 * 显示元素的属性
		 * @param element
		 */
		public function show(element:Sprite):void
		{
			_currentElement = element;
			listVG.removeAllElements();
			if(element == null) return;
			
			if(element is Tile)
			{
				pointText.text = "  x:" + tile.point.x + ",  y:" + tile.point.y;
				listVG.addElement(pointGroup);
				
				if(!tile.canPass) typeRG.selectedValue = "障碍";
				else if(tile.cover) typeRG.selectedValue = "遮挡";
				else typeRG.selectedValue = "普通";
				listVG.addElement(typeGroup);
				
				featureText.text = tile.feature;
				indexText.text = (tile.feature == null) ? "" : tile.index.toString();
				listVG.addElement(featureGroup);
				
				TweenMax.delayedCall(0.0, tile.draw, [0x00CC00, 1]);
				TweenMax.delayedCall(0.1, tile.draw);
				TweenMax.delayedCall(0.2, tile.draw, [0x00CC00, 1]);
				TweenMax.delayedCall(0.3, tile.draw);
				TweenMax.delayedCall(0.4, tile.draw, [0x00CC00, 1]);
				TweenMax.delayedCall(0.5, tile.draw);
			}
			else
			{
				nameText.text = _currentElement.name;
				listVG.addElement(nameGroup);
				
				xText.text = _currentElement.x.toString();
				yText.text = _currentElement.y.toString();
				listVG.addElement(xyGroup);
				
				widthText.text = _currentElement.width.toString();
				heightText.text = _currentElement.height.toString();
				listVG.addElement(whGroup);
			}
		}
		
		
		public function refrsh(element:Sprite):void
		{
			if(element == _currentElement) show(element);
		}
		
		
		
		
		
		protected function xText_changeHandler(event:TextOperationEvent):void
		{
			_currentElement.x = int(xText.text);
		}
		
		protected function yText_changeHandler(event:TextOperationEvent):void
		{
			_currentElement.y = int(yText.text);
		}
		
		
		protected function widthText_changeHandler(event:TextOperationEvent):void
		{
			_currentElement.width = int(widthText.text);
		}
		
		protected function heightText_changeHandler(event:TextOperationEvent):void
		{
			_currentElement.height = int(heightText.text);
		}
		
		
		
		protected function featureText_changeHandler(event:TextOperationEvent):void
		{
			tile.feature = feature;
		}
		
		
		protected function indexText_changeHandler(event:TextOperationEvent):void
		{
			tile.setIndex(uint(indexText.text));
		}
		
		
		
		
		protected function typeRG_changeHandler(event:Event):void
		{
			tile.canPass = typeRG.selectedValue != "障碍";
			tile.cover = typeRG.selectedValue == "遮挡";
		}
		
		
		
		/**
		 * 输入的特性
		 */
		private function get feature():String
		{
			var value:String = featureText.text;
			if(value == "特性" || value == "") return null;
			if(!Validator.notExactlySpace(value)) return null;
			return value;
		}
		
		
		private function get tile():Tile { return _currentElement as Tile; }
		//
	}
}