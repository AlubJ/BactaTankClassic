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
if (!surface_exists(textureStruct.meshSurface)) textureStruct.meshSurface = surface_create(202, 202);
surface_set_target(textureStruct.meshSurface);

// Background Colour
draw_clear_alpha(c_black, 0);

// Mouse Controls In Viewer Window
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
	if (mouse_wheel_up()) camera_dist-=0.05;
	if (mouse_wheel_down()) camera_dist+=0.05;
}

// Orbit Camera
if (device_mouse_check_button(0, mb_left) && clicked)
{
	dir += (lastXPos - device_mouse_raw_x(0))/2;
	look_pitch += (lastYPos - device_mouse_raw_y(0))/2;
	look_pitch = clamp(look_pitch, -89.999, 89.999);
			
	lastXPos = device_mouse_raw_x(0);
	lastYPos = device_mouse_raw_y(0);
}

// Orbit Camera Untoggle
if (device_mouse_check_button_released(0, mb_left)) clicked = false;

// Pan Camera
if (device_mouse_check_button(0, mb_right) && clickedMove)
{
	x += dsin(dir) * (lastXPos - device_mouse_raw_x(0))/1000;
	y += dcos(dir) * (lastXPos - device_mouse_raw_x(0))/1000;
	z -= dcos(look_pitch) * (lastYPos - device_mouse_raw_y(0))/1000;
			
	lastXPos = device_mouse_raw_x(0);
	lastYPos = device_mouse_raw_y(0);
}

// Pan Camera Untoggle
if (device_mouse_check_button_released(0, mb_right)) clickedMove = false;

// Clamp Values
camera_dist = clamp(camera_dist, 0.05, 2);
z = clamp(z, -1, 1);
y = clamp(y, -1, 1);
x = clamp(x, -1, 1);

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
proj_mat = matrix_build_projection_perspective_fov(60, 1/1, 0.001, 64000);
camera_set_view_mat(camera, view_mat);
camera_set_proj_mat(camera, proj_mat);
camera_apply(camera);

// Draw Grid
shader_set(gridShader);
vertex_submit(grid, pr_linelist, -1);
shader_reset();

// Draw Mesh
if (textureStruct.meshSelected != -1) drawBactaTankMesh(global.model, textureStruct.meshSelected);

// Reset Target
surface_reset_target();