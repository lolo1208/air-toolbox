package app.controls
{
	import app.common.AppCommon;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import toolbox.utils.SortJSONEncoder;

	/**
	 * 生成并保存HTML5项目对应的JSON文件
	 * @author LOLO
	 */
	public class SaveJSON
	{
		
		public static function save(config:XML):void
		{
			var data:Object = {};
			parseProps(data, config);
			delete data.name;
			parseContainer(data, config);
			var jsonStr:String = SortJSONEncoder.stringify(data);
			
			//保存xml对应的json文件
			var path:String = AppCommon.controller.configPath;
			path = path.replace(/^(.*)\.xml(.*)$/, "$1.json");
			path = path.replace(/^(.*)\\xml\\(.*)$/, "$1\\json\\$2");
			var file:File = new File(path);
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(jsonStr);
			fs.close();
		}
		
		
		
		private static function parseContainer(container:Object, config:XML):void
		{
			//生成子元素
			container.children = [];
			for each(var item:XML in config.*)
			{
				if(item.@ignore == "true") continue;//编辑器中才需要生成的层
				
				var child:Object = {};
				parseProps(child, item);
				container.children.push(child);
				
				//继续解析子元素
				parseContainer(child, item);
			}
			
			//没有子元素
			if(container.children.length == 0) delete container.children;
		}
		
		
		private static function parseProps(target:Object, config:XML):void
		{
			var itemName:String = config.name().toString();//在xml中，这条item的名称
			target.name = itemName;
			
			parseStringProp(target, config, "id");
			parseStringProp(target, config, "type");
			parseStringProp(target, config, "target");
			parseStringProp(target, config, "group");
			parseStringProp(target, config, "parent");
			
			parseJsonProp(target, config, "toolTip");
			parseJsonProp(target, config, "properties");
			parseJsonProp(target, config, "props");
			parseJsonProp(target, config, "vars");
			parseJsonProp(target, config, "style");
			parseJsonProp(target, config, "stageLayout");
		}
		
		
		private static function parseJsonProp(target:Object, config:XML, propName:String):void
		{
			var jsonStr:String = config["@" + propName];
			if(jsonStr == "") return;
			target[propName] = JSON.parse(jsonStr);
		}
		
		
		private static function parseStringProp(target:Object, config:XML, propName:String):void
		{
			var value:String = config["@" + propName];
			if(value == "") return;
			target[propName] = value;
		}
		//
	}
}