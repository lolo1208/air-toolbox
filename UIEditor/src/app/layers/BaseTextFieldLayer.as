package app.layers
{
	import app.common.LayerConstants;
	import app.utils.LayerUtil;
	
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	import lolo.core.Common;
	import lolo.display.BaseTextField;
	
	import toolbox.Toolbox;

	/**
	 * BaseTextField 层
	 * @author LOLO
	 */
	public class BaseTextFieldLayer extends Layer
	{
		/**默认样式名称*/
		private static const STYLE_NAME:String = "textField";
		
		/**替代文本*/
		protected var _tipsText:String = "";
		/**设定的文本内容*/
		protected var _text:String = "";
		
		
		
		public function BaseTextFieldLayer()
		{
			super();
			this.type = LayerConstants.BASE_TEXT_FIELD;
		}
		
		override protected function createElement():void
		{
			
		}
		
		
		
		override public function initProps(jsonStr:String):Object
		{
			if(jsonStr.length == 0) return null;
			
			var props:Object = super.initProps(jsonStr);
			if(props.text != null) _tipsText = _text = props.text;
			
			return props;
		}
		
		
		override public function initStyle(setter:Boolean=true):void
		{
			super.initStyle(setter);
			setStyleBySN(STYLE_NAME, setter);
		}
		
		
		
		/**
		 * 替代文本
		 */
		public function set tipsText(value:String):void
		{
			_tipsText = value;
			textField.text = _tipsText;
		}
		public function get tipsText():String { return _tipsText; }
		
		
		
		public function set text(value:String):void
		{
			_text = value;
			textField.text = value;
		}
		public function get text():String { return _text; }
		
		
		
		protected function get textField():BaseTextField { return _element as BaseTextField; }
		
		
		
		
		override public function get bounds():Rectangle
		{
			if(_width != 0 || _height != 0) {
				return new Rectangle(_element.x, _element.y, _width, _height);
			}
			return super.bounds;
		}
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(props.styleName == STYLE_NAME) {
				delete props.styleName;
			}
			
			
			if(Toolbox.isASProject)
			{
				if(textField.autoSize != TextFieldAutoSize.LEFT) {
					props.autoSize = textField.autoSize;
				}
			}
			
			if(Toolbox.isASProject || LayerUtil.isInputText(this))
			{
				if(textField.multiline) {
					props.multiline = true;
				}
			}
			
			if(_text != "") {
				props.text = _text;
			}
			
			if(textField.textID != "") {
				props.textID = textField.textID;
			}
			
			if(textField.embedFonts) {
				props.embedFonts = textField.embedFonts;
			}
			
			return props;
		}
		
		
		
		override public function get editorProps():Object
		{
			var props:Object = super.editorProps;
			
			if(_tipsText == "") return props;
			if(_tipsText == _text) return props;
			if(_tipsText == Common.language.getLanguage(textField.textID)) return props;
			
			if(props == null) props = {};
			props.tipsText = _tipsText;
			return props;
		}
		
		
		
		override public function get changedStyle():Object
		{
			super.changedStyle;
			
			checkStyle("align");
			checkStyle("bold");
			checkStyle("color");
			checkStyle("font");
			checkStyle("size");
			checkStyle("underline");
			checkStyle("leading");
			checkStyle("stroke");
			
			return _exportStyle;
		}
		//
	}
}