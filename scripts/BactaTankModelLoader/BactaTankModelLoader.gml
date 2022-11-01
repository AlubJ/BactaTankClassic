/*
	BactaTank Model Loader
	Loads TTGames' Models For Use Within BactaTank
	Written By Alub
*/

#region BactaTank Initialiser

function initBactaTank()
{
	// Model Version
	enum bactatankModelVersion
	{
		pcghgNU20Last,
		pcghgNU20First,
		none,
	}
	
	// Model Vertex Attributes
	enum bactatankVertexAttributes
	{
		position,
		normal,
		tangent,
		bitangent,
		colour,
		colour2,
		uv,
		blendIndices,
		blendWeights,
		lightDirection,
		lightColour,
	}
	global.__attributes = ["Position", "Normal", "Tangent", "BiTangent", "Colour", "Colour2", "UV", "BlendIndices", "BlendWeights", "LightDirection", "LightColour"];
	
	// Model Vertex Attributes
	enum bactatankVertexAttributeTypes
	{
		float2,
		float3,
		byte4,
		half2,
	}
	global.__attributeTypes = ["Float 2", "Float 3", "Byte 4", "Half 2"];
	
	// DXT Compressions
	global.DXTCompression = ["", "DXT1", "", "", "DXT3", "", "DXT5"];
	
	// Shader Settings
	#macro bactatankShaderLightDirection			shader_get_uniform(defaultShading, "lightDirection")
	#macro bactatankShaderLightColour				shader_get_uniform(defaultShading, "lightColour")
	#macro bactatankShaderBlendColour				shader_get_uniform(defaultShading, "colour")
	#macro bactatankShaderInvView					shader_get_uniform(defaultShading, "invView")
	#macro bactatankShaderShiny						shader_get_uniform(defaultShading, "shiny")
	#macro bactatankShaderUseTexture				shader_get_uniform(defaultShading, "useTexture")
	#macro bactatankShaderUseLighting				shader_get_uniform(defaultShading, "useLighting")
	#macro bactatankShaderUseNormalMap				shader_get_uniform(defaultShading, "useNormalMap")
	#macro bactatankShaderNormalMap					shader_get_sampler_index(defaultShading, "normalMap")
	#macro bactatankShaderCubeMap0					shader_get_sampler_index(defaultShading, "cubeMap0")
	#macro bactatankShaderCubeMap1					shader_get_sampler_index(defaultShading, "cubeMap1")
}

#endregion

#region Load Model

function loadBactaTankModel(model)
{
	// Model Struct
	var modelStruct = {  };
	
	// Load Model File Into Buffer
	var buffer = buffer_load(model);
	
	// Get And Check Model Version
	var modelVersion = getBactaTankModelVersion(buffer);
	if (modelVersion == bactatankModelVersion.none) return -1;
	variable_struct_set(modelStruct, "modelVersion", modelVersion)
	
	// Copy NU20 into separate buffer (NU20 isn't completely documented meaning we can't recreate it yet)
	var nu20Offset = buffer_tell(buffer);
	variable_struct_set(modelStruct, "nu20Offset", nu20Offset);
	var nu20Size = -buffer_peek(buffer, buffer_tell(buffer) + 4, buffer_u32);
	var nu20Buffer = buffer_create(nu20Size, buffer_fixed, 1);
	buffer_copy(buffer, buffer_tell(buffer), nu20Size, nu20Buffer, 0);
	
	// Read NU20
	var nu20 = readBactaTankNU20(buffer, modelVersion, buffer_tell(buffer));
	variable_struct_set(nu20, "buffer", nu20Buffer);
	variable_struct_set(modelStruct, "nu20", nu20);
	show_debug_message("<BactaTank Model Loader> NU20 Read!");
	
	// Seek either to the end of the NU20 or the start of the file depending on version
	if (modelVersion == bactatankModelVersion.pcghgNU20First) buffer_seek(buffer, buffer_seek_start, nu20Size + 4);
	else buffer_seek(buffer, buffer_seek_start, 6);
	
	// Read Textures
	var textures = readBactaTankTextures(buffer, modelStruct);
	variable_struct_set(modelStruct, "textures", textures[0]);
	variable_struct_set(modelStruct, "textureSprites", textures[1]);
	show_debug_message("<BactaTank Model Loader> Textures Read!");
	
	// Read Buffers
	var vertexBuffers = readBactaTankBuffers(buffer);
	var indexBuffers = readBactaTankBuffers(buffer);
	show_debug_message("<BactaTank Model Loader> Buffers Read!");
	
	// Link Meshes
	linkBactaTankMeshes(modelStruct, vertexBuffers, indexBuffers);
	show_debug_message("<BactaTank Model Loader> Meshes Linked!");
	
	// Delete Buffers
	for (var i = 0; i < array_length(vertexBuffers); i++) buffer_delete(vertexBuffers[i]);
	for (var i = 0; i < array_length(indexBuffers); i++) buffer_delete(indexBuffers[i]);
	
	// Generate VBOs
	generateBactaTankVBOs(modelStruct);
	show_debug_message("<BactaTank Model Loader> VBOs Generated!");
	
	// Delete Buffer
	buffer_delete(buffer);
	
	// Return Model Struct
	return modelStruct;
}

#endregion

#region Model Version

function getBactaTankModelVersion(buffer)
{
	// Read First int (Could be either 808605006 (NU20) or the offset to the NU20)
	var NU20 = buffer_read(buffer, buffer_u32);
	
	// Check for NU20 first (Batman & Indy models)
	if (NU20 == 808605006)
	{
		// Seek to the start of the nu20
		buffer_seek(buffer, buffer_seek_relative, -4);
		
		// Return Model Version
		return bactatankModelVersion.pcghgNU20First;
	}
	else
	{
		// Check if seek offset is within the size of the buffer
		if (NU20 + 4 > buffer_get_size(buffer)) return bactatankModelVersion.none;
		
		// Seek forward value of NU20 and check for NU20 there
		buffer_seek(buffer, buffer_seek_relative, NU20);
		
		// Check for NU20 last (TCS)
		NU20 = buffer_read(buffer, buffer_u32);
		if (NU20 == 808605006)
		{
			// Seek to the start of the nu20
			buffer_seek(buffer, buffer_seek_relative, -4);
			
			// Return Model Version
			return bactatankModelVersion.pcghgNU20Last;
		}
	}
	
	// Return Model Version None regardless
	return bactatankModelVersion.none;
}

#endregion

#region Read NU20

function readBactaTankNU20(buffer, modelVersion, nu20Offset)
{
	// NU20 Struct
	var nu20 = {  };
	
	// Goto GSNH
	buffer_seek(buffer, buffer_seek_relative, 0x1c);
	buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32)); // In future -4 from the buffer_read return
	
	// GSNH Offset
	var gsnhOffset = buffer_tell(buffer);
	
	// Texture Count
	var textureCount = buffer_read(buffer, buffer_u32);
	variable_struct_set(nu20, "textureCount", textureCount);
	
	// Texture MetaData
	var textureMetaData = [];
	buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) - 4);
	
	var currentTexture = 0;
	
	show_debug_message("<BactaTank Model Loader> Reading " + string(textureCount) + " Textures");
	
	for (var i = 0; i < textureCount; i++)
	{
		// Seek to texture entry
		var tempOffset = buffer_tell(buffer) + 4;
		buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) - 4);
		
		// Texture Metadata
		var textureOffset = buffer_tell(buffer) - nu20Offset;
		
		var textureWidth = buffer_read(buffer, buffer_u32);
		var textureHeight = buffer_read(buffer, buffer_u32);
		var textureCompression = 0;
		var textureSize = 0;
		var textureIsCubemap = false;
		
		// NU20 Last MetaData
		if (modelVersion == bactatankModelVersion.pcghgNU20First)
		{
			// Seek to cubemap
			buffer_seek(buffer, buffer_seek_relative, 0x2c);
			textureIsCubemap = buffer_read(buffer, buffer_u32);
			
			// Check If Texture Is Cubemap Or Not
			if (textureIsCubemap)
			{
				tempOffset = tempOffset + 20;
			}
			
			// Read DXT Compression
			textureCompression = buffer_read(buffer, buffer_u32);
			
			// Seek to size
			buffer_seek(buffer, buffer_seek_relative, 0x08);
			textureSize = buffer_read(buffer, buffer_u32);
		}
		else
		{
			if (textureWidth == 0)
			{
				i += 4;
				textureMetaData[currentTexture-1].isCubemap = true;
				buffer_seek(buffer, buffer_seek_start, tempOffset + 16);
				continue;
			}
		}
		
		// Texture Struct
		textureMetaData[currentTexture] = {
			index:			i,
			offset:			textureOffset,
			width:			textureWidth,
			height:			textureHeight,
			compression:	textureCompression,
			size:			textureSize,
			isCubemap:		textureIsCubemap,
		}
		
		// Increase Current Texture Index
		if (textureIsCubemap) i += 5;
		currentTexture++;
		
		// Seek back to start
		buffer_seek(buffer, buffer_seek_start, tempOffset);
	}
	
	// Add texture metadata to NU20 struct
	variable_struct_set(nu20, "textureMetaData", textureMetaData);
	
	// Goto GSNH
	buffer_seek(buffer, buffer_seek_start, gsnhOffset + 0x08);
	
	// Material Count
	var materialCount = buffer_peek(buffer, gsnhOffset + 0x0c, buffer_u32);
	
	// Material
	var materials = [];
	buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) - 4);
	
	show_debug_message("<BactaTank Model Loader> Reading " + string(materialCount) + " Materials");
	
	var lastVF = 0;
	
	// Materials
	for (var i = 0; i < materialCount; i++)
	{
		// Seek to texture entry
		var tempOffset = buffer_tell(buffer) + 4;
		buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) - 4);
		
		// Get Offset
		var materialOffset = buffer_tell(buffer) - nu20Offset;
		
		// Read Material Things
		var materialAlphaBlend = buffer_peek(buffer, buffer_tell(buffer) + 0x40, buffer_u32);
		var materialColourRed = buffer_peek(buffer, buffer_tell(buffer) + 0x54, buffer_f32);
		var materialColourGreen = buffer_peek(buffer, buffer_tell(buffer) + 0x58, buffer_f32);
		var materialColourBlue = buffer_peek(buffer, buffer_tell(buffer) + 0x5c, buffer_f32);
		var materialColourAlpha = buffer_peek(buffer, buffer_tell(buffer) + 0x60, buffer_f32);
		var materialTextureID = buffer_peek(buffer, buffer_tell(buffer) + 0x74, buffer_s16);
		var materialNormalID = buffer_peek(buffer, buffer_tell(buffer) + 0xB4 + 0x4C, buffer_s32);
		var materialShineID = buffer_peek(buffer, buffer_tell(buffer) + 0xB4 + 0x54, buffer_s32);
		var materialVertexFormat = buffer_peek(buffer, buffer_tell(buffer) + 0xB4 + 0x13c, buffer_u32);
		var materialShaderFlags = buffer_peek(buffer, buffer_tell(buffer) + 0xB4 + 0x1b8, buffer_u32);
		
		// Material Array
		materials[i] = {
			colour:				[materialColourRed, materialColourGreen, materialColourBlue, materialColourAlpha],
			textureID:			materialTextureID,
			normalID:			materialNormalID,
			shineID:			materialShineID,
			vertexFormat:		materialVertexFormat,
			shaderFlags:		materialShaderFlags,
			alphaBlend:			materialAlphaBlend,
			offset:				materialOffset,
		}
		
		// Seek back to start
		buffer_seek(buffer, buffer_seek_start, tempOffset);
	}
	
	// Add Materials to NU20 struct
	variable_struct_set(nu20, "materials", materials);
	
	// Goto GSNH
	buffer_seek(buffer, buffer_seek_start, gsnhOffset + 0x1cc);
	buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) + 0x10);
	
	// Mesh List
	var meshes = [];
	var meshCount = buffer_read(buffer, buffer_u32);
	buffer_seek(buffer, buffer_seek_relative, 0x08);
	
	show_debug_message("<BactaTank Model Loader> Reading " + string(meshCount) + " Meshes");
	
	// Mesh Loop
	for (var i = 0; i < meshCount; i++)
	{
		// Seek to texture entry
		var tempOffset = buffer_tell(buffer) + 4;
		buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) - 4);
		
		// Get Offset
		var meshOffset = buffer_tell(buffer) - nu20Offset;
		
		// Read Mesh Data
		var meshType = buffer_read(buffer, buffer_u32);
		var meshTriangleCount = buffer_read(buffer, buffer_u32);
		var meshVertexStride = buffer_read(buffer, buffer_u16);
		var meshBones = [];
		repeat(8) array_push(meshBones, buffer_read(buffer, buffer_s8));
		var meshFlags = buffer_read(buffer, buffer_u16); // Unused Within NU2 (We are using it to store some extra mesh data flags)
		var meshVertexOffset = buffer_read(buffer, buffer_u32);
		var meshVertexCount = buffer_read(buffer, buffer_u32);
		var meshIndexOffset = buffer_read(buffer, buffer_u32);
		var meshIndexBufferID = buffer_read(buffer, buffer_u32);
		var meshVertexBufferID = buffer_read(buffer, buffer_u32);
		
		// Add To Meshes Array
		meshes[i] = {
			offset:			meshOffset,
			type:			meshType,
			bones:			meshBones,
			flags:			meshFlags,
			vertexStride:	meshVertexStride,
			vertexOffset:	meshVertexOffset,
			vertexCount:	meshVertexCount,
			vertexBufferID: meshVertexBufferID,
			triangleCount:	meshTriangleCount,
			indexOffset:	meshIndexOffset,
			indexBufferID:	meshIndexBufferID,
			indexBuffer: buffer_create((meshTriangleCount + 2) * 2, buffer_fixed, 1),
			vertexBuffer: buffer_create(meshVertexCount * meshVertexStride, buffer_fixed, 1),
			vertexBufferObject: noone,
		}
		
		// Seek back to start
		buffer_seek(buffer, buffer_seek_start, tempOffset);
	}
	
	// Add Meshes to NU20 struct
	variable_struct_set(nu20, "meshes", meshes);
		
	// Read Bones
	buffer_seek(buffer, buffer_seek_start, gsnhOffset + 0x164);
	var boneCount = buffer_read(buffer, buffer_s32);
		
	// Read Layers
	buffer_seek(buffer, buffer_seek_start, gsnhOffset + 0x18c);
	var layers = readBactaTankLayers(buffer, boneCount);
	
	// Add Layers To NU20
	variable_struct_set(nu20, "layers", layers);
	
	// Return NU20 Struct
	return nu20;
}

#endregion

#region Read Layers

function readBactaTankLayers(buffer, boneCount)
{
	// Variables
	var currentMesh = -1;
	var layers = [];
	
	// Layer Count
	var layerCount = buffer_read(buffer, buffer_s32);
	
	show_debug_message("<BactaTank Model Loader> Reading " + string(layerCount) + " Layers");
	
	// Seek to layer entry
	buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_u32) - 4);
	
	// Loop though the layers
	for (var i = 0; i < layerCount; i++)
	{
		var tempOffset = buffer_tell(buffer);
		var layerMeshes = [];
		var mesh = 0;
		
		// Layer Name
		buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // Pointer to layer name
		var layerName = buffer_read(buffer, buffer_string);
		if (layerName == "") layerName = "TT" + string(i) + "_None";
		
		// Static 1
		buffer_seek(buffer, buffer_seek_start, tempOffset + 4);
		var layerStatic1 = buffer_read(buffer, buffer_s32);
		if (layerStatic1 != 0)
		{
			buffer_seek(buffer, buffer_seek_relative, layerStatic1-4); // Layer pointer 1 (static)
			for (var j = 0; j < boneCount; j++)
			{
				var temp = buffer_read(buffer, buffer_s32);
				if (temp != 0)
				{
					var tempStatic = buffer_tell(buffer);
					buffer_seek(buffer, buffer_seek_relative, temp-4); // Layer pointer 1 (static)
					buffer_seek(buffer, buffer_seek_relative, 8);
					buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // Matrix
					buffer_seek(buffer, buffer_seek_relative, 0xb0);
					buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // layerMeshCount
					var layerMeshCount = buffer_read(buffer, buffer_s32);
					buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // materials
					
					var readMat = layerMeshCount;
					var readMatOffset = buffer_tell(buffer);
					for (var m = 0; m < layerMeshCount; m++)
					{
						var layerMaterial = buffer_peek(buffer, readMatOffset + (readMat * 4) - 4, buffer_s32);
						
						readMat--;
						currentMesh++;
				
						layerMeshes[mesh] = {
							mesh: currentMesh,
							material: layerMaterial,
							bone: j,
						}
						mesh++;
					}
					buffer_seek(buffer, buffer_seek_start, tempStatic);
				}
			}
		}
		
		// Skinned 1
		buffer_seek(buffer, buffer_seek_start, tempOffset + 8);
		var layerSkinned1 = buffer_read(buffer, buffer_s32);
		if (layerSkinned1 != 0)
		{
			buffer_seek(buffer, buffer_seek_relative, layerSkinned1-4); // Layer pointer 1 (static)
			buffer_seek(buffer, buffer_seek_relative, 8);
			buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // Matrix
			buffer_seek(buffer, buffer_seek_relative, 0xb0);
			buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // layerMeshCount
			var layerMeshCount = buffer_read(buffer, buffer_s32);
			buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // materials
			
			var readMat = layerMeshCount;
			var readMatOffset = buffer_tell(buffer);
			for (var m = 0; m < layerMeshCount; m++)
			{
				var layerMaterial = buffer_peek(buffer, readMatOffset + (readMat * 4) - 4, buffer_s32);
						
				readMat--;
				currentMesh++;
				
				layerMeshes[mesh] = {
					mesh: currentMesh,
					material: layerMaterial,
					bone: -1,
				}
				mesh++;
			}
			
		}
		
		// Static 2
		buffer_seek(buffer, buffer_seek_start, tempOffset + 12);
		var layerStatic2 = buffer_read(buffer, buffer_s32);
		if (layerStatic2 != 0)
		{
			buffer_seek(buffer, buffer_seek_relative, layerStatic2-4); // Layer pointer 1 (static)
			for (var j = 0; j < boneCount; j++)
			{
				var temp = buffer_read(buffer, buffer_s32);
				if (temp != 0)
				{
					buffer_seek(buffer, buffer_seek_relative, temp-4); // Layer pointer 1 (static)
					buffer_seek(buffer, buffer_seek_relative, 8);
					buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // Matrix
					buffer_seek(buffer, buffer_seek_relative, 0xb0);
					buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // layerMeshCount
					var layerMeshCount = buffer_read(buffer, buffer_s32);
					buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // materials
			
					var readMat = layerMeshCount;
					var readMatOffset = buffer_tell(buffer);
					for (var m = 0; m < layerMeshCount; m++)
					{
						var layerMaterial = buffer_peek(buffer, readMatOffset + (readMat * 4) - 4, buffer_s32);
						
						readMat--;
						currentMesh++;
				
						layerMeshes[mesh] = {
							mesh: currentMesh,
							material: layerMaterial,
							bone: j,
						}
						mesh++;
					}
				}
			}
		}
		
		// Skinned 2
		buffer_seek(buffer, buffer_seek_start, tempOffset + 16);
		var layerSkinned2 = buffer_read(buffer, buffer_s32);
		if (layerSkinned2 != 0)
		{
			buffer_seek(buffer, buffer_seek_relative, layerSkinned2-4); // Layer pointer 1 (static)
			buffer_seek(buffer, buffer_seek_relative, 8);
			buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // Matrix
			buffer_seek(buffer, buffer_seek_relative, 0xb0);
			buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // layerMeshCount
			var layerMeshCount = buffer_read(buffer, buffer_s32);
			buffer_seek(buffer, buffer_seek_relative, buffer_read(buffer, buffer_s32)-4); // materials
			
			var readMat = layerMeshCount;
			var readMatOffset = buffer_tell(buffer);
			for (var m = 0; m < layerMeshCount; m++)
			{
				var layerMaterial = buffer_peek(buffer, readMatOffset + (readMat * 4) - 4, buffer_s32);
						
				readMat--;
				currentMesh++;
				
				layerMeshes[mesh] = {
					mesh: currentMesh,
					material: layerMaterial,
					bone: -1,
				}
				mesh++;
			}
		}
		
		// Set Layer
		layers[i] = {
			name: layerName,
			meshes: layerMeshes,
		}
		
		// Seek Forward To Next Layer
		buffer_seek(buffer, buffer_seek_start, tempOffset + 20);
	}
	
	// Return Layers
	return layers;
}

#endregion

#region Read Textures

function readBactaTankTextures(buffer, modelStruct)
{
	show_debug_message("<BactaTank Model Loader> Loading " + string(array_length(modelStruct.nu20.textureMetaData)) + " Textures");
	
	// Textures Array
	var textures = array_create(64, -1);
	var textureSprites = array_create(64, -1);
	
	// Textures Loop
	for (var i = 0; i < array_length(modelStruct.nu20.textureMetaData); i++)
	{
		var textureSize = modelStruct.nu20.textureMetaData[i].size;
		if (modelStruct.modelVersion == bactatankModelVersion.pcghgNU20Last)
		{
			// Texture Meta Data
			var textureWidth = buffer_read(buffer, buffer_s32);
			var textureHeight = buffer_read(buffer, buffer_s32);
			buffer_seek(buffer, buffer_seek_relative, 0x0c)
			textureSize = buffer_read(buffer, buffer_u32);
			if (textureWidth < 0) textureWidth = -textureWidth;
			
			// Replace metadata
			modelStruct.nu20.textureMetaData[i].width = textureWidth;
			modelStruct.nu20.textureMetaData[i].height = textureHeight;
			modelStruct.nu20.textureMetaData[i].size = textureSize;
			modelStruct.nu20.textureMetaData[i].compression = array_get_index(global.DXTCompression, buffer_peek(buffer, buffer_tell(buffer)+0x54, buffer_string));
		}
		
		// Texture Buffer
		textures[modelStruct.nu20.textureMetaData[i].index] = buffer_create(textureSize, buffer_fixed, 1);
		buffer_copy(buffer, buffer_tell(buffer), textureSize, textures[modelStruct.nu20.textureMetaData[i].index], 0);
		
		// Get Textures File Name For Saving
		var name = buffer_sha1(textures[modelStruct.nu20.textureMetaData[i].index], 0, textureSize);
		modelStruct.nu20.textureMetaData[i].file = global.tempDirectory + name;
		
		// Convert DDS to PNG
		var sprite;
		if (!file_exists(global.tempDirectory + @"\_textures\" + name + ".png"))
		{
			sprite = readBactaTankTexture(textures[modelStruct.nu20.textureMetaData[i].index]);
			sprite_save(sprite, 0, global.tempDirectory + @"\_textures\" + name + ".png");
		}
		else
		{
			sprite = sprite_add(global.tempDirectory + @"\_textures\" + name + ".png", 1, false, false, 0, 0);
		}
		
		// Add Sprite
		textureSprites[modelStruct.nu20.textureMetaData[i].index] = sprite;
		
		// Seek Forward Past Texture
		buffer_seek(buffer, buffer_seek_relative, textureSize);
	}
	
	// Return Textures
	return [textures, textureSprites];
}

#endregion

#region Read Buffers (Vertex/Index)

function readBactaTankBuffers(buffer)
{
	// Buffers Array
	var buffers = [];
	
	// Buffer Count
	var bufferCount = buffer_read(buffer, buffer_u16);
	
	// Loop through Buffers
	for (var i = 0; i < bufferCount; i++)
	{
		// Buffer Size
		var bufferSize = buffer_read(buffer, buffer_u32);
		
		// Copy Buffer into new buffer
		buffers[i] = buffer_create(bufferSize, buffer_fixed, 1);
		buffer_copy(buffer, buffer_tell(buffer), bufferSize, buffers[i], 0);
		buffer_seek(buffer, buffer_seek_relative, bufferSize);
	}
	
	// Return Buffer Array
	return buffers;
}

#endregion

#region Link Meshes With Buffers

function linkBactaTankMeshes(modelStruct, vertexBuffers, indexBuffers)
{
	for (var i = 0; i < array_length(modelStruct.nu20.meshes); i++)
	{
		buffer_copy(vertexBuffers[modelStruct.nu20.meshes[i].vertexBufferID], modelStruct.nu20.meshes[i].vertexOffset * modelStruct.nu20.meshes[i].vertexStride, modelStruct.nu20.meshes[i].vertexCount * modelStruct.nu20.meshes[i].vertexStride, modelStruct.nu20.meshes[i].vertexBuffer, 0);
		buffer_copy(indexBuffers[modelStruct.nu20.meshes[i].indexBufferID], modelStruct.nu20.meshes[i].indexOffset*2, (modelStruct.nu20.meshes[i].triangleCount + 2) * 2, modelStruct.nu20.meshes[i].indexBuffer, 0);
	}
}

#endregion

#region Generate Vertex Buffer Objects

function generateBactaTankVBOs(modelStruct)
{
	for (var i = 0; i < array_length(modelStruct.nu20.meshes); i++)
	{
		// Get Mesh And Skip If Null Mesh
		var mesh = modelStruct.nu20.meshes[i];
		if (mesh.triangleCount == 0 || mesh.vertexCount == 0)
		{
			mesh.vertexBufferObject = -1;
			continue;
		}
		
		// Get Vertex Format
		var material = getBactaTankMeshMaterial(modelStruct, i);
		var vertexFormat = [];
		if (material != -1)	vertexFormat = decodeBactaTankVertexFormat(modelStruct.nu20.materials[material].vertexFormat);
		
		// Vertex Buffer
		var currentVertexBuffer = noone;
		
		var timer = get_timer();
		
		// Get Cached Mesh If Possible
		var name = sha1_string_utf8(buffer_sha1(mesh.vertexBuffer, 0, buffer_get_size(mesh.vertexBuffer)) + buffer_sha1(mesh.indexBuffer, 0, buffer_get_size(mesh.indexBuffer))) + ".mesh";
		if (file_exists(global.tempDirectory + @"\_meshes\" + name))
		{
			var cachedMesh = buffer_load(global.tempDirectory + @"\_meshes\" + name);
			currentVertexBuffer = vertex_create_buffer_from_buffer(cachedMesh, global.vertexFormat);
		}
		else
		{
			// Create Vertex Buffer
			currentVertexBuffer = vertex_create_buffer();
			vertex_begin(currentVertexBuffer, global.vertexFormat);
		
			// Build VBO
			for (var j = 0; j < mesh.triangleCount+2; j++)
			{
				var index = buffer_peek(mesh.indexBuffer, j*2, buffer_u16);
				var pos = array_create(3, 0);
				var norm = array_create(3, 0);
				var tex = array_create(2, 0);
				var col = 0;
				for (var k = 0; k < array_length(vertexFormat); k++)
				{
					switch (vertexFormat[k].attribute)
					{
						case bactatankVertexAttributes.position:
							pos = [-buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position, buffer_f32),
								   buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 4, buffer_f32),
								   buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 8, buffer_f32)];
							break;
						case bactatankVertexAttributes.normal:
							norm = [((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position, buffer_u8)/255)*2)-1,
								   ((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 1, buffer_u8)/255)*2)-1,
								   ((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 2, buffer_u8)/255)*2)-1];
							break;
						case bactatankVertexAttributes.uv:
							tex = [buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position, buffer_f32),
									buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 4, buffer_f32)];
							break;
						case bactatankVertexAttributes.colour:
							col = make_colour_rgb(
									buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position, buffer_u8),
									buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 1, buffer_u8),
									buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + vertexFormat[k].position + 2, buffer_u8));
							break;
					}
				}
				
				if (array_length(vertexFormat) == 0)
				{
					pos = [-buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index), buffer_f32),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 4, buffer_f32),
							buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 8, buffer_f32)];
					norm = [((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 12, buffer_u8)/255)*2)-1,
							((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 13, buffer_u8)/255)*2)-1,
							((buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 14, buffer_u8)/255)*2)-1];
					if (mesh.vertexStride == 28)
			        {
			            tex = [buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 20, buffer_f32),
								buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 24, buffer_f32)];
			        }
			        else if (mesh.vertexStride == 36 || mesh.vertexStride == 44)
			        {
			            tex = [buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 28, buffer_f32),
								buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 32, buffer_f32)];
			        }
			        else if (mesh.vertexStride == 32 || mesh.vertexStride == 40)
			        {
			            tex = [buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 24, buffer_f32),
								buffer_peek(mesh.vertexBuffer, (mesh.vertexStride * index) + 28, buffer_f32)];
			        }
				}
			
				vertex_position_3d(currentVertexBuffer, pos[0], pos[1], pos[2]);
				vertex_normal(currentVertexBuffer, norm[0], norm[1], norm[2]);
				vertex_texcoord(currentVertexBuffer, tex[0], tex[1]);
				vertex_colour(currentVertexBuffer, #ffffff, 1);
			}
		
			vertex_end(currentVertexBuffer);
			
			// Cache Vertex Buffer
			var cachedMesh = buffer_create_from_vertex_buffer(currentVertexBuffer, buffer_fixed, 1);
			buffer_save(cachedMesh, global.tempDirectory + @"\_meshes\" + name);
			buffer_delete(cachedMesh);
		}
		
		show_debug_message("Mesh " + string(i) + " took " + string((get_timer() - timer) / 1000) + "ms to generate a VBO");
		
		// Freeze VBO For Better Performance
		vertex_freeze(currentVertexBuffer);
		
		mesh.vertexBufferObject = currentVertexBuffer;
		
		//for (var j = 0; j < array_length(model.meshes[i].dynamicBuffers); j++)
		//{
		//	var vertexBuffer = buffer_create_from_vertex_buffer(currentVertexBuffer, buffer_fixed, 1);
		//	for (var k = 0; k < model.meshes[i].vertexCount; k++)
		//	{
		//		buffer_poke(vertexBuffer, k*model.meshes[i].vertexSize, buffer_f32, buffer_peek(model.meshes[i].dynamicBuffers[j], k*3, buffer_f32));
		//		buffer_poke(vertexBuffer, k*model.meshes[i].vertexSize+4, buffer_f32, buffer_peek(model.meshes[i].dynamicBuffers[j], k*3+4, buffer_f32));
		//		buffer_poke(vertexBuffer, k*model.meshes[i].vertexSize+8, buffer_f32, buffer_peek(model.meshes[i].dynamicBuffers[j], k*3+8, buffer_f32));
		//	}
		//	model.meshes[i].dynamicBuffers[j] = vertex_create_buffer_from_buffer(vertexBuffer, VERTEX_FORMAT);
		//	buffer_delete(vertexBuffer);
		//}
		
	}
}

#endregion

#region Destroy Model

function destroyBactaTankModel(modelStruct)
{
	// Destroy NU20
	buffer_delete(modelStruct.nu20.buffer);
	
	// Delete Textures
	for (var i = 0; i < array_length(modelStruct.textures); i++)
	{
		if (modelStruct.textures[i] == -1 || modelStruct.textureSprites[i] == -1) continue;
		buffer_delete(modelStruct.textures[i]);
		sprite_delete(modelStruct.textureSprites[i]);
	}
	
	// Delete Meshes
	for (var i = 0; i < array_length(modelStruct.nu20.meshes); i++)
	{
		buffer_delete(modelStruct.nu20.meshes[i].vertexBuffer);
		buffer_delete(modelStruct.nu20.meshes[i].indexBuffer);
		if (modelStruct.nu20.meshes[i].vertexBufferObject != -1) vertex_delete_buffer(modelStruct.nu20.meshes[i].vertexBufferObject);
	}
}

#endregion

#region Draw Mesh

function drawBactaTankMesh(modelStruct, meshIndex)
{
	// Current Mesh
	var mesh = modelStruct.nu20.meshes[meshIndex];
	
	// Material
	var material = getBactaTankMeshMaterial(modelStruct, meshIndex);
	
	var texture = -1;
	var normal = -1;
	if (material != -1 && modelStruct.nu20.materials[material].textureID != -1 && modelStruct.nu20.materials[material].textureID < array_length(modelStruct.textureSprites)) texture = sprite_get_texture(modelStruct.textureSprites[modelStruct.nu20.materials[material].textureID], 0);
	if (material != -1 && modelStruct.nu20.materials[material].normalID != -1 && modelStruct.nu20.materials[material].normalID < array_length(modelStruct.textureSprites)) normal = sprite_get_texture(modelStruct.textureSprites[modelStruct.nu20.materials[material].normalID], 0);
		
	// Shading
	shader_set(defaultShading);
	
	// Shader Flags
	shader_set_uniform_f(bactatankShaderUseNormalMap, (modelStruct.nu20.materials[material].shaderFlags & 1) >= 1);
	shader_set_uniform_f(bactatankShaderShiny, (modelStruct.nu20.materials[material].shaderFlags & 8) >= 1);
	shader_set_uniform_f(bactatankShaderUseLighting, (modelStruct.nu20.materials[material].shaderFlags & 4096) >= 1);
	
	// Shader Lighting
	shader_set_uniform_f(bactatankShaderLightDirection, 1, -1, 1);
	shader_set_uniform_f(bactatankShaderLightColour, .9, .9, .9, 1);
	
	// Shader Blend Colour
	if (texture == -1) shader_set_uniform_f(bactatankShaderBlendColour, modelStruct.nu20.materials[material].colour[0], modelStruct.nu20.materials[material].colour[1], modelStruct.nu20.materials[material].colour[2], 1);
	else shader_set_uniform_f(bactatankShaderBlendColour, 1, 1, 1, 1);
	
	// Set Inverse View Matrix
	shader_set_uniform_matrix_array(bactatankShaderInvView, inverse_matrix(matrix_get(matrix_view)));
	
	// Shader Textures
	texture_set_stage(bactatankShaderCubeMap0, sprite_get_texture(cubemapShine, 0));
	texture_set_stage(bactatankShaderCubeMap1, sprite_get_texture(cubemapBlack, 0));
	if (normal != -1) texture_set_stage(bactatankShaderNormalMap, normal);
	
	// Backface Culling
	//if (modelStruct.nu20.materials[material].alphaBlend & 8192) gpu_set_cullmode(cull_noculling);
	//else if (modelStruct.nu20.materials[material].alphaBlend & 4096) gpu_set_cullmode(cull_counterclockwise);
	//else gpu_set_cullmode(cull_clockwise);
	
	// Submit Mesh
	if (mesh.vertexBufferObject != -1) vertex_submit(mesh.vertexBufferObject, pr_trianglestrip, texture);
	
	// Reset Backface Culling
	gpu_set_cullmode(cull_noculling);
	
	// Reset Shader
	shader_reset();
}

#endregion