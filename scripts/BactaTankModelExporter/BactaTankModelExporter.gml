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
	
	for (var i = 0; i < array_length(modelStruct.nu20.textureMetaData); i++)
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
		
		buffer_copy(modelStruct.textures[textureMeta.index], 0, textureMeta.size, buffer, buffer_tell(buffer));
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
		if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20First)
		{
			buffer_poke(modelStruct.nu20.buffer, currentTexture.offset + 0x38, buffer_u32, currentTexture.compression);
			buffer_poke(modelStruct.nu20.buffer, currentTexture.offset + 0x44, buffer_u32, currentTexture.size);
		}
	}
	
	for (var i = 0; i < array_length(modelStruct.nu20.materials); i++)
	{
		// Variables
		var material = modelStruct.nu20.materials[i];
		var offset = material.offset;
		
		// Edit Material Data
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
		
		// NU20 First Material Colours
		if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20First)
		{
			buffer_poke(modelStruct.nu20.buffer, offset + 0xc8,    buffer_u8, floor(material.colour[0] * 255));
			buffer_poke(modelStruct.nu20.buffer, offset + 0xc9,    buffer_u8, floor(material.colour[1] * 255));
			buffer_poke(modelStruct.nu20.buffer, offset + 0xca,    buffer_u8, floor(material.colour[2] * 255));
			buffer_poke(modelStruct.nu20.buffer, offset + 0xcb,    buffer_u8, floor(material.colour[3] * 255));
		}
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
	if (string_lower(filename_ext(exportFile)) == ".btank") exportBactaTankMeshBtank(modelStruct, meshIndex, exportFile);
	if (string_lower(filename_ext(exportFile)) == ".obj") exportBactaTankMeshObj(modelStruct, meshIndex, exportFile);
}

#endregion

#region Export .btank Mesh

function exportBactaTankMeshBtank(modelStruct, meshIndex, exportFile)
{
	// Create Export Buffer
	var buffer = buffer_create(1, buffer_grow, 1);
	
	// Mesh
	var mesh = modelStruct.nu20.meshes[meshIndex];
	
	// Get Vertex Format
	var vertexFormat = decodeBactaTankVertexFormat(modelStruct.nu20.materials[getBactaTankMeshMaterial(modelStruct, meshIndex)].vertexFormat);
	
	// Write Header
	buffer_write(buffer, buffer_string, "BactaTank");
	buffer_write(buffer, buffer_string, "PCGHG");
	buffer_write(buffer, buffer_f32, 0.2);
	buffer_write(buffer, buffer_string, "Materials");
	buffer_write(buffer, buffer_u32, 0);
	buffer_write(buffer, buffer_string, "Meshes");
	buffer_write(buffer, buffer_u32, 1);
	buffer_write(buffer, buffer_string, "MeshData");
	
	// Write Mesh Data
	buffer_write(buffer, buffer_u32, mesh.triangleCount);
	buffer_write(buffer, buffer_u32, mesh.vertexCount);
	
	// Write Mesh Attributes
	buffer_write(buffer, buffer_string, "MeshAttributes");
	buffer_write(buffer, buffer_u32, 4);
	buffer_write(buffer, buffer_string, "Position");
	buffer_write(buffer, buffer_string, "Normal");
	buffer_write(buffer, buffer_string, "Colour");
	buffer_write(buffer, buffer_string, "UV");
	
	// Write Vertex Buffer
	buffer_write(buffer, buffer_string, "VertexBuffer");
	
	// Write Positions
	buffer_write(buffer, buffer_string, "Position");
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.position)
			{
				buffer_write(buffer, buffer_f32, -buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_f32));
				buffer_write(buffer, buffer_f32, buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 4, buffer_f32));
				buffer_write(buffer, buffer_f32, buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 8, buffer_f32));
			}
		}
	}
	
	// Write Normals
	buffer_write(buffer, buffer_string, "Normal");
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.normal)
			{
				buffer_write(buffer, buffer_u32, buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_u32));
			}
		}
	}
	
	// Write Colour
	buffer_write(buffer, buffer_string, "Colour");
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.colour)
			{
				buffer_write(buffer, buffer_u32, buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_u32));
			}
		}
	}
	
	// Write UVs
	buffer_write(buffer, buffer_string, "UV");
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.uv)
			{
				buffer_write(buffer, buffer_f32, buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_f32));
				buffer_write(buffer, buffer_f32, buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 4, buffer_f32));
			}
		}
	}
	
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

#region Export .obj Mesh

function exportBactaTankMeshObj(modelStruct, meshIndex, exportFile)
{
	// File String
	var fileString = "# BactaTank\no Mesh" + string(meshIndex) + "\n";
	
	// Mesh
	var mesh = modelStruct.nu20.meshes[meshIndex];
	 
	// Get Vertex Format
	var vertexFormat = decodeBactaTankVertexFormat(modelStruct.nu20.materials[getBactaTankMeshMaterial(modelStruct, meshIndex)].vertexFormat);
	
	// Write Vertex Positions
	fileString += "# Positions\n";
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.position)
			{
				fileString += "v ";
				fileString += string_format(-buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_f32), 1, 5) + " ";
				fileString += string_format(buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 4, buffer_f32), 1, 5) + " ";
				fileString += string_format(buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 8, buffer_f32), 1, 5) + "\n";
			}
		}
	}
	
	// Write Vertex Normals
	fileString += "# Normals\n";
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.normal)
			{
				fileString += "vn ";
				fileString += string_format((((buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_u8)/255)*2)-1), 1, 5) + " ";
				fileString += string_format((((buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 1, buffer_u8)/255)*2)-1), 1, 5) + " ";
				fileString += string_format((((buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 2, buffer_u8)/255)*2)-1), 1, 5) + "\n";
			}
		}
	}
	
	// Write Vertex Textures
	fileString += "# UVs\n";
	for (var i = 0; i < mesh.vertexCount; i++)
	{
		for (var j = 0; j < array_length(vertexFormat); j++)
		{
			if (vertexFormat[j].attribute == bactatankVertexAttributes.uv)
			{
				fileString += "vt ";
				fileString += string_format(buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_f32), 1, 5) + " ";
				fileString += string_format(1-buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 4, buffer_f32), 1, 5) + "\n";
			}
		}
	}
	
	// Write Faces
	fileString += "# Faces\n";
	for (var i = 0; i < mesh.triangleCount; i++)
	{
		// Get Indices
		var indices = [0, 0, 0];
		indices[0] = buffer_peek(mesh.indexBuffer, i * 2, buffer_u16);
		indices[1] = buffer_peek(mesh.indexBuffer, i * 2 + 2, buffer_u16);
		indices[2] = buffer_peek(mesh.indexBuffer, i * 2 + 4, buffer_u16);
		
		// Write Face
		if (i % 2 == 0)
		{
			fileString += "f " +
			string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + " " +
			string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + " " +
			string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + "\n";
		}
		else
		{
			fileString += "f " +
			string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + " " +
			string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + " " +
			string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + "\n";
		}
	}
	
	// Save Buffer
	var buffer = buffer_create(string_length(fileString), buffer_fixed, 1);
	buffer_write(buffer, buffer_text, fileString);
	buffer_save(buffer, exportFile);
	buffer_delete(buffer);
}

#endregion

#region Export .obj Model

function exportBactaTankObj(modelStruct, exportFile)
{
	// Material File String
	var materialFileString = "# BactaTank\n";
	
	// Loop Through Materials
	for (var i = 0; i < array_length(modelStruct.nu20.materials); i++)
	{
		// Current Material
		var material = modelStruct.nu20.materials[i];
		
		// Write Material
		materialFileString += "newmtl Mat" + string(i) + "\n";
		
		// Write Diffuse Colour
		materialFileString += "\tKa " + string_format(material.colour[0], 1, 3) + " " + string_format(material.colour[1], 1, 3) + " " + string_format(material.colour[2], 1, 3) + "\n";
		
		// Write Textures
		if (material.textureID != -1) materialFileString += "\tmap_Kd tex/tex" + string(material.textureID) + ".dds";
		if (material.normalID != -1) materialFileString += "\map_bump tex/tex" + string(material.normalID) + ".dds";
	}
	
	// Save Material Buffer
	var buffer = buffer_create(string_length(materialFileString), buffer_fixed, 1);
	buffer_write(buffer, buffer_text, materialFileString);
	buffer_save(buffer, string_split(exportFile + ".", ".")[0] + ".mtl");
	buffer_delete(buffer);
	
	// Object File String
	var objectFileString = "# BactaTank\n";
	
	// Loop Through Meshes
	for (var i = 0; i < array_length(modelStruct.nu20.meshes); i++)
	{
		// Mesh
		var mesh = modelStruct.nu20.meshes[i];
	 
		// Get Vertex Format
		var vertexFormat = decodeBactaTankVertexFormat(modelStruct.nu20.materials[getBactaTankMeshMaterial(modelStruct, i)].vertexFormat);
		
		objectFileString += "o Mesh" + string(i) + "\n";
		
		// Write Vertex Positions
		objectFileString += "# Mesh " + string(i) + " Positions\n";
		for (var i = 0; i < mesh.vertexCount; i++)
		{
			for (var j = 0; j < array_length(vertexFormat); j++)
			{
				if (vertexFormat[j].attribute == bactatankVertexAttributes.position)
				{
					objectFileString += "v ";
					objectFileString += string_format(-buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_f32), 1, 5) + " ";
					objectFileString += string_format(buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 4, buffer_f32), 1, 5) + " ";
					objectFileString += string_format(buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 8, buffer_f32), 1, 5) + "\n";
				}
			}
		}
	
		// Write Vertex Normals
		objectFileString += "# Mesh " + string(i) + " Normals\n";
		for (var i = 0; i < mesh.vertexCount; i++)
		{
			for (var j = 0; j < array_length(vertexFormat); j++)
			{
				if (vertexFormat[j].attribute == bactatankVertexAttributes.normal)
				{
					objectFileString += "vn ";
					objectFileString += string_format(((buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_u8)/255)*2)-1, 1, 5) + " ";
					objectFileString += string_format(((buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 1, buffer_u8)/255)*2)-1, 1, 5) + " ";
					objectFileString += string_format(((buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 2, buffer_u8)/255)*2)-1, 1, 5) + "\n";
				}
			}
		}
	
		// Write Vertex Textures
		objectFileString += "# Mesh " + string(i) + " UVs\n";
		for (var i = 0; i < mesh.vertexCount; i++)
		{
			for (var j = 0; j < array_length(vertexFormat); j++)
			{
				if (vertexFormat[j].attribute == bactatankVertexAttributes.uv)
				{
					objectFileString += "vt ";
					objectFileString += string_format(buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position, buffer_f32), 1, 5) + " ";
					objectFileString += string_format(1-buffer_peek(mesh.vertexBuffer, (i*mesh.vertexStride) + vertexFormat[j].position + 4, buffer_f32), 1, 5) + "\n";
				}
			}
		}
	
		// Write Faces
		objectFileString += "# Mesh " + string(i) + " Faces\n";
		for (var i = 0; i < mesh.triangleCount; i++)
		{
			// Get Indices
			var indices = [0, 0, 0];
			indices[0] = buffer_peek(mesh.indexBuffer, i * 2, buffer_u16);
			indices[1] = buffer_peek(mesh.indexBuffer, i * 2 + 2, buffer_u16);
			indices[2] = buffer_peek(mesh.indexBuffer, i * 2 + 4, buffer_u16);
		
			// Write Face
			if (i % 2 == 0)
			{
				objectFileString += "f " +
				string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + " " +
				string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + " " +
				string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + "\n";
			}
			else
			{
				objectFileString += "f " +
				string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + "/" + string(indices[2] - mesh.vertexCount) + " " +
				string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + "/" + string(indices[1] - mesh.vertexCount) + " " +
				string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + "/" + string(indices[0] - mesh.vertexCount) + "\n";
			}
		}
	}
	
	// Save Mesh Buffer
	var buffer = buffer_create(string_length(objectFileString), buffer_fixed, 1);
	buffer_write(buffer, buffer_text, objectFileString);
	buffer_save(buffer, exportFile);
	buffer_delete(buffer);
	
	// Export Textures
	for (var i = 0; i < array_length(modelStruct.textures); i++)
	{
		buffer_save(modelStruct.textures[i], filename_dir(exportFile) + "/tex/tex" + string(i) + ".dds");
	}
}

#endregion