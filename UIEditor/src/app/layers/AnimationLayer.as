package app.layers
{
	import app.common.LayerConstants;
	import app.utils.LayerUtil;
	
	import lolo.display.Animation;

	/**
	 * Animation 图层
	 * @author LOLO
	 */
	public class AnimationLayer extends Layer
	{
		
		
		public function AnimationLayer(sourceName:String="")
		{
			super();
			this.type = LayerConstants.ANIMATION;
			
			ani.sourceName = sourceName;
		}
		
		
		override protected function createElement():void
		{
			this.element = new Animation();
		}
		
		
		
		/**
		 * element 转换为 Animation
		 */
		private function get ani():Animation { return LayerUtil.getAni(this); }
		
		
		
		
		
		override public function get properties():Object
		{
			var props:Object = super.properties;
			
			if(ani.fps != 12) props.fps = ani.fps;
			if(ani.playing) {
				props.playing = true;
			}
			else if(ani.currentFrame != 1){
				props.currentFrame = ani.currentFrame;
			}
			
			props.sourceName = ani.sourceName;
			
			return props;
		}
		//
	}
}