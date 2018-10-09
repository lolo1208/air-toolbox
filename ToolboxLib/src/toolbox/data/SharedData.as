package toolbox.data
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	
	/**
	 * 工具箱的共享数据
	 * @author LOLO
	 */
	public class SharedData
	{
		private static var _instance:SharedData;
		
		private var _file:File;
		private var _data:Object;
		
		
		
		/**
		 * 获取实例
		 */
		public static function getInstance():SharedData
		{
			if(_instance == null) _instance = new SharedData();
			return _instance;
		}
		
		
		/**
		 * 获取数据
		 */
		public static function get data():Object { return getInstance().data; }
		
		
		/**
		 * 保存数据
		 */
		public static function save():void { getInstance().save(); }
		
		
		
		
		
		/**
		 * 获取数据
		 */
		public function get data():Object
		{
			if(_data == null) loadData();
			return _data;
		}
		
		
		
		/**
		 * 保存数据
		 */
		public function save():void
		{
			if(_data == null) return;
			
			var fs:FileStream = new FileStream();
			fs.open(_file, FileMode.WRITE);
			fs.writeObject(_data);
			fs.close();
			
			loadData();
		}
		
		
		/**
		 * 加载数据（会覆盖当前未保存的数据）
		 */
		public function loadData():void
		{
			if(_file == null) {
				_file = new File(File.documentsDirectory.nativePath + "/LoloToolbox/SharedData");
			}
			if(_file.exists) {
				var fs:FileStream = new FileStream();
				fs.open(_file, FileMode.READ);
				_data = fs.readObject();
				fs.close();
			}
			else {
				_data = {};
			}
		}
		//
	}
}