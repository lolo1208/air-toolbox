package app.layers
{
	import app.common.LayerConstants;
	
	import flash.events.MouseEvent;
	
	import lolo.components.Button;
	import lolo.utils.ObjectUtil;

	/**
	 * Button 层
	 * @author LOLO
	 */
	public class ButtonLayer extends BaseButtonLayer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "button1";
		
		
		
		public function ButtonLayer()
		{
			super();
			this.type = LayerConstants.BUTTON;
			button.label = type.charAt().toUpperCase() + type.substr(1);
		}
		
		
		override protected function createElement():void
		{
			this.element = new Button();
			this.element.addEventListener(MouseEvent.CLICK, stopImmediatePropagation, false, 1);
			styleName = STYLE_NAME;
		}
		
		
		override public function initStyle(setter:Boolean=true):void
		{
			super.initStyle(setter);
			setStyleBySN(STYLE_NAME, setter);
		}
		
		
		
		
		protected function get button():Button { return _element as Button; }
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			/*
			//按钮不能去除默认样式名称，正式项目中需要依此初始化
			if(props.styleName == STYLE_NAME) {
				delete props.styleName;
			}
			*/
			
			if(button.labelID != "") {
				props.labelID = button.labelID;
			}
			else if(button.label != "") {
				props.label = button.label;
			}
			
			return props;
		}
		
		
		
		
		override public function get changedStyle():Object
		{
			super.changedStyle;
			
			checkStyle("autoSize");
			checkStyle("minWidth");
			checkStyle("maxWidth");
			checkStyle("minHeight");
			checkStyle("maxHeight");
			
			checkStyle("labelPaddingTop");
			checkStyle("labelPaddingBottom");
			checkStyle("labelPaddingLeft");
			checkStyle("labelPaddingRight");
			checkStyle("labelHorizontalAlign");
			checkStyle("labelVerticalAlign");
			
			
			//文本的样式
			var defaultStyle:Object = _exportStyle.labelStyle;//文本默认样式
			var labelStyle:Object = ObjectUtil.baseClone(style.labelStyle);//克隆一份，以免 for...in 乱序
			var labelStyleHasChanged:Boolean = false;//文本样式是否有改变
			for(var sn1:String in labelStyle)
			{
				//默认样式里没有这个属性
				if(defaultStyle[sn1] == null) {
					labelStyleHasChanged = true;
					continue;
				}
				
				var value1:* = labelStyle[sn1];
				//指定状态的样式
				if(typeof(value1) == "object")
				{
					var deleteStateStyle:Boolean = true;//是否删除指定状态的文本样式
					for(var sn2:String in value1)
					{
						var value2:* = value1[sn2];
						if(value2 == defaultStyle[sn1][sn2]) {
							delete labelStyle[sn1][sn2];
						}
						else {
							deleteStateStyle = false;
							labelStyleHasChanged = true;
						}
					}
					if(deleteStateStyle) delete labelStyle[sn1];
				}
					
				//所有状态的样式
				else
				{
					if(value1 == defaultStyle[sn1]) {
						delete labelStyle[sn1];
					}
					else {
						labelStyleHasChanged = true;
					}
				}
			}
			
			if(labelStyleHasChanged) {
				_exportStyle.labelStyle = labelStyle;
			}
			else {
				delete _exportStyle.labelStyle;
			}
			
			return _exportStyle;
		}
		//
	}
}