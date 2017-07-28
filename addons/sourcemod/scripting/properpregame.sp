#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

#define MAXWEPNAMELEN 72

#define PLUGIN_NAME		"Proper Pregame"
#define PLUGIN_AUTHOR	"Aidan Jagger"
#define PLUGIN_VERSION	"1.0"

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Make pregame fun again",
	version = PLUGIN_VERSION,
	url = ""
}

new bool:bDisableStickies = true;
new bool:bDisableSentries = true;
new Handle:hDisableStickies = INVALID_HANDLE;
new Handle:hDisableSentries = INVALID_HANDLE;

public OnPluginStart()
{
	//HookEvent("player_hurt", HandleDamage, EventHookMode_Pre);
/* 	RegAdminCmd("pp_list", ListCmds, ADMFLAG_RCON, "List Proper Pregame commands");
	RegAdminCmd("pp_status", PPStatus, ADMFLAG_RCON, "Proper Pregame status");
	RegAdminCmd("pp_enable", PPEnable, ADMFLAG_RCON, "Enable Proper Pregame");
	RegAdminCmd("pp_disable", PPDisable, ADMFLAG_RCON, "Disable Proper Pregame");
	RegAdminCmd("pp_toggle_sentry_dmg", ToggleSentryDamage, ADMFLAG_RCON, "Toggle sentries");
	RegAdminCmd("pp_toggle_sticky_dmg", ToggleStickyDamage, ADMFLAG_RCON, "Toggle stickies"); */
	
	CreateConVar("pp", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED);
	hDisableStickies = CreateConVar("pp_disablestickies", "1", "Disable sticky damage", FCVAR_NOTIFY);
	hDisableSentries = CreateConVar("pp_disablesentries", "1", "Disable sentry damage", FCVAR_NOTIFY);
	
	HookConVarChange(hDisableStickies, handler_ConVarChange);
	HookConVarChange(hDisableSentries, handler_ConVarChange);
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, HandleDamage);
}

/* public Action ListCmds(client, args)
{
	PrintToConsole(client, "pp_status - Proper Pregame status");
	PrintToConsole(client, "pp_enable - Enable Proper Pregame");
	PrintToConsole(client, "pp_disable - Disable Proper Pregame");
	PrintToConsole(client, "pp_toggle_sentry_dmg - Toggle sentries");
	PrintToConsole(client, "pp_toggle_sticky_dmg - Toggle stickies");
}

public Action PPStatus(client, args)
{
	PrintToConsole(client, "[SM] Proper Pregame Status:");
	//PrintToConsole(client, "Plugin Enabled: %b", pluginEnabled);
	PrintToConsole(client, "Sentries Disabled: %b", disableSentries);
	PrintToConsole(client, "Stickies Disabled: %b", disableStickies);
}

public Action PPEnable(client, args)
{
	if(!pluginEnabled)
	{
		pluginEnabled = true;
		PrintToConsole(client, "[SM] Proper Pregame Enabled");
	}
	else
	{
		PrintToConsole(client, "[SM] Proper Pregame is already enabled. Use \"pp_status\" to check which functions are enabled.");
	}
}

public Action PPDisable(client, args)
{
	if(pluginEnabled)
	{
		pluginEnabled = false;
		PrintToConsole(client, "[SM] Proper Pregame Disabled");
	}
	else
	{
		PrintToConsole(client, "[SM] Proper Pregame is already disabled");
	}	
}

public Action ToggleSentryDamage(client, args)
{
	if(disableSentries)
	{
		disableSentries = false;
		PrintToConsole(client, "[SM] Proper Pregame: Sentries are no longer disabled");
	}
	else
	{
		disableSentries = true;
		PrintToConsole(client, "[SM] Proper Pregame: Sentries are now disabled");
	}
}

public Action ToggleStickyDamage(client, args)
{
	if(disableStickies)
	{
		disableStickies = false;
		PrintToConsole(client, "[SM] Proper Pregame: Stickies are no longer disabled");
	}
	else
	{
		disableStickies = true;
		PrintToConsole(client, "[SM] Proper Pregame: Stickies are now disabled");
	}	
} */

public handler_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[]) {
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
}

public bool DefIdIsStickyLauncher(defid)
{
	//This is really fucking messy. Ideally would use defid to check for weapon_class == tf_weapon_pipebomblauncher but not sure how
	if(defid == 20 || 		//StickyBomb Launcher
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

public Action HandleDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	//if(pluginEnabled){
		
		//PrintToChatAll("Damage taken from weapon id %i", weapon);
		
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
						PrintToChatAll("Attacking self with sentry");
						return Plugin_Continue;
					}
					//If sentry owner is not the victim, disallow damage
					else
					{
						PrintToChatAll("Damage caused by sentry");
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
			PrintToChatAll("defid = %i", defid);
		}
		else
		{ 
			PrintToChatAll("weapon %i invalid", weapon);
			return Plugin_Continue;			
		}
		
		//Check to see if the damage is caused by stickies
		if(bDisableStickies && DefIdIsStickyLauncher(defid))
		{
			PrintToChatAll("Stickies Detected");
			//Check to see if the damaged player is the demo who shot the sticky			
			if(victim <= MAXPLAYERS && attacker <= MAXPLAYERS)
			{
				//If demo is the victim, allow damage
				if(victim == attacker){
					PrintToChatAll("Allowing self-damage stickies");
					return Plugin_Continue;
				}
				//If the demo is not the victim, disallow damage
				else
				{
					return Plugin_Handled;
				}
			}					
		}
	//}
	
	//If nothing caught, continue with no actions
	return Plugin_Continue;
	
}