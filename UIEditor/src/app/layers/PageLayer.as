package app.layers
{
	import app.common.LayerConstants;
	
	import lolo.components.Page;
	
	
	public class PageLayer extends Layer
	{
		/**图层类型*/
		private static const LAYER_TYPE:String = "Page";
		
		/**首页按钮的属性*/
		private var _firstBtnProp:String;
		/**尾页按钮的属性*/
		private var _lastBtnProp:String;
		/**上一页按钮的属性*/
		private var _prevBtnProp:String;
		/**下一页按钮的属性*/
		private var _nextBtnProp:String;
		/**页码显示文本的属性*/
		private var _pageTextProp:String;
		
		
		
		
		public function PageLayer()
		{
			super();
			this.type = LayerConstants.PAGE;
		}
		
		
		override protected function createElement():void
		{
			this.element = new Page();
		}
		
		
		override public function init():void
		{
			firstBtnProp = '{"width":40, "height":20, "styleName":"button1", "label":"first"}';
			prevBtnProp = '{"x":45, "width":40, "height":20, "styleName":"button1", "label":"prev"}';
			pageTextProp = '{"x":90, "y":3, "width":40, "height":16, "align":"center", "autoSize":"none"}';
			nextBtnProp = '{"x":135, "width":40, "height":20, "styleName":"button1", "label":"next"}';
			lastBtnProp = '{"x":180, "width":40, "height":20, "styleName":"button1", "label":"last"}';
			page.initialize(1, Math.random() * 99 + 1);
		}
		
		
		override public function initProps(jsonStr:String):Object
		{
			if(jsonStr.length == 0) return null;
			
			var propObj:Object = super.initProps(jsonStr);
			if(propObj.firstBtnProp != null) _firstBtnProp = JSON.stringify(propObj.firstBtnProp);
			if(propObj.lastBtnProp != null) _lastBtnProp = JSON.stringify(propObj.lastBtnProp);
			if(propObj.prevBtnProp != null) _prevBtnProp = JSON.stringify(propObj.prevBtnProp);
			if(propObj.nextBtnProp != null) _nextBtnProp = JSON.stringify(propObj.nextBtnProp);
			if(propObj.pageTextProp != null) _pageTextProp = JSON.stringify(propObj.pageTextProp);
			page.initialize(1, Math.random() * 99 + 1);
			
			return propObj;
		}
		
		
		
		public function set firstBtnProp(value:String):void
		{
			try {
				_firstBtnProp = value;
				page.firstBtn.visible = true;
				page.firstBtnProp = JSON.parse(value);
			}
			catch(error:Error) {
				page.firstBtn.visible = false;
			}
		}
		public function get firstBtnProp():String { return _firstBtnProp; }
		
		
		public function set lastBtnProp(value:String):void
		{
			try {
				_lastBtnProp = value;
				page.lastBtn.visible = true;
				page.lastBtnProp = JSON.parse(value);
			}
			catch(error:Error) {
				page.lastBtn.visible = false;
			}
		}
		public function get lastBtnProp():String { return _lastBtnProp; }
		
		
		public function set prevBtnProp(value:String):void
		{
			try {
				_prevBtnProp = value;
				page.prevBtn.visible = true;
				page.prevBtnProp = JSON.parse(value);
			}
			catch(error:Error) {
				page.prevBtn.visible = false;
			}
		}
		public function get prevBtnProp():String { return _prevBtnProp; }
		
		
		public function set nextBtnProp(value:String):void
		{
			try {
				_nextBtnProp = value;
				page.nextBtn.visible = true;
				page.nextBtnProp = JSON.parse(value);
			}
			catch(error:Error) {
				page.nextBtn.visible = false;
			}
		}
		public function get nextBtnProp():String { return _nextBtnProp; }
		
		
		public function set pageTextProp(value:String):void
		{
			try {
				_pageTextProp = value;
				page.pageText.visible = true;
				page.pageTextProp = JSON.parse(value);
			}
			catch(error:Error) {
				page.pageText.visible = false;
			}
		}
		public function get pageTextProp():String { return _pageTextProp; }
		
		
		public function set enabled(value:Boolean):void { page.enabled = value; }
		public function get enabled():Boolean { return page.enabled; }
		
		
		
		
		
		private function get page():Page { return _element as Page; }
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			
			var obj:Object;
			try {
				obj = JSON.parse(_firstBtnProp);
				props.firstBtnProp = obj;
			}
			catch(error:Error) {}
			
			try {
				obj = JSON.parse(_lastBtnProp);
				props.lastBtnProp = obj;
			}
			catch(error:Error) {}
			
			try {
				obj = JSON.parse(_prevBtnProp);
				props.prevBtnProp = obj;
			}
			catch(error:Error) {}
			
			try {
				obj = JSON.parse(_nextBtnProp);
				props.nextBtnProp = obj;
			}
			catch(error:Error) {}
			
			try {
				obj = JSON.parse(_pageTextProp);
				props.pageTextProp = obj;
			}
			catch(error:Error) {}
			
			
			if(!page.enabled) props.enabled = false;
			
			
			return props;
		}
		//
	}
}