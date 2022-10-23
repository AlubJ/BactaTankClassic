/// @desc UI

if (imguigml_ready())
{
	//uiFileMenu();
	//uiProjectWindow();
	if (textureStruct.toolSelected == "")
	{
		uiShortcuts(textureStruct);
		if (global.model == -1 && !textureStruct.homeConfirmation) uiAlphaHomeScreen(textureStruct);
		if (global.model != -1 && !textureStruct.homeConfirmation) uiAlphaMainScreen(textureStruct);
		if (textureStruct.homeConfirmation) uiAlphaGoHomeScreen(textureStruct);
	}
	else
	{
		if (textureStruct.toolSelected == "fe")
		{
			uiFontEditor(textureStruct);
			window_set_caption("BactaTank - Font Editor");
		}
	}
}