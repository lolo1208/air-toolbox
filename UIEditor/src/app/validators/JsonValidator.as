package app.validators
{
	import mx.utils.StringUtil;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	
	/**
	 * 验证是否为JSON数据
	 * @author LOLO
	 */
	public class JsonValidator extends Validator
	{
		
		
		public function JsonValidator()
		{
			super();
		}
		
		
		override protected function doValidation(value:Object):Array
		{
			var str:String = StringUtil.trim(value as String);
			if(str.length == 0) return super.doValidation(value);
			
			try {
				JSON.parse(str);
			}
			catch (error:Error) {
				return [new ValidationResult(true, null, "", "不是有效的JSON数据")];
			}
			
			return super.doValidation(value);
		}
		//
	}
}