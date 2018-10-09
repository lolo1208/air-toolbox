package app.layers
{
	import app.common.LayerConstants;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	
	/**
	 * Container 图层
	 * @author LOLO
	 */
	public class ContainerLayer extends Layer
	{
		/**容器的XML父级的路径*/
		public var parentXML:String = "";
		/**容器的图层深度*/
		public var depth:String = "";
		/**是否是一个继承至Container的容器*/
		public var extContainer:Boolean;
		/**容器类型*/
		public var cType:String = "normal";
		
		
		
		public function ContainerLayer(name:String, extContainer:Boolean)
		{
			super();
			this.type = LayerConstants.CONTAINER;
			
			this.id = name;
			this.extContainer = extContainer;
		}
		
		
		override protected function createElement():void
		{
			this.element = new MovieClip();
		}
		
		
		
		override public function set otherProps(value:String):void
		{
			itemWidth = itemHeight = 0;
			super.otherProps = value;
		}
		
		
		
		
		/**
		 * 在当前容器中获取指定ID的图层
		 * @param id
		 * @return 
		 */
		public function getLayerByID(id:String):Layer
		{
			if(id == "") return null;
			
			var c:Sprite = _element as Sprite;
			for(var i:int = 0; i < c.numChildren; i++) {
				var layer:Layer = c.getChildAt(i) as Layer;
				if(layer.id == id) return layer;
			}
			
			return null;
		}
		
		
		
		
		/**
		 * Item的宽度
		 */
		public function set itemWidth(value:uint):void { _element["itemWidth"] = value; }
		public function get itemWidth():uint
		{
			return int(_element["itemWidth"]) > 0 ? _element["itemWidth"] : this.width;
		}
		
		/**
		 * Item的高度
		 */
		public function set itemHeight(value:uint):void { _element["itemHeight"] = value; }
		public function get itemHeight():uint
		{
			return int(_element["itemHeight"]) > 0 ? _element["itemHeight"] : this.height;
		}
		
		
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(parentXML == "" && depth == "") return props;
			
			if(props == null) props = {};
			if(parentXML != "") props.parentXML = parentXML;
			if(depth != "") props.depth = depth;
			return props;
		}
		//
	}
}