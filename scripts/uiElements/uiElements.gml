#region Character Panel

function uiMainCharacterPanel(uiController, project)
{
	// Character
	var character = project;
	
	// ImGUI Main Character Panel
	imguigml_set_next_window_size(floor(global.screenWidth/4), floor(global.screenHeight/3 * 2), EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, floor(global.screenHeight/3), EImGui_Cond.Always);
	
	// Begin Window
	var ret = imguigml_begin("MainCharacterPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse);
	
	if (ret[0])
	{
		// Selected Character
		imguigml_text("LANDO_GENERAL");
		var cur = imguigml_get_cursor_pos();
		imguigml_set_cursor_pos(cur[0], cur[1]+3);
		imguigml_separator();
		
		// Character Attributes
		imguigml_push_style_color(EImGui_Col.ChildBg, 0, 0, 0, 0);
		if (imguigml_begin_child("CharacterAttributes"))
		{
			// Text File
			imguigml_set_cursor_pos(0, 2);
			imguigml_selectable("##hiddenTextFile");
			imguigml_same_line();
			var cur = imguigml_get_cursor_pos();
			imguigml_set_cursor_pos(cur[0] + 14, cur[1]);
			imguigml_text("LANDO_GENERAL.TXT");
			
			// Model
			imguigml_selectable("##hiddenModelHigh", false, EImGui_SelectableFlags.AllowItemOverlap);
			imguigml_same_line();
			var cur = imguigml_get_cursor_pos();
			imguigml_set_cursor_pos(4, cur[1] + 2);
			imguigml_sprite(collapseArrow, uiController.dropdowns.modelDropdown);
			if (imguigml_is_item_clicked()) uiController.dropdowns.modelDropdown = !uiController.dropdowns.modelDropdown;
			imguigml_same_line();
			imguigml_set_cursor_pos(cur[0] + 14, cur[1]);
			imguigml_text("LANDO_GENERAL_PC.GHG");
			
			if (uiController.dropdowns.modelDropdown)
			{
				// Textures
				imguigml_selectable("##hiddenModelTextures", false, EImGui_SelectableFlags.AllowItemOverlap);
				imguigml_same_line();
				var cur = imguigml_get_cursor_pos();
				imguigml_set_cursor_pos(20, cur[1] + 2);
				imguigml_sprite(collapseArrow, uiController.dropdowns.modelTexturesDropdown);
				if (imguigml_is_item_clicked()) uiController.dropdowns.modelTexturesDropdown = !uiController.dropdowns.modelTexturesDropdown;
				imguigml_same_line();
				imguigml_set_cursor_pos(cur[0] + 30, cur[1]);
				imguigml_text("Textures");
				
				if (uiController.dropdowns.modelTexturesDropdown)
				{
					for (var i = 0; i < array_length(character.nu20.textureMetaData); i++)
					{
						if (imguigml_selectable("##hiddenTexture" + string(i), ("##hiddenTexture" + string(i)) == uiController.characterAttributeSelected)[0]) uiController.characterAttributeSelected = "##hiddenTexture" + string(i);
						imguigml_same_line();
						var cur = imguigml_get_cursor_pos();
						imguigml_set_cursor_pos(cur[0] + 46, cur[1]);
						imguigml_text("Texture " + string(character.nu20.textureMetaData[i].index));
					}
				}
				
				// Meshes
				imguigml_selectable("##hiddenModelMeshes", false, EImGui_SelectableFlags.AllowItemOverlap);
				imguigml_same_line();
				var cur = imguigml_get_cursor_pos();
				imguigml_set_cursor_pos(20, cur[1] + 2);
				imguigml_sprite(collapseArrow, uiController.dropdowns.modelMeshesDropdown);
				if (imguigml_is_item_clicked()) uiController.dropdowns.modelMeshesDropdown = !uiController.dropdowns.modelMeshesDropdown;
				imguigml_same_line();
				imguigml_set_cursor_pos(cur[0] + 30, cur[1]);
				imguigml_text("Meshes");
				
				if (uiController.dropdowns.modelMeshesDropdown)
				{
					for (var i = 0; i < array_length(character.nu20.meshes); i++)
					{
						if (imguigml_selectable("##hiddenMesh" + string(i), ("##hiddenMesh" + string(i)) == uiController.characterAttributeSelected)[0]) uiController.characterAttributeSelected = "##hiddenMesh" + string(i);
						imguigml_same_line();
						var cur = imguigml_get_cursor_pos();
						imguigml_set_cursor_pos(cur[0] + 46, cur[1]);
						imguigml_text("Mesh " + string(i));
					}
				}
				
				imguigml_selectable("##hiddenModelMaterials", false, EImGui_SelectableFlags.AllowItemOverlap);
				imguigml_same_line();
				var cur = imguigml_get_cursor_pos();
				imguigml_set_cursor_pos(20, cur[1] + 2);
				imguigml_sprite(collapseArrow, uiController.dropdowns.modelMaterialsDropdown);
				if (imguigml_is_item_clicked()) uiController.dropdowns.modelMaterialsDropdown = !uiController.dropdowns.modelMaterialsDropdown;
				imguigml_same_line();
				imguigml_set_cursor_pos(cur[0] + 30, cur[1]);
				imguigml_text("Materials");
				
				// Materials
				if (uiController.dropdowns.modelMaterialsDropdown)
				{
					for (var i = 0; i < array_length(character.nu20.materials); i++)
					{
						if (imguigml_selectable("##hiddenMaterial" + string(i), ("##hiddenMaterial" + string(i)) == uiController.characterAttributeSelected)[0]) uiController.characterAttributeSelected = "##hiddenMaterial" + string(i);
						imguigml_same_line();
						var cur = imguigml_get_cursor_pos();
						imguigml_set_cursor_pos(cur[0] + 46, cur[1]);
						imguigml_text("Material " + string(i));
					}
				}
			
				imguigml_selectable("##hiddenModelLayers");
				imguigml_same_line();
				var cur = imguigml_get_cursor_pos();
				imguigml_set_cursor_pos(20, cur[1] + 2);
				imguigml_sprite(collapseArrow, 0);
				imguigml_same_line();
				imguigml_set_cursor_pos(cur[0] + 30, cur[1]);
				imguigml_text("Layers");
			
				imguigml_selectable("##hiddenModelBones");
				imguigml_same_line();
				var cur = imguigml_get_cursor_pos();
				imguigml_set_cursor_pos(20, cur[1] + 2);
				imguigml_sprite(collapseArrow, 0);
				imguigml_same_line();
				imguigml_set_cursor_pos(cur[0] + 30, cur[1]);
				imguigml_text("Bones");
			
				imguigml_selectable("##hiddenModelLocators");
				imguigml_same_line();
				var cur = imguigml_get_cursor_pos();
				imguigml_set_cursor_pos(20, cur[1] + 2);
				imguigml_sprite(collapseArrow, 0);
				imguigml_same_line();
				imguigml_set_cursor_pos(cur[0] + 30, cur[1]);
				imguigml_text("Locators");
			}
			
			imguigml_end_child();
		}
		imguigml_push_style_color(EImGui_Col.ChildBg, 0.13, 0.13, 0.13, 1);
		
		imguigml_end();
	}
}

#endregion

#region Project Panel

function uiMainProjectPanel(uiController, project)
{
	// Character
	var character = project;
	
	// ImGUI Main Character Panel
	imguigml_set_next_window_size(floor(global.screenWidth/4), floor(global.screenHeight/3) - 23, EImGui_Cond.Always);
	imguigml_set_next_window_pos(0, 22, EImGui_Cond.Once);
	
	// Begin Window
	var ret = imguigml_begin("MainProjectPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse);
	
	if (ret[0])
	{
		// Title Bar
		imguigml_text("Untitled Project");
		
		// Get Current Cursor
		imguigml_same_line();
		var cur = imguigml_get_cursor_pos();
		
		// Buttons
		imguigml_set_cursor_pos(floor(global.screenWidth/4) - 50, cur[1]-3);
		imguigml_button("+", 22, 22);
		imguigml_set_cursor_pos(floor(global.screenWidth/4) - 26, cur[1]-3);
		imguigml_button("-", 22, 22);
		
		// Separate
		imguigml_separator();
		
		// Project Characters
		imguigml_push_style_color(EImGui_Col.ChildBg, 0, 0, 0, 0);
		if (imguigml_begin_child("ProjectCharacters"))
		{
			imguigml_set_cursor_pos(0, 2);
			imguigml_selectable("##hiddenTextFile", true);
			imguigml_same_line();
			imguigml_text("LANDO_GENERAL");
			
			imguigml_selectable("##hiddenTextFile");
			imguigml_same_line();
			imguigml_text("VENKMAN");
			
			imguigml_selectable("##hiddenTextFile");
			imguigml_same_line();
			imguigml_text("BACTABUDDY");
			
			imguigml_end_child();
		}
		imguigml_push_style_color(EImGui_Col.ChildBg, 0.13, 0.13, 0.13, 1);
		
		imguigml_end();
	}
}

#endregion

#region Viewer Panel

function uiMainViewerPanel(uiController, project)
{
	// Character
	var character = project;
	
	// ImGUI Main Character Panel
	imguigml_set_next_window_size(floor(global.screenWidth/2)-2, floor(global.screenHeight/4 * 3) - 23, EImGui_Cond.Always);
	imguigml_set_next_window_pos(floor(global.screenWidth/4)+1, 22, EImGui_Cond.Always);
	
	// Begin Window
	var ret = imguigml_begin("MainViewerPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse);
	
	if (ret[0])
	{	
		// Viewer Surface
		imguigml_push_style_color(EImGui_Col.ChildBg, 0, 0, 0, 0);
		if (imguigml_begin_child("Viewer"))
		{
			imguigml_surface(uiController.viewerSurface);
			imguigml_end_child();
		}
		imguigml_push_style_color(EImGui_Col.ChildBg, 0.13, 0.13, 0.13, 1);
		
		imguigml_end();
	}
}

#endregion

#region Editor Panel

function uiMainEditorPanel(uiController, project)
{
	// Character
	var character = project;
	
	// ImGUI Main Character Panel
	imguigml_set_next_window_size(floor(global.screenWidth/4) + 1, global.screenHeight - 22, EImGui_Cond.Always);
	imguigml_set_next_window_pos(floor(global.screenWidth/4 * 3), 22, EImGui_Cond.Always);
	
	// Begin Window
	var ret = imguigml_begin("MainEditorPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse);
	
	if (ret[0])
	{
		// Editor Title
		imguigml_text("Editor");
		var cur = imguigml_get_cursor_pos();
		imguigml_set_cursor_pos(cur[0], cur[1]+3);
		imguigml_separator();
		
		// Editor
		if (uiController.characterAttributeSelected != -1)
		{
			if (string_pos("Texture", uiController.characterAttributeSelected))
			{
				var index = string_digits(uiController.characterAttributeSelected);
				
				imguigml_sprite(character.textureSprites[character.nu20.textureMetaData[index].index], 0, 256, 256);
			}
		}
		
		imguigml_end();
	}
}

#endregion

#region Debug Panel

function uiMainDebugPanel(uiController, project)
{
	// Character
	var character = project;
	
	// ImGUI Main Character Panel
	imguigml_set_next_window_size(floor(global.screenWidth/2) - 2, floor(global.screenHeight/4), EImGui_Cond.Always);
	imguigml_set_next_window_pos(floor(global.screenWidth/4) + 1, floor(global.screenHeight/4 * 3), EImGui_Cond.Always);
	
	// Begin Window
	var ret = imguigml_begin("MainDebugPanel", undefined, EImGui_WindowFlags.NoMove | EImGui_WindowFlags.NoResize | EImGui_WindowFlags.NoTitleBar | EImGui_WindowFlags.NoScrollbar| EImGui_WindowFlags.NoScrollWithMouse);
	
	if (ret[0])
	{
		// Debug Log Title
		imguigml_text("Debug Log");
		var cur = imguigml_get_cursor_pos();
		imguigml_set_cursor_pos(cur[0], cur[1]+3);
		imguigml_separator();
		
		// Debug Log
		if (imguigml_begin_child("ProjectCharacters"))
		{
			imguigml_end_child();
		}
		
		imguigml_end();
	}
}

#endregion