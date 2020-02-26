#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#undef REQUIRE_PLUGIN

#define PLUGIN_NAME	"Proper Pregame"
#define PLUGIN_AUTHOR	"Fishage"
#define PLUGIN_VERSION	"2.0"

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Make pregame fun again",
	version = PLUGIN_VERSION,
	url = "https://github.com/AJagger/ProperPregame"
}

new bool:bDisableStickies = true;
new bool:bDisableSentries = true;
new bool:bDisableAfterburn = false;
new bool:bDisableClassLimits = true;
new bool:bEditMode = false;

new int:limitScout = -1
new int:limitSoldier = -1
new int:limitPyro = -1
new int:limitDemoman = -1
new int:limitHeavy = -1
new int:limitEngineer = -1
new int:limitMedic = -1
new int:limitSniper = -1
new int:limitSpy = -1

new Handle:hDisableStickies = INVALID_HANDLE;
new Handle:hDisableSentries = INVALID_HANDLE;
new Handle:hDisableAfterburn = INVALID_HANDLE;
new Handle:hDisableClassLimits = INVALID_HANDLE;

public OnPluginStart()
{
	CreateConVar("pp", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_REPLICATED);
	hDisableStickies = CreateConVar("pp_disableStickies", "1", "Disable sticky damage", FCVAR_NOTIFY);
	hDisableSentries = CreateConVar("pp_disableSentries", "1", "Disable sentry damage", FCVAR_NOTIFY);
	hDisableAfterburn = CreateConVar("pp_disableAfterburn", "0", "Disable afterburn damage", FCVAR_NOTIFY);
	hDisableClassLimits = CreateConVar("pp_disableClassLimits", "1", "Disable config-enforced class limits in pregame", FCVAR_NOTIFY);
	
	HookConVarChange(hDisableStickies, handler_ConVarChange);
	HookConVarChange(hDisableSentries, handler_ConVarChange);
	HookConVarChange(hDisableAfterburn, handler_ConVarChange);
	HookConVarChange(hDisableClassLimits, handler_ConVarChange);
	
	if(bDisableClassLimits)
	{
		DisableExistingClassLimits();
	}
	
	HookConVarChange(FindConVar("tf_tournament_classlimit_scout"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_soldier"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_pyro"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_demoman"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_heavy"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_engineer"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_medic"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_sniper"), handler_ClassLimitChange);
	HookConVarChange(FindConVar("tf_tournament_classlimit_spy"), handler_ClassLimitChange);
	
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
		EnableExistingClassLimits();
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
		bDisableStickies = !(StringToInt(newValue) == 0)
	} 
	else if (convar == hDisableSentries) 
	{
		bDisableSentries = !(StringToInt(newValue) == 0)
	}
	else if (convar == hDisableAfterburn) 
	{
		bDisableAfterburn = !(StringToInt(newValue) == 0)
	}
	else if (convar == hDisableClassLimits) 
	{
		if(StringToInt(newValue) == 0)
		{
			EnableExistingClassLimits();
			bDisableClassLimits = false;	
		}
		else
		{
			bDisableClassLimits = true;
			DisableExistingClassLimits();
		}
	}
}

public handler_ClassLimitChange(Handle:convar, const String:oldValue[], const String:newValue[]) 
{
	if(bDisableClassLimits)
	{
		if(convar == FindConVar("tf_tournament_classlimit_scout") && !bEditMode)
		{
			bEditMode = true;
			limitScout = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_soldier") && !bEditMode)
		{
			bEditMode = true;
			limitSoldier = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_pyro") && !bEditMode)
		{
			bEditMode = true;
			limitPyro = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_demoman") && !bEditMode)
		{
			bEditMode = true;
			limitDemoman = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_heavy") && !bEditMode)
		{
			bEditMode = true;
			limitHeavy = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_engineer") && !bEditMode)
		{
			bEditMode = true;
			limitEngineer = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_medic") && !bEditMode)
		{
			bEditMode = true;
			limitMedic = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_sniper") && !bEditMode)
		{
			bEditMode = true;
			limitSniper = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), -1);	
		}
		else if(convar == FindConVar("tf_tournament_classlimit_spy") && !bEditMode)
		{
			bEditMode = true;
			limitSpy = StringToInt(newValue);
			SetConVarInt(FindConVar("tf_tournament_classlimit_spy"), -1);	
		}
		
		bEditMode = false;
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

public EnableExistingClassLimits()
{
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_scout"), limitScout);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_soldier"), limitSoldier);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_pyro"), limitPyro);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_demoman"), limitDemoman);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_heavy"), limitHeavy);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_engineer"), limitEngineer);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_medic"), limitMedic);
	
	bEditMode = true;
	SetConVarInt(FindConVar("tf_tournament_classlimit_sniper"), limitSniper);
	
	bEditMode = true;
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