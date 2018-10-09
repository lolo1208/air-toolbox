package app.layers
{
	import app.common.AppCommon;
	import app.common.ImageAssets;
	import app.common.LayerConstants;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	import lolo.components.ArtText;
	import lolo.core.Constants;

	/**
	 * ArtText 图层
	 * @author LOLO
	 */
	public class ArtTextLayer extends Layer
	{
		private var _icon:DisplayObject;
		
		
		public function ArtTextLayer()
		{
			super();
			this.type = LayerConstants.ART_TEXT;
			show("public.artText.num1");
		}
		
		
		override protected function createElement():void
		{
			_icon = ImageAssets.getInstance("C_ArtText");
			this.element = new ArtText();
		}
		
		
		override public function initProps(jsonStr:String):Object
		{
			var props:Object = super.initProps(jsonStr);
			show((props.prefix == null ? "" : props.prefix));
			return props;
		}
		
		
		
		public function show(prefix:String=null, text:String=null):void
		{
			if(prefix != null) artText.prefix = prefix;
			if(text != null) artText.text = text;
			artText.updateNow();
			
			//显示出了内容
			if(artText.width > 0) {
				if(_icon.parent != null) this.removeChild(_icon);
			}
			else {
				if(_icon.parent == null) this.addChild(_icon);
			}
			
			AppCommon.controller.updateFrame();
		}
		
		
		
		override public function set x(value:Number):void
		{
			super.x = _icon.x = value;
			artText.updateNow();
		}
		
		override public function set y(value:Number):void
		{
			super.y = _icon.y = value;
			artText.updateNow();
		}
		
		
		override public function get bounds():Rectangle
		{
			if(_icon.parent != null) return _icon.getBounds(this);
			return _element.getBounds(this);
		}
		
		
		
		
		private function get artText():ArtText { return _element as ArtText; }
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(artText.prefix != null && artText.prefix != "") props.prefix = artText.prefix;
			if(artText.text != null && artText.text != "") props.text = artText.text;
			if(artText.align != Constants.ALIGN_LEFT) props.align = artText.align;
			if(artText.valign != Constants.VALIGN_TOP) props.valign = artText.valign;
			if(artText.spacing != 0) props.spacing = artText.spacing;
			
			return props;
		}
		//
	}
}