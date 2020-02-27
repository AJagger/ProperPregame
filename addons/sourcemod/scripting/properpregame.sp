#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#undef REQUIRE_PLUGIN

#define PLUGIN_NAME	"Proper Pregame"
#define PLUGIN_AUTHOR	"Fishage"
#define PLUGIN_VERSION	"2.1"

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Make pregame fun again",
	version = PLUGIN_VERSION,
	url = "https://github.com/AJagger/ProperPregame"
}

new bool:disableStickies = true;
new bool:disableSentries = true;
new bool:disableAfterburn = false;
new bool:disableClassLimits = true;
new bool:editMode = false;

new int:limitScout = -1
new int:limitSoldier = -1
new int:limitPyro = -1
new int:limitDemoman = -1
new int:limitHeavy = -1
new int:limitEngineer = -1
new int:limitMedic = -1
new int:limitSniper = -1
new int:limitSpy = -1

new Handle:disableStickiesHandle = INVALID_HANDLE;
new Handle:disableSentriesHandle = INVALID_HANDLE;
new Handle:disableAfterburnHandle = INVALID_HANDLE;
new Handle:disableClassLimitsHandle = INVALID_HANDLE;

public OnPluginStart()
{
	CreateConVar("pp", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED);
	disableStickiesHandle = CreateConVar("pp_disableStickies", "1", "Disable sticky damage", FCVAR_NOTIFY);
	disableSentriesHandle = CreateConVar("pp_disableSentries", "1", "Disable sentry damage", FCVAR_NOTIFY);
	disableAfterburnHandle = CreateConVar("pp_disableAfterburn", "0", "Disable afterburn damage", FCVAR_NOTIFY);
	disableClassLimitsHandle = CreateConVar("pp_disableClassLimits", "1", "Disable config-enforced class limits in pregame", FCVAR_NOTIFY);
	
	HookConVarChange(disableStickiesHandle, ConVarChangeHandler);
	HookConVarChange(disableSentriesHandle, ConVarChangeHandler);
	HookConVarChange(disableAfterburnHandle, ConVarChangeHandler);
	HookConVarChange(disableClassLimitsHandle, ConVarChangeHandler);
	
	if(disableClassLimits)
	{
		DisableExistingClassLimits();
	}
	
	HookConVarChange(FindConVar("tf_tournament_classlimit_scout"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_soldier"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_pyro"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_demoman"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_heavy"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_engineer"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_medic"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_sniper"), ClassLimitChangeHandler);
	HookConVarChange(FindConVar("tf_tournament_classlimit_spy"), ClassLimitChangeHandler);
	
	AddCommandListener(execListener, "exec");
	
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
	if(disableClassLimits)
	{
		EnableExistingClassLimits();
	}
}

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_OnTakeDamage, HandleDamage);
}

public ConVarChangeHandler(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	if (convar == disableStickiesHandle) 
	{
		disableStickies = !(StringToInt(newValue) == 0)
	} 
	else if (convar == disableSentriesHandle) 
	{
		disableSentries = !(StringToInt(newValue) == 0)
	}
	else if (convar == disableAfterburnHandle) 
	{
		disableAfterburn = !(StringToInt(newValue) == 0)
	}
	else if (convar == disableClassLimitsHandle) 
	{
		if(StringToInt(newValue) == 0)
		{
			EnableExistingClassLimits();
			disableClassLimits = false;	
		}
		else
		{
			disableClassLimits = true;
			DisableExistingClassLimits();
		}
	}
}

public ClassLimitChangeHandler(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	if(disableClassLimits && !editMode)
	{
		if(convar == FindConVar("tf_tournament_classlimit_scout"))
		{
			editMode = true;
			limitScout = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_soldier"))
		{
			editMode = true;
			limitSoldier = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_pyro"))
		{
			editMode = true;
			limitPyro = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_demoman"))
		{
			editMode = true;
			limitDemoman = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_heavy"))
		{
			editMode = true;
			limitHeavy = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_engineer"))
		{
			editMode = true;
			limitEngineer = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_medic"))
		{
			editMode = true;
			limitMedic = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_sniper"))
		{
			editMode = true;
			limitSniper = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_spy"))
		{
			editMode = true;
			limitSpy = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), -1);	
		}
		
		editMode = false;
	}
}

public bool DefIdIsStickyLauncher(defid)
{
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
	if(disableSentries && weapon == -1)
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
	
	//Check to see if the damage is caused by stickies
	if(disableStickies && DefIdIsStickyLauncher(defid))
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
	if(disableAfterburn && DamageTypeIsAfterburn(damagetype))
	{
		return Plugin_Handled;				
	}
	
	//If nothing caught, continue with no actions
	return Plugin_Continue;
}

// UGC does not use class limits. Since the cvar will not be changed from -1 when the config is executed then the hook will not be triggered
// and so the previous config's class limits will be reinstated.
// Check to see if the UGC config is executed and clear the stored limits.
public Action:execListener(client, const String:cmd[], argc)
{
	new String:cfgName[50]
	GetCmdArgString(cfgName, sizeof(cfgName))
	
	if(StrContains(cfgName, "UGC", false) >= 0)
	{
		ClearStoredClassLimits();
		PrintToChatAll("[ProperPregame] UGC config detected, no class limits will be applied.");
	}
}

public EnableExistingClassLimits()
{
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), limitScout);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), limitSoldier);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), limitPyro);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), limitDemoman);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), limitHeavy);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), limitEngineer);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), limitMedic);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), limitSniper);
	
	editMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), limitSpy);
	
	PrintToChatAll("[ProperPregame] Class limits restored.");
}

public DisableExistingClassLimits()
{
	limitScout = GetConVarInt(FindConVar("tf_tournament_classlimit_scout"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), -1);
	
	limitSoldier = GetConVarInt(FindConVar("tf_tournament_classlimit_soldier"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), -1);	

	limitPyro = GetConVarInt(FindConVar("tf_tournament_classlimit_pyro"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), -1);	

	limitDemoman = GetConVarInt(FindConVar("tf_tournament_classlimit_demoman"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), -1);	

	limitHeavy = GetConVarInt(FindConVar("tf_tournament_classlimit_heavy"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), -1);	

	limitEngineer = GetConVarInt(FindConVar("tf_tournament_classlimit_engineer"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), -1);	

	limitMedic = GetConVarInt(FindConVar("tf_tournament_classlimit_medic"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), -1);	

	limitSniper = GetConVarInt(FindConVar("tf_tournament_classlimit_sniper"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), -1);	

	limitSpy = GetConVarInt(FindConVar("tf_tournament_classlimit_spy"));
	SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), -1);
}

public ClearStoredClassLimits()
{
	limitScout = -1;
	limitSoldier = -1;
	limitPyro = -1;
	limitDemoman = -1;
	limitHeavy = -1;
	limitEngineer = -1;
	limitMedic = -1;
	limitSniper = -1;
	limitSpy = -1;
}