function imGuiInit(){
	if (!instance_exists(imgui)) {
		instance_create_depth(0, 0, depth-10, imgui);
		
		global.font = imguigml_add_font_from_ttf("styles/nunito.ttf", 16);
		var timeSource = time_source_create(time_source_game, 1, time_source_units_frames, function() {imguigml_push_font(global.font)}, [], -1, time_source_expire_after);
		time_source_start(timeSource);
		
		// Colours \\
		imguigml_push_style_color(EImGui_Col.WindowBg, 0.07, 0.07, 0.07, 1);
		imguigml_push_style_color(EImGui_Col.TitleBg, 0.16, 0.16, 0.16, 1);
		imguigml_push_style_color(EImGui_Col.TitleBgActive, 0.18, 0.18, 0.18, 1);
		imguigml_push_style_color(EImGui_Col.MenuBarBg, 0.13, 0.13, 0.13, 1);
		imguigml_push_style_color(EImGui_Col.ChildBg, 0.13, 0.13, 0.13, 1);
		imguigml_push_style_color(EImGui_Col.PopupBg, 0.07, 0.07, 0.07, 1);
		imguigml_push_style_color(EImGui_Col.Button, 1, 1, 1, 0);
		imguigml_push_style_color(EImGui_Col.ButtonHovered, 1, 1, 1, 0.13);
		imguigml_push_style_color(EImGui_Col.ButtonActive, 1, 1, 1, 0.20);
		imguigml_push_style_color(EImGui_Col.Header, 0.15, 0.15, 0.15, 1);
		imguigml_push_style_color(EImGui_Col.HeaderHovered, 0.17, 0.17, 0.17, 1);
		imguigml_push_style_color(EImGui_Col.HeaderActive, 0.16, 0.16, 0.16, 1);
		imguigml_push_style_color(EImGui_Col.FrameBg, 0.17, 0.17, 0.17, 1);
		imguigml_push_style_color(EImGui_Col.FrameBgHovered, 0.20, 0.20, 0.20, 1);
		imguigml_push_style_color(EImGui_Col.FrameBgActive, 0.20, 0.20, 0.20, 1);
		imguigml_push_style_color(EImGui_Col.CheckMark, 0.5, 0.5, 0.5, 1);
		imguigml_push_style_color(EImGui_Col.SliderGrab, 0.39, 0.39, 0.39, 1);
		imguigml_push_style_color(EImGui_Col.SliderGrabActive, 0.43, 0.43, 0.43, 1);
		imguigml_push_style_color(EImGui_Col.Tab, 1, 1, 1, 0);
		imguigml_push_style_color(EImGui_Col.TabActive, 0.13, 0.13, 0.13, 1);
		imguigml_push_style_color(EImGui_Col.TabHovered, 0.20, 0.20, 0.20, 1);
	
		//  Other  \\
		imguigml_push_style_var(EImGui_StyleVar.WindowBorderSize, 0);
		imguigml_push_style_var(EImGui_StyleVar.ChildBorderSize, 0);
		imguigml_push_style_var(EImGui_StyleVar.PopupBorderSize, 0);
		imguigml_push_style_var(EImGui_StyleVar.FrameBorderSize, 0);
		imguigml_push_style_var(EImGui_StyleVar.WindowRounding, 0);
		imguigml_push_style_var(EImGui_StyleVar.ChildRounding, 3);
		imguigml_push_style_var(EImGui_StyleVar.FrameRounding, 3);
		imguigml_push_style_var(EImGui_StyleVar.PopupRounding, 0);
		imguigml_push_style_var(EImGui_StyleVar.ScrollbarRounding, 3);
		imguigml_push_style_var(EImGui_StyleVar.GrabRounding, 3);
		imguigml_push_style_var(EImGui_StyleVar.TabRounding, 3);
	
		//imguigml_push_font(font);
	}
}

function imguigml_tooltip(desc)
{
    imguigml_text_disabled("(?)");
    if (imguigml_is_item_hovered())
    {
        imguigml_begin_tooltip();
        imguigml_push_text_wrap_pos(imguigml_get_font_size() * 35.0);
        imguigml_text(desc);
        imguigml_pop_text_wrap_pos();
        imguigml_end_tooltip();
    }
}

function imguigml_tooltip_element(desc)
{
    if (imguigml_is_item_hovered())
    {
        imguigml_begin_tooltip();
        imguigml_push_text_wrap_pos(imguigml_get_font_size() * 35.0);
        imguigml_text(desc);
        imguigml_pop_text_wrap_pos();
        imguigml_end_tooltip();
    }
}

function imguigml_input_int_clamp(_label, _val, _width = 0, _min, _max)
{
	var textRet = [0, 0];
	var changed = false;
	if (imguigml_begin_child(_label + "Child", _width, 100, false, EImGui_WindowFlags.NoScrollbar)) // Workaround for shitty separators
	{
		imguigml_set_cursor_pos(0, 0);
		imguigml_push_item_width(_width - 44);
		textRet = imguigml_input_text(_label + "ChildText", string(_val), 3, EImGui_InputTextFlags.CharsDecimal);
		if (textRet[0] && textRet[1] != "" && string_is_real(textRet[1])) _val = real(textRet[1]); changed = true;
		imguigml_pop_item_width();
		imguigml_set_cursor_pos(_width-44, 0);
		if (imguigml_button("-", 22, 22))
		{
			_val--;
			changed = true;
		}
		imguigml_set_cursor_pos(_width-22, 0);
		if (imguigml_button("+", 22, 22))
		{
			_val++;
			changed = true;
		}
		imguigml_end_child();
	}
	
	return [changed, clamp(_val, _min, _max)];
}