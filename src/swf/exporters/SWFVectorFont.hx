package swf.exporters;

enum GlyphCommand
{
	MoveTo(x:Float, y:Float);
	LineTo(x:Float, y:Float);
	CurveTo(cx:Float, cy:Float, ax:Float, ay:Float);
}

typedef GlyphData =
{
	var commands:Array<GlyphCommand>;
	var advance:Float;
}

typedef SWFVectorFont =
{
	var name:String;
	var ascent:Float;
	var descent:Float;
	var leading:Float;
	var glyphs:Map<Int, GlyphData>;
}
