
function COMPANIONHIRE_ON_INIT(addon, frame)
	addon:RegisterMsg('BUY_SLOT', 'REQ_CHAR_SLOT_BUY');
end

function OPEN_COMPANION_HIRE(clsName)
	
	local frame = ui.GetFrame("companionhire");
	frame:ShowWindow(1);

	frame:SetUserValue("CLSNAME", clsName);
	local cls = GetClass("Companion", clsName);
	
	local input = frame:GetChild("input");
	input:SetText("");

	local price = frame:GetChild("price");
	local sellPrice = cls.SellPrice;
	if sellPrice ~= "None" then
		sellPrice = _G[sellPrice];
		sellPrice = sellPrice(cls, pc);
		price:SetTextByKey("value", GET_MONEY_IMG(24) .. " " .. GetCommaedText(sellPrice));
	else
		price:SetTextByKey("value", "");
	end

	local monCls = GetClass("Monster", clsName);
	local pic = GET_CHILD(frame ,"pic", "ui::CPicture");
	pic:SetImage(monCls.Icon);
	
	local petname = frame:GetChild("petname");
	petname:SetTextByKey("value", monCls.Name);
        

end

function TRY_COMPANION_HIRE()
	local frame = ui.GetFrame("companionhire");
	local clsName = frame:GetUserValue("CLSNAME");
	local exchange = frame:GetUserIValue("EXCHANGE_TIKET");
	
	if 0 < exchange then
		frame:SetUserValue("EXCHANGE_TIKET", 0);
		TRY_CECK_BARRACK_SLOT_BY_COMPANION_EXCHANGE(exchange);
		return;
	end

	local cls = GetClass("Companion", clsName);
	local sellPrice = cls.SellPrice;
	if sellPrice == "None" then
		return;
	end

		sellPrice = _G[sellPrice];
		sellPrice = sellPrice(cls, pc);

	local name = frame:GetChild("input");
		if string.find(name:GetText(), ' ') ~= nil then
			ui.SysMsg(ClMsg("NameCannotIncludeSpace"));
			return;
		end

	if ui.IsValidCharacterName(name:GetText()) == false then
		return;
	end
			if GET_TOTAL_MONEY() < sellPrice then
				ui.SysMsg(ClMsg('NotEnoughMoney'));
			else
				local scpString = string.format("EXEC_BUY_COMPANION(\"%s\", \"%s\")", clsName, name:GetText());
				ui.MsgBox(ScpArgMsg("ReallyBuyCompanion?"), scpString, "None");
			end
		end

function TRY_CECK_BARRACK_SLOT_BY_COMPANION_EXCHANGE(select)
	local accountInfo = session.barrack.GetMyAccount();
	local myCharCont = accountInfo:GetPCCount() + accountInfo:GetPetCount();
	local buySlot = session.loginInfo.GetBuySlotCount();
	local barrackCls = GetClass("BarrackMap", accountInfo:GetThemaName());
	
	if myCharCont > barrackCls.MaxCashPC + barrackCls.BaseSlot then
		ui.SysMsg(ClMsg('CanCreateCharCuzMaxSlot')); -- 구입할 슬롯이 없다는거
		return;
	end

	local itemIES = "None"
	local itemCls = nil;
	
	if 1 == select then
		itemCls = GetClass('Item', 'JOB_VELHIDER_COUPON')
		local item = session.GetInvItemByName("JOB_VELHIDER_COUPON");
		if nil == item then
			return;
		end
		itemIES = item:GetIESID();
	elseif 2 == select then
		itemCls = GetClass('Item', 'JOB_HAWK_COUPON')
		local item = session.GetInvItemByName("JOB_HAWK_COUPON");
		if nil == item then
			return;
		end
		itemIES = item:GetIESID();
	end

	if nil == itemCls then
		return;
	end
	local monCls =	GetClass("Monster", itemCls.StringArg);

	local argList = string.format("%d", monCls.ClassID);
	if myCharCont < barrackCls.BaseSlot + buySlot then
		pc.ReqExecuteTx_Item("SCR_USE_ITEM_COMPANION", itemIES, argList);
		return;
	end

		-- 슬롯 산다는거
	if myCharCont >= barrackCls.BaseSlot and buySlot + barrackCls.BaseSlot <= barrackCls.MaxCashPC then
		local frame = ui.GetFrame("companionhire");
		frame:SetUserValue("EXCHANGE_TIKET", select);
		control.ReqCharSlotTPPrice();
		return;
	end
	pc.ReqExecuteTx_Item("SCR_USE_ITEM_COMPANION", itemIES, argList);
end

function TRY_CHECK_BARRACK_SLOT(handle)
	local accountInfo = session.barrack.GetMyAccount();
	local myCharCont = accountInfo:GetPCCount() + accountInfo:GetPetCount();
	local buySlot = session.loginInfo.GetBuySlotCount();
	local barrackCls = GetClass("BarrackMap", accountInfo:GetThemaName());
	if myCharCont > barrackCls.MaxCashPC + barrackCls.BaseSlot then
		ui.SysMsg(ClMsg('CanCreateCharCuzMaxSlot')); -- 구입할 슬롯이 없다는거
		return;
	end
	
	if myCharCont < barrackCls.BaseSlot + buySlot then
		if session.GetMapName() ~= "guild_agit_1" then
			TRY_COMPANION_HIRE();
		else
			GUILD_SEND_CLICK_TRIGGER(handle);
			return 1;
		end
		return 0;
	end
	
	-- 슬롯 산다는거
	if myCharCont >= barrackCls.BaseSlot and buySlot + barrackCls.BaseSlot <= barrackCls.MaxCashPC then
		control.ReqCharSlotTPPrice();
		return 0;
	end

	if session.GetMapName() ~= "guild_agit_1" then
		 TRY_COMPANION_HIRE();
	else
		GUILD_SEND_CLICK_TRIGGER(handle);
		return 1;
	end
	return 0;
end

function REQ_CHAR_SLOT_BUY(frame, msg, argStr, argNum)
	local str = ScpArgMsg('{TP}ReqSlotBuy', "TP", argNum);
	if nil == str then
		return;
	end

	local yesScp = string.format("control.ReqCharSlotToZone()");
	ui.MsgBox(ClMsg("DontHaveSlot")..str, yesScp, "None");
end

function EXEC_BUY_COMPANION(clsName, inputName)

	local petCls = GetClass("Companion", clsName);
	local scpString = string.format("/pethire %d %s",  petCls.ClassID, inputName);
	ui.Chat(scpString);
end

function PET_ADOPT_SUC()
	ui.CloseFrame("companionhire");
	ui.CloseFrame("companionshop");

	ui.SysMsg(ClMsg("CompanionAdoptionSuccess"));
end

function PET_ADOPT_SUC_BARRACK()
	ui.CloseFrame("companionhire");
	ui.CloseFrame("companionshop");

	ui.SysMsg(ClMsg("CompanionAdoptionSuccessBarrack"));
end

