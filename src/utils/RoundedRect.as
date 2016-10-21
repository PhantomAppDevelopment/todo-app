package utils
{
	import flash.geom.Rectangle;

	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;

	public class RoundedRect
	{
		[Embed(source="../assets/icons/rounded.png")]
		private static const myAsset:Class;

		public static function createRoundedRect(color:uint = 0xFF0000):Image
		{
			var myImage:Image = new Image(Texture.fromEmbeddedAsset(myAsset));
			myImage.pixelSnapping = true;
			myImage.textureSmoothing = TextureSmoothing.TRILINEAR;
			myImage.scale9Grid = new Rectangle(24, 24, 2, 2);
			myImage.color = color;
			return myImage;
		}
	}
}