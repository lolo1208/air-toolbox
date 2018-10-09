package app.effects
{
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;

	/**
	 * 项目相关的代码特效
	 * @author LOLO
	 */
	public class AppEffect
	{
		
		
		/**
		 * 发光滤镜动画
		 * @param target
		 * @param color
		 */
		public static function glowFilterAni(target:DisplayObject, color:uint=0xFF0000):void
		{
			TweenMax.killTweensOf(target);
			TweenMax.to(target, 0.8, { glowFilter:{color:color, alpha:1, blurX:20, blurY:20 }});
			TweenMax.to(target, 0.4, { glowFilter:{color:color, alpha:0.1, blurX:0, blurY:0 }, delay:0.8});
			TweenMax.to(target, 0.4, { glowFilter:{color:color, alpha:1, blurX:10, blurY:10 }, delay:1.2});
			TweenMax.to(target, 0.2, { glowFilter:{color:color, alpha:0.1, blurX:0, blurY:0 }, delay:1.6});
		}
		//
	}
}