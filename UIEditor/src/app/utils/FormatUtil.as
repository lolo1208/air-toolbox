package app.utils
{
	/**
	 * 格式化工具
	 * @author LOLO
	 */
	public class FormatUtil
	{
		
		
		/**
		 * 获取格式化好的JSON字符串
		 * @param obj
		 * @return 
		 */
		public static function getJsonString(obj:Object):String
		{
			//把简单数据类型放在前面
			var arr1:Array = [];
			var arr2:Array = [];
			for(var key:String in obj)
			{
				var value:* = obj[key];
				if(typeof(value) == "object") {
					arr1.push({ key:key, value:JSON.stringify(value) });
				}
				else {
					var isStr:Boolean = value is String;
					arr2.push({ key:key, value:(isStr ? '"' : "") + value.toString() + (isStr ? '"' : "") });
				}
			}
			
			//固定顺序
			arr1.sortOn("key");
			arr2.sortOn("key");
			var arr:Array = arr2.concat(arr1);
			
			//组成JSON字符串
			var str:String = "{\n";
			for each(var item:Object in arr) {
				//if(str != "{\n") str += ",\n\n";
				if(str != "{\n") str += ",\n";
				str += '"' + item.key + '":';
				str += item.value;
			}
			str += "\n}";
			
			return str;
		}
		//
	}
}