/// @desc UI Controller

imGuiInit()

global.model = -1;
global.filename = "";

//var ts = time_source_create(time_source_game, 10, time_source_units_frames, function() {
//var startFile = parameter_string(1);
//if (file_exists(startFile))
//{
//	// Set Cursor To Wait
//	window_set_cursor(cr_hourglass);
	
//	// Get File Name
//	var split = string_split(startFile + @"\", @"\");
//	global.filename = split[array_length(split)-1];
					
//	// Load New Model
//	global.model = loadBactaTankModel(startFile);
					
//	// Change Window Title
//	window_set_caption(global.filename + " - BactaTank");
	
//	// Set Cursor Back To Normal
//	window_set_cursor(cr_default);
//}
//}, [], -1, time_source_expire_after);
//time_source_start(ts);

textureStruct = {
	presetSelected: -1,
	
	tabSelected: 0,
	
	textureSelected: -1,
	meshSelected: -1,
	meshSurface: -1,
	materialSelected: -1,
	
	homeConfirmation: false,
	
	toolSelected: "",
	
	fontCharacterSelected: -1,
	loadedFont: -1,
}

lastXPos = device_mouse_raw_x(0);
lastYPos = device_mouse_raw_y(0);
clicked = false;
clickedMove = false;
camera_dist = 0.5;
dir = 0;
look_pitch = 0;
z = 0;
view_mat = 0;
proj_mat = 0;

// Editor Grid
grid = vertex_create_buffer();

vertex_begin(grid, global.gridFormat);

vertex_position_3d(grid, -1, 0, 1);
vertex_position_3d(grid, 1, 0, 1);
vertex_position_3d(grid, 1, 0, 1);
vertex_position_3d(grid, 1, 0, -1);

for (var i = -10; i < 10; i++)
{
	vertex_position_3d(grid, i/10, 0, -1);
	vertex_position_3d(grid, i/10, 0, 1);
}

for (var i = -10; i < 10; i++)
{
	vertex_position_3d(grid, -1, 0, i/10);
	vertex_position_3d(grid, 1, 0, i/10);
}

vertex_end(grid);

// Set Size For Project Window
window_command_hook(window_command_maximize);
window_command_hook(window_command_resize);
window_command_set_active(window_command_maximize, false);
window_command_set_active(window_command_resize, false);