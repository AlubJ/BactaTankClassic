/// @desc Window Rescale
global.screenWidth = window_get_width();
global.screenHeight = window_get_height();
if (surface_exists(application_surface) && window_has_focus()) surface_resize(application_surface, global.screenWidth, global.screenHeight);
display_set_gui_size(global.screenWidth, global.screenHeight);
room_width = global.screenWidth;
room_height = global.screenHeight;


// Draw To Surface
if (global.model == -1) exit;

// Create Surface If It Doesnt Exist
//if (!surface_exists(uiController.viewerSurface)) uiController.viewerSurface = surface_create(floor(global.screenWidth/2)-18, floor(global.screenHeight/4 * 3) - 39);
//surface_set_target(uiController.viewerSurface);
if (!surface_exists(textureStruct.meshSurface)) textureStruct.meshSurface = surface_create(202, 202);
surface_set_target(textureStruct.meshSurface);

// Background Colour
draw_clear_alpha(c_black, 0);

// Mouse Controls In Viewer Window
//if (point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), floor(global.screenWidth/4)+9, 30, floor(global.screenWidth/4) + floor(global.screenWidth/2) - 9, floor(global.screenHeight/4 * 3) - 9))
if (point_in_rectangle(window_mouse_get_x(), window_mouse_get_y(), 12, 370, 12+202, 370+202))
{
	// Orbit Camera Toggle
	if (device_mouse_check_button_pressed(0, mb_left))
	{
		lastXPos = device_mouse_raw_x(0);
		lastYPos = device_mouse_raw_y(0);
		clicked = true;
	}
	
	// Pan Camera Toggle
	if (device_mouse_check_button_pressed(0, mb_right))
	{
		lastXPos = device_mouse_raw_x(0);
		lastYPos = device_mouse_raw_y(0);
		clickedMove = true;
	}
	
	// Zoom in and out
	if (mouse_wheel_up()) camera_distPre -= camera_distPre / 4;
	if (mouse_wheel_down()) camera_distPre += camera_distPre / 3;
}

// Orbit Camera
if (device_mouse_check_button(0, mb_left) && clicked)
{
	dirPre += (lastXPos - device_mouse_raw_x(0))/2;
	look_pitchPre += (lastYPos - device_mouse_raw_y(0))/2;
	look_pitchPre = clamp(look_pitchPre, -89.999, 89.999);
			
	lastXPos = device_mouse_raw_x(0);
	lastYPos = device_mouse_raw_y(0);
}

// Orbit Camera Untoggle
if (device_mouse_check_button_released(0, mb_left)) clicked = false;

// Pan Camera
if (device_mouse_check_button(0, mb_right) && clickedMove)
{
	xPre += dsin(dir) * (lastXPos - device_mouse_raw_x(0))/1000;
	yPre += dcos(dir) * (lastXPos - device_mouse_raw_x(0))/1000;
	zPre -= dcos(look_pitch) * (lastYPos - device_mouse_raw_y(0))/1000;
			
	lastXPos = device_mouse_raw_x(0);
	lastYPos = device_mouse_raw_y(0);
}

// Pan Camera Untoggle
if (device_mouse_check_button_released(0, mb_right)) clickedMove = false;

// Clamp Values
camera_distPre = clamp(camera_distPre, 0.05, 2);
zPre = clamp(zPre, -1, 1);
yPre = clamp(yPre, -1, 1);
xPre = clamp(xPre, -1, 1);

// Smooth
if (global.settings.cameraSmooth)
{
	camera_dist += (camera_distPre - camera_dist) / 8;
	dir += (dirPre - dir) / 4;
	look_pitch += (look_pitchPre - look_pitch) / 4;
	x += (xPre - x) / 4;
	y += (yPre - y) / 4;
	z += (zPre - z) / 4;
}
else
{
	camera_dist = camera_distPre;
	dir = dirPre;
	look_pitch = look_pitchPre;
	x = xPre;
	y = yPre;
	z = zPre;
}

// Point camera in 3rd person
var xto = x;
var yto = z;
var zto = y;
var xfrom = xto - camera_dist * dcos(dir) * dcos(look_pitch);
var zfrom = zto + camera_dist * dsin(dir) * dcos(look_pitch);
var yfrom = yto - camera_dist * dsin(look_pitch);

// Do the camera
var camera = camera_get_active();
view_mat = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, -1, 0);
//proj_mat = matrix_build_projection_perspective_fov(60, (floor(global.screenWidth/2)-18) / (floor(global.screenHeight/4 * 3) - 39), 0.001, 64000);
proj_mat = matrix_build_projection_perspective_fov(60, 1/1, 0.001, 64000);
camera_set_view_mat(camera, view_mat);
camera_set_proj_mat(camera, proj_mat);
camera_apply(camera);

// Draw Grid
shader_set(gridShader);
vertex_submit(grid, pr_linelist, -1);
shader_reset();

if (textureStruct.meshSelected != -1)
{
	if (mouse_wheel_up())
	{
		dynindex++;
		show_debug_message(dynindex);
	}
	if (mouse_wheel_down()) dynindex--;

	dynindex = clamp(dynindex, 0, array_length(global.model.nu20.meshes[textureStruct.meshSelected].dynamicBuffers) - 1);
}
else dynindex = 0;

// Draw Mesh
if (textureStruct.meshSelected != -1) drawBactaTankMesh(global.model, textureStruct.meshSelected, dynindex);
//drawBactaTankModel(global.model);

// Reset Target
surface_reset_target();