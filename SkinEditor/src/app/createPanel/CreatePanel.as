package app.createPanel
{
	import app.common.AppCommon;
	
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.validators.Validator;
	
	import spark.components.Panel;
	import spark.components.TextInput;

	/**
	 * 创建皮肤面板
	 * @author LOLO
	 */
	public class CreatePanel extends Panel
	{
		public var nameText:TextInput;
		public var upText:TextInput;
		public var overText:TextInput;
		public var downText:TextInput;
		public var disabledText:TextInput;
		public var selectedUpText:TextInput;
		public var selectedOverText:TextInput;
		public var selectedDownText:TextInput;
		public var selectedDisabledText:TextInput;
		
		private var _naemValidator:Validator;
		private var _upValidator:Validator;
		
		
		
		public function CreatePanel()
		{
			
		}
		
		
		protected function creationCompleteHandler(event:FlexEvent):void
		{
			_naemValidator = new Validator();
			_naemValidator.requiredFieldError = "请输入皮肤名称！";
			_naemValidator.source = nameText;
			_naemValidator.property = "text";
			
			_upValidator = new Validator();
			_upValidator.requiredFieldError = "请输入 up状态 的 sourceName！";
			_upValidator.source = upText;
			_upValidator.property = "text";
			
			
			nameText.promptDisplay["setStyle"]("color", 0x666666);
			upText.promptDisplay["setStyle"]("color", 0x666666);
			overText.promptDisplay["setStyle"]("color", 0x999999);
			downText.promptDisplay["setStyle"]("color", 0x999999);
			disabledText.promptDisplay["setStyle"]("color", 0x999999);
			selectedUpText.promptDisplay["setStyle"]("color", 0x999999);
			selectedOverText.promptDisplay["setStyle"]("color", 0x999999);
			selectedDownText.promptDisplay["setStyle"]("color", 0x999999);
			selectedDisabledText.promptDisplay["setStyle"]("color", 0x999999);
		}
		
		
		
		protected function createBtn_clickHandler(event:MouseEvent):void
		{
			var s1:String = _naemValidator.validate().type;
			var s2:String = _upValidator.validate().type;
			if(s1 == "invalid" || s2 == "invalid") return;
			
			var states:Array = [
				upText.text, overText.text, downText.text, disabledText.text,
				selectedUpText.text, selectedOverText.text, selectedDownText.text, selectedDisabledText.text
			];
			AppCommon.app.skinListGroup.addSkin(nameText.text, states);
			
			nameText.text = "";
			upText.text = overText.text = downText.text = disabledText.text = "";
			selectedUpText.text = selectedOverText.text = selectedDownText.text = selectedDisabledText.text = "";
			closeBtn_clickHandler();
		}
		
		
		
		protected function closeBtn_clickHandler(event:MouseEvent=null):void
		{
			PopUpManager.removePopUp(this);
		}
		//
	}
}