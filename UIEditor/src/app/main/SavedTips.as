package app.main
{
	import app.common.ImageAssets;
	
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	
	import mx.core.UIComponent;

	public class SavedTips extends UIComponent
	{
		private var _icon:DisplayObject;
		
		
		
		public function SavedTips()
		{
			this.visible = false;
			this.mouseEnabled = this.mouseChildren = false;
			
			_icon = ImageAssets.getInstance("Saved");
			this.addChild(_icon);
		}
		
		
		
		public function show():void
		{
			TweenMax.killTweensOf(_icon);
			
			_icon.y = 10;
			TweenMax.to(_icon, 0.3, { y:0 });
			TweenMax.to(this, 0.3, { autoAlpha:1 });
			
			TweenMax.to(_icon, 0.3, { y:-10, delay:0.8 });
			TweenMax.to(this, 0.3, { autoAlpha:0, delay:0.8 });
		}
		//
	}
}