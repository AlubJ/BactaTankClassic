/// @desc Initialise BactaTank

// 3D Settings
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_tex_repeat(true);
gpu_set_tex_filter(true);
gpu_set_tex_mip_enable(mip_on);
gpu_set_tex_min_mip(0);
gpu_set_tex_max_mip(4);
gpu_set_tex_mip_bias(0);
gpu_set_tex_mip_filter(tf_anisotropic);

// Default Vertex Format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
vertex_format_add_colour();
global.vertexFormat = vertex_format_end();

// Billboard Vertex Format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
global.billboardFormat = vertex_format_end();

// Grid Vertex Format
vertex_format_begin();
vertex_format_add_position_3d();
global.gridFormat = vertex_format_end();

#region Platform Settings

// Base Window Size
global.screenWidth = window_get_width();
global.screenHeight = window_get_height();

// Window Settings
window_set_size(500, 600);
//window_set_clamp_size(global.screenWidth, global.screenHeight);

// Resize the surfaces
surface_resize(application_surface, global.screenWidth, global.screenHeight);
display_set_gui_size(global.screenWidth, global.screenHeight);

// Resize all rooms
for(var i = 0; room_exists(i); i++)
{
	room_set_width(i, global.screenWidth);
	room_set_height(i, global.screenHeight);
}

#endregion

#region Initialise Stuff

// Initialise BactaTank
initBactaTank();

// Create Cache Folder
global.tempDirectory = temp_directory + @"BactaTankClassic\_cache\";
directory_create(global.tempDirectory);

// Font
global.font = -1;

#endregion

#region BactaTank Settings

if (file_exists("settings.bin"))
{
	global.settings = snap_from_binary("settings.bin");
}
else
{
	global.settings = {
		// Advanced Options
		advancedOptions: false,
		defaultSkinning: false,
		cubeMapReplacement: false,
		
		// Other
		cameraSmooth: true,
		shading: true,
		AALevel: 4,
		useDifferentCacheLocation: false,
		watermark: "Made With BactaTank",
		version: 0.4,
	}
	
	snap_to_binary(global.settings, "settings.bin");
}

// AA
display_reset(global.settings.AALevel, true);

global.version = "v0.0.4";

global.openFileName = "TTGames Model (*.GHG)|*.ghg";
global.saveFileName = "TTGames Model (*.GHG)|*.ghg";

#endregion

#region Character Presets

var buffer = buffer_load("characterPresets/Presets.json");
global.characterPresets = snap_from_json(buffer_read(buffer, buffer_text)).presets;
buffer_delete(buffer);

#endregion

#region Project Settings

global.projects = [];

#endregion

#region Goto Next Scene

room_goto(scnMain);

#endregion