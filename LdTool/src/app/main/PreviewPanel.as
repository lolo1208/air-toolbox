package app.main
{
	import app.common.AppCommon;
	import app.common.ImageAssets;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import lolo.display.Animation;
	import lolo.display.BitmapSprite;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.Panel;
	
	import toolbox.Toolbox;
	import toolbox.controls.GridBackground;
	
	
	/**
	 * 预览面板
	 * @author LOLO
	 */
	public class PreviewPanel extends Panel
	{
		public var typeIcon:Image;
		public var snText:Label;
		public var fpsText:Label;
		public var fpsLb:Label;
		
		private var _gridBG:GridBackground;
		private var _uic:UIComponent;
		private var _bs:BitmapSprite;
		private var _ani:Animation;
		
		private var _item:Object;
		
		
		
		public function PreviewPanel()
		{
			super();
			
			_bs = new BitmapSprite();
			_ani = new Animation();
		}
		
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_gridBG = new GridBackground();
			_gridBG.x = 10;
			_gridBG.y = 40;
			_gridBG.width = 677;
			_gridBG.height = 416;
			this.addElement(_gridBG);
			
			_uic = new UIComponent();
			this.addElement(_uic);
			
			var centerPoint:Shape = new Shape();
			centerPoint.graphics.lineStyle(3, 0xFFFFFF);
			centerPoint.graphics.moveTo(2, 4);
			centerPoint.graphics.lineTo(7, 4);
			centerPoint.graphics.moveTo(4, 2);
			centerPoint.graphics.lineTo(4, 7);
			centerPoint.graphics.lineStyle(1, 0x0);
			centerPoint.graphics.moveTo(4, 0);
			centerPoint.graphics.lineTo(4, 9);
			centerPoint.graphics.moveTo(0, 4);
			centerPoint.graphics.lineTo(9, 4);
			centerPoint.x = centerPoint.y = -4;
			_uic.addChild(centerPoint);
		}
		
		
		
		public function show(item:Object):void
		{
			if(!this.parent) {
				this.x = Toolbox.app.stage.stageWidth - width >> 1;
				this.y = Toolbox.app.stage.stageHeight - height >> 1;
				PopUpManager.addPopUp(this, Toolbox.app, true);
				Toolbox.app.stage.addEventListener(MouseEvent.MOUSE_DOWN, hide);
				Toolbox.app.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, hide);
				
				typeIcon.source = AppCommon.isUI ? ImageAssets.UI : ImageAssets.Animation;
			}
			_item = item;
			
			snText.text = item.name;
			
			if(AppCommon.isUI)
			{
				fpsText.visible = fpsLb.visible = false;
				
				BitmapSprite.config[item.name] = item.info;
				BitmapSprite.cache.add(item.name, (item.info.scale9Grid != null ? item.s9bd : item.bd));
				_bs.sourceName = item.name;
				_uic.addChildAt(_bs, 0);
			}
			else
			{
				fpsText.visible = fpsLb.visible = true;
				fpsText.text = item.info.fps;
				
				Animation.config[item.name] = item.info;
				Animation.cache.add(item.name, item.frameList);
				_ani.sourceName = item.name;
				_ani.fps = item.info.fps;
				_ani.play();
				_uic.addChildAt(_ani, 0);
			}
			
			var element:DisplayObject = AppCommon.isUI ? _bs : _ani;
			var rect:Rectangle = element.getBounds(element);
			_uic.x = int(_gridBG.x + (_gridBG.width - rect.width) / 2 - rect.x);
			_uic.y = int(_gridBG.y + (_gridBG.height - rect.height) / 2 - rect.y);
		}
		
		
		
		protected function hide(event:MouseEvent=null):void
		{
			if(this.parent) PopUpManager.removePopUp(this);
			Toolbox.app.stage.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			Toolbox.app.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, hide);
			
			while(_uic.numChildren > 1)
				_uic.removeChildAt(0);
			
			if(AppCommon.isUI) {
				BitmapSprite.cache.remove(_item.name);
			}
			else {
				_ani.stop();
				Animation.cache.remove(_item.name);
			}
		}
		
		//
	}
}