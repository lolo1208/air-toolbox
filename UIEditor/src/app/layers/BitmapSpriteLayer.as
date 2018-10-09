package app.layers
{
	import app.common.LayerConstants;
	
	import lolo.display.BitmapSprite;

	/**
	 * BitmapSprite 图层
	 * @author LOLO
	 */
	public class BitmapSpriteLayer extends Layer
	{
		
		
		public function BitmapSpriteLayer(sourceName:String="")
		{
			super();
			this.type = LayerConstants.BITMAP_SPRITE;
			
			(_element as BitmapSprite).sourceName = sourceName;
		}
		
		
		override protected function createElement():void
		{
			this.element = new BitmapSprite();
		}
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			props.sourceName = _element["sourceName"];
			
			return props;
		}
		//
	}
}