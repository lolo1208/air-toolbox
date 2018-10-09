package app.layers
{
	import app.common.AppCommon;
	import app.common.ImageAssets;
	import app.common.LayerConstants;
	
	import flash.display.DisplayObject;
	
	import lolo.components.ImageLoader;

	/**
	 * ImageLoader 层
	 * @author LOLO
	 */
	public class ImageLoaderLayer extends Layer
	{
		/**是否是正常显示，还是在编辑器中替代显示*/
		public var isDisplay:Boolean = true;
		
		/**在ImageLoader没有参数显示图像时，替代显示的ICON*/
		private var _icon:DisplayObject;
		
		
		
		public function ImageLoaderLayer()
		{
			super();
			this.type = LayerConstants.IMAGE_LOADER;
		}
		
		
		override protected function createElement():void
		{
			this.element = new ImageLoader();
			change();
		}
		
		
		public function change(key:String=null, value:String=null):void
		{
			imageLoader.callback = loaded;
			if(key != null && value != null) imageLoader[key] = value;
			if(key == "extension") imageLoader.loadFile();
			loaded(true);
		}
		
		
		private function loaded(success:Boolean):void
		{
			if(!success
				|| imageLoader.directory == "" || imageLoader.directory == null
				||	imageLoader.fileName == "" || imageLoader.fileName == null)
			{
				if(_icon == null) _icon = new ImageAssets.C_ImageLoader();
				imageLoader.addChild(_icon);
			}
			else
			{
				if(_icon != null && _icon.parent != null) _icon.parent.removeChild(_icon);
			}
			
			AppCommon.prop.updateBounds();
		}
		
		
		
		
		
		private function get imageLoader():ImageLoader { return _element as ImageLoader; }
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(imageLoader.directory != null && imageLoader.directory != "") {
				props.directory = imageLoader.directory;
			}
			
			if(imageLoader.fileName != null && imageLoader.fileName != "" && isDisplay) {
				props.fileName = imageLoader.fileName;
			}
			
			if(imageLoader.extension != "png") {
				props.extension = imageLoader.extension;
			}
			
			return props;
		}
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(isDisplay) return props;
			if(imageLoader.fileName == null || imageLoader.fileName == "") return props;
			
			if(props == null) props = {};
			props.fileName = imageLoader.fileName;
			return props;
		}
		//
	}
}