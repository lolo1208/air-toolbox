package toolbox.utils
{
	import com.greensock.TweenMax;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import toolbox.Toolbox;
	import toolbox.data.SharedData;

	/**
	 * 帮助菜单相关
	 * @author LOLO
	 */
	public class Helper
	{
		
		
		/**
		 * 检查更新
		 */
		public static function checkUpdate():void
		{
			//关闭工具箱
			var args:Vector.<String> = new Vector.<String>();
			args.push("/F");
			args.push("/IM");
			args.push(SharedData.data["toolbox"].name + ".exe");
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File("C:/Windows/System32/taskkill.exe");
			npsi.arguments = args;
			new NativeProcess().start(npsi);
			
			Toolbox.progressPanel.show(2, 1, "正在进行更新前的准备..");
			TweenMax.delayedCall(1, checkUpdate2);
		}
		
		private static function checkUpdate2():void
		{
			//重新打开工具箱
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File(SharedData.data["toolbox"].path);
			new NativeProcess().start(npsi);
			
			Toolbox.progressPanel.addProgress();
			TweenMax.delayedCall(1, checkUpdate3);
		}
		
		private static function checkUpdate3():void
		{
			//关闭当前程序
			var args:Vector.<String> = new Vector.<String>();
			args.push("/F");
			args.push("/IM");
			args.push(SharedData.data[Toolbox.currentTool].name + ".exe");
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			npsi.executable = new File("C:/Windows/System32/taskkill.exe");
			npsi.arguments = args;
			new NativeProcess().start(npsi);
		}
		
		
		
		
		
		/**
		 * 关于
		 */
		public static function about():void
		{
			Alert.show("有问题？ 找LOLO！", "关于");
		}
		
		//
	}
}