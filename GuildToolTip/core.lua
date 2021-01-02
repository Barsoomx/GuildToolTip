local GTT = GameTooltip;
local GuildInfo = {};
local mfloor = math.floor;
local InCombatLockdown, GetTime, UnitIsPlayer = InCombatLockdown, GetTime, UnitIsPlayer
local GetMouseFocus, GetNumGuildMembers, GetGuildRosterInfo = GetMouseFocus, GetNumGuildMembers, GetGuildRosterInfo
local lastScan = GetTime() - 20

GTT:HookScript("OnTooltipSetUnit",function(self,...)
    if InCombatLockdown() == 1 then return end
    local _, unit = self:GetUnit();
    if (not unit) then
        local mFocus = GetMouseFocus();
        if (mFocus) and (mFocus.unit) then
            unit = mFocus.unit;
        end
    end
    GIScan()
    local uId = unit or "player"
    local uname = UnitName(uId);
    if (UnitIsPlayer(uId)) then
        if GuildInfo[uname] then
            self:AddLine("Rank: |cFFFFFFFF" .. GuildInfo[uname].rank .. "|r");
            self:AddLine(format("Note: |cFFFFFFFF[|r|cff00ff10%s|r|cFFFFFFFF]|r",GuildInfo[uname].note));
            if EPGP then
                local ep, gp, main = EPGP:GetEPGP(uname);
				if (not ep) then self:AddLine("EPGP: |cFFFFFFFF" .. GuildInfo[uname].EPGP .. "|r") end
                main = main or uname
                if ep and gp and main then
                    self:AddLine("EPGP: |cFFFFFFFF" .. main .. "->".. ep .. ", " .. gp .. ", " .. round(ep/gp, 2)  .. "|r");
                end
            else
                self:AddLine("EPGP: |cFFFFFFFF" .. GuildInfo[uname].EPGP .. "|r");
            end
        end
    end
end);

function GIScan()
    if (GetTime() - lastScan > 30) and InCombatLockdown() ~= 1 then
        if GRN and GRN.MyGUILD then
            GuildInfo = GRN.MyGUILD
        else
            for i = 1, GetNumGuildMembers() do
                local name, rank, _, _, _, _, note, officernote = GetGuildRosterInfo(i);
                GuildInfo[name] = {};
                GuildInfo[name].rank = rank;
                GuildInfo[name].note = note;
                GuildInfo[name].EPGP = officernote;
            end
        end
        lastScan = GetTime()
	end
end

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return mfloor(num * mult + 0.5) / mult
end