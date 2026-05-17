package swf.exporters;

import swf.SWF;
import swf.tags.TagDefineFont2;
import swf.tags.TagDefineFont3;
import swf.exporters.ShapeCommandExporter;
import swf.exporters.core.ShapeCommand;
import swf.exporters.SWFVectorFont;

class NativeFontExporter
{
	private static inline var TWIPS:Float = 20.0;

	public static function extract(swf:SWF):Array<SWFVectorFont>
	{
		var exportedFonts = new Array<SWFVectorFont>();

		for (tag in swf.data.tags)
		{
			if (Std.isOfType(tag, TagDefineFont2))
			{
				var fontTag:TagDefineFont2 = cast tag;
				exportedFonts.push(processFontTag(fontTag));
			}
		}

		return exportedFonts;
	}

	private static function processFontTag(fontTag:TagDefineFont2):SWFVectorFont
	{
		var isFont3 = Std.isOfType(fontTag, TagDefineFont3);
		var scale = isFont3 ? (TWIPS * 20.0) : TWIPS;

		var font:SWFVectorFont = {
			name: fontTag.fontName != null ? fontTag.fontName : "Unknown_" + fontTag.characterId,
			ascent: 0,
			descent: 0,
			leading: 0,
			glyphs: new Map<Int, GlyphData>()
		};

		if (fontTag.hasLayout)
		{
			font.ascent = roundFloat(fontTag.ascent / scale);
			font.descent = roundFloat(fontTag.descent / scale);
			font.leading = roundFloat(fontTag.leading / scale);
		}

		var shapeTable = fontTag.glyphShapeTable;
		var codeTable = fontTag.codeTable;

		if (shapeTable != null && codeTable != null)
		{
			for (i in 0...shapeTable.length)
			{
				if (i >= codeTable.length) break;

				var charCode = codeTable[i];
				var shape = shapeTable[i];

				var shapeExporter = new ShapeCommandExporter(null);
				shape.export(shapeExporter);

				var glyphCommands = convertCommands(shapeExporter.commands, scale);

				var charAdvance = 0.0;
				if (fontTag.hasLayout && fontTag.fontAdvanceTable != null && i < fontTag.fontAdvanceTable.length)
				{
					charAdvance = roundFloat(fontTag.fontAdvanceTable[i] / scale);
				}

				font.glyphs.set(charCode, {
					commands: glyphCommands,
					advance: charAdvance
				});
			}
		}

		return font;
	}

	private static function convertCommands(openflCommands:Array<ShapeCommand>, scale:Float):Array<GlyphCommand>
	{
		var result = new Array<GlyphCommand>();

		for (cmd in openflCommands)
		{
			switch (cmd)
			{
				case MoveTo(x, y):
					result.push(GlyphCommand.MoveTo(roundFloat(x / scale), roundFloat(y / scale)));

				case LineTo(x, y):
					result.push(GlyphCommand.LineTo(roundFloat(x / scale), roundFloat(y / scale)));

				case CurveTo(cx, cy, ax, ay):
					result.push(GlyphCommand.CurveTo(roundFloat(cx / scale), roundFloat(cy / scale), roundFloat(ax / scale), roundFloat(ay / scale)));

				default:
			}
		}

		return result;
	}

	private static inline function roundFloat(val:Float):Float
	{
		return Math.round(val * 10000.0) / 10000.0;
	}
}
