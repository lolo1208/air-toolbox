package app.common
{
	import app.groups.aniGroup.AniGroup;
	import app.groups.canvasGroup.CanvasGroup;
	import app.groups.canvasGroup.Toolbar;
	import app.groups.componentGroup.ComponentGroup;
	import app.groups.configGroup.ConfigGroup;
	import app.groups.layerGroup.LayerGroup;
	import app.groups.propGroup.PropGroup;
	import app.groups.skinGroup.SkinGroup;
	import app.groups.styleGroup.StyleGroup;
	import app.groups.uiGroup.UIGroup;
	import app.main.Main;
	
	import lolo.core.Common;
	import lolo.ui.Console;
	import lolo.utils.StringUtil;
	
	import toolbox.Toolbox;
	
	
	/**
	 * 项目公共数据和方法
	 * @author LOLO
	 */
	public class AppCommon
	{
		/**对当前程序的引用*/
		public static var app:Main;
		
		public static var canvas:CanvasGroup;
		public static var toolbar:Toolbar;
		
		public static var ui:UIGroup;
		public static var ani:AniGroup;
		
		public static var config:ConfigGroup;
		public static var layer:LayerGroup;
		
		public static var component:ComponentGroup;
		public static var skin:SkinGroup;
		
		public static var prop:PropGroup;
		public static var style:StyleGroup;
		
		
		/**控制器*/
		public static var controller:Controller;
		
		
		/**是否有组件在占用着键盘（编辑中..）*/
		public static function get keyboardUsing():Boolean
		{
			if(Common.stage.focus == Console.getInstance().outputText) return true;
			if(Common.stage.focus == Console.getInstance().inputText) return true;
			return _keyboardUsing;
		}
		public static function set keyboardUsing(value:Boolean):void { _keyboardUsing = value; }
		private static var _keyboardUsing:Boolean;
		
		
		
		
		
		/**
		 * 将资源地址转换成正确的网络地址
		 * @param url 资源的url
		 * @param version 资源的版本号
		 * return 
		 */
		public static function getResUrl(url:String, version:uint=0):String
		{
			return "file:///" + StringUtil.backslashToSlash(url.replace("assets/{resVersion}/", Toolbox.resRootDir));
		}
		//
	}
}