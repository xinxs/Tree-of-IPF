function CHAT_OPTION_ON_INIT(addon, frame)endfunction CHAT_OPTION_CREATE(addon, frame)	local slide_opacity = GET_CHILD(frame, "slide_opacity");	local opacity = config.GetConfigInt("CHAT_OPACITY", 255);	slide_opacity:SetLevel(opacity);	local slide_fontsize = GET_CHILD(frame, "slide_fontsize");	local fontSize = config.GetConfigInt("CHAT_FONTSIZE", 100);	slide_fontsize:SetLevel(fontSize);endfunction CHAT_OPTION_OPEN(frame)	local beforeOpacity = config.GetConfigInt("CHAT_OPACITY", 255);	frame:SetUserValue("BEFORE_OPACITY", beforeOpacity);	  local chatframe = ui.GetFrame('chat');	frame:SetMargin(chatframe:GetX() + 470,chatframe:GetY() - 295,0,0)endfunction CHAT_OPTION_APPLY(frame)		local slide_opacity = GET_CHILD(frame, "slide_opacity", "ui::CSlideBar");	config.SetConfig("CHAT_OPACITY", slide_opacity:GetLevel());	CHAT_OPTION_OPEN(frame);	frame:ShowWindow(0);endfunction CHAT_OPTION_CANCEL(frame)	local beforeOpacity = frame:GetUserIValue("BEFORE_OPACITY");	CHAT_SET_OPACITY(beforeOpacity);	local slide_opacity = GET_CHILD(frame, "slide_opacity", "ui::CSlideBar");	slide_opacity:SetLevel(beforeOpacity);	frame:ShowWindow(0);endfunction CHATOPTION_OPACITY(frame, slide, str, num)		config.SetConfig("CHAT_OPACITY", num);	CHAT_SET_OPACITY(num);endfunction CHATOPTION_FONTSIZE(frame, slide, str, num)		config.SetConfig("CHAT_FONTSIZE", num);	CHAT_SET_FONTSIZE(num);end