class SS_GameMod_CriticalHit extends GameMod;

var config int PlayerAffectedByCrits; // If true apply the critical hit rules on the player.
var config int EnemiesImmuneToCrits; // If true enemies are immune to it.
var config int AlwaysCriticalHit; // CP_Orange servers be like.
var config int MinCriticalChance; // Starting point, default: 10%.
var config int MaxCriticalChance; // Highest critical hit reachable, default: 25%

const Default_Player_Crit_Affected = false;
const Default_Crit_Enemy_Immunity = false;
const Default_Always_Crit = false;
const Default_Max_Crit_Chance = 0.25f;
const Default_Min_Crit_Chance = 0.1f;

event OnModLoaded()
{
    HookActorSpawn(class'Hat_Player', 'Hat_Player');
}

event OnModUnloaded()
{
    GiveItems(false);
}

simulated event Tick(float d)
{
    super.Tick(d);
}

event OnHookedActorSpawn(Object NewActor, Name Identifier)
{
    if (Identifier == 'Hat_Player') GiveItems(true);
}

function GiveItems(bool b)
{
    GiveItem(class'SS_Ability_CriticalHit', b);
}

function GiveItem(class c, bool b)
{
    if (b) Hat_PlayerController(GetALocalPlayerController()).GetLoadout().AddBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(c), false);
    else Hat_PlayerController(GetALocalPlayerController()).GetLoadout().RemoveBackpack(class'Hat_Loadout'.static.MakeLoadoutItem(c));
}

event OnConfigChanged(Name ConfigName)
{
    local SS_Ability_CriticalHit badge;
	
	foreach DynamicActors(class'SS_Ability_CriticalHit', badge)
    {
		if (badge.Instigator == None || badge.Instigator.Controller == None) continue;
		badge.ConfigsChanged = true;
	}
}

static function bool CritImmunity()
{
	if (class'SS_GameMod_CriticalHit'.default.PlayerAffectedByCrits == 0)
		return Default_Crit_Enemy_Immunity;
	return true;
}

static function bool CritImmunityEnemy()
{
	if (class'SS_GameMod_CriticalHit'.default.EnemiesImmuneToCrits == 0)
		return Default_Player_Crit_Affected;
	return true;
}

static function bool AlwaysCrits()
{
	if (class'SS_GameMod_CriticalHit'.default.AlwaysCriticalHit == 0)
		return Default_Always_Crit;
	return true;
}

static function float MinCrits()
{
	if (class'SS_GameMod_CriticalHit'.default.MinCriticalChance == 0)
		return Default_Min_Crit_Chance;
	return float(class'SS_GameMod_CriticalHit'.default.MinCriticalChance) / 100;
}

static function float MaxCrits()
{
	if (class'SS_GameMod_CriticalHit'.default.MaxCriticalChance == 0)
		return Default_Max_Crit_Chance;
	if (class'SS_GameMod_CriticalHit'.default.MaxCriticalChance == 99)
		return 1;
	return float(class'SS_GameMod_CriticalHit'.default.MaxCriticalChance) / 100;
}