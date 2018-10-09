package app.groups.skinGroup
{
	import app.common.AppCommon;
	
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lolo.display.BitmapSprite;
	
	import mx.core.UIComponent;
	
	import spark.components.Panel;
	
	/**
	 * 皮肤预览浮动面板
	 * @author LOLO
	 */
	public class SkinPreviewPanel extends Panel
	{
		private var _container:Sprite;
		
		
		
		public function SkinPreviewPanel()
		{
			super();
			this.mouseChildren = this.mouseEnabled = this.mouseFocusEnabled = false;
			this.alpha = 0;
			this.visible = false;
			
			var uic:UIComponent = new UIComponent();
			uic.x = uic.y = 10;
			this.addElement(uic);
			
			_container = new Sprite();
			uic.addChild(_container);
		}
		
		
		
		public function show(name:String, skins:Array):void
		{
			TweenMax.killTweensOf(this);
			TweenMax.killDelayedCallsTo(tweenHide);
			this.alpha = 1;
			this.visible = true;
			this.title = name;
			
			_container.removeChildren();
			for(var i:int = 0; i < skins.length; i++)
			{
				var skin:Sprite = new Sprite();
				
				var bs:BitmapSprite = new BitmapSprite(skins[i].sourceName);
				skin.addChild(bs);
				
				var label:TextField = new TextField();
				label.defaultTextFormat = new TextFormat("微软雅黑", 12, 0x333333);
				label.autoSize = "left";
				label.text = skins[i].state;
				label.x = bs.width + 5;
				label.y = bs.height - label.height >> 1;
				skin.addChild(label);
				
				skin.y = _container.height;
				if(i != 0) skin.y += 5;
				_container.addChild(skin);
			}
			
			this.width = _container.width + 20;
			this.height = _container.height + 55;
			
			this.y = AppCommon.skin.height - this.height >> 1;
			this.y += AppCommon.app.lb.y;
			this.y += 50;
			if(y + height > stage.stageHeight) y = stage.stageHeight - height - 10;
		}
		
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(this);
			TweenMax.killDelayedCallsTo(tweenHide);
			TweenMax.delayedCall(0.05, tweenHide);
		}
		
		private function tweenHide():void
		{
			TweenMax.to(this, 0.3, { autoAlpha:0 });
		}
		
		//
	}
}