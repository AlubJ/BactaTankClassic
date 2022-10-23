/*
	BactaTank Font Loader
	Loads TTGames' Fonts For Use Within BactaTank
	Written By Alub
*/

function loadBactaTankFont(font)
{
	// Load Buffer
	var buffer = buffer_load(font);
	
	// Read Texture Offset
	buffer_seek(buffer, buffer_seek_relative, 0x8);
	var textureOffset = buffer_read(buffer, buffer_s32) + 8;
	
	// Get Texture Size
	var textureSize = buffer_peek(buffer, 0x00, buffer_u32) - textureOffset;
	
	// Get Character Count
	buffer_seek(buffer, buffer_seek_relative, 0x10);
	var characterCount = buffer_read(buffer, buffer_s32);
	
	// Get Character Height
	buffer_seek(buffer, buffer_seek_relative, 0x4);
	var characterHeight = buffer_read(buffer, buffer_f32);

	// Read Characters
	buffer_seek(buffer, buffer_seek_relative, 0x38);
	var characters = [];
	
	var maxWidth = 0;
	
	for (var i = 0; i < characterCount; i++)
	{
		var charOffset = buffer_tell(buffer);
		var charPosX = buffer_read(buffer, buffer_f32);
		var charPosY = buffer_read(buffer, buffer_f32);
		var charWidth = buffer_read(buffer, buffer_f32);
	
		characters[i] = {
			x: charPosX,
			y: charPosY,
			width: charWidth,
			height: characterHeight,
			offset: charOffset,
		}
	}
	
	// Get Texture
	buffer_seek(buffer, buffer_seek_start, textureOffset);
	var textureBuffer = buffer_create(textureSize, buffer_fixed, 1);
	buffer_copy(buffer, textureOffset, textureSize, textureBuffer, 0);
	var fontSprite = readBactaTankTexture(textureBuffer);
	
	// Cleanup
	buffer_delete(textureBuffer);
	buffer_delete(buffer);
	
	// Font Struct
	var fontStruct = {
		characterHeight: characterHeight,
		characters: characters,
		sprite: fontSprite,
	};
	
	// Return
	return fontStruct;
}