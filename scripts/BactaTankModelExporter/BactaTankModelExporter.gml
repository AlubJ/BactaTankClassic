/*
	BactaTank Model Exporter
	Exports TTGames' Models For Use Ingame
	Written By Alub
*/

#region Export Model

function exportBactaTankModel(modelStruct, filepath)
{
	// Create Buffer
	var buffer = buffer_create(1, buffer_grow, 1);
	
	// Create New Buffers
	var buffers = buildBactaTankBuffers(modelStruct);
	
	// Edit NU20
	editBactaTankNU20(modelStruct);
	
	// Pre-NU20 Size
	var preNU20Size = buffer_get_size(modelStruct.nu20.buffer);
	
	// Write NU20 if NU20 First
	if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20First)
	{
		buffer_copy(modelStruct.nu20.buffer, 0, preNU20Size, buffer, 0);
		buffer_seek(buffer, buffer_seek_relative, preNU20Size);
	}
	
	// Write Textures
	buffer_write(buffer, buffer_u32, 0); // Pre-NU20 Size
	if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20Last) buffer_write(buffer, buffer_u16, modelStruct.nu20.textureCount); // Texture Count
	
	for (var i = 0; i < modelStruct.nu20.textureCount; i++)
	{
		var textureMeta = modelStruct.nu20.textureMetaData[i];
		if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20Last)
		{
			// Texture Meta Data
			buffer_write(buffer, buffer_u32, textureMeta.width);
			buffer_write(buffer, buffer_u32, textureMeta.height);
			repeat(12) buffer_write(buffer, buffer_u8, 0);
			buffer_write(buffer, buffer_u32, textureMeta.size);
		}
		
		buffer_copy(modelStruct.textures[i], 0, textureMeta.size, buffer, buffer_tell(buffer));
		buffer_seek(buffer, buffer_seek_relative, textureMeta.size);
	}
	
	// Write Vertex Buffers
	buffer_write(buffer, buffer_u16, array_length(buffers[0]));
	
	for (var i = 0; i < array_length(buffers[0]); i++)
	{
		buffer_write(buffer, buffer_u32, buffer_get_size(buffers[0][i]));
		buffer_copy(buffers[0][i], 0, buffer_get_size(buffers[0][i]), buffer, buffer_tell(buffer));
		buffer_seek(buffer, buffer_seek_relative, buffer_get_size(buffers[0][i]));
	}
	
	// Write Index Buffers
	buffer_write(buffer, buffer_u16, array_length(buffers[1]));
	
	for (var i = 0; i < array_length(buffers[1]); i++)
	{
		buffer_write(buffer, buffer_u32, buffer_get_size(buffers[1][i]));
		buffer_copy(buffers[1][i], 0, buffer_get_size(buffers[1][i]), buffer, buffer_tell(buffer));
		buffer_seek(buffer, buffer_seek_relative, buffer_get_size(buffers[1][i]));
	}
	
	// Watermark
	buffer_write(buffer, buffer_string, global.settings.watermark);
	
	// Pre-NU20Size
	if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20Last)
	{
		buffer_poke(buffer, 0, buffer_u32, buffer_tell(buffer) - 4);
		buffer_copy(modelStruct.nu20.buffer, 0, preNU20Size, buffer, buffer_tell(buffer));
		buffer_seek(buffer, buffer_seek_relative, preNU20Size);
	}
	else
	{
		buffer_poke(buffer, preNU20Size, buffer_u32, (buffer_get_size(buffer) - 4) - preNU20Size);
	}
	
	// Save Buffer
	buffer_save(buffer, filepath);
	
	// Destroy Buffers
	buffer_delete(buffer);
	for (var i = 0; i < array_length(buffers[0]); i++) buffer_delete(buffers[0][i]);
	for (var i = 0; i < array_length(buffers[1]); i++) buffer_delete(buffers[1][i]);
}

#endregion

#region Build New Buffers

function buildBactaTankBuffers(modelStruct)
{
	// Create New Buffers
	var writeVertexBuffers = [];
	var writeIndexBuffers = [];
	var vbIndex = [];
	var ibIndex = [];
			
	// Alwasy 1 Index Buffer
	writeIndexBuffers[0] = buffer_create(1, buffer_grow, 1);
	
	// Make Vertex Buffers
	for (var i = 0; i < array_length(modelStruct.nu20.meshes); i++) {
		// If the vertex stride isn't in the array, add a new entry. Each vertex stride is treated as a new vertexBuffer.
		if (array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride) == -1) {
			array_push(vbIndex, modelStruct.nu20.meshes[i].vertexStride);
			writeVertexBuffers[array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride)] = buffer_create(1, buffer_grow, 1);
		}
		
		// Set Vertex Buffer Index
		modelStruct.nu20.meshes[i].vertexBufferID = array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride);
		modelStruct.nu20.meshes[i].vertexOffset = buffer_tell(writeVertexBuffers[array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride)]) / modelStruct.nu20.meshes[i].vertexStride;
		buffer_copy(modelStruct.nu20.meshes[i].vertexBuffer, 0, buffer_get_size(modelStruct.nu20.meshes[i].vertexBuffer), writeVertexBuffers[array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride)], buffer_tell(writeVertexBuffers[array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride)]));
		buffer_seek(writeVertexBuffers[array_get_index(vbIndex, modelStruct.nu20.meshes[i].vertexStride)], buffer_seek_relative, buffer_get_size(modelStruct.nu20.meshes[i].vertexBuffer));
				
		modelStruct.nu20.meshes[i].indexBufferID = 0;
		modelStruct.nu20.meshes[i].indexOffset = buffer_tell(writeIndexBuffers[0]) / 2;
		buffer_copy(modelStruct.nu20.meshes[i].indexBuffer, 0, buffer_get_size(modelStruct.nu20.meshes[i].indexBuffer), writeIndexBuffers[0], buffer_tell(writeIndexBuffers[0]));
		buffer_seek(writeIndexBuffers[0], buffer_seek_relative, buffer_get_size(modelStruct.nu20.meshes[i].indexBuffer));
	}
			
	// Return Buffers
	return [writeVertexBuffers, writeIndexBuffers];
}

#endregion

#region Edit NU20

function editBactaTankNU20(modelStruct)
{
	// Edit NU20
	for (var i = 0; i < array_length(modelStruct.nu20.textureMetaData); i++)
	{
		var currentTexture = modelStruct.nu20.textureMetaData[i];
		buffer_poke(modelStruct.nu20.buffer, currentTexture.offset, buffer_u32, currentTexture.width);
		buffer_poke(modelStruct.nu20.buffer, currentTexture.offset + 0x04, buffer_u32, currentTexture.height);
		if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20First) buffer_poke(modelStruct.nu20.buffer, currentTexture.offset + 0x44, buffer_u32, currentTexture.size);
	}
	
	for (var i = 0; i < array_length(modelStruct.nu20.materials); i++)
	{
		// Variables
		var material = modelStruct.nu20.materials[i];
		var offset = material.offset;
		
		// Edit Mesh Data
		buffer_poke(modelStruct.nu20.buffer, offset + 0x40,    buffer_u32, material.alphaBlend);
		buffer_poke(modelStruct.nu20.buffer, offset + 0x54,    buffer_f32, material.colour[0]);
		buffer_poke(modelStruct.nu20.buffer, offset + 0x58,    buffer_f32, material.colour[1]);
		buffer_poke(modelStruct.nu20.buffer, offset + 0x5c,    buffer_f32, material.colour[2]);
		buffer_poke(modelStruct.nu20.buffer, offset + 0x60,    buffer_f32, material.colour[3]);
		buffer_poke(modelStruct.nu20.buffer, offset + 0x74,    buffer_s16, material.textureID);
		buffer_poke(modelStruct.nu20.buffer, offset + 0xb4 + 0x04,    buffer_s32, material.textureID);
		buffer_poke(modelStruct.nu20.buffer, offset + 0xb4 + 0x4c,    buffer_s32, material.normalID);
		buffer_poke(modelStruct.nu20.buffer, offset + 0xb4 + 0x54,    buffer_s32, material.shineID);
		buffer_poke(modelStruct.nu20.buffer, offset + 0xb4 + 0x1b8,   buffer_u32, material.shaderFlags);
	}
	
	for (var i = 0; i < array_length(modelStruct.nu20.meshes); i++)
	{
		// Variables
		var mesh = modelStruct.nu20.meshes[i];
		var offset = mesh.offset;
		
		// Edit Mesh Data
		buffer_poke(modelStruct.nu20.buffer, offset,    buffer_s32, mesh.type);
		buffer_poke(modelStruct.nu20.buffer, offset+4,  buffer_s32, mesh.triangleCount);
		buffer_poke(modelStruct.nu20.buffer, offset+8,  buffer_s16, mesh.vertexStride);
		buffer_poke(modelStruct.nu20.buffer, offset+10, buffer_s8,  mesh.bones[0]);
		buffer_poke(modelStruct.nu20.buffer, offset+11, buffer_s8,  mesh.bones[1]);
		buffer_poke(modelStruct.nu20.buffer, offset+12, buffer_s8,  mesh.bones[2]);
		buffer_poke(modelStruct.nu20.buffer, offset+13, buffer_s8,  mesh.bones[3]);
		buffer_poke(modelStruct.nu20.buffer, offset+14, buffer_s8,  mesh.bones[4]);
		buffer_poke(modelStruct.nu20.buffer, offset+15, buffer_s8,  mesh.bones[5]);
		buffer_poke(modelStruct.nu20.buffer, offset+16, buffer_s8,  mesh.bones[6]);
		buffer_poke(modelStruct.nu20.buffer, offset+17, buffer_s8,  mesh.bones[7]);
		buffer_poke(modelStruct.nu20.buffer, offset+20, buffer_s32, mesh.vertexOffset);
		buffer_poke(modelStruct.nu20.buffer, offset+24, buffer_s32, mesh.vertexCount);
		buffer_poke(modelStruct.nu20.buffer, offset+28, buffer_s32, mesh.indexOffset);
		buffer_poke(modelStruct.nu20.buffer, offset+32, buffer_s32, mesh.indexBufferID);
		buffer_poke(modelStruct.nu20.buffer, offset+36, buffer_s32, mesh.vertexBufferID);
	}
}

#endregion

#region Export Mesh

function exportBactaTankMesh(modelStruct, meshIndex, exportFile)
{
	// Create Export Buffer
	var buffer = buffer_create(1, buffer_grow, 1);
	
	// Mesh
	var mesh = modelStruct.nu20.meshes[meshIndex];
	
	// Write Header
	buffer_write(buffer, buffer_string, "BactaTank");
	buffer_write(buffer, buffer_string, "PCGHG");
	buffer_write(buffer, buffer_f32, 0.1);
	buffer_write(buffer, buffer_string, "Materials");
	buffer_write(buffer, buffer_u32, 0);
	buffer_write(buffer, buffer_string, "Meshes");
	buffer_write(buffer, buffer_u32, 1);
	buffer_write(buffer, buffer_string, "MeshData");
	
	// Write Mesh Data
	buffer_write(buffer, buffer_u16, mesh.vertexStride);
	buffer_write(buffer, buffer_u32, mesh.triangleCount);
	buffer_write(buffer, buffer_u32, mesh.vertexCount);
	
	// Write Vertex Buffer
	buffer_write(buffer, buffer_string, "VertexBuffer");
	buffer_write(buffer, buffer_u32, buffer_get_size(mesh.vertexBuffer));
	buffer_copy(mesh.vertexBuffer, 0, buffer_get_size(mesh.vertexBuffer), buffer, buffer_tell(buffer));
	buffer_seek(buffer, buffer_seek_relative, buffer_get_size(mesh.vertexBuffer));
	
	// Write Index Buffer
	buffer_write(buffer, buffer_string, "IndexBuffer");
	buffer_write(buffer, buffer_u32, buffer_get_size(mesh.indexBuffer));
	buffer_copy(mesh.indexBuffer, 0, buffer_get_size(mesh.indexBuffer), buffer, buffer_tell(buffer));
	buffer_seek(buffer, buffer_seek_relative, buffer_get_size(mesh.indexBuffer));
	
	// Buffer Save
	buffer_save(buffer, exportFile);
	buffer_delete(buffer);
}

#endregion