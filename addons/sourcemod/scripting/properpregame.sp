#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#undef REQUIRE_PLUGIN

#define PLUGIN_NAME	"Proper Pregame"
#define PLUGIN_AUTHOR	"Fishage"
#define PLUGIN_VERSION	"2.0"

enum Gamemode
{
	Unknown = 0,
	Sixes = 1,
	Highlander = 2
}

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Make pregame fun again",
	version = PLUGIN_VERSION,
	url = "https://github.com/AJagger/ProperPregame"
}

new bool:bDisableStickies = true;
new bool:bDisableSentries = true;
new bool:bDisableAfterburn = true;
new bool:bDisableClassLimits = true;
new int:iSetGamemode = -1;

new Handle:hDisableStickies = INVALID_HANDLE;
new Handle:hDisableSentries = INVALID_HANDLE;
new Handle:hDisableAfterburn = INVALID_HANDLE;
new Handle:hDisableClassLimits = INVALID_HANDLE;
new Handle:hSetGamemode = INVALID_HANDLE;

public OnPluginStart()
{
	CreateConVar("pp", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED);
	hDisableStickies = CreateConVar("pp_disableStickies", "1", "Disable sticky damage", FCVAR_NOTIFY);
	hDisableSentries = CreateConVar("pp_disableSentries", "1", "Disable sentry damage", FCVAR_NOTIFY);
	hDisableAfterburn = CreateConVar("pp_disableAfterburn", "1", "Disable afterburn damage", FCVAR_NOTIFY);
	hDisableClassLimits = CreateConVar("pp_disableClassLimits", "1", "Disable config-enforced class limits in pregame", FCVAR_NOTIFY);
	hSetGamemode = CreateConVar("pp_setGamemode", "c", "Select a gamemode for ProperPregame to use when reinstating class limits", FCVAR_NOTIFY);
	
	
	HookConVarChange(hDisableStickies, handler_ConVarChange);
	HookConVarChange(hDisableSentries, handler_ConVarChange);
	HookConVarChange(hDisableAfterburn, handler_ConVarChange);
	HookConVarChange(hDisableClassLimits, handler_ConVarChange);
	HookConVarChange(hSetGamemode, handler_ConVarChange);
	
	RegServerCmd("pp_getGamemode", GetGameModeType);
	RegServerCmd("pp_removeClassLimits", RemoveClassLimits);
	
	//Hook players already in the game. Used on plugin reload.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, HandleDamage);
		}
	} 	
}

public OnPluginEnd()
{
	if(bDisableClassLimits)
	{
		if(iSetGamemode == -1)
		{
			iSetGamemode = DetermineGameModeType();
		}
		
		switch (iSetGamemode)
		{
			case Sixes:
			{
				EnforceEtf2l6v6ClassLimits();
			}
			case Highlander:
			{
				EnforceEtf2l9v9ClassLimits();
			}
			default:
			{
				PrintToChatAll("[ProperPregame] WARNING: Gamemode could not be established. No class limits have been enforced.");
			}
		}
	}
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, HandleDamage);
}

public handler_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	if (convar == hDisableStickies) 
	{
		if(StringToInt(newValue) == 0)
		{
			bDisableStickies = false;
		}
		else
		{
			bDisableStickies = true;
		}
	} 
	else if (convar == hDisableSentries) 
	{
		if(StringToInt(newValue) == 0)
		{
			bDisableSentries = false;
		}
		else
		{
			bDisableSentries = true;
		}
	}
	else if (convar == hDisableAfterburn) 
	{
		if(StringToInt(newValue) == 0)
		{
			bDisableAfterburn = false;
		}
		else
		{
			bDisableAfterburn = true;
		}
	}
	else if (convar == hDisableClassLimits) 
	{
		if(StringToInt(newValue) == 0)
		{
			bDisableClassLimits = false;
		}
		else
		{
			bDisableClassLimits = true;
		}
	}
	else if (convar == hSetGamemode) 
	{
		if(StrEqual(newValue, "6v6", false) || StrEqual(newValue, "6", false))
		{
			iSetGamemode = Sixes;
		}
		else if(StrEqual(newValue, "9v9", false) || StrEqual(newValue, "9", false))
		{
			iSetGamemode = Highlander;
		}
		else if(StrEqual(newValue, "clear", false) || StrEqual(newValue, "c", false))
		{
			iSetGamemode = -1;
		}
	}
}

public bool DefIdIsStickyLauncher(defid)
{
	//This is really fucking messy. Ideally would use defid to check for weapon_class == tf_weapon_pipebomblauncher but not sure how
	if(defid == 20 || 		//StickyBomb Launcher
		defid == 130 ||		//Scottish Resistance
		defid == 207 ||		//Stickybomb Launcher (Renamed/Strange)
		defid == 1150 ||	//The Quickiebomb Launcher
		defid == 661 ||		//Festive Stickybomb Launcher 
		defid == 797 ||		//Silver Botkiller Stickybomb Launcher Mk.I
		defid == 806 ||		//Gold Botkiller Stickybomb Launcher Mk.I 
		defid == 886 ||		//Rust Botkiller Stickybomb Launcher Mk.I 
		defid == 895 ||		//Blood Botkiller Stickybomb Launcher Mk.I 
		defid == 904 ||		//Carbonado Botkiller Stickybomb Launcher Mk.I 
		defid == 913 ||		//Diamond Botkiller Stickybomb Launcher Mk.I
		defid == 962 ||		//Silver Botkiller Stickybomb Launcher Mk.II 
		defid == 971 ||		//Gold Botkiller Stickybomb Launcher Mk.II 
		defid == 15009 ||	//Sudden Flurry 
		defid == 15012 ||	//Carpet Bomber 
		defid == 15024 ||	//Blasted Bombardier
		defid == 15038 ||	//Rooftop Wrangler 
		defid == 15045 ||	//Liquid Asset 
		defid == 15048 ||	//Pink Elephant 
		defid == 15082 ||	//Autumn 
		defid == 15083 ||	//Pumpkin Patch 
		defid == 15084 ||	//Macabre Web 
		defid == 15113 ||	//Sweet Dreams 
		defid == 15137 ||	//Coffin Nail 
		defid == 15138 ||	//Dressed to Kill 
		defid == 15155)		//Blitzkrieg
	{
		return true;
	}
	
	return false;	
}

public bool DamageTypeIsAfterburn(damagetype)
{
	return damagetype == 2056;
}

public Action HandleDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{	
	//Check to see if damage is caused by a sentry. Uses same logic (weapon = -1) as F2's Supplemental Stats
	if(bDisableSentries && weapon == -1)
	{
		if (inflictor > MaxClients && IsValidEntity(inflictor))
		{			
			if(victim <= MAXPLAYERS && attacker <= MAXPLAYERS)
			{
				//Check to see if the damaged player is the engineer who owns the sentry
				//If sentry owner is the victim, allow damage
				if(victim == attacker){
					return Plugin_Continue;
				}
				//If sentry owner is not the victim, disallow damage
				else
				{
					return Plugin_Handled;
				}
			}
		}
	}
	
	//For all weapons other than sentries...
	//Get weapon item definition id
	int defid = -1;
	
	if (IsValidEntity(weapon))
	{
		defid = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	}
	else
	{ 
		//Invalid weapon, ignore
		return Plugin_Continue;			
	}
	
	//PrintToChatAll("%i", defid);
	//PrintToChatAll("%i", damagetype);
	
	//Check to see if the damage is caused by stickies
	if(bDisableStickies && DefIdIsStickyLauncher(defid))
	{
		//Check to see if the damaged player is the demo who shot the sticky			
		if(victim <= MAXPLAYERS && attacker <= MAXPLAYERS)
		{
			//If demo is the victim, allow damage
			if(victim == attacker){
				return Plugin_Continue;
			}
			//If the demo is not the victim, disallow damage
			else
			{
				return Plugin_Handled;
			}
		}					
	}
	
	//Check to see if the damage is caused by afterburn
	if(bDisableAfterburn && DamageTypeIsAfterburn(damagetype))
	{
		return Plugin_Handled;				
	}
	
	//If nothing caught, continue with no actions
	return Plugin_Continue;
}

public Action GetGameModeType(int args)
{
	PrintToChatAll("%i", DetermineGameModeType());
}

public Action RemoveClassLimits(int args)
{
	ServerCommand("tf_tournament_classlimit_scout -1");
	ServerCommand("tf_tournament_classlimit_soldier -1");
	ServerCommand("tf_tournament_classlimit_pyro -1");
	ServerCommand("tf_tournament_classlimit_demoman -1");
	ServerCommand("tf_tournament_classlimit_heavy -1");
	ServerCommand("tf_tournament_classlimit_engineer -1");
	ServerCommand("tf_tournament_classlimit_medic -1");
	ServerCommand("tf_tournament_classlimit_sniper -1");
	ServerCommand("tf_tournament_classlimit_spy -1");
	
	PrintToChatAll("[ProperPregame] Config-enforced class limits removed.");
	
	return Plugin_Handled;
}

EnforceEtf2l6v6ClassLimits()
{
	ServerCommand("tf_tournament_classlimit_scout 2");
	ServerCommand("tf_tournament_classlimit_soldier 2");
	ServerCommand("tf_tournament_classlimit_pyro 1");
	ServerCommand("tf_tournament_classlimit_demoman 1");
	ServerCommand("tf_tournament_classlimit_heavy 1");
	ServerCommand("tf_tournament_classlimit_engineer 1");
	ServerCommand("tf_tournament_classlimit_medic 1");
	ServerCommand("tf_tournament_classlimit_sniper 1");
	ServerCommand("tf_tournament_classlimit_spy 2");
	
	PrintToChatAll("[ProperPregame] ETF2L 6v6 class limits re-enabled.");
}

EnforceEtf2l9v9ClassLimits()
{
	ServerCommand("tf_tournament_classlimit_scout 1");
	ServerCommand("tf_tournament_classlimit_soldier 1");
	ServerCommand("tf_tournament_classlimit_pyro 1");
	ServerCommand("tf_tournament_classlimit_demoman 1");
	ServerCommand("tf_tournament_classlimit_heavy 1");
	ServerCommand("tf_tournament_classlimit_engineer 1");
	ServerCommand("tf_tournament_classlimit_medic 1");
	ServerCommand("tf_tournament_classlimit_sniper 1");
	ServerCommand("tf_tournament_classlimit_spy 1");
	
	PrintToChatAll("[ProperPregame] ETF2L 9v9 class limits re-enabled.");
}

public int DetermineGameModeType()
{
	new redCount = GetTeamClientCount(2);
	new bluCount = GetTeamClientCount(3);
	
	new avgTeamSize = (redCount + bluCount)/2
	
	if (avgTeamSize == 6)
	{
		return Sixes;
	}	
	else if (avgTeamSize == 9)
	{
		return Highlander;
	}
	else
	{
		//If number of players are not exactly 6v6 or 9v9 then fuzzy match to gamemode or select unknown if the difference is too great.
		if(4 < avgTeamSize < 8)
		{
			return Sixes;
		}
		else if(7 < avgTeamSize < 11)
		{
			return Highlander;
		}
		else
		{
			return Unknown;
		}
	}
}