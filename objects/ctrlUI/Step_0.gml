/// @desc UI

if (imguigml_ready())
{
	//// Main title bar
	//if (imguigml_begin_main_menu_bar())
	//{
	//	imguigml_end_tab_bar();
	//}
	
	//uiMainProjectPanel(uiController, global.model);
	//uiMainCharacterPanel(uiController, global.model);
	//uiMainViewerPanel(uiController, global.model);
	//uiMainDebugPanel(uiController, global.model);
	//uiMainEditorPanel(uiController, global.model);
	//uiFileMenu();
	//uiProjectWindow();
	if (textureStruct.toolSelected == "" && !textureStruct.settingsPage)
	{
		uiShortcuts(textureStruct);
		if (global.model == -1 && !textureStruct.homeConfirmation) uiAlphaHomeScreen(textureStruct);
		if (global.model != -1 && !textureStruct.homeConfirmation) uiAlphaMainScreen(textureStruct);
		if (textureStruct.homeConfirmation) uiAlphaGoHomeScreen(textureStruct);
	}
	else
	{
		if (!textureStruct.homeConfirmation) uiAlphaPreferencesScreen(textureStruct);
	}
}