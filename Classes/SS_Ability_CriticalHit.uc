class SS_Ability_CriticalHit extends Hat_Ability_Automatic;

var float critChance, minCritChance, maxCritChance, refreshCritChanceDelay;
var bool PlayerAffectedByCrits, EnemyImmuneToCrits, ConfigsChanged, AlwaysCriting;
var SoundCue CriticalHitSound;
var ParticleSystem CriticalHitParticle;

defaultproperties
{
	Begin Object Name=Mesh2
		Materials(0) = MaterialInstanceConstant'CriticalHit_Content.Materials.CriticalHitBadge_mat'; 
	End Object
	
	HUDIcon = Texture2D'CriticalHit_Content.CriticalHit_Badge';
	CosmeticItemName = "SSCriticalHitBadgeName";
	Description(0) = "SSCriticalHitBadgeDesc0";

	IsCrappy = false;
	
	critChance = 0.1f;
	minCritChance = 0.1f;
	maxCritChance = 0.25f;
	refreshCritChanceDelay = 1f;
	
	PlayerAffectedByCrits = false;
	EnemyImmuneToCrits = false;
	AlwaysCriting = false;
	ConfigsChanged = true;
	
	CriticalHitSound = SoundCue'CriticalHit_Content.Sounds.CriticalHitCue';
	CriticalHitParticle = ParticleSystem'CriticalHit_Content.Particles.CriticalHit_Particle';
}

function OnTakeDamage(out int Damage, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if(!PlayerAffectedByCrits) return;	
	Damage = CheckCriticalHitChance(Damage, Hat_Player(Instigator), true);
}

function OnDealDamage(out int Damage, Actor Victim, vector HitLocation, class<DamageType> DamageType) 
{
	//Print(string(Victim));
	if(Pawn(Victim).IsA('Hat_Enemy_Boss') /*|| Pawn(Victim).IsA('Hat_Vacuum')*/) return;
	if(EnemyImmuneToCrits) return;
	Damage = CheckCriticalHitChance(Damage, Victim);
}

function int CheckCriticalHitChance(int Damage, Actor target, optional bool ItIsPlayer = false)
{	
	local float change;
	
	if(FRand() <= (ItIsPlayer ? minCritChance : critChance) || AlwaysCriting)
	{
		PlayCriticalHit(target);
		Damage *= 3;
	}
	
	if(!ItIsPlayer)
	{
		change = (maxCritChance - minCritChance) * (float(Damage) / 12.0f);
		AdjustCriticalChance(change);
	}
	
	return Damage;
}

function AdjustCriticalChance(optional float CritValueChange, optional bool ConfigChanged = false)
{	
	refreshCritChanceDelay = default.refreshCritChanceDelay;
	
	if(minCritChance >= maxCritChance || ConfigChanged) // Minimum higher than the max?? ok....
		critChance = minCritChance;
	else
		critChance = CritValueChange > 0.0f ? FMin(critChance + CritValueChange, maxCritChance) : FMax(critChance + CritValueChange, minCritChance);	
}

function PlayCriticalHit(Actor target)
{
	Hat_Player(Instigator).PlaySound(CriticalHitSound);
	WorldInfo.MyEmitterPool.SpawnEmitter(CriticalHitParticle, target.Location, rot(0, 0, 0), target);
}

simulated event Tick(float d)
{
	local float change;
	
	Super.Tick(d);
	
	if(ConfigsChanged)
	{
		ConfigsChanged = false;
		ReapplyVars();
	}
	
	refreshCritChanceDelay -= d;
	
	if(refreshCritChanceDelay <= 0)
	{
		change = (maxCritChance - minCritChance) * (-1.0f / 60.0f);
		AdjustCriticalChance(change);
	}
}

function ReapplyVars()
{
	minCritChance = class'SS_GameMod_CriticalHit'.static.MinCrits(); 
	maxCritChance = class'SS_GameMod_CriticalHit'.static.MaxCrits(); 
	AlwaysCriting = class'SS_GameMod_CriticalHit'.static.AlwaysCrits();
	PlayerAffectedByCrits = class'SS_GameMod_CriticalHit'.static.CritImmunity();
	EnemyImmuneToCrits = class'SS_GameMod_CriticalHit'.static.CritImmunityEnemy();
	
	if(minCritChance > critChance || maxCritChance < critChance)
		AdjustCriticalChance(,true);
}

static function bool IsAllowedInManor()
{
	return true; // I'm definetly sure when it comes to Vanessa this doesn't matter and probably impossible, but like who cares tbh.
}

static function Print(string s)
{
    class'WorldInfo'.static.GetWorldInfo().Game.Broadcast(class'WorldInfo'.static.GetWorldInfo(), s);
}