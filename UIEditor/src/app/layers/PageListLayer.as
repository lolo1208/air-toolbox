package app.layers
{
	import app.common.LayerConstants;
	
	import flash.display.MovieClip;
	
	
	/**
	 * PageList 层
	 * @author LOLO
	 */
	public class PageListLayer extends ListLayer
	{
		/**图层类型*/
		private static const LAYER_TYPE:String = "PageList";
		
		/**对应的翻页组件*/
		protected var _pageLayer:PageLayer;
		
		
		
		public function PageListLayer()
		{
			super();
			this.type = LayerConstants.PAGE_LIST;
		}
		
		override protected function createElement():void
		{
			this.element = new MovieClip();
		}
		
		
		
		
		public function set pageLayer(value:PageLayer):void
		{
			_pageLayer = value;
		}
		public function get pageLayer():PageLayer { return _pageLayer; }
		
		
		public function get pageID():String
		{
			if(_pageLayer == null) return null;
			if(_pageLayer.id == "") return null;
			return _pageLayer.id;
		}
		
		
		
		//
	}
}