package app.layers
{
	import app.common.AppCommon;
	import app.common.ImageAssets;
	import app.common.LayerConstants;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	
	import lolo.components.AlertText;
	
	
	/**
	 * DisplayObject 层
	 * @author LOLO
	 */
	public class DisplayObjectLayer extends Layer
	{
		/**对应的SWF*/
		public var swf:String = "";
		/**SWF的加载域*/
		public var domain:ApplicationDomain;
		
		/**类的完整定义名称*/
		private var _definition:String;
		
		
		
		public function DisplayObjectLayer(definition:String="")
		{
			super();
			this.definition = definition;
			this.type = LayerConstants.DISPLAY_OBJECT;
		}
		
		
		override protected function createElement():void
		{
			
		}
		
		
		
		
		/**
		 * 类的完整定义名称
		 */
		public function set definition(value:String):void
		{
			_definition = value;
			
			var element:DisplayObject;
			try {
				var tempClass:Class = domain.getDefinition(_definition) as Class;
				element = new tempClass();
			}
			catch(error:Error) {
				if(domain != null && _definition != "")
					AlertText.show("definition: " + _definition + " 不存在", "failed").moveToStageMousePosition();
			}
			
			if(element == null) {
				element = new Sprite();
				(element as Sprite).addChild(new ImageAssets.C_DisplayObject());
			}
			if(_element == null) {
				this.element = element;
				return;
			}
			
			//更新属性
			if(x != 0) element.x = x;
			if(y != 0) element.y = y;
			if(alpha != 1) element.alpha = alpha;
			if(rotation != 0) element.rotation = rotation;
			
			if(_width != 0){
				element.width = _width;
			}
			else if(scaleX != 1) {
				element.scaleX = scaleX;
			}
			
			if(_height != 0){
				element.height = _height;
			}
			else if(scaleY != 1) {
				element.scaleY = scaleY;
			}
			
			//替换element
			this.element = element;
			
			//更新otherProps
			otherProps = _otherProps;
			
			AppCommon.controller.updateFrame();
			AppCommon.prop.update();
		}
		
		public function get definition():String { return _definition; }
		
		
		
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(swf == null || swf == "") return props;
			
			if(props == null) props = {};
			props.swf = swf;
			return props;
		}
		//
	}
}