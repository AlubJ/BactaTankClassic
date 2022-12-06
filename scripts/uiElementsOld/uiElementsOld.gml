/*
	UI Elements
*/

#region File Menu

function uiFileMenu()
{
	if (imguigml_begin_main_menu_bar())
	{
		if (imguigml_begin_menu("File"))
		{
			imguigml_menu_item("Open");
			imguigml_end_menu();
		}
		imguigml_end_main_menu_bar();
	}
}

#endregion

#region Project Window

function uiProjectWindow()
{
	imguigml_set_next_window_size(global.screenWidth, global.screenHeight, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("ProjectWindow", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse)
	
	if (ret[0])
	{
		imguigml_text("BactaTank - Projects");
		imguigml_separator();
		if (imguigml_begin_child("ProjectList", 0, 420))
		{
			var mainCursor = imguigml_get_cursor_pos();
			for (var i = 1; i <= 10; i++)
			{
				imguigml_set_cursor_pos(mainCursor[0], mainCursor[1] + ((i-1) * 52));
				var cursor = imguigml_get_cursor_pos();
				imguigml_selectable("", false, 0, 0, 48);
				imguigml_same_line();
				imguigml_set_cursor_pos(cursor[0] + 8, cursor[1] + 8);
				imguigml_text("Project Name " + string(i));
				//imguigml_same_line();
				imguigml_set_cursor_pos(cursor[0] + 16, cursor[1] + 28);
				imguigml_text(@"D:\Projects\Modding\CharacterProjects\LandoGeneral\LandoGeneral.bactatank");
			}
			imguigml_end_child();
		}
		var cursor = imguigml_get_cursor_pos();
		imguigml_set_cursor_pos(cursor[0] + 170, cursor[1]);
		imguigml_button("Create Project", 112);
		imguigml_set_cursor_pos(cursor[0] + 342, cursor[1]);
		imguigml_button("Open Project", 112);
		imguigml_end();
	}
}

#endregion

#region Main Left Panel

function uiMainLeftPanel()
{
	imguigml_set_next_window_size(ceil(global.screenWidth / 2), global.screenHeight + 2, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("MainLeftPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse)
	
	if (ret[0])
	{
		imguigml_text(window_get_width());
		imguigml_text(window_get_height());
		imguigml_end();
	}
}

#endregion

#region Alpha Main Screen

function uiAlphaMainScreen(textureStruct)
{
	// ImGUI Main Window
	imguigml_set_next_window_size(global.screenWidth, global.screenHeight, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("AlphaMainPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse | (global.model != -1 && textureStruct.homeConfirmation == false ? EImGui_WindowFlags.MenuBar : 0));
	
	if (ret[0] && global.model != -1 && textureStruct.homeConfirmation == false)
	{
		#region MenuBar
		
		if (imguigml_begin_menu_bar())
		{
			if (imguigml_begin_menu("File"))
			{
				// Back Home
				if (imguigml_menu_item("Home", "Ctrl+H"))
				{
					textureStruct.homeConfirmation = true;
				}
				
				imguigml_separator();
				
				// Open GHG
				if (imguigml_menu_item("Open GHG", "Ctrl+O"))
				{
					var file = get_open_filename(global.openFileName, "");
					if (file != "")
					{
						// Change Cursor To Loading Cursor
						window_set_cursor(cr_hourglass);
					
						// Destroy Old Model If It's Loaded
						if (global.model != -1) destroyBactaTankModel(global.model);
					
						// Get File Name
						var split = string_split(file + @"\", @"\");
						global.filename = split[array_length(split)-1];
					
						// Load New Model
						global.model = loadBactaTankModel(file);
						
						// Change Window Title
						window_set_caption(global.filename + " - BactaTank");
					
						// Create New Directory
						directory_create(global.tempDirectory + global.filename + @"\");
					
						// Set Selected
						textureStruct.textureSelected = -1;
						textureStruct.meshSelected = -1;
						textureStruct.materialSelected = -1;
					
						// Change Cursor Back To Default
						window_set_cursor(cr_default);
					}
				}
			
				// Save GHG
				if (imguigml_menu_item("Save GHG", "Ctrl+S", false, global.model == -1 ? false : true))
				{
					var file = get_save_filename(global.saveFileName, global.filename);
					if (file != "")
					{
						window_set_cursor(cr_hourglass);
						exportBactaTankModel(global.model, file);
						window_set_cursor(cr_default);
					}
				}
				
				//imguigml_separator();
				
				//// Export Model
				//if (imguigml_menu_item("Export Model", "Ctrl+E", false, global.model == -1 ? false : true))
				//{
				//	var file = get_save_filename("Wavefront Object (*.obj)|*.obj", "*.obj");
				//	if (file != "")
				//	{
				//		window_set_cursor(cr_hourglass);
				//		exportBactaTankObj(global.model, file);
				//		window_set_cursor(cr_default);
				//	}
				//}
				
				imguigml_separator();
				
				if (imguigml_menu_item("Preferences"))
				{
					textureStruct.settingsPage = true;
				}
				
				imguigml_separator();
				
				// Save GHG
				if (imguigml_menu_item("Exit", "Alt+F4"))
				{
					// Destroy Old Model If It's Loaded
					if (global.model != -1) destroyBactaTankModel(global.model);
					
					// End Game
					game_end();
				}
				
				imguigml_end_menu();
			}
			
			//if (imguigml_begin_menu("Tools"))
			//{
			//	imguigml_menu_item("Convert Normal Map");
			//	imguigml_end_menu();
			//}
			
			if (imguigml_menu_item("Help"))
			{
				url_open("https://github.com/AlubJ/BactaTankDocs/wiki/Getting-Started");
			}
			
			imguigml_end_menu_bar();
		}
		
		#endregion
		
		// Tab Buttons
		var buttons = ["Textures", "Meshes", "Materials"];
		
		// Tabs
		for (var i = 0; i < array_length(buttons); i++)
		{
			if (i == textureStruct.tabSelected) imguigml_push_style_color(EImGui_Col.Button, 0.13, 0.13, 0.13, 1);
			if (imguigml_button(buttons[i], 94, 24)) textureStruct.tabSelected = i;
			if (i != array_length(buttons)-1) imguigml_same_line();
			if (i == textureStruct.tabSelected) imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
		}
		
		#region Textures
		
		// Textures List
		if (textureStruct.tabSelected == 0)
		{
			if (imguigml_begin_child("TextureList", 0, 76*4))
			{
				// Check If Model Is Loaded First
				if (global.model != -1)
				{
					// Get Main Cursor Position
					var mainCursor = imguigml_get_cursor_pos();
				
					// Textures List Box
					for (var i = 0; i < array_length(global.model.nu20.textureMetaData); i++)
					{
						// Position Selectable
						imguigml_set_cursor_pos(mainCursor[0], mainCursor[1] + ((i) * 76));
						if (imguigml_selectable("##hidden" + string(i), textureStruct.textureSelected == i, 0, 0, 72)[0])
						{
							textureStruct.textureSelected = i;
						}
					
						// Transparent Image
						imguigml_same_line();
						var cursor = imguigml_get_cursor_pos();
						imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
						imguigml_sprite(sprTransparent, 0, 64, 64, 1, 1, 1, 1, 0, 0, 0, 0);
					
						// Main Texture
						imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
						imguigml_sprite(global.model.textureSprites[global.model.nu20.textureMetaData[i].index], 0, 64, 64, 1, 1, 1, 1, 0, 0, 0, 0);
					
						// Texture Text
						imguigml_set_cursor_pos(cursor[0] + 76, cursor[1] + 29);
						imguigml_text("Texture " + string(global.model.nu20.textureMetaData[i].index));
					}
				}
				imguigml_end_child();
			}
		
			// Texture Details Child
			if (imguigml_begin_child("TextureDetails", 0, 210))
			{
				// Check If Model Is Loaded And Texture Is Selected
				if (global.model != -1 && textureStruct.textureSelected >= 0)
				{
					// Get Cursor Position
					var cursor = imguigml_get_cursor_pos();
				
					// Transparent Image
					imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
					imguigml_sprite(sprTransparent, 0, 202, 202, 1, 1, 1, 1, 0, 0, 0, 0);
				
					// Main Texture
					imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
					imguigml_sprite(global.model.textureSprites[global.model.nu20.textureMetaData[textureStruct.textureSelected].index], 0, 202, 202, 1, 1, 1, 1, 0, 0, 0, 0);
				
					// Export Texture Button
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 8);
					if (imguigml_button("Export Texture", 264, 24))
					{
						// Get Save File Name For DDS Export
						var file = get_save_filename("DirectDraw Surface (*.dds)|*.dds", "*.dds");
						if (file != "")
						{
							// Export Texture
							window_set_cursor(cr_hourglass);
							buffer_save(global.model.textures[global.model.nu20.textureMetaData[textureStruct.textureSelected].index], file);
							window_set_cursor(cr_default);
						}
					}
				
					// Replace Texture Button
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 36);
					if (imguigml_button("Replace Texture", 264, 24) && (!global.model.nu20.textureMetaData[textureStruct.textureSelected].isCubemap || (global.settings.advancedOptions && global.settings.cubeMapReplacement)))
					{
						// Get Open File Name For Replacement
						var file = get_open_filename("DirectDraw Surface (*.dds)|*.dds", "");
						if (file != "")
						{
							// Set Cursor To Wait
							window_set_cursor(cr_hourglass);
						
							// Replace Texture
							replaceBactaTankTexture(global.model, textureStruct.textureSelected, file);
						
							// Reset Cursor To Default
							window_set_cursor(cr_default);
						}
					}
				
					// Texture Details Separator
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 64);
					if (imguigml_begin_child("TextureDetailsSeparator", 264, 10)) // Workaround for shitty separators
					{
						imguigml_separator();
						imguigml_end_child();
					}
				
					// Texture Details
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 70);
					imguigml_text("Texture Details:");
				
					// Width
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 84);
					imguigml_text("Width:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 84);
					imguigml_text(global.model.nu20.textureMetaData[textureStruct.textureSelected].width);
				
					// Height
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 98);
					imguigml_text("Height:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 98);
					imguigml_text(global.model.nu20.textureMetaData[textureStruct.textureSelected].height);
				
					// Buffer Size
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 112);
					imguigml_text("Buffer Size:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 112);
					imguigml_text("0x" + string_hex(global.model.nu20.textureMetaData[textureStruct.textureSelected].size, 8));
				
					// Compression
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 126);
					imguigml_text("Compression Type:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 126);
					imguigml_text(global.DXTCompression[global.model.nu20.textureMetaData[textureStruct.textureSelected].compression]);
				
					// Metadata Offset
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 140);
					imguigml_text("Metadata Offset:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 140);
					imguigml_text("0x" + string_hex(global.model.nu20Offset + global.model.nu20.textureMetaData[textureStruct.textureSelected].offset, 8));
					if (imguigml_is_item_hovered())
					{
						window_set_cursor(cr_handpoint);
						if (mouse_check_button_pressed(mb_left)) clipboard_set_text(string_hex(global.model.nu20Offset + global.model.nu20.textureMetaData[textureStruct.textureSelected].offset, 8));
					}
					else window_set_cursor(cr_default);
				}
				else
				{
					imguigml_set_cursor_pos(196, 98);
					imguigml_text("Select a texture...");
				}
				imguigml_end_child();
			}
		}
		
		#endregion
		
		#region Meshes
		
		// Mesh List
		if (textureStruct.tabSelected == 1)
		{
			if (imguigml_begin_child("MeshList", 0, 76*4, false, EImGui_WindowFlags.AlwaysVerticalScrollbar))
			{
				// Check If Model Is Loaded First
				if (global.model != -1)
				{
					// Get Main Cursor Position
					var mainCursor = imguigml_get_cursor_pos();
					
					// Mesh List Box
					for (var i = 0; i < array_length(global.model.nu20.meshes); i++)
					{
						// Position Selectable
						imguigml_set_cursor_pos(mainCursor[0], mainCursor[1] + ((i) * 36));
						if (imguigml_selectable("##hidden" + string(i), textureStruct.meshSelected == i, EImGui_SelectableFlags.AllowItemOverlap, 0, 32)[0])
						{
							textureStruct.meshSelected = i;
						}
					
						// Mesh Text
						imguigml_same_line();
						var cursor = imguigml_get_cursor_pos();
						imguigml_set_cursor_pos(cursor[0] + 8, cursor[1] + 8);
						imguigml_text("Mesh " + string(i));
						
						var colour = 1;
						if (global.model.nu20.meshes[i].type == 0) colour = 0.4;
						
						if (global.model.nu20.meshes[i].bones[0] == -1)
						{
							imguigml_set_cursor_pos(cursor[0] + 434, cursor[1] + 8);
							imguigml_sprite(meshIcons, 0, 16, 16, colour, colour, colour, colour);
							if (imguigml_is_item_clicked())
							{
								if (global.model.nu20.meshes[i].type == 6) global.model.nu20.meshes[i].type = 0;
								else global.model.nu20.meshes[i].type = 6;
							}
							if (global.model.nu20.meshes[i].type == 0)
							{
								imguigml_set_cursor_pos(cursor[0] + 431, cursor[1] + 6);
								imguigml_sprite(crossedOut, 0, 20, 20);
							}
						}
						else
						{
							imguigml_set_cursor_pos(cursor[0] + 432, cursor[1] + 8);
							imguigml_sprite(meshIcons, 1, 18, 18, colour, colour, colour, colour);
							if (imguigml_is_item_clicked())
							{
								if (global.model.nu20.meshes[i].type == 6) global.model.nu20.meshes[i].type = 0;
								else global.model.nu20.meshes[i].type = 6;
							}
							if (global.model.nu20.meshes[i].type == 0)
							{
								imguigml_set_cursor_pos(cursor[0] + 431, cursor[1] + 6);
								imguigml_sprite(crossedOut, 0, 20, 20);
							}
						}
					}
				}
				imguigml_end_child();
			}
		
			// Mesh Details Child
			if (imguigml_begin_child("MeshDetails", 0, 210))
			{
				// Check If Model Is Loaded And Mesh Is Selected
				if (global.model != -1 && textureStruct.meshSelected >= 0)
				{
					// Get Cursor Position
					var cursor = imguigml_get_cursor_pos();
				
					// Surface Image
					imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
					imguigml_surface(textureStruct.meshSurface, 202, 202);
				
					// Export Mesh Button
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 8);
					if (imguigml_button("Export Mesh", 264, 24))
					{
						// Get Save File Name For DDS Export
						var file = get_save_filename("Wavefront Object (*.obj)|*.obj|BactaTank Model (*.btank)|*.btank", "*.obj");
						if (file != "")
						{
							// Set Cursor To Wait
							window_set_cursor(cr_hourglass);
							
							// Export Mesh
							exportBactaTankMesh(global.model, textureStruct.meshSelected, file);
							
							// Set Cursor To Default
							window_set_cursor(cr_default);
						}
					}
				
					// Replace Mesh Button
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 36);
					if (imguigml_button("Replace Mesh", 264, 24) && (global.model.nu20.meshes[textureStruct.meshSelected].bones[0] == -1 || (global.settings.advancedOptions && global.settings.defaultSkinning)))
					{
						// Get Open File Name For Replacement
						var file = get_open_filename("BactaTank Model (*.btank)|*.btank", "");
						if (file != "")
						{
							// Set Cursor To Wait
							window_set_cursor(cr_hourglass);
						
							// Replace Mesh
							replaceBactaTankMesh(global.model, textureStruct.meshSelected, file);
						
							// Reset Cursor To Default
							window_set_cursor(cr_default);
						}
					}
				
					// Mesh Details Separator
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 64);
					if (imguigml_begin_child("MeshDetailsSeparator", 264, 10)) // Workaround for shitty separators
					{
						imguigml_separator();
						imguigml_end_child();
					}
					
					var material = getBactaTankMeshMaterial(global.model, textureStruct.meshSelected);
					
					// Mesh Details
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 70);
					imguigml_text("Mesh Details:");
				
					// Vertex Stride
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 84);
					imguigml_text("Vertex Size:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 84);
					imguigml_text(global.model.nu20.meshes[textureStruct.meshSelected].vertexStride);
				
					// Vertex Count
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 98);
					imguigml_text("Vertex Count:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 98);
					imguigml_text(global.model.nu20.meshes[textureStruct.meshSelected].vertexCount);
				
					// Triangle Count
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 112);
					imguigml_text("Triangle Count:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 112);
					imguigml_text(global.model.nu20.meshes[textureStruct.meshSelected].triangleCount);
					
					// Vertex Buffer Size
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 126);
					imguigml_text("Vertex Buffer Size:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 126);
					imguigml_text(global.model.nu20.meshes[textureStruct.meshSelected].vertexCount * global.model.nu20.meshes[textureStruct.meshSelected].vertexStride);
					
					// Index Buffer Size
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 140);
					imguigml_text("Index Buffer Size:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 140);
					imguigml_text((global.model.nu20.meshes[textureStruct.meshSelected].triangleCount + 2) * 2);
					
				
					// Metadata Offset
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 156);
					imguigml_text("Metadata Offset:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 156);
					imguigml_text("0x" + string_hex(global.model.nu20Offset + global.model.nu20.meshes[textureStruct.meshSelected].offset, 8));
					if (imguigml_is_item_hovered())
					{
						window_set_cursor(cr_handpoint);
						if (mouse_check_button_pressed(mb_left)) clipboard_set_text(string_hex(global.model.nu20Offset + global.model.nu20.meshes[textureStruct.meshSelected].offset, 8));
					}
					else window_set_cursor(cr_default);
					
				
					// Material Offset
					imguigml_set_cursor_pos(cursor[0] + 222, cursor[1] + 172);
					imguigml_text("Material Index:");
					imguigml_set_cursor_pos(cursor[0] + 342, cursor[1] + 172);
					imguigml_text(material);
				}
				else
				{
					imguigml_set_cursor_pos(201, 98);
					imguigml_text("Select a mesh...");
				}
				imguigml_end_child();
			}
		}
		
		#endregion
		
		#region Materials
		
		// Materials List
		if (textureStruct.tabSelected == 2)
		{
			if (imguigml_begin_child("MaterialsList", 0, 76*4))
			{
				// Check If Model Is Loaded First
				if (global.model != -1)
				{
					// Get Main Cursor Position
					var mainCursor = imguigml_get_cursor_pos();
				
					// Materials List Box
					for (var i = 0; i < array_length(global.model.nu20.materials); i++)
					{
						// Position Selectable
						imguigml_set_cursor_pos(mainCursor[0], mainCursor[1] + ((i) * 36));
						if (imguigml_selectable("##hidden" + string(i), textureStruct.materialSelected == i, 0, 0, 32)[0])
						{
							textureStruct.materialSelected = i;
						}
					
						// Material Text
						imguigml_same_line();
						var cursor = imguigml_get_cursor_pos();
						imguigml_set_cursor_pos(cursor[0] + 8, cursor[1] + 8);
						imguigml_text("Material " + string(i));
					}
				}
				imguigml_end_child();
			}
		
			// Material Details Child
			if (imguigml_begin_child("MaterialDetails", 0, 210))
			{
				// Check If Model Is Loaded And Material Is Selected
				if (global.model != -1 && textureStruct.materialSelected >= 0)
				{
					// Get Cursor Position
					var cursor = imguigml_get_cursor_pos();
				
					// Texture Indexes
					var textureID = global.model.nu20.materials[textureStruct.materialSelected].textureID;
					var normalID = global.model.nu20.materials[textureStruct.materialSelected].normalID;
					var shineID = global.model.nu20.materials[textureStruct.materialSelected].shineID;
				
					// Main Texture
					imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
					imguigml_sprite(sprTransparent, 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					
					imguigml_set_cursor_pos(cursor[0] + 4, cursor[1] + 4);
					if (textureID != -1) imguigml_sprite(global.model.textureSprites[textureID], 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					else imguigml_sprite(sprQuestionMark, 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					
					// Normal Texture
					imguigml_set_cursor_pos(cursor[0] + 107, cursor[1] + 4);
					imguigml_sprite(sprTransparent, 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					
					imguigml_set_cursor_pos(cursor[0] + 107, cursor[1] + 4);
					if (normalID != -1) imguigml_sprite(global.model.textureSprites[normalID], 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					else imguigml_sprite(sprQuestionMark, 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					
					// Shine Texture
					imguigml_set_cursor_pos(cursor[0] + 57, cursor[1] + 107);
					imguigml_sprite(sprTransparent, 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					
					imguigml_set_cursor_pos(cursor[0] + 57, cursor[1] + 107);
					if (shineID != -1) imguigml_sprite(global.model.textureSprites[shineID], 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					else imguigml_sprite(sprQuestionMark, 0, 99, 99, 1, 1, 1, 1, 0, 0, 0, 0);
					
					// Edit Text
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 8);
					imguigml_text("Edit Material:");
				
					// Edit Colour
					var colour = global.model.nu20.materials[textureStruct.materialSelected].colour;
					
					imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 28);
					
					if (imguigml_begin_child("MaterialEditor", 264, 180, false, EImGui_WindowFlags.AlwaysVerticalScrollbar))
					{
						imguigml_set_cursor_pos(0, 0);
						imguigml_push_item_width(248);
						var editColour = imguigml_color_edit4("##hiddenColourPicker", colour[0], colour[1], colour[2], colour[3]);
						imguigml_pop_item_width();
					
						if (editColour[0]) global.model.nu20.materials[textureStruct.materialSelected].colour = [editColour[1], editColour[2], editColour[3], editColour[4]];
					
						// Texture Index
						imguigml_set_cursor_pos(0, 30);
						imguigml_text("TextureID:");
						imguigml_set_cursor_pos(112, 28);
						var ret = imguigml_input_int_clamp("##hiddenTexture", textureID, 136, -1, array_length(global.model.textures) - 1);
						if (ret[0]) global.model.nu20.materials[textureStruct.materialSelected].textureID = ret[1];
					
						// Normal Index
						imguigml_set_cursor_pos(0, 56);
						imguigml_text("NormalID:");
						imguigml_set_cursor_pos(112, 54);
						ret = imguigml_input_int_clamp("##hiddenNormal", normalID, 136, -1, array_length(global.model.textures) - 1);
						if (ret[0]) global.model.nu20.materials[textureStruct.materialSelected].normalID = ret[1];
					
						// Shine Index
						imguigml_set_cursor_pos(0, 82);
						imguigml_text("ShineID:");
						imguigml_set_cursor_pos(112, 80);
						ret = imguigml_input_int_clamp("##hiddenShine", shineID, 136, -1, array_length(global.model.textures) - 1);
						if (ret[0]) global.model.nu20.materials[textureStruct.materialSelected].shineID = ret[1];
					
						imguigml_set_cursor_pos(0, 108);
						imguigml_text("Shader Flags:");
					
						// Shiny?
						imguigml_set_cursor_pos(0, 130);
						if (imguigml_checkbox("##hiddenShiny", (global.model.nu20.materials[textureStruct.materialSelected].shaderFlags & 8) > 0)[0])
						{
							if (global.model.nu20.materials[textureStruct.materialSelected].shaderFlags & 8) global.model.nu20.materials[textureStruct.materialSelected].shaderFlags &= ~8;
							else global.model.nu20.materials[textureStruct.materialSelected].shaderFlags |= 8;
						}
					
						imguigml_set_cursor_pos(26, 132);
						imguigml_text("Shiny");
						
						// Lighting?
						imguigml_set_cursor_pos(0, 156);
						if (imguigml_checkbox("##hiddenLighting", (global.model.nu20.materials[textureStruct.materialSelected].shaderFlags & 4096) == 0)[0])
						{
							if (global.model.nu20.materials[textureStruct.materialSelected].shaderFlags & 4096) global.model.nu20.materials[textureStruct.materialSelected].shaderFlags &= ~4096;
							else global.model.nu20.materials[textureStruct.materialSelected].shaderFlags |= 4096;
						}
					
						imguigml_set_cursor_pos(26, 158);
						imguigml_text("Lighting");
					
						// Transparent?
						imguigml_set_cursor_pos(0, 182);
						if (imguigml_checkbox("##hiddenTransparent", global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 1)[0])
						{
							if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 1) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend &= ~1;
							else global.model.nu20.materials[textureStruct.materialSelected].alphaBlend |= 1;
							if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 32) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend &= ~32;
						}
					
						imguigml_set_cursor_pos(26, 184);
						imguigml_text("Transparent");
					
						//// Backface Culling?
						//imguigml_set_cursor_pos(0, 182);
						//if (imguigml_checkbox("##hiddenBackface", global.model.nu20.materials[textureStruct.materialSelected].alphaBlend == 20)[0])
						//{
						//	if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend == 0) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend = 20;
						//	else global.model.nu20.materials[textureStruct.materialSelected].alphaBlend = 0;
						//}
					
						//imguigml_set_cursor_pos(26, 184);
						//imguigml_text("Backface Cull");
					
						// Use Normal Map?
						imguigml_set_cursor_pos(26, 210);
						imguigml_text("Use Normal Map");
						
						imguigml_same_line();
						imguigml_set_cursor_pos(0, 208);
						if (imguigml_checkbox("##hiddenUseNormal", global.model.nu20.materials[textureStruct.materialSelected].shaderFlags & 1)[0])
						{
							if (global.model.nu20.materials[textureStruct.materialSelected].shaderFlags & 1) global.model.nu20.materials[textureStruct.materialSelected].shaderFlags &= ~1;
							else global.model.nu20.materials[textureStruct.materialSelected].shaderFlags |= 1;
						}
						
						var cullMode = 0;
						if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 8192) cullMode = 1;
						else if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 4096) cullMode = 2;
						
						imguigml_set_cursor_pos(0, 234);
						var combo = imguigml_combo("##hiddenBackface", cullMode, ["Backface Culling", "No Culling", "Frontface Culling"]);
						if (combo[0])
						{
							cullMode = combo[1];
							if (cullMode == 0)
							{
								if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 8192) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend &= ~8192;
								if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 4096) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend &= ~4096;
							}
							else if (cullMode == 1)
							{
								if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & ~8192) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend |= 8192;
								if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 4096) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend &= ~4096;
							}
							else if (cullMode == 2)
							{
								if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & 8192) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend &= ~8192;
								if (global.model.nu20.materials[textureStruct.materialSelected].alphaBlend & ~4096) global.model.nu20.materials[textureStruct.materialSelected].alphaBlend |= 4096;
							}
						}
					
						imguigml_end_child();
					}
				
					// Meterials Details Separator
					//imguigml_set_cursor_pos(cursor[0] + 214, cursor[1] + 64);
					//if (imguigml_begin_child("TextureDetailsSeparator", 264, 10)) // Workaround for shitty separators
					//{
					//	imguigml_separator();
					//	imguigml_end_child();
					//}
				}
				else
				{
					imguigml_set_cursor_pos(194, 98);
					imguigml_text("Select a material...");
				}
				imguigml_end_child();
			}
		}
		
		#endregion
		
		// Footer
		imguigml_set_cursor_pos(8, global.screenHeight - 20);
		imguigml_text("BactaTank " + global.version);
		
		imguigml_set_cursor_pos(global.screenWidth - 96, global.screenHeight - 20);
		imguigml_text("Created By Alub");
		imguigml_end();
	}
}

#endregion

#region Alpha Home Screen

function uiAlphaHomeScreen(texureStruct)
{
	// ImGUI Main Window
	imguigml_set_next_window_size(global.screenWidth, global.screenHeight, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("AlphaMainPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse | EImGui_WindowFlags.MenuBar);
	
	if (ret[0])
	{
		if (imguigml_begin_menu_bar())
		{
			if (imguigml_menu_item("Preferences"))
			{
				textureStruct.settingsPage = true;
			}
			
			if (imguigml_menu_item("Help"))
			{
				url_open("https://github.com/AlubJ/BactaTankDocs/wiki/Getting-Started");
			}
			
			imguigml_end_menu_bar();
		}
		
		// Logo
		imguigml_set_cursor_pos(58, 32);
		imguigml_sprite(sprBactaTankLogoRelease, 0, 128, 128);
		imguigml_set_cursor_pos(198, 64);
		imguigml_sprite(sprBactaTankText, 0, 256, 64);
		imguigml_set_cursor_pos(406, 116);
		imguigml_text(global.version);
		
		#region Buttons
		
		imguigml_set_cursor_pos(208, 202);
		imguigml_push_style_color(EImGui_Col.Button, 0.13, 0.13, 0.13, 1);
		if (imguigml_button("Open GHG", 94, 24))
		{
			var file = get_open_filename(global.openFileName, "");
			if (file != "")
			{
				// Change Cursor To Loading Cursor
				window_set_cursor(cr_hourglass);
					
				// Destroy Old Model If It's Loaded
				if (global.model != -1) destroyBactaTankModel(global.model);
					
				// Get File Name
				var split = string_split(file + @"\", @"\");
				global.filename = split[array_length(split)-1];
					
				// Load New Model
				global.model = loadBactaTankModel(file);
						
				// Change Window Title
				window_set_caption(global.filename + " - BactaTank");
					
				// Create New Directory
				directory_create(global.tempDirectory + global.filename + @"\");
					
				// Set Selected
				textureStruct.textureSelected = -1;
				textureStruct.meshSelected = -1;
				textureStruct.materialSelected = -1;
					
				// Change Cursor Back To Default
				window_set_cursor(cr_default);
			}
		}
		imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
		imguigml_set_cursor_pos(170, 232);
		imguigml_text("or drag and drop a *.GHG here!");
		
		#endregion
		
		#region Character Presets
		
		imguigml_set_cursor_pos(8, 264);
		if (imguigml_begin_child("CharacterPresetContainer", 0, 296))
		{
			imguigml_set_cursor_pos(8, 6);
			imguigml_text_disabled("Preset");
			imguigml_set_cursor_pos(228, 6);
			imguigml_text_disabled("Skeleton");
			imguigml_set_cursor_pos(370, 6);
			imguigml_text_disabled("Author");
			if (imguigml_begin_child("CharacterPresetList", 0, 0))
			{
				for (var i = 0; i < array_length(global.characterPresets); i++)
				{
					if (imguigml_selectable("##hidden" + string(i), textureStruct.presetSelected == i)[0])
					{
						textureStruct.presetSelected = i;
					}
					imguigml_same_line();
					var cursor = imguigml_get_cursor_pos();
					imguigml_text(global.characterPresets[i].character_title);
					imguigml_same_line();
					imguigml_set_cursor_pos(228, cursor[1]);
					imguigml_text(global.characterPresets[i].skeleton);
					imguigml_same_line();
					imguigml_set_cursor_pos(370, cursor[1]);
					imguigml_text(global.characterPresets[i].author);
				}
				imguigml_end_child();
			}
			imguigml_end_child();
		}
		imguigml_set_cursor_pos(208, 568);
		imguigml_push_style_color(EImGui_Col.Button, 0.13, 0.13, 0.13, 1);
		if (imguigml_button("Create", 94, 24) && textureStruct.presetSelected != -1)
		{
			// Change Cursor To Loading Cursor
			window_set_cursor(cr_hourglass);
		
			// Destroy Old Model If It's Loaded
			if (global.model != -1) destroyBactaTankModel(global.model);
		
			// Get File Name
			var split = string_split(global.characterPresets[textureStruct.presetSelected].location + @"/", @"/");
			global.filename = split[array_length(split)-1];
		
			// Load New Model
			global.model = loadBactaTankModel(global.characterPresets[textureStruct.presetSelected].location);
		
			// Change Window Title
			window_set_caption(global.filename + " - BactaTank");
		
			// Set Selected
			textureStruct.textureSelected = -1;
			textureStruct.meshSelected = -1;
			textureStruct.materialSelected = -1;
		
			// Change Cursor Back To Default
			window_set_cursor(cr_default);
		}
		imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
		
		#endregion
		
	}
}

#endregion

#region Alpha Go Home Screen

function uiAlphaGoHomeScreen(textureStruct)
{
	// ImGUI Main Window
	imguigml_set_next_window_size(global.screenWidth, global.screenHeight, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("AlphaMainPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse | (global.model != -1 && textureStruct.homeConfirmation == false ? EImGui_WindowFlags.MenuBar : 0));
	
	if (ret[0] && global.model != -1 && textureStruct.homeConfirmation == true)
	{
		imguigml_set_cursor_pos(152, 285);
		imguigml_text("Are you sure you want to return home?");
		imguigml_set_cursor_pos(157, 305);
		imguigml_push_style_color(EImGui_Col.Button, 0.13, 0.13, 0.13, 1);
		if (imguigml_button("Yes", 94, 24))
		{
			// Destroy Old Model If It's Loaded
			if (global.model != -1) destroyBactaTankModel(global.model);
			global.model = -1;
		
			// Change Window Title
			window_set_caption("BactaTank");
			
			textureStruct.homeConfirmation = false;
		}
		imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
		
		imguigml_set_cursor_pos(259, 305);
		imguigml_push_style_color(EImGui_Col.Button, 0.13, 0.13, 0.13, 1);
		if (imguigml_button("No", 94, 24))
		{
			textureStruct.homeConfirmation = false;
		}
		imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
	}
}

#endregion

#region Alpha Preferences Screen

function uiAlphaPreferencesScreen(textureStruct)
{
	// ImGUI Main Window
	imguigml_set_next_window_size(global.screenWidth, global.screenHeight, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("AlphaPreferences", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse);
	
	if (ret[0] && textureStruct.settingsPage == true)
	{
		
		// Advanced Checkbox
		imguigml_set_cursor_pos(122, 200);
		if (imguigml_checkbox("##hiddenAdvancedOptions", global.settings.advancedOptions)[0]) global.settings.advancedOptions = !global.settings.advancedOptions;
		imguigml_set_cursor_pos(150, 204);
		imguigml_text("Advanced Options");
		imguigml_same_line();
		imguigml_tooltip("Advanced Options should only be used by experienced modders.\nAdvanced Options can cause models to become corrupted and\nit is YOUR fault if this happens!");
		
		var yy = 0;
		
		if (global.settings.advancedOptions)
		{
			// Cubemap Replacement
			imguigml_set_cursor_pos(150, 228);
			if (imguigml_checkbox("##hiddenCubemapReplacement", global.settings.cubeMapReplacement)[0]) global.settings.cubeMapReplacement = !global.settings.cubeMapReplacement;
			imguigml_set_cursor_pos(178, 232);
			imguigml_text("Cubemap Replacement");
			imguigml_same_line();
			imguigml_tooltip("Allows for replacing cubemap textures, may cause\nBactaTank to crash.");
			
			// Default Skinning
			imguigml_set_cursor_pos(150, 256);
			if (imguigml_checkbox("##hiddenDefaultSkinning", global.settings.defaultSkinning)[0]) global.settings.defaultSkinning = !global.settings.defaultSkinning;
			imguigml_set_cursor_pos(178, 260);
			imguigml_text("Default Static Skinning");
			imguigml_same_line();
			imguigml_tooltip("Inserts default skinning to make a skinned mesh appear as\nstatic, requires manual mesh data editing.");
			
			yy += 56;
		}
		
		textureStruct.yySmooth += (yy - textureStruct.yySmooth) / 8;
		
		imguigml_set_cursor_pos(122, 228 + textureStruct.yySmooth);
		if (imguigml_checkbox("##hiddenSmoothCamera", global.settings.cameraSmooth)[0]) global.settings.cameraSmooth = !global.settings.cameraSmooth;
		imguigml_set_cursor_pos(150, 232 + textureStruct.yySmooth);
		imguigml_text("Smooth Camera");
		
		var AALevel = ["No Anti-Aliasing", "2x", "4x", "8x"];
		imguigml_set_cursor_pos(122, 256 + textureStruct.yySmooth);
		imguigml_text("AA Level:");
		imguigml_set_cursor_pos(122, 274 + textureStruct.yySmooth);
		imguigml_push_item_width(256);
		var index = 0;
		if (global.settings.AALevel == 2) index = 1;
		if (global.settings.AALevel == 4) index = 2;
		if (global.settings.AALevel == 8) index = 3;
		var ret = imguigml_combo("##hiddenAA", index, AALevel);
		if (ret[0])
		{
			if (ret[1] == 0) global.settings.AALevel = 0;
			if (ret[1] == 1) global.settings.AALevel = 2;
			if (ret[1] == 2) global.settings.AALevel = 4;
			if (ret[1] == 3) global.settings.AALevel = 8;
			display_reset(global.settings.AALevel, true);
		}
		
		imguigml_set_cursor_pos(122, 302 + textureStruct.yySmooth);
		imguigml_text("Watermark:");
		imguigml_set_cursor_pos(122, 320 + textureStruct.yySmooth);
		imguigml_push_item_width(256);
		var ret = imguigml_input_text("##hiddenWaterMark", global.settings.watermark, 100);
		if (ret[0])
		{
			global.settings.watermark = ret[1];
		}
		
		imguigml_push_style_color(EImGui_Col.Button, 0.13, 0.13, 0.13, 1);
		imguigml_set_cursor_pos(122, 348 + textureStruct.yySmooth);
		if (imguigml_button("Clear Cache", 256, 24))
		{
			directory_destroy(global.tempDirectory + @"_textures\");
			directory_destroy(global.tempDirectory + @"_meshes\");
		}
		
		imguigml_set_cursor_pos(203, 380 + textureStruct.yySmooth);
		if (imguigml_button("Save", 96, 24))
		{
			snap_to_binary(global.settings, "settings.bin");
			textureStruct.settingsPage = false;
		}
		imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
		
		imguigml_end();
	}
}

#endregion

#region Font Editor

function uiFontEditor(textureStruct)
{
	// Check If File Is Being Dragged Onto The App
	var array = file_dropper_get_files([".fnt"]);
	file_dropper_flush();

	if (array_length(array) > 0 && file_exists(array[0])) {
		// Change Cursor To Loading Cursor
		window_set_cursor(cr_hourglass);
		
		// Get File Name
		var split = string_split(array[0] + @"\", @"\");
		
		// Load New Font
		textureStruct.loadedFont = loadBactaTankFont(array[0]);
		
		// Set Selected
		textureStruct.fontCharacterSelected = -1;
		
		// Change Cursor Back To Default
		window_set_cursor(cr_default);
	}
	
	// ImGUI Main Window
	imguigml_set_next_window_size(global.screenWidth, global.screenHeight, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 0, EImGui_Cond.Once);
	
	var ret = imguigml_begin("AlphaMainPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse | EImGui_WindowFlags.MenuBar);
	
	if (ret[0] && textureStruct.loadedFont != -1)
	{
		if (imguigml_begin_menu_bar())
		{
			if (imguigml_menu_item("Open Font"))
			{
				textureStruct.toolSelected = "fe";
			}
			
			imguigml_end_menu_bar();
		}
		
		imguigml_set_cursor_pos(8, 30);
		imguigml_sprite(sprTransparent, 0, 244, 244);
		imguigml_set_cursor_pos(8, 30);
		imguigml_sprite(textureStruct.loadedFont.sprite, 0, 244, 244);
		
		imguigml_set_cursor_pos(260, 30);
		if (imguigml_begin_child("CharacterPreview", 0, 244))
		{
			imguigml_end_child();
		}
		
		imguigml_set_cursor_pos(8, 282);
		if (imguigml_begin_child("CharacterList", 0, 294, false, EImGui_WindowFlags.AlwaysVerticalScrollbar))
		{
			var xx = 0;
			var yy = 0;
			for (var i = 0; i < 20; i++)
			{
				var posX = 6 + ((64 * xx) + (2 * xx));
				var posY = 6 + ((64 * yy) + (2 * yy));
				imguigml_set_cursor_pos(posX, posY);
				imguigml_button("##hiddenCharacter" + string(i), 64, 64);
				imguigml_set_cursor_pos(posX+floor((64 - textureStruct.loadedFont.characters[i].width) / 2), posY + 8);
				imguigml_sprite_part(textureStruct.loadedFont.sprite, 0, textureStruct.loadedFont.characters[i].x, textureStruct.loadedFont.characters[i].y, textureStruct.loadedFont.characters[i].width, textureStruct.loadedFont.characters[i].height);
				xx++;;
				if (xx == 7)
				{
					xx = 0;
					yy++;
				}
			}
			
			//imguigml_set_cursor_pos(6, 6);
			//imguigml_button("", 64, 64);
			//imguigml_set_cursor_pos(72, 6);
			//imguigml_button("", 64, 64);
			//imguigml_set_cursor_pos(138, 6);
			//imguigml_button("", 64, 64);
			//imguigml_set_cursor_pos(204, 6);
			//imguigml_button("", 64, 64);
			//imguigml_set_cursor_pos(270, 6);
			//imguigml_button("", 64, 64);
			//imguigml_set_cursor_pos(336, 6);
			//imguigml_button("", 64, 64);
			//imguigml_set_cursor_pos(402, 6);
			//imguigml_button("", 64, 64);
			imguigml_end_child();
		}
		
		// Footer
		imguigml_set_cursor_pos(8, global.screenHeight - 20);
		imguigml_text("BactaTank " + global.version);
		
		imguigml_set_cursor_pos(global.screenWidth - 96, global.screenHeight - 20);
		imguigml_text("Created By Alub");
		imguigml_end();
		
	}
}

#endregion

#region Shortcuts

function uiShortcuts(textureStruct)
{
	// Keyboard Shortcuts
	if (keyboard_check(vk_control))
	{
		if (keyboard_check_pressed(ord("O")) && textureStruct.homeConfirmation == false)
		{
			var file = get_open_filename(global.openFileName, "");
			if (file != "")
			{
				// Change Cursor To Loading Cursor
				window_set_cursor(cr_hourglass);
					
				// Destroy Old Model If It's Loaded
				if (global.model != -1) destroyBactaTankModel(global.model);
					
				// Get File Name
				var split = string_split(file + @"\", @"\");
				global.filename = split[array_length(split)-1];
					
				// Load New Model
				global.model = loadBactaTankModel(file);
						
				// Change Window Title
				window_set_caption(global.filename + " - BactaTank");
					
				// Create New Directory
				directory_create(global.tempDirectory + global.filename + @"\");
					
				// Set Selected
				textureStruct.textureSelected = -1;
				textureStruct.meshSelected = -1;
				textureStruct.materialSelected = -1;
					
				// Change Cursor Back To Default
				window_set_cursor(cr_default);
			}
		}
		else if (keyboard_check_pressed(ord("S")) && global.model != -1 && textureStruct.homeConfirmation == false)
		{
			var file = get_save_filename(global.saveFileName, global.filename);
			if (file != "")
			{
				window_set_cursor(cr_hourglass);
				exportBactaTankModel(global.model, file);
				window_set_cursor(cr_default);
			}
		}
		else if (keyboard_check_pressed(ord("H")) && global.model != -1 && textureStruct.homeConfirmation == false)
		{
			textureStruct.homeConfirmation = true;
		}
	}
	
	// Check If File Is Being Dragged Onto The App
	var ext = [".ghg"];
	var array = file_dropper_get_files(ext);
	file_dropper_flush();

	if (array_length(array) > 0 && file_exists(array[0]) && !textureStruct.homeConfirmation) {
		// Change Cursor To Loading Cursor
		window_set_cursor(cr_hourglass);
		
		// Destroy Old Model If It's Loaded
		if (global.model != -1) destroyBactaTankModel(global.model);
		
		// Get File Name
		var split = string_split(array[0] + @"\", @"\");
		global.filename = split[array_length(split)-1];
		
		// Load New Model
		global.model = loadBactaTankModel(array[0]);
		
		// Change Window Title
		window_set_caption(global.filename + " - BactaTank");
		
		// Set Selected
		textureStruct.textureSelected = -1;
		textureStruct.meshSelected = -1;
		textureStruct.materialSelected = -1;
		
		// Change Cursor Back To Default
		window_set_cursor(cr_default);
	}
}

#endregion