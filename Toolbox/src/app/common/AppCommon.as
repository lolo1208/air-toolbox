package app.common
{
	import app.main.Main;
	
	/**
	 * 项目公共数据和方法
	 * @author LOLO
	 */
	public class AppCommon
	{
		
		/**对当前程序的引用*/
		public static var app:Main;
		
		
		/**更新服务器列表*/
		public static const UPDATE_SERVER_LIST:Array = [
			"http://127.0.0.1/toolbox/",
			"http://rz-js-luozc/toolbox/",
			"http://dr-js-luozc/toolbox/"
		];
		//
	}
}