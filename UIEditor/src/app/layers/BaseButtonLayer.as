package app.layers
{
	import app.common.AppCommon;
	import app.common.LayerConstants;
	import app.utils.LayerUtil;
	
	import flash.events.MouseEvent;
	
	import lolo.components.BaseButton;
	import lolo.components.ItemGroup;

	/**
	 * BaseButton层
	 * @author LOLO
	 */
	public class BaseButtonLayer extends Layer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "baseButton1";
		
		/**所属组的图层对象*/
		protected var _groupLayer:ItemGroupLayer;
		
		
		
		public function BaseButtonLayer()
		{
			super();
			this.type = LayerConstants.BASE_BUTTON;
		}
		
		
		override protected function createElement():void
		{
			this.element = new BaseButton();
			this.element.addEventListener(MouseEvent.CLICK, stopImmediatePropagation, false, 1);
			styleName = STYLE_NAME;
		}
		
		
		override public function initStyle(setter:Boolean=true):void
		{
			super.initStyle(setter);
			setStyleBySN(STYLE_NAME, setter);
		}
		
		
		
		override public function set x(value:Number):void
		{
			if(value == super.x) return;
			super.x = value;
			if(_groupLayer != null) _groupLayer.update();
		}
		
		override public function set y(value:Number):void
		{
			if(value == super.y) return;
			super.y = value;
			if(_groupLayer != null) _groupLayer.update();
		}
		
		
		
		
		public function set groupLayer(value:ItemGroupLayer):void
		{
			if(_groupLayer != null) _groupLayer.removeFromGroup(this);
			
			_groupLayer = value;
			if(_groupLayer != null) {
				baseButton.selected = false;
				baseButton.group = _groupLayer.element as ItemGroup;
				_groupLayer.addToGroup(this);
			}
			else {
				baseButton.group = null;
			}
			AppCommon.prop.common2G.updateSelected();
		}
		public function get groupLayer():ItemGroupLayer { return _groupLayer; }
		
		
		public function get groupID():String
		{
			if(_groupLayer == null) return null;
			if(_groupLayer.id == "") return null;
			return _groupLayer.id;
		}
		
		
		
		
		override public function set parentLayer(value:SpriteLayer):void
		{
			super.parentLayer = value;
			if(value == _groupLayer && _groupLayer != null) _groupLayer.update(); 
		}
		
		
		
		
		public function set selected(value:Boolean):void { baseButton.selected = value; }
		public function get selected():Boolean { return baseButton.selected; }
		
		public function set enabled(value:Boolean):void { baseButton.enabled= value; }
		public function get enabled():Boolean { return baseButton.enabled; }
		
		
		
		
		/**
		 * element 转换为 BaseButton
		 */
		private function get baseButton():BaseButton { return LayerUtil.getBaseButton(this); }
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			/*
			//按钮不能去除默认样式名称，正式项目中需要依此初始化
			if(props.styleName == STYLE_NAME) {
				delete props.styleName;
			}
			*/
			
			if(baseButton.selected) props.selected = true;
			
			if(!baseButton.enabled) {
				if(_groupLayer == null) props.enabled = false;
				else if(_groupLayer.enabled) props.enabled = false;
			}
			
			return props;
		}
		
		
		
		override public function get changedStyle():Object
		{
			super.changedStyle;
			
			checkStyle("skinName");
			checkStyle("hitAreaPaddingTop");
			checkStyle("hitAreaPaddingBottom");
			checkStyle("hitAreaPaddingLeft");
			checkStyle("hitAreaPaddingRight");
			
			return _exportStyle;
		}
		//
	}
}