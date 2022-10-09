/*
	BactaTank Model Functions
	Misc Functions For TTGames' Models
	Written by Alub
*/

#region Replace Texture

function replaceBactaTankTexture(modelStruct, textureIndex, textureFile)
{
	// Load New Texture Buffer
	var buffer = buffer_load(textureFile);
						
	// Get Metadata
	var newWidth = buffer_peek(buffer, 0x10, buffer_u32);
	var newHeight = buffer_peek(buffer, 0x0c, buffer_u32);
	var newSize = buffer_get_size(buffer);
						
	// Get Textures File Name For Saving
	var name = buffer_sha1(buffer, 0, newSize);
	modelStruct.nu20.textureMetaData[textureIndex].file = global.tempDirectory + @"\" + name;
		
	// Save DDS
	buffer_save(buffer, global.tempDirectory + @"\" + name + ".dds");
		
	// Convert DDS to PNG
	//show_debug_message("\"bin/python/python.exe\" \"bin/scripts/texconverter.py\" \"" + global.tempDirectory + name + ".dds\" \"" + global.tempDirectory + "/" + name + ".png\"");
	ProcessExecute("\"bin/utils/BactaTankUtils.exe\" --convertImage \"" + global.tempDirectory + name + ".dds\" \"" + global.tempDirectory + name + ".png\"");
						
	// Free Memory
	var oldSpriteIndex = modelStruct.nu20.textureMetaData[textureIndex].sprite;
	buffer_delete(modelStruct.textures[textureIndex]);
						
	// Set Buffer
	modelStruct.textures[textureIndex] = buffer;
	modelStruct.nu20.textureMetaData[textureIndex].width = newWidth;
	modelStruct.nu20.textureMetaData[textureIndex].height = newHeight;
	modelStruct.nu20.textureMetaData[textureIndex].size = newSize;
						
	// Add Sprite
	modelStruct.nu20.textureMetaData[textureIndex].sprite = sprite_add(global.tempDirectory + name + ".png", 1, false, false, 0, 0);
	//sprite_delete(oldSpriteIndex);
}

#endregion

#region Replace Mesh

function replaceBactaTankMesh(modelStruct, meshIndex, meshFile)
{
	// Load Mesh File
	var buffer = buffer_load(meshFile);
	
	// Current Mesh
	var mesh = modelStruct.nu20.meshes[meshIndex];
	
	// Get Vertex Format
	var vertexFormat = decodeBactaTankVertexFormat(modelStruct.nu20.materials[getBactaTankMeshMaterial(modelStruct, meshIndex)].vertexFormat);
	
	// Delete Old Buffers
	buffer_delete(mesh.vertexBuffer);
	buffer_delete(mesh.indexBuffer);
	
	// Read Mesh File
	buffer_read(buffer, buffer_string);					// BactaTank
	buffer_read(buffer, buffer_string);					// PCGHG
	var version = buffer_read(buffer, buffer_f32);		// 0.2
	if (version != 0.2) return;
	buffer_read(buffer, buffer_string);					// Materials
	buffer_read(buffer, buffer_u32);					// 0
	buffer_read(buffer, buffer_string);					// Meshes
	buffer_read(buffer, buffer_u32);					// 1
	buffer_read(buffer, buffer_string);					// MeshData
	
	// Mesh Data
	var newTriangleCount = buffer_read(buffer, buffer_u32);
	var newVertexCount = buffer_read(buffer, buffer_u32);
	
	// Mesh Attributes
	buffer_read(buffer, buffer_string);	// Mesh Attributes
	var attributeCount = buffer_read(buffer, buffer_u32);
	repeat (attributeCount) buffer_read(buffer, buffer_string); // Position, Normal, Colour, UV
	
	// Vertex Buffer
	buffer_read(buffer, buffer_string);
	
	// Position Attribute
	buffer_read(buffer, buffer_string);
	var position = [];
	
	for (var i = 0; i < newVertexCount; i++)
	{
		var positionX = buffer_read(buffer, buffer_f32);
		var positionY = buffer_read(buffer, buffer_f32);
		var positionZ = buffer_read(buffer, buffer_f32);
		array_push(position, [positionX, positionY, positionZ])
	}
	
	// Normal Attribute
	buffer_read(buffer, buffer_string);
	var normal = [];
	
	for (var i = 0; i < newVertexCount; i++)
	{
		array_push(normal, buffer_read(buffer, buffer_u32));
	}
	
	// Colour Attribute
	buffer_read(buffer, buffer_string);
	var colour = [];
	
	for (var i = 0; i < newVertexCount; i++)
	{
		array_push(colour, buffer_read(buffer, buffer_u32));
	}
	
	// UV Attribute
	buffer_read(buffer, buffer_string);
	var uv = [];
	
	for (var i = 0; i < newVertexCount; i++)
	{
		var uvX = buffer_read(buffer, buffer_f32);
		var uvY = buffer_read(buffer, buffer_f32);
		array_push(uv, [uvX, uvY]);
	}
	
	// Delete Old Vertex Buffer
	buffer_delete(mesh.vertexBuffer)
	
	// Build New Vertex Buffer
	mesh.vertexBuffer = buffer_create(newVertexCount * mesh.vertexStride, buffer_fixed, 1);
	
	for (var i = 0; i < newVertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			switch (vertexFormat[j].attribute)
			{
				case bactatankVertexAttributes.position:
					buffer_write(mesh.vertexBuffer, buffer_f32, position[i][0]);
					buffer_write(mesh.vertexBuffer, buffer_f32, position[i][1]);
					buffer_write(mesh.vertexBuffer, buffer_f32, position[i][2]);
					break;
				case bactatankVertexAttributes.normal:
					buffer_write(mesh.vertexBuffer, buffer_u32, normal[i]);
					break;
				case bactatankVertexAttributes.colour:
					buffer_write(mesh.vertexBuffer, buffer_u32, colour[i]);
					break;
				case bactatankVertexAttributes.uv:
					buffer_write(mesh.vertexBuffer, buffer_f32, uv[i][0]);
					buffer_write(mesh.vertexBuffer, buffer_f32, uv[i][1]);
					break;
				case bactatankVertexAttributes.tangent:
					buffer_write(mesh.vertexBuffer, buffer_u32, 0);
					break;
				case bactatankVertexAttributes.bitangent:
					buffer_write(mesh.vertexBuffer, buffer_u32, 0);
					break;
				case bactatankVertexAttributes.blendIndices:
					buffer_write(mesh.vertexBuffer, buffer_s32, -1);
					break;
				case bactatankVertexAttributes.blendWeights:
					buffer_write(mesh.vertexBuffer, buffer_s32, -1);
					break;
			}
		}
	}
	
	// Index Buffer
	buffer_read(buffer, buffer_string); // IndexBuffer
	var newIndexBufferSize = buffer_read(buffer, buffer_u32);
	mesh.indexBuffer = buffer_create(newIndexBufferSize, buffer_fixed, 1);
	buffer_copy(buffer, buffer_tell(buffer), newIndexBufferSize, mesh.indexBuffer, 0);
	buffer_seek(buffer, buffer_seek_relative, newIndexBufferSize);
	
	// Delete Mesh Buffer
	buffer_delete(buffer);
	vertex_delete_buffer(mesh.vertexBufferObject);
	
	// Set New Variables
	mesh.triangleCount = newTriangleCount;
	mesh.vertexCount = newVertexCount;
	
	// Build New VBO
	if (mesh.triangleCount == 0 || mesh.vertexCount == 0)
	{
		mesh.vertexBufferObject = -1;
		return;
	}
	
	// Create New Vertex Buffer
	var currentVertexBuffer = vertex_create_buffer();
	vertex_begin(currentVertexBuffer, global.vertexFormat);
	
	// Build VBO
	for (var i = 0; i < mesh.triangleCount+2; i++)
	{
		var index = buffer_peek(mesh.indexBuffer, i*2, buffer_u16);
		var pos = array_create(3, 0);
		var norm = array_create(3, 0);
		var tex = array_create(2, 0);
		var col = 0;
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			switch (vertexFormat[j].attribute)
			{
				case bactatankVertexAttributes.position:
					pos = [-buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position, buffer_f32),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 4, buffer_f32),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 8, buffer_f32)];
					break;
				case bactatankVertexAttributes.normal:
					norm = [((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position, buffer_u8)/255)*2)-1,
							((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 1, buffer_u8)/255)*2)-1,
							((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 2, buffer_u8)/255)*2)-1];
					break;
				case bactatankVertexAttributes.uv:
					tex = [buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position, buffer_f32),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 4, buffer_f32)];
					break;
				case bactatankVertexAttributes.colour:
					col = make_colour_rgb(
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position, buffer_u8),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 1, buffer_u8),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[j].position + 2, buffer_u8));
					break;
			}
		}
			
		vertex_position_3d(currentVertexBuffer, pos[0], pos[1], pos[2]);
		vertex_normal(currentVertexBuffer, norm[0], norm[1], norm[2]);
		vertex_texcoord(currentVertexBuffer, tex[0], tex[1]);
		vertex_colour(currentVertexBuffer, #ffffff, 1);
	}
	vertex_end(currentVertexBuffer);
	
	// Freeze VBO For Better Performance
	vertex_freeze(currentVertexBuffer);
	
	// Set VBO
	mesh.vertexBufferObject = currentVertexBuffer;
}

#endregion

#region Get Mesh Material

function getBactaTankMeshMaterial(modelStruct, mesh)
{
	// Get Layers
	var layers = modelStruct.nu20.layers;
	
	// Loop Through Layers
	for (var i = 0; i < array_length(layers); i++)
	{
		// Loop Through Layer Meshes
		for (var j = 0; j < array_length(layers[i].meshes); j++)
		{
			if (layers[i].meshes[j].mesh == mesh) return layers[i].meshes[j].material;
		}
	}
	
	// Return -1 just incase
	return -1;
}

#endregion

#region Decode Vertex Format

function decodeBactaTankVertexFormat(vertexFormat)
{
	var normalType;
	var texType;
	var tangentType;
	var local_24;
	var tangentType2;
	var local_1c;
	var halfFloatTexType;
	var local_c;
	var colorFlag1;
	var arrayFormat = [];

	if (((vertexFormat & 8) == 0) && ((vertexFormat & 0x880000) == 0)) {
	    normalType = vertexFormat >> 2 & 1;
	}
	else {
	    normalType = 2;
	}
	if (((vertexFormat & 0x20) == 0) && ((vertexFormat & 0x1000000) == 0)) {
	    tangentType = vertexFormat >> 4 & 1;
	}
	else {
	    tangentType = 2;
	}
	if ((vertexFormat < 0) || ((vertexFormat & 0x2000000) != 0)) {
	    tangentType2 = 2;
	}
	else {
	    tangentType2 = vertexFormat >> 6 & 1;
	}
	colorFlag1 = vertexFormat >> 8 & 1;
	if ((vertexFormat >> 0x1b & 1) == 0) {
	    texType = vertexFormat >> 0xb & 7;
	    halfFloatTexType = 0;
	}
	else {
	    texType = 0;
	    halfFloatTexType = vertexFormat >> 0xb & 7;
	}
	if ((vertexFormat & 0x8000) == 0) {
	    local_1c = vertexFormat >> 0xe & 1;
	}
	else {
	    local_1c = 2;
	}
	if ((vertexFormat & 0x20000) == 0) {
	    local_24 = vertexFormat >> 0x10 & 1;
	}
	else {
	    local_24 = 2;
	}
	local_c = vertexFormat >> 0x1a & 1;
	var local_4 = vertexFormat >> 0x16 & 1;
	
	array_push(arrayFormat, {attribute: bactatankVertexAttributes.position, type: bactatankVertexAttributeTypes.float3, position: 0x00});

	var offset = 0x0c;

	if (normalType == 1) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.normal, type: bactatankVertexAttributeTypes.float3, position: offset});
		offset += 0x0c;
	} else if (normalType == 2) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.normal, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x04;
	}

	if (tangentType == 1) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.tangent, type: bactatankVertexAttributeTypes.float3, position: offset});
		offset += 0x0c;
	} else if (tangentType == 2) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.tangent, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x04;
	}

	if (tangentType2 == 1) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.bitangent, type: bactatankVertexAttributeTypes.float3, position: offset});
		offset += 0x0c;
	} else if (tangentType2 == 2) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.bitangent, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x04;
	}

	if (colorFlag1 != 0) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.colour, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x04;
	}
	if ((vertexFormat & 0x600) != 0) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.colour2, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x04;
	}

	if(texType != 0){
	    for(var i = 0; i < texType; i++){
			array_push(arrayFormat, {attribute: bactatankVertexAttributes.uv, type: bactatankVertexAttributeTypes.float2, position: offset});
			offset += 0x08;
	    }
	}else{
	    for(var i = 0; i < halfFloatTexType; i++){
			array_push(arrayFormat, {attribute: bactatankVertexAttributes.uv, type: bactatankVertexAttributeTypes.half2, position: offset});
			offset += 0x08;
	    }
	}

	if (local_1c == 1) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.blendIndices, type: bactatankVertexAttributeTypes.float2, position: offset});
		offset += 0x08;
	} else if (local_1c == 2) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.blendIndices, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x04;
	}

	if (local_24 == 1) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.blendWeights, type: bactatankVertexAttributeTypes.float3, position: offset});
		offset += 0x0c;
	} else if (local_24 == 2) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.blendWeights, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x08;
	}

	if (local_c != 0) {
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.lightDirection, type: bactatankVertexAttributeTypes.byte4, position: offset});
		array_push(arrayFormat, {attribute: bactatankVertexAttributes.bitangent, type: bactatankVertexAttributeTypes.byte4, position: offset});
		offset += 0x08;
	}
	
	return arrayFormat;
}

#endregion