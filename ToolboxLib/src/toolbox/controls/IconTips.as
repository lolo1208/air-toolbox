package toolbox.controls
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	
	import lolo.core.Common;
	
	import mx.core.UIComponent;

	public class IconTips extends UIComponent
	{
		private var _icon:DisplayObject;
		
		
		
		public function IconTips(icon:DisplayObject)
		{
			this.visible = false;
			this.mouseEnabled = this.mouseChildren = false;
			
			_icon = icon;
			this.addChild(_icon);
		}
		
		
		
		public function show():void
		{
			x = int(Common.stage.stageWidth - _icon.width >> 1);
			y = int(Common.stage.stageHeight - _icon.height >> 1);
			
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