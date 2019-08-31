#include <a_samp>
#include <YSF>
#include <Dini>
#include <WC>

//new S_AMT;
//new S_OBJ[100];
#define O_HEALTH 1240
#define O_ARMOR 1242
// Dialog ID
#define GM_VERSION "BattleGrounds 7.0.1b"

new
		Text:InfoTextDraw[MAX_PLAYERS][2], bool:isInfoTDCreated1[MAX_PLAYERS],
		textdrawString[256];

/*#define PRIV_MODE
#define PRIV_IP "188.72.232.144"
#define PRIV_IP2 "109.73.163.17"
#define PRIV_IP3 "127.0.0.1"
#define PRIV_PORT 7780*/

#define MAX_BASES 150
#define MAX_TEAMS 8
#define ACTIVE_TEAMS MAX_TEAMS-2

new gTeam[MAX_SERVER_PLAYERS];
new sTeam[MAX_SERVER_PLAYERS];
new ffTeam[MAX_SERVER_PLAYERS];

new MainColors[5];

new bool:BaseExists[MAX_BASES];
new bool:ArenaExists[MAX_BASES];
new MAX_EXISTING[2];
new Interior[MAX_BASES][4];
new LocationName[MAX_BASES][4][STR];
new Weather[MAX_BASES][4];
new TimeX[MAX_BASES][4];
new newbases,newarenas;//,newdmzs;

new Current = -1;
new StopCounting[3][2];
new Winner;
new GunUsed[MAX_WEAPONS][2];
new GunAmmo[MAX_WEAPONS][2];
new GunLimit[MAX_WEAPONS][2];
new pGunAmmo[MAX_WEAPONS];
new pGunUsed[MAX_WEAPONS];
new Players;
new Vehicles;
new RoundLimit;
new RoundsPlayed;
new Float:MainSpawn[4];
new Float:nDist;
new bool:SlideSho;
new bool:GamePaused;
new bool:WatchingBase;
new bool:nmtimer;
new bool:AllowGunMenu;

new IntroBeats[13] = {1002,1039,1085,1095,1130,1132,1133,1134,1135,1136,1140,1144,1190};
new RandSongs[8] = {1187,1183,1185,1068,1062,1076,1097,1142};
new RandIcon[7] = {19,23,58,59,60,61,62};
new ModeMin;
new ModeSec;
new zone;
new ModeType;
new Float:times;
new Xminute;
new Xsecond;
new aLvl[3];
new ZoneCols[2];
new ObjectCount;
new BlackRadar;
new HighestVID;
new TeamsBeingUsed;

enum FightingStyles
{
	f_Name[10],
	f_ID
}

new FightStyle[6][FightingStyles] = {
{"Normal",4},
{"Boxing",5},
{"Kung Fu",6},
{"Knee-Head",7},
{"Grab-Kick",15},
{"Elbow",16}
};

//------------------------------------------------------------------------------
//administration

#define PM_COLOR 0x80FFFFFF
#define CMD_COLOR 0xFFA953FF

new Colors[5];
new bool:unos[MAX_SERVER_PLAYERS];
new bool:ShowCommands[MAX_SERVER_PLAYERS];
new bool:ShowPMs[MAX_SERVER_PLAYERS];

enum PlayerData
{
	Level,
	bool:Registered,
	bool:LoggedIn,
	bool:Muted
};

new Float:Loc[4][MAX_SERVER_PLAYERS];
new bool:DisplayCommandMessage = true;
new Variables[MAX_SERVER_PLAYERS][PlayerData];

//------------------------------------------------------------------------------
//Server config - gameconfig.ini

new CPsize;
new CPtime[2];
new KeyTime,CmdTime,TextTime;//,AFKtime;
new modetime;
new ServerPass[20] = "off";
new HostTag[10];
new PlayingTag[9];
new DeadTag[9];
//new MOTDtext[256];
new gWeather,gTime,rWeather,rTime;
new gHealth,gArmor,rHealth,rArmor;
new VPPPT;
new GameMap;
new Pickups;
new DropLifeTime;
new IDLEtime;
new AutoPause;
new MarkerFade;
new AutoMode;
new RoundCode;
new MaxPing;
new ShowTeamDmg;
new Float:Gravity;
new Float:MinDist;
new Float:MaxDist;
new bool:CPused;
new bool:Allowswitch;
new bool:Allownicks;
new bool:FriendlyFire;
new bool:TabHP;
new bool:JnP;
new bool:RoundMuting;
new bool:IDnames;
new bool:UseSubs;
new bool:EnemyUAV;
new bool:UseClock;
new bool:HideCPText = true;
new bool:AutoModeActive;
new bool:NoNameMode;
new bool:AutoTeamSpec;
new bool:AntiC;
new bool:LockMode;
new bool:Pausing;
new bool:Debug;
new bool:UseRadar;
new bool:Randomization;
new bool:AutoSwap;
new bool:TeamLock[MAX_TEAMS];
new bool:TeamUsed[MAX_TEAMS];
new bool:v_AllowSpawning;
new bool:UseNameTags;
new bool:PrivateMode;

enum WeaponSkillInfo
{
	s_Name[30],
	s_Level
}

new WeaponSkills[11][WeaponSkillInfo] = {
{"Pistol",999},
{"Silenced Pistol",999},
{"Deagle",999},
{"Shotgun",999},
{"Sawnoff",999},
{"Spas 12",999},
{"Uzi and Tec-9",999},
{"MP5",999},
{"AK-47",999},
{"M4",999},
{"Sniper Rifle",999}
};

//------------------------------------------------------------------------------
//Team related

new TeamSkin[MAX_TEAMS];
new TeamName[MAX_TEAMS][10];
new CurrentPlayers[MAX_TEAMS];
new TeamActiveColors[MAX_TEAMS];
new TeamInactiveColors[MAX_TEAMS];
new TeamGZColors[MAX_TEAMS];

new TeamTotalScore[ACTIVE_TEAMS];
new TeamTempScore[ACTIVE_TEAMS];
new TeamRoundsWon[ACTIVE_TEAMS];
new Float:TmpCP[ACTIVE_TEAMS];
new TeamStartingPlayers[ACTIVE_TEAMS];
new TeamCurrentPlayers[ACTIVE_TEAMS];
new Float:TeamArenaSpawns[MAX_BASES][ACTIVE_TEAMS][ACTIVE_TEAMS];
new Float:ArenaCP[MAX_BASES][3];
new Float:ArenaZones[MAX_BASES][ACTIVE_TEAMS];
new TeamTotalDeaths[ACTIVE_TEAMS];
new TeamTempDeaths[ACTIVE_TEAMS];
new VehiclesSpawned[ACTIVE_TEAMS];
new Float:TeamHighestCombo[ACTIVE_TEAMS][2];

new CurrentConfig[4];
new TeamStatus[2];
new TeamStatusStr[2][10];
new TeamVehColor[2][2];
new Float:TeamBaseSpawns[MAX_BASES][3][2];
new Float:HomeCP[MAX_BASES][3];
new Float:TeamLifeTotal[ACTIVE_TEAMS];

new Float:TeamDmgAmt[ACTIVE_TEAMS];
new TeamLifeCombo[ACTIVE_TEAMS];
new TeamDmgTimer[ACTIVE_TEAMS];
new bool:TeamDmgTimerActive[ACTIVE_TEAMS];

//------------------------------------------------------------------------------
//Player vars

new Chase_Checks[MAX_SERVER_PLAYERS];
new Chase_ChaseID[MAX_SERVER_PLAYERS];
new Chase_AmtChasing[MAX_SERVER_PLAYERS];
new Float:Chase_TotalTime[MAX_SERVER_PLAYERS];
new Float:Chase_MinDist[MAX_SERVER_PLAYERS];
new Float:Chase_MaxDist[MAX_SERVER_PLAYERS];
new Float:Chase_TotalDist[MAX_SERVER_PLAYERS];

new SyncTimer[MAX_SERVER_PLAYERS];
new pClassID[MAX_SERVER_PLAYERS];
new OldClassID[MAX_SERVER_PLAYERS];
new gSpectateID[MAX_SERVER_PLAYERS];
new gSpectateType[MAX_SERVER_PLAYERS];
new Float:PlayerPosition[MAX_SERVER_PLAYERS][4];
new Float:ViewPos[MAX_SERVER_PLAYERS][4];
new SpawnAtPlayerPosition[MAX_SERVER_PLAYERS];
new PlayerWeapons[MAX_SERVER_PLAYERS][MAX_SLOTS];
new TempKills[MAX_SERVER_PLAYERS];
new TempDeaths[MAX_SERVER_PLAYERS];
new TempTKs[MAX_SERVER_PLAYERS];
new RealName[MAX_SERVER_PLAYERS][STR];
new NickName[MAX_SERVER_PLAYERS][STR];
new TempName[MAX_SERVER_PLAYERS][STR];
new udbName[MAX_SERVER_PLAYERS][128];
new ListName[MAX_SERVER_PLAYERS][STR];
new WeaponSet[MAX_SERVER_PLAYERS][4][2];
new LockedVehicle[MAX_SERVER_PLAYERS] = -1;
new TempGuns[MAX_SERVER_PLAYERS][MAX_SLOTS][2];
new ReAddWeps[MAX_SERVER_PLAYERS][MAX_SLOTS][2];
new Float:ReAddPos[MAX_SERVER_PLAYERS][4];
new BaseEditing[MAX_SERVER_PLAYERS];
new ArenaEditing[MAX_SERVER_PLAYERS];
new ViewingBase[MAX_SERVER_PLAYERS];
new ViewingArena[MAX_SERVER_PLAYERS];
new Skin[MAX_SERVER_PLAYERS];
new WorldPass[MAX_SERVER_PLAYERS][32];
new PlayerWorld[MAX_SERVER_PLAYERS];
new vColor[2][MAX_SERVER_PLAYERS];
new Spree[2][MAX_SERVER_PLAYERS];
new MaxSpree[2][MAX_SERVER_PLAYERS];
new SetSpawn[MAX_SERVER_PLAYERS];
new Float:mSpawn[5][MAX_SERVER_PLAYERS];
new TimeAtConnect[MAX_SERVER_PLAYERS];
new UAVtime[MAX_SERVER_PLAYERS];
new CurrentInt[MAX_SERVER_PLAYERS];
//new Float:HP[3][MAX_SERVER_PLAYERS];
//new KillMsg[MAX_SERVER_PLAYERS][128];
new pWeather[MAX_SERVER_PLAYERS];
new pTime[MAX_SERVER_PLAYERS][2];
new Float:Angle[MAX_SERVER_PLAYERS];
new Float:Vert[MAX_SERVER_PLAYERS];
new VertDirect[MAX_SERVER_PLAYERS];
new Float:Horiz[MAX_SERVER_PLAYERS][2];
new Float:rottimes[MAX_SERVER_PLAYERS];
new Float:VertLookAt[MAX_SERVER_PLAYERS];
new GunEdit[MAX_SERVER_PLAYERS][3];
new LastWeapon[MAX_SERVER_PLAYERS];
new InVehicle[MAX_SERVER_PLAYERS];
new Float:TempHP[MAX_SERVER_PLAYERS][2];
new PlayerPickup[MAX_SERVER_PLAYERS];
new LifeUpdateVar[MAX_SERVER_PLAYERS];
new Float:LifeUpdateAmt[MAX_SERVER_PLAYERS];
new HitCounter[MAX_SERVER_PLAYERS];
new PlayerVehicleID[MAX_SERVER_PLAYERS];
new CurLetter[MAX_SERVER_PLAYERS];
new MOTDScreen[MAX_SERVER_PLAYERS];
new Float:MOTD_Z[MAX_SERVER_PLAYERS];
//new Location[MAX_SERVER_PLAYERS][MAX_STRING];
new TotPing[MAX_SERVER_PLAYERS];
new PingChecks[MAX_SERVER_PLAYERS];
new AmtSpectating[MAX_SERVER_PLAYERS];
new CurrentColor[MAX_SERVER_PLAYERS];
new Wheels[MAX_SERVER_PLAYERS];
new NewVehicle[MAX_SERVER_PLAYERS];
new KillMsgTimer[MAX_SERVER_PLAYERS];
new IntroBeat[MAX_SERVER_PLAYERS];
new DmgObject[MAX_SERVER_PLAYERS];
new DmgObjectTimer[MAX_SERVER_PLAYERS];
new DmgObjectCreated[MAX_SERVER_PLAYERS];
new wSkillEdit[MAX_SERVER_PLAYERS];
new wSkill[MAX_SERVER_PLAYERS][11];
new pFightStyle[MAX_SERVER_PLAYERS];
new bool:KillMsgShowing[MAX_SERVER_PLAYERS];
new bool:GracePeriod[MAX_SERVER_PLAYERS];
new bool:Rotating[MAX_SERVER_PLAYERS];
new bool:gPlayerSpawned[MAX_SERVER_PLAYERS];
new bool:gSpectating[MAX_SERVER_PLAYERS];
new bool:Playing[MAX_SERVER_PLAYERS];
new bool:AFK[MAX_SERVER_PLAYERS];
new bool:NoCmds[MAX_SERVER_PLAYERS];
new bool:NoText[MAX_SERVER_PLAYERS];
new bool:NoKeys[MAX_SERVER_PLAYERS];
new bool:ViewingResults[MAX_SERVER_PLAYERS];
new bool:HasPlayed[MAX_SERVER_PLAYERS];
new bool:gSelectingClass[MAX_SERVER_PLAYERS];
new bool:ClanLeader[MAX_SERVER_PLAYERS];
new bool:CorrectPassword[MAX_SERVER_PLAYERS];
new bool:FinishedMenu[MAX_SERVER_PLAYERS];
new bool:ViewingMOTD[MAX_SERVER_PLAYERS];
new bool:GivenMenu[MAX_SERVER_PLAYERS];
new bool:AllowSuicide[MAX_SERVER_PLAYERS];
new bool:ReAdding[MAX_SERVER_PLAYERS];
new bool:Stored[MAX_SERVER_PLAYERS];
new bool:SelectingWeaps[MAX_SERVER_PLAYERS];
new bool:cBugDetect[MAX_SERVER_PLAYERS];
new bool:KillFade[MAX_SERVER_PLAYERS];
new bool:ShowDMG[MAX_SERVER_PLAYERS];
new bool:ChangedWeapon[MAX_SERVER_PLAYERS];
new bool:Syncing[MAX_SERVER_PLAYERS];
new bool:Ignored[MAX_SERVER_PLAYERS][MAX_SERVER_PLAYERS];
new bool:FirstSelect[MAX_SERVER_PLAYERS];
new bool:SettingHP[MAX_SERVER_PLAYERS];
new bool:DontCountDeaths[MAX_SERVER_PLAYERS];

//------------------------------------------------------------------------------
//vehicle related
#define MAX_SPAWNABLE_VEHICLES 212

new v_Health[MAX_SPAWNABLE_VEHICLES];
new v_Usage[MAX_SPAWNABLE_VEHICLES];

new RandWheels[17] = {1025,1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083,1084,1085,1096,1097,1098};
enum w_info{w_id,w_name[10]}
new const Wheel_Info[19][w_info] = {
{-1, "Random"},
{1025, "Offroad"},
{1073, "Shadow"},
{1074, "Mega"},
{1075, "Rimshine"},
{1076, "Wires"},
{1077, "Classic"},
{1078, "Twist"},
{1079, "Cutter"},
{1080, "Switch"},
{1081, "Grove"},
{1082, "Import"},
{1083, "Dollar"},
{1084, "Trance"},
{1085, "Atomic"},
{1096, "Ahab"},
{1097, "Virtual"},
{1098, "Access"},
{0, "Default"}
};

new v_Trailer[MAX_SERVER_VEHICLES] = -1;
new v_AmtInside[MAX_SERVER_VEHICLES];
new bool:v_InRound[MAX_SERVER_VEHICLES];
new bool:v_Locked[MAX_SERVER_VEHICLES];
new bool:v_Destroy[MAX_SERVER_VEHICLES];
new bool:v_Exists[MAX_SERVER_VEHICLES];

//------------------------------------------------------------------------------
//Duel
new DuelInvitation[MAX_SERVER_PLAYERS] = -1;
new DuelWeapon[MAX_SERVER_PLAYERS][2];
new DuelSpectating[MAX_SERVER_PLAYERS] = -1;
new DuelWorld[MAX_SERVER_PLAYERS];
new DuelTimer[MAX_SERVER_PLAYERS];
new DuelPlayerSign[MAX_SERVER_PLAYERS][97];
new bool:IsDueling[MAX_SERVER_PLAYERS];
new bool:DuelDisable[MAX_SERVER_PLAYERS];
new bool:DuelIgnored[MAX_SERVER_PLAYERS][MAX_SERVER_PLAYERS];
new bool:DuelWaiting[MAX_SERVER_PLAYERS];
new bool:DuelStarting[MAX_SERVER_PLAYERS];
new bool:DuelArenaCreated[MAX_SERVER_PLAYERS];

new const Float:DuelPos[14][4] = {
{-1255.13, -128.20, 14.14, 134.62}, //[NB]90NINE - player pos 1
{-1324.64, -198.12, 14.14, 314.46}, //[NB]90NINE - player pos 2
{-1265.41, -217.85, 27.30, 1.21}, //[NB]90NINE - spec
{-1297.86, -217.78, 27.30, 1.13}, //[NB]90NINE - spec
{-1332.31, -217.97, 27.30, 0.87}, //[NB]90NINE - spec
{-1344.07, -189.63, 27.30, 271.97}, //[NB]90NINE - spec
{-1344.16, -155.62, 27.30, 271.64}, //[NB]90NINE - spec
{-1344.18, -121.96, 27.30, 269.63}, //[NB]90NINE - spec
{-1315.27, -109.25, 27.30, 180.39}, //[NB]90NINE - spec
{-1281.66, -109.07, 27.30, 178.39}, //[NB]90NINE - spec
{-1248.61, -109.27, 27.30, 181.48}, //[NB]90NINE - spec
{-1235.64, -138.54, 27.30, 91.49}, //[NB]90NINE - spec
{-1235.64, -172.01, 27.30, 89.74}, //[NB]90NINE - spec
{-1235.54, -204.40, 27.30, 91.41} //[NB]90NINE - spec
};

new const DuelBillboards[10] = {7906,7907,7908,7909,7910,7911,7912,7913,7914,7915};

new const Float:DuelObj[12][7] = {
{4563.0,-1167.214233,-83.028252,-3.723772,90.0000,0.0000,270.0000},
{4563.0,-1370.386719,-41.803055,-3.723772,90.0000,0.0000,0.0000},
{4563.0,-1412.908325,-244.302933,-3.723772,90.0000,0.0000,90.0000},
{4563.0,-1209.404419,-244.302933,-3.723772,90.0000,0.0000,180.0000},
{4563.0,-1391.663452,-194.651978,41.150978,90.0000,0.0000,180.0000},
{4563.0,-1260.758179,-263.823212,41.150978,90.0000,0.0000,270.0000},
{4563.0,-1190.042114,-143.623566,41.150978,90.0000,0.0000,0.0000},
{4563.0,-1329.769531,-61.722466,41.150978,90.0000,0.0000,90.0000},
{4563.0,-1333.302368,-101.820313,88.059994,270.0000,0.0000,180.0000},
{4563.0,-1283.800171,-101.820313,88.059994,270.0000,0.0000,180.0000},
{4563.0,-1234.416016,-101.820313,88.059994,270.0000,0.0000,180.0000},
{7474.0,-1282.968994,-182.390350,13.019511,0.0000,0.0000,0.0000}//8664
};

new const Float:DuelDynamicObj[97][6] = {
{-1281.567505,-214.254700,16.302399,0.0000,0.0000,180.0000},
{-1298.272095,-214.254700,16.302399,0.0000,0.0000,180.0000},
{-1315.022827,-214.254700,16.302399,0.0000,0.0000,180.0000},
{-1331.747559,-214.254700,16.302399,0.0000,0.0000,180.0000},
{-1264.841309,-214.254700,16.302399,0.0000,0.0000,180.0000},
{-1248.064819,-214.254700,16.302399,0.0000,0.0000,180.0000},
{-1239.484375,-205.380341,16.302399,0.0000,0.0000,270.0000},
{-1239.484375,-172.032623,16.302399,0.0000,0.0000,270.0000},
{-1239.484375,-155.333527,16.302399,0.0000,0.0000,270.0000},
{-1239.484375,-138.609192,16.302399,0.0000,0.0000,270.0000},
{-1239.484375,-121.834396,16.302399,0.0000,0.0000,270.0000},
{-1248.064819,-113.180450,16.302399,0.0000,0.0000,0.0000},
{-1264.768921,-113.180450,16.302399,0.0000,0.0000,0.0000},
{-1281.421265,-113.180450,16.302399,0.0000,0.0000,0.0000},
{-1298.271606,-113.180450,16.302399,0.0000,0.0000,0.0000},
{-1314.975708,-113.180450,16.302399,0.0000,0.0000,0.0000},
{-1331.701904,-113.180450,16.302399,0.0000,0.0000,0.0000},
{-1340.512085,-205.380341,16.302399,0.0000,0.0000,90.0000},
{-1340.512085,-188.606140,16.302399,0.0000,0.0000,90.0000},
{-1340.512085,-171.956421,16.302399,0.0000,0.0000,90.0000},
{-1340.512085,-155.257629,16.302399,0.0000,0.0000,90.0000},
{-1340.512085,-138.632599,16.302399,0.0000,0.0000,90.0000},
{-1340.512085,-121.957748,16.302399,0.0000,0.0000,90.0000},
{-1239.463379,-205.342636,22.907461,0.0000,0.0000,270.0000},
{-1239.463379,-188.743515,22.907461,0.0000,0.0000,270.0000},
{-1239.463379,-172.094101,22.907461,0.0000,0.0000,270.0000},
{-1239.463379,-155.394150,22.907461,0.0000,0.0000,270.0000},
{-1239.463379,-138.694565,22.907461,0.0000,0.0000,270.0000},
{-1239.463379,-121.969734,22.907461,0.0000,0.0000,270.0000},
{-1248.068115,-113.119621,22.907461,0.0000,0.0000,0.0000},
{-1264.722656,-113.119621,22.907461,0.0000,0.0000,0.0000},
{-1281.427246,-113.119621,22.907461,0.0000,0.0000,0.0000},
{-1298.179932,-113.119621,22.907461,0.0000,0.0000,0.0000},
{-1314.932129,-113.119621,22.907461,0.0000,0.0000,0.0000},
{-1331.634766,-113.119621,22.907461,0.0000,0.0000,0.0000},
{-1340.535400,-121.919930,22.907461,0.0000,0.0000,90.0000},
{-1340.535400,-138.519196,22.907461,0.0000,0.0000,90.0000},
{-1340.535400,-155.168976,22.907461,0.0000,0.0000,90.0000},
{-1340.535400,-171.918549,22.907461,0.0000,0.0000,90.0000},
{-1340.535400,-188.568451,22.907461,0.0000,0.0000,90.0000},
{-1340.535400,-205.418365,22.907461,0.0000,0.0000,90.0000},
{-1331.858276,-214.292664,22.907461,0.0000,0.0000,180.0000},
{-1315.029541,-214.292664,22.907461,0.0000,0.0000,180.0000},
{-1298.352905,-214.292664,22.907461,0.0000,0.0000,180.0000},
{-1281.626221,-214.292664,22.907461,0.0000,0.0000,180.0000},
{-1264.875000,-214.292664,22.907461,0.0000,0.0000,180.0000},
{-1248.146606,-214.292664,22.907461,0.0000,0.0000,180.0000},
{-1239.484375,-205.380341,29.527353,0.0000,0.0000,270.0000},
{-1239.484375,-188.705994,16.302399,0.0000,0.0000,270.0000},
{-1239.463379,-205.467606,36.007622,0.0000,0.0000,270.0000},
{-1239.484375,-188.705994,29.527353,0.0000,0.0000,270.0000},
{-1239.484375,-172.082245,29.527353,0.0000,0.0000,270.0000},
{-1239.484375,-155.383026,29.527353,0.0000,0.0000,270.0000},
{-1239.484375,-138.684174,29.527353,0.0000,0.0000,270.0000},
{-1239.484375,-122.033989,29.527353,0.0000,0.0000,270.0000},
{-1248.062378,-113.108978,29.527353,0.0000,0.0000,0.0000},
{-1264.740479,-113.108978,29.527353,0.0000,0.0000,0.0000},
{-1281.492188,-113.108978,29.527353,0.0000,0.0000,0.0000},
{-1298.191650,-113.108978,29.527353,0.0000,0.0000,0.0000},
{-1314.970337,-113.108978,29.527353,0.0000,0.0000,0.0000},
{-1331.675415,-113.108978,29.527353,0.0000,0.0000,0.0000},
{-1340.551514,-121.909256,29.527353,0.0000,0.0000,90.0000},
{-1340.551514,-138.483597,29.527353,0.0000,0.0000,90.0000},
{-1340.551514,-155.183365,29.527353,0.0000,0.0000,90.0000},
{-1340.551514,-171.958359,29.527353,0.0000,0.0000,90.0000},
{-1340.551514,-188.558029,29.527353,0.0000,0.0000,90.0000},
{-1340.551514,-205.383072,29.527353,0.0000,0.0000,90.0000},
{-1331.893066,-214.305893,29.527353,0.0000,0.0000,180.0000},
{-1314.990723,-214.305893,29.527353,0.0000,0.0000,180.0000},
{-1298.287109,-214.305893,29.527353,0.0000,0.0000,180.0000},
{-1281.660278,-214.305893,29.527353,0.0000,0.0000,180.0000},
{-1264.806519,-214.305893,29.527353,0.0000,0.0000,180.0000},
{-1248.178711,-214.305893,29.527353,0.0000,0.0000,180.0000},
{-1239.463379,-188.768509,36.007622,0.0000,0.0000,270.0000},
{-1239.463379,-172.194016,36.007622,0.0000,0.0000,270.0000},
{-1239.463379,-155.444992,36.007622,0.0000,0.0000,270.0000},
{-1239.463379,-138.770950,36.007622,0.0000,0.0000,270.0000},
{-1239.363281,-121.896179,36.007622,0.0000,0.0000,270.0000},
{-1247.971680,-113.045883,36.007622,0.0000,0.0000,0.0000},
{-1264.746460,-113.045883,36.007622,0.0000,0.0000,0.0000},
{-1281.375732,-113.045883,36.007622,0.0000,0.0000,0.0000},
{-1298.128906,-113.045883,36.007622,0.0000,0.0000,0.0000},
{-1314.929199,-113.045883,36.007622,0.0000,0.0000,0.0000},
{-1331.756470,-113.045883,36.007622,0.0000,0.0000,0.0000},
{-1340.685791,-121.796143,36.007622,0.0000,0.0000,90.0000},
{-1340.685791,-138.371277,36.007622,0.0000,0.0000,90.0000},
{-1340.685791,-155.144745,36.007622,0.0000,0.0000,90.0000},
{-1340.685791,-171.918945,36.007622,0.0000,0.0000,90.0000},
{-1340.685791,-188.493378,36.007622,0.0000,0.0000,90.0000},
{-1340.685791,-205.317871,36.007622,0.0000,0.0000,90.0000},
{-1340.660767,-205.567810,36.007622,0.0000,0.0000,90.0000},
{-1332.002319,-214.392548,36.007622,0.0000,0.0000,180.0000},
{-1315.151978,-214.392548,36.007622,0.0000,0.0000,180.0000},
{-1298.296265,-214.392548,36.007622,0.0000,0.0000,180.0000},
{-1281.693237,-214.392548,36.007622,0.0000,0.0000,180.0000},
{-1264.865723,-214.392548,36.007622,0.0000,0.0000,180.0000},
{-1248.036987,-214.392548,36.007622,0.0000,0.0000,180.0000}
};

new pDuelObj[MAX_SERVER_PLAYERS][12+97];

//------------------------------------------------------------------------------
//TextDraw


#define MAIN_TEXT 14
#define TOP_SHOTTA 5
#define WEAPON_TEXT 5
#define MOTD_TEXT 5
#define PTEXT 16
#define ARENA_TEXT ACTIVE_TEAMS
#define FINALTEAMTEXT 10
#define FINALSCOREBOARDTEXT 8

new Text:pText[16][MAX_SERVER_PLAYERS];
new Text:MainText[14];
//new Text:MoneyBox;
new Text:TopShotta[5];
new Text:WeaponText[5][2];
new Text:MOTD[1][MAX_SERVER_PLAYERS];
new Text:ArenaTxt[ACTIVE_TEAMS];

new Text:gFinalTeamText[10][2];
new Text:gFinalScoreBoardRounds[8];

new Text:gFinalText;
new Text:gFinalText1[ACTIVE_TEAMS];
new Text:gFinalText2[ACTIVE_TEAMS];
new Text:gFinalText3[ACTIVE_TEAMS];
new Text:gFinalText4[ACTIVE_TEAMS];
new Text:StatusText[2];
new Text:TeamDmgTextA[ACTIVE_TEAMS];
new Text:TeamDmgTextB[2];

new FinalStr2[ACTIVE_TEAMS][32];
new FinalStr3[ACTIVE_TEAMS][256];
new FinalStr4[ACTIVE_TEAMS][32];

//------------------------------------------------------------------------------
//player textdraw bools

new bool:PanoShowing[MAX_SERVER_PLAYERS];
new bool:VehInfoShowing[MAX_SERVER_PLAYERS];

new bool:MainTextShowing[MAX_SERVER_PLAYERS][MAIN_TEXT];
new bool:pTextShowing[MAX_SERVER_PLAYERS][MAX_SERVER_PLAYERS][PTEXT];

//------------------------------------------------------------------------------

//final result stuff
enum F_Location
{
	F_Type,
	F_ID,
	F_Winner,
	F_Status,
	F_Name
}
new FinalData[F_Location][256];

#define F_EOC_1 "~y~"
#define F_EOC_2 "~w~"
#define F_EOC_3 "~b~"
#define F_EOC_4 "~w~"
#define F_EOC_5 "~r~"
#define F_EOC_6 "~w~"

new L_Colors[15][5] = {{F_EOC_1},{F_EOC_2},{F_EOC_1},{F_EOC_2},{F_EOC_1},{F_EOC_2},{F_EOC_1},{F_EOC_2},{F_EOC_1},{F_EOC_2},{F_EOC_1},{F_EOC_2},{F_EOC_1},{F_EOC_2},{F_EOC_1}};
new T_Colors[2][15][5] = {{{F_EOC_3},{F_EOC_4},{F_EOC_3},{F_EOC_4},{F_EOC_3},{F_EOC_4},{F_EOC_3},{F_EOC_4},{F_EOC_3},{F_EOC_4},{F_EOC_3},{F_EOC_4},{F_EOC_3},{F_EOC_4},{F_EOC_3}},{{F_EOC_5},{F_EOC_6},{F_EOC_5},{F_EOC_6},{F_EOC_5},{F_EOC_6},{F_EOC_5},{F_EOC_6},{F_EOC_5},{F_EOC_6},{F_EOC_5},{F_EOC_6},{F_EOC_5},{F_EOC_6},{F_EOC_5}}};
//------------------------------------------------------------------------------
//Menu

new Menu:GunMenu[MAX_SERVER_PLAYERS];
new CurrentMenu[MAX_SERVER_PLAYERS];
new bool:IsPlayerInMenu[MAX_SERVER_PLAYERS];

//------------------------------------------------------------------------------
//Temporary round information (used to save round statistics)

new TR_StartStr[20];
new TR_WinReason[16];
new TR_Start;
new TR_FirstStart;
new TR_DeathPosInt;
new TR_Kills[MAX_SERVER_PLAYERS];
new TR_KilledWith[MAX_SERVER_PLAYERS];
new TR_DeathPosStr[MAX_SERVER_PLAYERS][10];
new TR_StartGun[MAX_SERVER_PLAYERS][MAX_SLOTS][2];
new TR_EndGun[MAX_SERVER_PLAYERS][MAX_SLOTS][2];
new TR_KilledBy[MAX_SERVER_PLAYERS][STR];
new Float:TR_KillersHP[MAX_SERVER_PLAYERS];
new Float:TR_KillDist[MAX_SERVER_PLAYERS];
new bool:TR_Suicide[MAX_SERVER_PLAYERS];
new bool:TR_Died[MAX_SERVER_PLAYERS];

//------------------------------------------------------------------------------

new const Float:TeleportsSA[10][3] = {
{0.0,0.0,0.0},//place holder
{2490.2466,-1668.2576,13.3438}, // grove TP
{196.9142,-1806.1362,4.3861}, // LS beach
{-2320.3835,-1625.7712,483.7062}, // chilliad TP
{-1645.1465,-251.1209,14.1484}, // SF airport
{-2261.8892,2314.0288,4.8125}, // bayside TP
{365.3049,2537.0740,16.6650}, // desert airstrip TP
{1599.9838,1604.7397,10.8203}, // LV airport TP
{2323.2095,1283.8733,10.8203}, // lobby TP
{490.3671,-2698.3640,-37.7500} // underwater TP
};

new const Float:TeleportsVCLC[23][3] = {
{0.0,0.0,0.0},
{2511.7566,-2680.5215,6.6569}, // lighthouse TP
{2080.0464,-648.9916,15.0835}, // golfcourse TP
{2510.1497,-1049.6204,5.0082}, // club malibu
{2413.6931,232.2469,13.2005}, // north point mall
{2034.6456,79.0600,5.3150}, // prawn island
{1609.4886,-1523.3506,34.5056}, // starfish helipad
{2769.5496,-182.7447,14.5479}, // dirtbike track 1
{2121.0488,-1331.2994,30.8182}, // vc construction site building
{1509.7385,503.0215,10.2169}, // vc dirtbiketrack ii
{1319.6498,-2284.9409,5.5292}, // VC docks
{713.9167,-1850.3933,9.3281}, // VC airport
{234.2381,-1214.4095,13.3146}, // VC army base
{234.2381,-1214.4095,13.3146}, // VC army base
{748.8687,-831.6287,6.2189}, // VC junkyard
{928.0362,-630.1910,5.7262}, // VC phils place
{1451.1996,-175.3450,91.9699}, // VC high office
{209.2638,675.6224,2.9466}, // LC ferry
{67.9563,1626.9426,50.7290}, // LC mansion
{-367.6342,1306.5865,14.7796}, // LC chinatown
{207.4237,1090.6282,11.7862}, // LC docks
{-2156.3357,1391.1315,11.0766}, // LC airport
{-2520.3049,2276.0693,68.1933} // LC dam
};

new cSelect[MAX_SERVER_PLAYERS];
enum screens
{
	Float:s_x,
	Float:s_y,
	Float:s_z,
	Float:s_r,
	Float:s_cx,
	Float:s_cy,
	Float:s_cz,
	s_int
}

new const Float:sScreenSA[102][screens] = {
{955.81,-50.90,1001.11,270.10,959.81,-50.90,1001.11,3}, //[NB]90NINE (4.00) BROTHEL_HOTEL
{513.04,-17.21,1001.56,357.03,513.25,-13.22,1001.56,3}, //[NB]90NINE (4.00) OG_LOC
{1220.48,-6.39,1001.32,90.57,1216.48,-6.43,1001.32,2}, //[NB]90NINE (4.00) STRIP_CLUB
{1221.43,8.60,1001.33,136.07,1218.66,5.72,1001.33,2}, //[NB]90NINE (4.00) STRIP_CLUB_SIDE
{-2666.92,1429.46,906.46,180.33,-2666.90,1425.46,906.46,3}, //[NB]90NINE (4.00) JIZZY'S_WITH_SIGN
{-2654.45,1425.91,906.46,180.28,-2654.43,1421.91,906.46,3}, //[NB]90NINE (4.00) JIZZY'S_OLD
{2193.82,1598.62,1005.06,177.95,2193.68,1594.62,1005.06,1}, //[NB]90NINE (4.00) CALIGULAS_OLD
{506.90,-4.29,1000.67,86.58,502.90,-4.05,1000.67,17}, //[NB]90NINE (4.00) DANCECLUB_OLD
{446.05,-11.11,1000.73,1.38,445.96,-7.11,1000.73,1}, //[NB]90NINE (4.00) RESTAURANT_1
{443.09,-17.73,1001.13,127.38,439.91,-20.16,1001.13,1}, //[NB]90NINE (4.00) RESTUARANT_2
{-223.29,1405.88,27.77,88.12,-227.29,1406.01,27.77,18}, //[NB]90NINE (4.00)
{953.58,2143.96,1011.02,271.58,957.58,2144.07,1011.02,1}, //[NB]90NINE (4.00)
{2324.44,-1136.41,1051.30,177.21,2324.24,-1140.41,1051.30,12}, //[NB]90NINE (4.00)
{140.24,1378.15,1088.36,179.29,140.20,1374.15,1088.36,5}, //[NB]90NINE (4.00)
{-1833.59,16.95,1061.14,182.24,-1833.44,12.95,1061.14,14}, //[NB]90NINE (4.00)
{759.96,1443.13,1102.70,175.90,759.67,1439.14,1102.70,6}, //[NB]90NINE (4.00)
{315.79,1027.13,1949.18,0.62,315.74,1031.13,1949.18,9}, //[NB]90NINE (4.00) ANDROMEDA
{508.35,-85.03,998.96,358.16,508.48,-81.03,998.96,11}, //[NB]90NINE (4.00)
{1084.76,2094.60,15.35,225.87,1087.63,2091.81,15.35,0}, //[NB]90NINE (4.00)
{2029.30,-1762.23,32.25,353.26,2029.77,-1758.26,32.25,0}, //[NB]90NINE - homies billboard LS
{2230.30,-2276.74,17.73,101.47,2226.38,-2277.53,17.73,0}, //[NB]90NINE - grey imports train station
{2140.53,-2271.04,15.47,317.29,2143.24,-2268.10,15.47,0}, //[NB]90NINE - grey imports under stairsa
{2838.32,-2374.17,32.54,358.23,2838.44,-2370.17,32.54,0}, //[NB]90NINE - LS docks overlooking boat
{723.16,-1496.19,1.93,179.00,723.09,-1500.19,1.93,0}, //[NB]90NINE - GTAT SS
{387.02,-2028.47,23.38,88.14,383.03,-2028.34,23.38,0}, //[NB]90NINE - ferris wheel
{154.13,-1952.03,51.34,131.90,151.16,-1954.70,51.34,0}, //[NB]90NINE - lighthouse top LS
{1427.95,-808.72,81.52,181.03,1428.02,-812.72,81.52,0}, //[NB]90NINE - vinewood O
{-39.05,55.20,6.64,341.31,-37.77,58.99,6.64,0}, //[NB]90NINE - farm
{-1447.75,501.28,3.04,268.27,-1443.75,501.16,3.04,0}, //[NB]90NINE - aircraft carrier SF
{-1422.21,1483.91,11.80,102.77,-1426.11,1483.03,11.80,0}, //[NB]90NINE - danang ship
{-2433.70,1549.18,34.40,89.67,-2437.70,1549.20,34.40,0}, //[NB]90NINE - big SF cargo ship
{-714.66,2043.80,61.28,1.94,-714.80,2047.80,61.28,0}, //[NB]90NINE - desert dam
{268.66,1876.85,8.43,3.39,268.42,1880.85,8.43,0}, //[NB]90NINE - area51 back
{1413.08,2773.77,14.69,90.91,1409.08,2773.70,14.69,0}, //[NB]90NINE - golf course house
{2584.64,2822.63,19.99,91.58,2580.65,2822.52,19.99,0}, //[NB]90NINE - KACC warehouse
{2138.13,1787.66,38.19,176.50,2137.89,1783.67,38.19,0}, //[NB]90NINE - clowns picket sign
{2117.11,2374.62,41.83,271.74,2121.11,2374.74,41.83,0}, //[NB]90NINE - 10 story car-park
{766.07,5.91,1000.71,268.38,770.07,5.80,1000.71,5}, //[NB]90NINE - ganton gym
{941.24,4.77,1000.92,183.03,941.46,0.77,1000.92,3}, //[NB]90NINE - brothel
{831.66,1.84,1004.17,46.30,828.76,4.60,1004.17,3}, //[NB]90NINE - betting shop
{617.96,-74.56,997.99,92.14,613.96,-74.71,997.99,2}, //[NB]90NINE - loco low
{209.20,-34.43,1001.92,138.70,206.56,-37.44,1001.92,1}, //[NB]90NINE - suburban
{1982.29,1017.80,1000.20,268.98,1986.29,1017.73,1000.20,10}, //[NB]90NINE - 4dragons
{1956.17,993.48,996.80,46.01,1953.29,996.26,996.80,10}, //[NB]90NINE - 4dragons bhead
{-909.84,459.11,1346.87,92.33,-913.84,458.94,1346.87,1}, //[NB]90NINE - LC
{2236.07,1645.24,1008.35,179.74,2236.06,1641.24,1008.35,1}, //[NB]90NINE - caligulas
{2156.96,1599.52,1006.17,274.41,2160.95,1599.83,1006.17,1}, //[NB]90NINE - caligulas chip cashing place
{-2634.66,1406.10,906.46,89.67,-2638.66,1406.12,906.46,3}, //[NB]90NINE - jizzy's front
{1266.96,-835.14,1085.63,266.08,1270.95,-835.41,1085.63,5}, //[NB]90NINE - maddoggs
{1244.08,-803.83,1084.00,267.08,1248.07,-804.04,1084.00,5}, //[NB]90NINE - maddoggs studio
{1232.06,-809.70,1084.81,176.03,1231.79,-813.69,1084.81,5}, //[NB]90NINE - maddogs office
{1234.12,-763.80,1084.00,0.48,1234.08,-759.80,1084.00,5}, //[NB]90NINE - maddogs gym
{2567.54,-1295.63,1048.28,89.17,2563.54,-1295.57,1048.28,2}, //[NB]90NINE - crack factory
{2547.43,-1298.81,1054.64,179.07,2547.37,-1302.81,1054.64,2}, //[NB]90NINE - crack palace
{2561.00,-1299.58,1054.64,178.19,2560.87,-1303.57,1054.64,2}, //[NB]90NINE - crack factory stripper room
{1728.02,-1667.80,22.60,46.33,1725.13,-1665.03,22.60,18}, //[NB]90NINE - rus building
{941.88,2147.78,1011.02,2.30,941.72,2151.77,1011.02,1}, //[NB]90NINE - meat factory
{959.00,2123.24,1011.02,181.95,959.13,2119.25,1011.02,1}, //[NB]90NINE - meat factory slaughter room
{768.14,-29.42,1000.58,178.82,768.06,-33.42,1000.58,6}, //[NB]90NINE - dojo
{-1833.34,-33.34,1061.14,178.21,-1833.47,-37.34,1061.14,14}, //[NB]90NINE - airport wall
{-1417.37,1246.13,1039.86,272.41,-1413.38,1246.30,1039.86,16}, //[NB]90NINE - circle stadium
{315.79,1039.84,1947.59,181.95,315.92,1035.84,1947.59,9}, //[NB]90NINE - cargo plane
{508.21,-79.26,998.96,1.86,508.08,-75.26,998.96,11}, //[NB]90NINE - bar pool area
{489.41,-75.30,999.67,269.11,493.41,-75.36,999.67,11}, //[NB]90NINE - bar 2
{-46.67,1400.06,1084.42,89.87,-50.67,1400.06,1084.42,8}, //[NB]90NINE - house wall
{1056.44,2091.16,16.85,272.19,1060.44,2091.31,16.85,0}, //[NB]90NINE - chip factory
{2138.63,1285.32,7.94,90.63,2134.63,1285.28,7.94,0}, //[NB]90NINE - LV under egyptian thing
{2111.44,1285.31,10.82,89.54,2107.44,1285.34,10.82,0}, //[NB]90NINE - LV farther from the egyptian
{1884.24,-1319.42,44.49,129.13,1881.14,-1321.95,44.49,0}, //[NB]90NINE - Construction Open
{1870.40,-1306.87,34.49,233.70,1873.63,-1309.24,34.49,0}, //[NB]90NINE - Construction LS inside
{272.82,175.85,1008.17,351.62,273.40,179.80,1008.17,3}, //[NB]90NINE - LV Police Dep Int
{238.78,184.02,1003.02,179.91,238.78,180.02,1003.02,3}, //[NB]90NINE - LV Police Dep Stairs
{199.35,167.30,1003.02,268.76,203.35,167.22,1003.02,3}, //[NB]90NINE - LV Police Dep Desk
{246.25,184.59,1008.17,355.31,246.58,188.58,1008.17,3}, //[NB]90NINE - LV Police Dep Window
{259.33,182.70,1003.02,178.65,259.23,178.70,1003.02,3}, //[NB]90NINE - LV Police Dep Wall
{293.25,180.82,1008.17,146.93,291.07,177.47,1008.17,3}, //[NB]90NINE - LV Police Dep Desktop
{-1980.32,137.85,30.40,90.86,-1984.32,137.79,30.40,0}, //[NB]90NINE - SF doherty window
{-2060.53,251.78,37.93,171.00,-2061.16,247.83,37.93,0}, //[NB]90NINE - SF construction cement O
{-2046.55,310.14,42.26,358.53,-2046.45,314.14,42.26,0}, //[NB]90NINE - SF construction window
{-2060.16,310.21,47.04,357.87,-2060.01,314.21,47.04,0}, //[NB]90NINE - SF construction window up
{-2114.64,280.06,39.42,356.47,-2114.39,284.05,39.42,0}, //[NB]90NINE - SF construction window 2
{-2132.19,368.67,47.51,89.93,-2136.19,368.68,47.51,0}, //[NB]90NINE - SF glass
{-2206.83,648.42,54.57,177.90,-2206.97,644.42,54.57,0}, //[NB]90NINE - SF chinatown wooden ledge
{-2240.52,580.56,57.63,129.05,-2243.63,578.04,57.63,0}, //[NB]90NINE - SF Chinatown roof
{773.92,5.40,1000.78,87.18,769.92,5.59,1000.78,5}, //[NB]90NINE - Gym dumbells
{763.29,11.08,1001.16,269.77,767.29,11.07,1001.16,5}, //[NB]90NINE - Ganton Gym Ring
{938.63,-15.35,1000.92,266.28,942.62,-15.61,1000.92,3}, //[NB]90NINE - Brothel Wall
{970.71,0.45,1001.14,269.41,974.71,0.41,1001.14,3}, //[NB]90NINE - Brothel Wall 2
{948.28,-55.95,1001.12,89.26,944.28,-55.89,1001.12,3}, //[NB]90NINE - Brothel Wall 3
{1209.10,-35.02,1001.48,12.54,1208.23,-31.12,1001.48,3}, //[NB]90NINE - Strip Club Small
{1214.94,-33.51,1001.38,91.50,1210.94,-33.61,1001.38,3}, //[NB]90NINE - Strip Club Small 2
{360.78,173.60,1009.10,268.78,364.78,173.51,1009.10,3}, //[NB]90NINE - Planning Dep Desk
{354.91,193.56,1014.17,271.11,358.91,193.64,1014.17,3}, //[NB]90NINE - Planning Dep Room
{-103.58,-9.61,1001.82,115.59,-107.19,-11.34,1001.82,3}, //[NB]90NINE - Porn shop
{-19.24,-185.85,1003.54,357.51,-19.06,-181.86,1003.54,17}, //[NB]90NINE - 24/7
{224.38,-12.71,1002.21,359.08,224.44,-8.71,1002.21,5}, //[NB]90NINE - Victim
{768.81,-66.40,1001.56,136.91,766.07,-69.33,1001.56,7}, //[NB]90NINE - LV Gym
{769.11,-68.68,1001.56,268.84,773.11,-68.76,1001.56,7}, //[NB]90NINE - LV Gym 2
{197.29,-44.30,1001.80,272.09,201.29,-44.15,1001.80,1}, //[NB]90NINE - Suburban wall
{-2043.26,153.01,28.83,359.25,-2043.21,157.00,28.83,1}, //[NB]90NINE - CJ garage
{147.23,-73.05,1001.80,218.31,149.71,-76.19,1001.80,18}, //[NB]90NINE - Zip
{2531.04,-1294.39,1037.77,269.60,2535.04,-1294.42,1037.77,2} //[NB]90NINE - Crack palace
};

new const Float:sScreenGTAU[35][screens] = {
{-347.77,1451.59,24.01,359.29,-347.73,1455.59,24.01,0}, //[NB]90NINE (4.00) LC_SUBWAY_TRACKS
{1621.55,-1542.23,20.28,2.22,1621.40,-1538.23,20.28,0}, //[NB]90NINE (4.00) VC_DIAZ_MAINSION_MA
{1621.50,-1513.76,14.03,358.33,1621.62,-1509.76,14.03,0}, //[NB]90NINE (4.00) VC_DIAZ_MAINSION_LO
{1621.34,-1545.99,4.82,180.51,1621.38,-1549.99,4.82,0}, //[NB]90NINE (4.00) VC_DIAZ_MAINSION_BA
{2472.62,-1019.67,4.94,317.21,2475.34,-1016.74,4.94,17}, //[NB]90NINE (4.00) VC_MALIBU_STAGE
{2467.22,-1003.70,5.94,226.00,2470.10,-1006.48,5.94,17}, //[NB]90NINE (4.00) VC_MALIBU_BAR
{2074.74,163.29,17.70,179.72,2074.72,159.29,17.70,0}, //[NB]90NINE (4.00) VC_PRAWN_ISLAND_HOU
{1913.53,-18.95,5.32,88.49,1909.53,-18.84,5.32,0}, //[NB]90NINE (4.00) VC_SEX_SCENE
{229.75,-85.73,1011.60,1.31,229.66,-81.73,1011.60,6}, //[NB]90NINE (4.00) VC_SHOOTING_WAREHOU
{270.12,-61.21,1011.60,177.47,269.94,-65.21,1011.60,6}, //[NB]90NINE (4.00) VC_AMMU_BIG_FLAG
{1397.32,-317.20,6.69,274.66,1401.31,-316.88,6.69,0}, //[NB]90NINE (4.00) VC_BIKER_BAR_MIC
{1405.44,-308.45,6.13,101.64,1401.52,-309.25,6.13,0}, //[NB]90NINE (4.00) VC_BIKER_BAR_CASHIE
{1037.40,-1284.83,10.05,0.98,1037.33,-1280.83,10.05,0}, //[NB]90NINE (4.00) VC_BANK_MANAGER_ROO
{1134.34,-1518.36,10.52,280.63,1138.27,-1517.62,10.52,0}, //[NB]90NINE (4.00) VC_CHERRY_POPPER
{2332.22,-2758.56,6.07,209.95,2334.22,-2762.02,6.07,10}, //[NB]90NINE (4.00) VC_POLE_POSITION_ST
{2320.86,-2752.67,5.02,209.29,2322.81,-2756.16,5.02,10}, //[NB]90NINE (4.00) VC_POLE_POSITION_BA
{2228.92,-2216.06,14.56,318.84,2231.55,-2213.04,14.56,0}, //[NB]90NINE (4.00) VC_TOMMY_ROOM
{2223.94,-2224.94,6.53,166.56,2223.01,-2228.83,6.53,0}, //[NB]90NINE (4.00) VC_TOMMY_LOBBY
{-917.88,1460.12,145.34,42.44,-920.58,1463.07,145.34,0}, //[NB]90NINE (4.00) LC_CLEAR_VIEW_1
{-971.56,1483.89,147.62,273.44,-967.57,1484.13,147.62,0}, //[NB]90NINE (4.00) LC_CLEAR_VIEW_2
{-1167.80,207.43,13.30,183.52,-1167.55,203.44,13.30,0}, //[NB]90NINE (4.00) LC_STAUTON_SUBWAY_STAIRS
{-1168.87,176.97,3.65,175.48,-1169.18,172.98,3.65,0}, //[NB]90NINE (4.00) LC_STAUTON_SUBWAY_ESCALATOR
{-1148.87,121.84,2.98,180.30,-1148.84,117.84,2.98,0}, //[NB]90NINE (4.00) LC_STAUTON_SUBWAY_HALL
{1243.39,251.65,5.52,271.21,1247.39,251.74,5.52,0}, //[NB]90NINE (4.00) VC_UNITED_BACKGROUN
{2478.06,-919.77,25.43,272.77,2482.05,-919.58,25.43,0}, //[NB]90NINE (4.00) VC_DIAZ_CHAINSAW_RO
{2428.63,-317.69,6.00,0.84,2428.57,-313.69,6.00,0}, //[NB]90NINE (4.00) VC_KFC_BASE
{2421.36,-440.99,6.10,210.63,2423.40,-444.43,6.10,0}, //[NB]90NINE (4.00) VC_HOUSE_POOL-BAR
{1626.29,-1171.81,3.58,180.98,1626.36,-1175.81,3.58,0}, //[NB]90NINE (4.00) VC_STARFISH_HOUSE
{1362.87,-1246.00,4.49,340.59,1364.20,-1242.22,4.49,0}, //[NB]90NINE (4.00) VCMP_SELECT
{1035.43,-800.41,3.85,270.47,1039.43,-800.37,3.85,0}, //[NB]90NINE (4.00) VC_GRANDMA_HOUSE
{-884.67,422.97,68.41,99.65,-888.61,422.30,68.41,0}, //[NB]90NINE (4.00)
{-735.31,895.49,142.53,179.94,-735.32,891.49,142.53,0}, //[NB]90NINE (4.00)
{-1172.62,540.32,33.12,267.43,-1168.62,540.14,33.12,0}, //[NB]90NINE (4.00)
{1674.30,541.90,2.95,180.31,1674.33,537.90,2.95,0}, //[NB]90NINE (4.00)
{893.12,-597.58,6.10,268.44,897.12,-597.69,6.10,0} //[NB]90NINE (4.00)
};

new const Float:MOTDScreens[17][6] = {//campos xyz camlook@ xyz
{1997.6104,1844.4302,124.5000,2323.6565,1283.1251,97.5327},
{1479.7021,-1788.9418,156.7533,526.5471,-991.6736,90.9792},
{611.6418,-1285.0751,64.1875,1092.2123,-910.5407,62.9453},
{-1807.3213,559.7010,227.7866,-1806.8649,559.0714,54.3606},
{1973.6964,1240.6625,63.7670,2170.3188,1509.0540,30.4204},
{-337.4875,-149.7615,56.4067,572.8127,401.4011,18.9297},
{-2380.0117,-574.3899,133.6172,-1555.7738,292.8461,53.4609},
{-2388.6055,-537.9532,125.1522,-2244.9363,473.0975,73.7422},
{-2662.4395,1594.5344,225.7578,-2649.7937,663.1368,66.0938},
{-2661.5132,1594.9020,225.7578,-1847.7334,1052.3835,145.1297},
{-1844.9967,1086.3348,145.2758,-1451.8572,1920.6370,50.4200},
{-2469.1313,1544.5826,41.8047,-2372.1335,1544.7698,31.8594},
{2685.0342,2778.4353,61.7891,1579.0430,2470.4395,6.7553},
{844.3621,-1306.7241,30.0794,1772.1797,-1298.8765,131.7344},
{-1948.8137,654.7035,100.4172,-1952.5120,659.0026,47.7031},
{-1502.7479,585.7156,34.5781,-918.9612,1010.1230,34.5781},
{1305.1544,2107.1965,11.0156,1415.0515,2207.6660,29.7109}
};

new FinalR_Loc;
new const Float:FinalResultLocs[29][4] = {
{2490.7063,-1668.5127,13.3438,0.0}, // grove
{371.6014,-2028.8739,7.6719,0.0}, // ferris wheel
{1291.2859,-788.1967,96.4609,0.0}, // maddoggs helipad
{-1274.6075,501.4547,18.2344,0.0}, // army boat
{-1469.3323,1489.4231,8.2501,0.0}, // SF small boat
{-2681.3542,1767.0336,68.4844,0.0}, // golden gate bridge
{-2227.2439,2326.7834,7.5469,0.0}, // bayside helipad
{1358.5453,2160.1565,11.0156,0.0}, // baseball field
{-994.2756,1029.1530,1341.8438,10.0}, // RC battlefield Int 10
{2235.8555,1676.5292,1008.3594,1.0}, // caligulas INT 1
{-1373.1587,1591.7797,1052.5313,14.0}, // kickstart stadium INT 14
{-1401.3016,995.5995,1024.1133,15.0}, // bloodbowl stadium INT 15
{2587.1143,2828.2180,10.8203,0.0}, // KACC warehouse
{2737.7966,-1760.2612,44.1487,0.0}, // LS stadium top
{2508.8599,-2656.1409,27.0000,0.0}, // LS Docks big tank
{2212.0154,-2236.1001,13.5469,0.0}, // Grey Imports
{1544.1686,-1352.9142,329.4750,0.0}, // LS highest building
{756.0528,-1259.2528,13.5647,0.0}, // LS house with tennis courts
{725.5969,-1462.0695,22.2109,0.0}, // LS building above waterway
{296.8583,-1168.1163,80.9099,0.0}, // LS Vincewood big house
{1100.9690,-825.7762,114.4477,0.0}, // LS Vinewood saucer house
{-41.0972,78.1380,3.1172,0.0}, // Farm
{-1522.9600,-408.1206,7.0781,0.0}, // SF airport entrance
{-2378.1323,1551.6788,31.8594,0.0}, // SF cargo ship
{-1468.4606,1489.5836,8.2578,0.0}, // SF danang boat
{404.7168,2454.6287,16.5000,0.0}, // desert airstrip garage
{1240.5667,2794.2168,10.8203,0.0}, // golf course
{2428.2427,1811.5505,38.8203,0.0}, // LV purple dome
{2319.3516,1286.8563,10.8203,0.0} // inside pyramid
};

new const RandWeaps[18] = {5,9,12,22,23,24,25,26,27,28,29,30,31,32,34,35,36,38};

new const WeaponClipSize[MAX_WEAPONS] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,-1,-1,-1,17,7,0,4,7,100,30,30,50,100,0,0,0,0,0,500,0,1,500,500,1,1,1,1};

#define MAX_DROP_AMOUNT				-1
#define INVALID_PICKUP				-1
#define MAX_SCRIPT_PICKUPS					200

enum pickup
{
	p_weapon,
	p_ammo,
	p_timer,
	p_creation_time,
	Float:p_x,
	Float:p_y,
	Float:p_z
}
new pickups[MAX_SCRIPT_PICKUPS][pickup];
new const weapons[]={-1,331,333,334,335,336,337,338,339,341,321,322,323,324,325,326,342,343,344,-1,-1,-1,346,347,348,349,350,351,352,353,355,356,372,357,358,359,360,361,362,363,-1,365,366,367,-1,-1,371};

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

#define e_STATE_IDLE 0
#define e_STATE_ACTIVE 1
#define e_STATE_NONE 2

new gLastUpdate[MAX_SERVER_PLAYERS],
Float:gPlayerHealth[MAX_SERVER_PLAYERS],
Float:gPlayerArmor[MAX_SERVER_PLAYERS],
gPlayerAmmo[MAX_SERVER_PLAYERS][MAX_SLOTS],
gState[MAX_SERVER_PLAYERS] = e_STATE_NONE,
Ticks = 0;

public OnPlayerUpdate(playerid)
{
	format(textdrawString, 256,"~r~~h~%s - ~w~%d ~b~~h~%s - ~w~%d",TeamName[T_HOME],TeamRoundsWon[T_HOME],TeamName[T_AWAY],TeamRoundsWon[T_AWAY]);
	UpdatePlayerInfo(0, playerid, textdrawString);
	if(AllowSuicide[playerid] == true && ShowDMG[playerid] == true)
	{
	    new Float:temph,Float:tempa, changed;//, string[40];
	    GetPlayerHealth(playerid,temph);
		GetPlayerArmour(playerid,tempa);
		/*format(string,sizeof(string),"HP:    %.0f~n~Team: %s",temph + tempa, TeamName[gTeam[playerid]]);
		TextDrawSetString(pText[6][playerid],string);*/
  		if(temph != gPlayerHealth[playerid])
		{
		    if(SettingHP[playerid] == true)
			{
				gPlayerHealth[playerid] = temph;
				gPlayerArmor[playerid] = tempa;
				SettingHP[playerid] = false;
			}
			else changed = O_HEALTH;
		}
  		else if(tempa != gPlayerArmor[playerid])
		{
			if(SettingHP[playerid] == true)
			{
				gPlayerHealth[playerid] = temph;
				gPlayerArmor[playerid] = tempa;
				SettingHP[playerid] = false;
			}
			else changed = O_ARMOR;
		}
		if(changed && SettingHP[playerid] == false)OnPlayerLifeChange(playerid,temph,tempa,gPlayerHealth[playerid],gPlayerArmor[playerid],changed);
	}
	if(Syncing[playerid] == true)
	{
		if(GetPlayerWeapon(playerid) != LastWeapon[playerid])
		{
		    KillTimer(SyncTimer[playerid]);
		    SendClientMessage(playerid,MainColors[2],"Sync failed! (you changed weapons motherfucker)");
    		Syncing[playerid] = false;
            NoKeys[playerid] = false;
			ChangedWeapon[playerid] = true;
		}
	}
	if(gState[playerid] != e_STATE_NONE)
	{
		gLastUpdate[playerid] = Ticks;
		if(gState[playerid] == e_STATE_IDLE)
		{
		    OnPlayerUnpause(playerid);
		}
		gState[playerid] = e_STATE_ACTIVE;
	}
 	return 1;
}

UpdateTeamLife(teamid,Float:amount)
{
	if(amount > 0.0)
	{
    	TeamLifeCombo[teamid]++;
    	if(TeamDmgTimerActive[teamid] == true)
		{
			KillTimer(TeamDmgTimer[teamid]);
			TeamDmgAmt[teamid]+=amount;
			if(TeamDmgAmt[teamid] > TeamHighestCombo[teamid][1])
			{
			    TeamHighestCombo[teamid][1] = TeamDmgAmt[teamid];
			    TeamHighestCombo[teamid][0] = TeamLifeCombo[teamid];
			}
		}
		else
		{
			TeamDmgAmt[teamid] = amount;
			TeamDmgTimerActive[teamid] = true;
		}
		new string[6];
		format(string,sizeof(string),"%.0f",TeamDmgAmt[teamid]);
		if(ModeType == BASE || (TeamsBeingUsed == 2 && ModeType != TDM))TextDrawSetString(TeamDmgTextB[teamid],string);
		else TextDrawSetString(TeamDmgTextA[teamid],string);
		TeamDmgTimer[teamid] = SetTimerEx("HideTeamLifeText",3000,0,"i",teamid);
	}
	UpdateRoundStrings(teamid);
	return 1;
}

forward HideTeamLifeText(teamid);
public HideTeamLifeText(teamid)
{
    TeamDmgTimerActive[teamid] = false;
    TeamLifeCombo[teamid] = 0;
    if(ModeType == BASE || (TeamsBeingUsed == 2 && ModeType != TDM))TextDrawSetString(TeamDmgTextB[teamid]," ");
	else TextDrawSetString(TeamDmgTextA[teamid]," ");
	return 1;
}

forward OnPlayerLifeChange(playerid,Float:newhealth,Float:newarmor,Float:oldhealth,Float:oldarmor,type);
public OnPlayerLifeChange(playerid,Float:newhealth,Float:newarmor,Float:oldhealth,Float:oldarmor,type)
{
	if(ShowDMG[playerid] == false || gPlayerSpawned[playerid] == false)return 1;
	gPlayerHealth[playerid] = newhealth;
	gPlayerArmor[playerid] = newarmor;
	new Float:AMT = (oldhealth + oldarmor) - (newhealth + newarmor), string[140];
	if(AMT == 0)return 1;
	CreatePlayerDmgObject(playerid,type);
    if(Playing[playerid] == true)
	{
	    if(AmtSpectating[playerid] > 0)
	    {
			new Float:ratio,Float:killz,Float:deathz;killz = TempKills[playerid];deathz = TempDeaths[playerid];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~w~Kills: ~b~%d  ~w~Deaths: ~b~%d  ~w~Ratio: ~b~%.02f ~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,TempKills[playerid],TempDeaths[playerid],ratio,newhealth,newarmor);
			TextDrawSetString(pText[1][playerid],string);
		}
		if(WatchingBase == false)
		{
		    if(AMT > 0.0)
		    {
				if(LifeUpdateVar[playerid] > 0)LifeUpdateAmt[playerid] += AMT;
				else LifeUpdateAmt[playerid] = AMT;
				LifeUpdateVar[playerid] = 3;
				HitCounter[playerid]++;
				format(string,40,"%.0f DMG~n~~w~%d combo",LifeUpdateAmt[playerid],HitCounter[playerid]);
				TextDrawSetString(pText[14][playerid],string);
			}
			if(TabHP == true)SetPlayerScore(playerid,floatround(newarmor + newhealth));
			UpdateTeamLife(gTeam[playerid],AMT);
		}
	}
	else
	{
	    if(AmtSpectating[playerid] > 0)
	    {
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,newhealth,newarmor);
			TextDrawSetString(pText[1][playerid],string);
		}
		if(AMT > 0.0)
		{
			if(LifeUpdateVar[playerid] > 0)LifeUpdateAmt[playerid] += AMT;
			else LifeUpdateAmt[playerid] = AMT;
			LifeUpdateVar[playerid] = 3;
			HitCounter[playerid]++;
			format(string,40,"%.0f DMG~n~~w~%d combo",LifeUpdateAmt[playerid],HitCounter[playerid]);
			TextDrawSetString(pText[14][playerid],string);
		}
		if(TabHP == true && Current != -1)SetPlayerScore(playerid,0);
	}
	return 1;
}

CreatePlayerDmgObject(playerid,type)
{
	if(!DmgObjectCreated[playerid])//no object created
	{
		DmgObject[playerid] = CreateObject(type,0.0,0.0,0.0,0.0,0.0,0.0);
		AttachObjectToPlayer(DmgObject[playerid],playerid,0.0,0.0,2.0,0.0,0.0,0.0);
		DmgObjectCreated[playerid] = type;
	}
	else if(DmgObjectCreated[playerid] != type)//created, but is showing the armor object
	{
	    KillTimer(DmgObjectTimer[playerid]);
	    DestroyObject(DmgObject[playerid]);
	    DmgObjectCreated[playerid] = type;
	    DmgObject[playerid] = CreateObject(type,0.0,0.0,0.0,0.0,0.0,0.0);
		AttachObjectToPlayer(DmgObject[playerid],playerid,0.0,0.0,2.0,0.0,0.0,0.0);
	}
	else KillTimer(DmgObjectTimer[playerid]);//is already showing the correct object
 	DmgObjectTimer[playerid] = SetTimerEx("DestroyPlayerDmgObject",150,0,"i",playerid);
	return 1;
}

forward DestroyPlayerDmgObject(playerid);
public DestroyPlayerDmgObject(playerid)
{
	DestroyObject(DmgObject[playerid]);
	DmgObjectCreated[playerid] = 0;
}

OnPlayerPause(playerid)
{
	gState[playerid] = e_STATE_IDLE;
	/*if(IsPlayerInCheckpoint(playerid) && Playing[playerid] == true)
 	{
 		RemovePlayerFromRound(playerid);
 		new string[128];format(string,128,"*** \"%s\" has been removed from the round for pausing in the CHECKPOINT!",NickName[playerid]);
 		SendClientMessageToAll(MainColors[0],string);
 	}*/
	return 1;
}

OnPlayerUnpause(playerid)
{
	SetTimerEx("FixRadioStart",100,0,"i",playerid);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

main()
{
	print("_________________________________________________________");
	print("    											   			");
    printf("%s",GM_VERSION);
	print("By: MozZ - [NB]90NINE									");
	print("www.bg.samp.com											");
	print("     _/_/_/    _/_/_/   _/        _/           _/_/_/_/_/                   _/");
	print("   _/    _/  _/    _/  _/_/_/    _/   _/_/_/         _/     _/_/       _/_/_/");
	print("    _/_/_/    _/_/_/  _/    _/  _/  _/    _/      _/      _/_/_/_/   _/   _/");
	print("      _/        _/  _/     _/  _/  _/    _/    _/         _/_/      _/   _/");
	print("_/_/_/    _/_/_/   _/_/_/     _/   _/_/_/  _/_/_/_/_/     _/_/_/    _/_/_/");
	print("_________________________________________________________");
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnGameModeInit()
{
	/*#if defined PRIV_MODE
	{
    	new BIND[16];GetServerVarAsString("bind",BIND,sizeof(BIND));
		if((strcmp(BIND,PRIV_IP,false,16) && strcmp(BIND,PRIV_IP2,false,16) && strcmp(BIND,PRIV_IP3,false,16)) || !strlen(BIND))
		{
	    	print("You do not have permission to use this gamemode.");
			print("Server Shutting Down...");
		    SendRconCommand("exit");
			return 0;
 		}
 		new port = GetServerVarAsInt("port");
		if(PRIV_PORT != -1 && port != PRIV_PORT)
		{
	    	print("You do not have permission to use this gamemode.");
			print("Server Shutting Down...");
			SendRconCommand("exit");
			return 0;
		}
	}
	#endif*/
	

    for(new i; i < MAX_SERVER_PLAYERS-1; i++)
    {
        if(IsPlayerConnected(i))IsConnected[i] = true;
        if(IsPlayerConnected(i)) CreatePlayerInfo(i);
    }
	
	LoadConfig();
	LoadColors();
	TD_CreateScoreboard();
	CreateGlobalTextdraws();
	SetGameModeText(GM_VERSION);
	UpdateMapName();
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	EnableTirePopping(true);
	AllowAdminTeleport(true);
	AllowInteriorWeapons(true);
	EnableStuntBonusForAll(false);
	SetNameTagDrawDistance(110);
	//SetDisabledWeapons(43,44,45);
	SetTeamCount(4);
	ClearDeathMessages();
	
	for(new i; i < MAX_TEAMS+1; i++)
	{
		AddPlayerClassEx(i,21,1413.5219,2153.8735,12.0156,94.2749,0,0,0,0,0,0);
	}

	if(GameMap == VC)CreateObject(15753,-1629.4340,1168.4301,42.9641,0.1800,-0.0199,0.0000);//missing bridge from GTAU - Staunton to Shoreside
	BlackRadar = GangZoneCreate(-9000,-9000,9000,9000);

	SetTimer("LoadBases",1000,0);
	SetTimer("LoadArenas",1500,0);
	SetTimerEx("LoadConfigB",2000,0,"i",0);
	SetTimerEx("LoadConfigA",2500,0,"i",0);
	SetTimerEx("LoadConfigP",3000,0,"i",0);
	SetTimer("LoadVehicleInfo",3500,0);
	
	SetTimer("LoadJnP",500,0);
	SetTimer("ShowMoneyAsHP",1200,1);
	SetTimer("XTime",1000,0);
	SetTimer("DestroyEmptyVehicles",120000,1);
	SetTimer("UpdateVehicleInfo",999,1);
	SetTimer("Advert",15 * 60000,1);
	SetTimer("LifeUpdater",1000,1);
	SetTimer("Spectate_UpdatePlayerAmmo",1100,1);
	SetTimer("PingUpdate",2999,1);
	SetTimer("YOUNOS",15000,1);
	return 1;
	}
public OnGameModeExit()
{
    //FunctionLog("OnGameModeExit");
    for(new i = 0; i < MAX_SERVER_PLAYERS; i++)
	{
		SetPlayerName(i,RealName[i]);
		SetPlayerInterior(i,0);
		TogglePlayerControllable(i,1);
		SetCameraBehindPlayer(i);
		if(IsPlayerConnected(i)) DestroyPlayerInfo(i);
	}
	DestroyAllTextDraws();
	ClearDeathMessages();
	JnP = false;
	GangZoneDestroy(BlackRadar);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

forward FindNextAvailableClass(playerid,direction);
public FindNextAvailableClass(playerid,direction)
{
    //FunctionLog("FindNextAvailableClass");
	if(direction == UP)
	{
	    if(pClassID[playerid] == MAX_TEAMS+1)pClassID[playerid] = 0;
	    else pClassID[playerid]++;
	}
	else
	{
	    if(pClassID[playerid] == 0)pClassID[playerid] = MAX_TEAMS;
	    else pClassID[playerid]--;
	}
	if(pClassID[playerid] != 0 && (TeamUsed[pClassID[playerid]-1] == false || TeamLock[pClassID[playerid]-1] == true))return FindNextAvailableClass(playerid,direction);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    //FunctionLog("OnPlayerRequestClass");
	if(Playing[playerid] == true && ModeType == TDM){SpawnPlayer(playerid);return 1;}
    if(ViewingMOTD[playerid] == true){return 1;}
	if(Rotating[playerid] == false){Rotating[playerid] = true;RotatePlayer(playerid);}
	if(gTeam[playerid] == T_SUB)sTeam[playerid] = T_SUB;
	if(classid > OldClassID[playerid])
	{
	    if(OldClassID[playerid] == 0 && classid == MAX_TEAMS)
		{
		    if(pClassID[playerid] == 0)pClassID[playerid] = MAX_TEAMS;
		    else pClassID[playerid]--;
			OldClassID[playerid] = classid;
			if(pClassID[playerid] != 0 && TeamUsed[pClassID[playerid]-1] == false)FindNextAvailableClass(playerid,DOWN);
		}
	    else
		{
		    if(pClassID[playerid] >= MAX_TEAMS)pClassID[playerid] = 0;
		    else pClassID[playerid]++;
			OldClassID[playerid] = classid;
			if(pClassID[playerid] != 0 && TeamUsed[pClassID[playerid]-1] == false)FindNextAvailableClass(playerid,UP);
		}
	}
	else if(classid < OldClassID[playerid])
	{
	    if(OldClassID[playerid] == MAX_TEAMS && classid == 0)
		{
		    if(pClassID[playerid] >= MAX_TEAMS)pClassID[playerid] = 0;
		    else pClassID[playerid]++;
			OldClassID[playerid] = classid;
			if(pClassID[playerid] != 0 && TeamUsed[pClassID[playerid]-1] == false)FindNextAvailableClass(playerid,UP);
		}
	    else
		{
		    if(pClassID[playerid] == 0)pClassID[playerid] = MAX_TEAMS;
		    else pClassID[playerid]--;
			OldClassID[playerid] = classid;
			if(pClassID[playerid] != 0 && TeamUsed[pClassID[playerid]-1] == false)FindNextAvailableClass(playerid,DOWN);
		}
	}
	
	//TextDrawHideForPlayer(playerid,MoneyBox);
    //TextDrawHideForPlayer(playerid,pText[6][playerid]);
    SetTimerEx("GiveSelectionWeapon",15,0,"i",playerid);
    if(FirstSelect[playerid] == false)
    {
        TD_HideRoundScoreBoard(playerid);
    	UpdatePrefixName(playerid);
    	SetTeam(playerid,T_SUB);
		SetPlayerColorEx(playerid,grey);
    	TD_ShowPanoForPlayer(playerid);
 		gSelectingClass[playerid] = true;
 		PlayerPlaySound(playerid,death+1,0.0,0.0,0.0);
 		FirstSelect[playerid] = true;
 		SetPlayerWeather(playerid,44);
		SetPlayerTime(playerid,6,0);
	}
    
    new SelectionString[32];
	new realteam = pClassID[playerid] - 1;
	
    if(pClassID[playerid] == 0)
	{
		format(SelectionString, sizeof(SelectionString), "Auto-Assign");
		TextDrawBackgroundColor(pText[0][playerid],MainColors[3]);
	}
	else
	{
	    if(TeamLock[realteam] == true)
	    {
	        TextDrawBackgroundColor(pText[0][playerid],TeamActiveColors[realteam] | 255);
	        SetPlayerSkin(playerid,252);
	        format(SelectionString, sizeof(SelectionString), "%s ~w~(~r~LOCKED~w~)",TeamName[realteam]);
	    }
	    else
	    {
	    	if(TeamSkin[realteam] != -1)SetPlayerSkin(playerid,TeamSkin[realteam]);
    		else if(Skin[playerid] != -1)SetPlayerSkin(playerid,Skin[playerid]);
    	
			TextDrawBackgroundColor(pText[0][playerid],TeamActiveColors[realteam] | 255);
			if(realteam < 2)
			{
				format(SelectionString, sizeof(SelectionString), "%s ~w~(%s)",TeamName[realteam],TeamStatusStr[realteam]);
			}
			else format(SelectionString, sizeof(SelectionString), "%s",TeamName[realteam]);
		}
	}
    TD_HidepTextForPlayer(playerid,playerid,0);
	TextDrawSetString(pText[0][playerid],SelectionString);
	TD_ShowpTextForPlayer(playerid,playerid,0);


    if(GameMap == SA){SetPlayerPos(playerid,sScreenSA[cSelect[playerid]][s_x],sScreenSA[cSelect[playerid]][s_y],sScreenSA[cSelect[playerid]][s_z]);SetPlayerInterior(playerid,sScreenSA[cSelect[playerid]][s_int]);}
	else{SetPlayerPos(playerid,sScreenGTAU[cSelect[playerid]][s_x],sScreenGTAU[cSelect[playerid]][s_y],sScreenGTAU[cSelect[playerid]][s_z]);SetPlayerInterior(playerid,sScreenGTAU[cSelect[playerid]][s_int]);}
	return 1;
}

forward GiveSelectionWeapon(playerid);
public GiveSelectionWeapon(playerid)
{
	GivePlayerWeapon(playerid,RandWeaps[random(sizeof(RandWeaps))],1234);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnPlayerRequestSpawn(playerid)
{
    //FunctionLog("OnPlayerRequestSpawn");
	if(ViewingMOTD[playerid] == true)return 0;
	if(Variables[playerid][LoggedIn] == false && Variables[playerid][Registered] == true)
	{
	    SendClientMessage(playerid,Colors[2],"YOU CANNOT SPAWN UNTIL YOU HAVE LOGGED IN!");
	    return 0;
	}
	if(strcmp(ServerPass,"off",true,3) && CorrectPassword[playerid] == false && !IsPlayerAdmin(playerid))
	{
		SendClientMessage(playerid,MainColors[2],"YOU MUST ENTER THE CORRECT PASSWORD BEFORE SPAWNING! (/pass [password])");
		return 0;
	}
	ShowDMG[playerid] = false;
	if(ReAdding[playerid] == true)
	{
		SetTimerEx("ReAddPlayer",2500,0,"i",playerid);
		TD_ShowRoundScoreBoard(playerid);
		return 1;
	}
	if(pClassID[playerid] == 0)
	{
	    new teamid = Team_GetTeamWithLowestPlayers();
	    new string[128];
    	TD_HidepTextForPlayer(playerid,playerid,0);
		SetTeam(playerid,teamid);
		SetPlayerColorEx(playerid,TeamInactiveColors[teamid]);
		format(string,sizeof(string),"*** \"%s\" has Spawned as \"%s\" (Auto-Assigned)",NickName[playerid],TeamName[teamid]);
		SendClientMessageToAll(TeamActiveColors[teamid],string);
	}
	else if(TeamLock[pClassID[playerid]-1] == true)
	{
		return 0;
	}
	else if(pClassID[playerid]-1 == T_SUB)
	{
	    TD_HidepTextForPlayer(playerid,playerid,0);
	    SetTimerEx("SubMenu",50,0,"i",playerid);
	}
	else
	{
	    new string[128];
	    new realteam = pClassID[playerid]-1;
	    TD_HidepTextForPlayer(playerid,playerid,0);
		SetTeam(playerid,realteam);
		SetPlayerColorEx(playerid,TeamInactiveColors[realteam]);
		format(string,sizeof(string),"*** \"%s\" has Spawned as \"%s\"",NickName[playerid],TeamName[realteam]);
		SendClientMessageToAll(TeamActiveColors[realteam],string);
	}
	
    SetTimerEx("UpdatePrefixName",500,0,"i",playerid);
	FindPlayerSpawn(playerid,1);
 	SetPlayerRandomSelectionScreen(playerid);
	Rotating[playerid] = false;
	FirstSelect[playerid] = false;
	TD_ShowRoundScoreBoard(playerid);
	//TextDrawShowForPlayer(playerid,MoneyBox);
	//TextDrawShowForPlayer(playerid,pText[6][playerid]);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

forward SetCam(playerid);
public SetCam(playerid)
{
    //FunctionLog("SetCam");
    SetPlayerCameraPos(playerid,MOTDScreens[MOTDScreen[playerid]][0],MOTDScreens[MOTDScreen[playerid]][1],MOTDScreens[MOTDScreen[playerid]][2]);
	SetPlayerCameraLookAt(playerid,MOTDScreens[MOTDScreen[playerid]][3],MOTDScreens[MOTDScreen[playerid]][4],MOTDScreens[MOTDScreen[playerid]][5]);
	return 1;
}

public OnPlayerConnect(playerid)
{
    //FunctionLog("OnPlayerConnect");
    if(playerid >= MAX_SERVER_PLAYERS)return Kick(playerid);
    Itter_OnPlayerConnect(playerid);
    //Sound_OnPlayerConnect(playerid);
    Players++;
    IsConnected[playerid] = true;
    if(playerid > HighestID)HighestID = playerid;
	
    new PlayerName[24],file[60];
	GetPlayerName(playerid,PlayerName,24);
	RealName[playerid] = PlayerName;
	NickName[playerid] = PlayerName;
	TempName[playerid] = PlayerName;
	ListName[playerid] = Misc_RemovePlayerTags(RealName[playerid]);
	udbName[playerid] = udb_encode(PlayerName);
	
	UpdateNewPlayerLocks(playerid);
	SetPlayerRandomSelectionScreen(playerid);
	ResetPlayerVars(playerid);
	HideAllTextDraws(playerid);
	TD_ShowpTextForPlayer(playerid,playerid,14);
	TimeAtConnect[playerid] = Now();
	SetTimerEx("EndGracePeriod",20000,0,"i",playerid);
	SetTimerEx("CheckPlayerName",1000,0,"i",playerid);
	
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	if(!dini_Exists(file))
	{
	    dini_Create(file);
		CreateProfile(playerid);
	}
	else
	{
	    Variables[playerid][Registered] = bool:dini_Int(file,"Registered");
		if(Variables[playerid][Registered] == true)
    	{
			new tmp2[128],IP[20];
			GetPlayerIp(playerid,IP,sizeof(IP));
			tmp2 = dini_Get(file,"IP");
			if(!strcmp(IP,tmp2,true))
			{
			    Variables[playerid][Level] = dini_Int(file,"Level");
		    	format(tmp2,sizeof(tmp2),"Welcome back, %s. You have automatically been logged in. (Level %d)",RealName[playerid],Variables[playerid][Level]);
		    	Variables[playerid][LoggedIn] = true;
			}
	 		else
	 		{
		 		format(tmp2,sizeof(tmp2),"Welcome back, %s. To log back into your account, type /XLOGIN <PASSWORD>. YOU HAVE 30 SECONDS!",RealName[playerid]);
		 		Variables[playerid][LoggedIn] = false;
		 		SetTimerEx("LoginCheck",32000,0,"i",playerid);
			}
			SendClientMessage(playerid,Colors[0],tmp2);
		}
        
        new string[STR],idx;
	    LoadPlayerTemp(playerid,file);
	    SetSpawn[playerid] = dini_Int(file,"SetSpawn");
     	if(SetSpawn[playerid] == 1 || SetSpawn[playerid] == 2)//load player spawn coords
		{
			string = dini_Get(file,"mSpawn");
			mSpawn[0][playerid] = floatstr(strtok(string,idx,','));
			mSpawn[1][playerid] = floatstr(strtok(string,idx,','));
			mSpawn[2][playerid] = floatstr(strtok(string,idx,','));
			mSpawn[3][playerid] = floatstr(strtok(string,idx,','));
			mSpawn[4][playerid] = floatstr(strtok(string,idx,','));
		}
	    for(new i = 1; i < MAX_SLOTS; i++)//load player weapons
		{
			format(string,sizeof(string),"wS%d",i);
			PlayerWeapons[playerid][i] = dini_Int(file,string);
		}
		if(dini_Isset(file,"wSkill"))
		{
  			idx = 0;string = dini_Get(file,"wSkill");//load player weapon skill
			for(new i; i < 11; i++)
			{
				wSkill[playerid][i] = strval(strtok(string,idx,','));
				//printf("%s - %d",WeaponSkills[i][s_Name],WeaponSkills[i][s_Level]);
			}
		}
		else
		{
		    dini_Set(file,"wSkill","999,999,999,999,999,999,999,999,999,999,999");
		    for(new i; i < 11; i++)
		    {
				wSkill[playerid][i] = 999;
		    }
		}
		pFightStyle[playerid] = dini_Int(file,"fStyle");
		UpdatePlayerInactiveSkills(playerid);
		SetPlayerFightingStyle(playerid,pFightStyle[playerid]);
		vColor[0][playerid] = dini_Int(file,"vColor1");
		vColor[1][playerid] = dini_Int(file,"vColor2");
		//if(dini_Isset(file,"KillMsg")){KillMsg[playerid] = dini_Get(file,"KillMsg");}else {KillMsg[playerid] = " ";}
		if(dini_Isset(file,"Wheels")){Wheels[playerid] = dini_Int(file,"Wheels");}else {Wheels[playerid] = -1;}
		if(dini_Isset(file,"Weather")){pWeather[playerid] = dini_Int(file,"Weather");}else {pWeather[playerid] = gWeather;}
		if(dini_Isset(file,"Time")){pTime[playerid][0] = dini_Int(file,"Time");}else {pTime[playerid][0] = gTime;}
		if(dini_Isset(file,"Skin")){Skin[playerid] = dini_Int(file,"Skin");}else {Skin[playerid] = -1;}
		if(dini_Isset(file,"K_Spree")){Spree[KILL][playerid] = dini_Int(file,"K_Spree");MaxSpree[KILL][playerid] = Spree[KILL][playerid];}else {Spree[KILL][playerid] = 0;MaxSpree[KILL][playerid] = 0;}
		if(dini_Isset(file,"D_Spree")){Spree[DEATH][playerid] = dini_Int(file,"D_Spree");MaxSpree[DEATH][playerid] = Spree[DEATH][playerid];}else {Spree[DEATH][playerid] = 0;MaxSpree[DEATH][playerid] = 0;}
	}
	if(dini_Int(file,"RoundCode") == RoundCode && dini_Int(file,"Playing") == 1 && Current != -1)
	{
		SpawnAtPlayerPosition[playerid] = 3;
		ReAdding[playerid] = true;
		SendClientMessage(playerid,0xFFFFFFFF,"Prepare to be brought back into the round.");
		ViewingMOTD[playerid] = false;
	}
	else
	{
	   	//MOTDScreen[playerid] = random(sizeof(MOTDScreens));
 		//SetPlayerCameraPos(playerid,MOTDScreens[MOTDScreen[playerid]][0],MOTDScreens[MOTDScreen[playerid]][1],MOTDScreens[MOTDScreen[playerid]][2]);
 		//SetPlayerCameraLookAt(playerid,MOTDScreens[MOTDScreen[playerid]][3],MOTDScreens[MOTDScreen[playerid]][4],MOTDScreens[MOTDScreen[playerid]][5]);
 		//SetTimerEx("SetCam",200,0,"ii",playerid);
 		//TD_ShowpTextForPlayer(playerid,playerid,4);

 		ViewingMOTD[playerid] = true;
	    if(strcmp(ServerPass,"off",true,3) && !IsPlayerAdmin(playerid))
 		{
	 		SendClientMessage(playerid,MainColors[2],"This server is password protected!");
	 		SendClientMessage(playerid,MainColors[2],"Please enter the server password now");
	 		SendClientMessage(playerid,MainColors[3],"Usage: /pass [password] - You have 20 seconds");
	 		SetTimerEx("PasswordCheck",22000,0,"i",playerid);
	 		TD_HidepTextForPlayer(playerid,playerid,4);
			TextDrawBoxColor(pText[4][playerid],0x000000FF);
			TD_ShowpTextForPlayer(playerid,playerid,4);
			TD_ShowMainTextForPlayer(playerid,5);
			return 1;
		}
		StartIntro(playerid);
		//SetTimerEx("CreateMOTD",7000,0,"i",playerid);
		//SetTimerEx("FadeIn",2000,0,"ii",playerid,0);
		//KillFade[playerid] = false;
	}
	if(JnP == true)
	{
	    new IP[20];GetPlayerIp(playerid,IP,sizeof(IP));
	    dini_IntSet(ServerFile(),"Connects",dini_Int(ServerFile(),"Connects") + 1);
	    new string[100],string2[128];//,country[MAX_STRING];
		
		/*if(dini_Isset(file,"Location")){Location[playerid] = dini_Get(file,"Location");}else {Location[playerid] = " ";}
		/if(strlen(Location[playerid]) <= 1)country = GetPlayerCountryName(playerid);
		else country = Location[playerid];*/
		
		format(string,sizeof(string),"*** %s (ID:%d) has joined the server.",PlayerName,playerid);
		format(string2,sizeof(string2),"*** %s (ID:%d) has joined the server. (IP:%s)",PlayerName,playerid,IP);
		foreach(Player,i)
		{

			PlayerPlaySound(i,complete,0.0,0.0,0.0);
			if(IsPlayerAdmin(i) || i == playerid)SendClientMessage(i,grey,string2);
			else SendClientMessage(i,grey,string);
		}
	}
	{
    CreatePlayerInfo(playerid);
    }
 	SetPlayerColorEx(playerid,grey);
 	SetTimerEx("GiveSelectionWeapon",15,0,"i",playerid);
 	if(Current != -1 && ModeType == BASE)SetPlayerCheckpoint(playerid,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],CPsize);
 	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnPlayerSpawn(playerid)
{
    //FunctionLog("OnPlayerSpawn");
    foreach(Player,x)
	{
		if(gSpectateID[x] == playerid)
		{
			SetTimerEx("Spectate_ReSpecPlayer",400,0,"ii",x,playerid);
		}
	}
	new Float:xHP, Float: xAR;//, string[50]
	GetPlayerHealth(playerid,xHP);
	GetPlayerArmour(playerid,xAR);
	//format(string,sizeof(string),"HP:     %.0f~n~Team: %s",xHP + xAR, TeamName[gTeam[playerid]]);
	//TextDrawSetString(pText[6][playerid],string);
	if(DontCountDeaths[playerid] == true)DontCountDeaths[playerid] = false;
	GivePlayerWeapon(playerid,1,1);
	if(SpawnAtPlayerPosition[playerid] == 3)
    {
        SpawnAtPlayerPosition[playerid] = 0;
        return 1;
    }
    Team_FriendlyFix();
    ViewingBase[playerid] = -1;
    ViewingArena[playerid] = -1;
    PlayerPlaySound(playerid,death+1,0.0,0.0,0.0);
    PlayerPlaySound(playerid,1150,0.0,0.0,0.0);//money sound
    
    if(SpawnAtPlayerPosition[playerid] == 5)
    {
        SpawnAtPlayerPosition[playerid] = 0;
		GivePlayerWeapons(playerid,playerid);
  		SetPlayerInterior(playerid,Interior[Current][ModeType]);
  		SetPlayerVirtualWorld(playerid,1);
  		SetPlayerLife(playerid,TempHP[playerid][0],TempHP[playerid][1]);
  		SetCameraBehindPlayer(playerid);
        return 1;
    }
    if(SpawnAtPlayerPosition[playerid] == 4)
    {
        SetPlayerInterior(playerid,Interior[Current][ARENA]);
        SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]] & 0xFFFFFF00);
        SetPlayerVirtualWorld(playerid,1);
        ShowDMG[playerid] = false;
        SetPlayerLife(playerid,rHealth,rArmor);
        SetTimerEx("TDMprot",3500,0,"i",playerid);
		SetSpawnInfo(playerid,playerid,FindPlayerSkin(playerid),TeamArenaSpawns[Current][0][gTeam[playerid]]-4+random(4),TeamArenaSpawns[Current][1][gTeam[playerid]]-4+random(4),TeamArenaSpawns[Current][2][gTeam[playerid]]+0.5,0.0,0,0,0,0,0,0);
   		return 1;
    }
	if(SpawnAtPlayerPosition[playerid] == 2)
    {
        FindPlayerSpawn(playerid,1);
        SpawnAtPlayerPosition[playerid] = 0;
        if(IsDueling[playerid] == true)
		{
		    ResetPlayerWeapons(playerid);
			GivePlayerWeapon(playerid,DuelWeapon[playerid][0],9900);
			GivePlayerWeapon(playerid,DuelWeapon[playerid][1],9900);
			GivePlayerWeapon(playerid,1,1);
		}
        return 1;
    }
    if(SpawnAtPlayerPosition[playerid] == 1)
    {
		FindPlayerSpawn(playerid,1);
    	SpawnAtPlayerPosition[playerid] = 0;
    	if(Playing[playerid] == true || IsDueling[playerid] == true)
		{
			GivePlayerWeapons(playerid,playerid);
			if(Playing[playerid] == true)SetPlayerVirtualWorld(playerid,1);
			else SetPlayerVirtualWorld(playerid,DuelWorld[playerid]);
			if(ModeType == TDM || ModeType == ARENA)
			{
				SpawnAtPlayerPosition[playerid] = 4;
				SetSpawnInfo(playerid,playerid,FindPlayerSkin(playerid),TeamArenaSpawns[Current][0][gTeam[playerid]]-4+random(4),TeamArenaSpawns[Current][1][gTeam[playerid]]-4+random(4),TeamArenaSpawns[Current][2][gTeam[playerid]]+0.5,0.0,0,0,0,0,0,0);
			}
			return 1;
		}
    	else if(Playing[playerid] == false)
		{
		    SetPlayerInterior(playerid,CurrentInt[playerid]);
			GiveHimHisGuns(playerid);
			return 1;
		}
	}
	if(Playing[playerid] == true)return 1;
	if(Current != -1 && TabHP == true)SetPlayerScore(playerid,0);
	else SetPlayerScore(playerid,TempKills[playerid]);
	SetPlayerWorldBounds(playerid,20000,-20000,20000,-20000);
    SetPlayerNewWorld(playerid);
	SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
	ResetPlayerHealth(playerid);
	ResetPlayerArmor(playerid);
	GiveHimHisGuns(playerid);
	ResetPlayerWeatherAndTime(playerid);
	SetPlayerInterior(playerid,CurrentInt[playerid]);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnPlayerDeath(playerid,killerid,reason)
{
    //FunctionLog("OnPlayerDeath");
	SetPlayerLife(playerid,0.0,0.0);
	TextDrawSetString(pText[14][playerid]," ");
	LifeUpdateVar[playerid] = 0;
	SetPlayerTeam(playerid,playerid);
	new Float:He,Float:Ar;GetPlayerHealth(playerid,He);GetPlayerArmour(playerid,Ar);GetPlayerWeapons(playerid);
    new Float:X,Float:Y,Float:Z;GetPlayerPos(playerid,X,Y,Z);CreateExplosion(X,Y,Z,13,0.5);CreateExplosion(X,Y,Z,13,0.5);CreateExplosion(X,Y,Z,13,0.5);
    ResetPlayerWeapons(playerid);
    SetPlayerNewWorld(playerid);
    ViewingBase[playerid] = -1;
    ViewingArena[playerid] = -1;
    BaseEditing[playerid] = -1;
 	ArenaEditing[playerid] = -1;
 	DuelSpectating[playerid] = -1;
 	gPlayerHealth[playerid] = gHealth;
	gPlayerArmor[playerid] = gArmor;
	PlayerPlaySound(playerid,death,0.0,0.0,0.0);
	
	new killerfile[64],Float:H,Float:A, string[128],playerfile[64];
	if(IsPlayerConnected(killerid) && DontCountDeaths[playerid] == false)
	{
	    GetPlayerHealth(killerid,H);GetPlayerArmour(killerid,A);
		format(killerfile,sizeof(killerfile),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		dini_IntSet(killerfile,"TotalKills",dini_Int(killerfile,"TotalKills") + 1);
		dini_IntSet(ServerFile(),"TotalKills",dini_Int(ServerFile(),"TotalKills") + 1);
	}
	if(DontCountDeaths[playerid] == false)
	{
		format(playerfile,sizeof(playerfile),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		dini_IntSet(playerfile,"TotalDeaths",dini_Int(playerfile,"TotalDeaths") + 1);
		dini_IntSet(ServerFile(),"TotalDeaths",dini_Int(ServerFile(),"TotalDeaths") + 1);
	}
	
	if(IsDueling[playerid] == true)
	{
		if(killerid == DuelInvitation[playerid]){Duel_End(killerid,playerid,1);}
		else if(killerid == INVALID_PLAYER_ID || reason == 54){Duel_End(DuelInvitation[playerid],playerid,1);}
		else if(killerid != DuelInvitation[playerid]){Duel_End(playerid,DuelInvitation[playerid],2);}
		else {Duel_End(playerid,DuelInvitation[playerid],3);}
	}
	
	if(Current == -1)
    {
        if(Chase_ChaseID[playerid] != -1)Chase_Finish(playerid,Chase_ChaseID[playerid],255);
        foreach(Player,x)
		{
            if(Chase_ChaseID[x] == playerid)Chase_Finish(x,playerid,255);
	    	if(gSpectateID[x] == playerid)
			{
			    ShowPlayerNameTagForPlayer(x,gSpectateID[x],1);
			    if(gTeam[x] == T_NON && IsPlayerConnected(killerid))Spectate_QuickStart(x,playerid,killerid);
		    	else if(gTeam[x] == T_NON)Spectate_Advance(x);
		    	else Spectate_Stop(x);
			}
		}
		ResetPlayerWeatherAndTime(playerid);
        SendDeathMessage(killerid,playerid,reason);
        FindPlayerSpawn(playerid,1);
    }
    else // Round is active
    {
        if(IsPlayerInAnyVehicle(playerid))
        {
            GetPlayerPos(playerid,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid]);
			SetPlayerPos(playerid,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid]+2);
			SetTimerEx("SpawnPlayerFix",5000,0,"i",playerid);
        }
        if(Playing[playerid] == true)
        {
			if(ModeType != TDM && IsPlayerConnected(killerid))
			{
				HasPlayed[playerid] = true;
				if(((reason == 50 || reason == 49 || reason == 28 || reason == 29 || reason == 32) && GetPlayerState(killerid) == PLAYER_STATE_DRIVER && gTeam[killerid] != gTeam[playerid]))
				{
					if(IsVehicleHeli(GetVehicleModel(GetPlayerVehicleID(killerid))) == 1)
					{
						if(IsPlayerConnected(killerid))
						{
							dini_IntSet(killerfile,"K_50",dini_Int(killerfile,"K_50") + 1);dini_IntSet(playerfile,"D_50",dini_Int(playerfile,"D_50") + 1);
							dini_IntSet(ServerFile(),"D_50",dini_Int(ServerFile(),"D_50") + 1);
							format(string,sizeof(string),"*** \"%s\" Heli-Killed \"%s\" and has been eliminated.",RealName[killerid],RealName[playerid]);SendClientMessageToAll(MainColors[2],string);
						}
					}
					else if(reason == 29 || reason == 28 || reason == 32)
					{
						format(string,sizeof(string),"*** \"%s\" Drive-Byed \"%s\" and has been eliminated.",RealName[killerid],RealName[playerid]);SendClientMessageToAll(MainColors[2],string);
					}
					else
					{
						if(killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
						{
							dini_IntSet(killerfile,"K_49",dini_Int(killerfile,"K_49") + 1);dini_IntSet(playerfile,"D_49",dini_Int(playerfile,"D_49") + 1);
							dini_IntSet(ServerFile(),"D_49",dini_Int(ServerFile(),"D_49") + 1);
							format(string,sizeof(string),"*** \"%s\" Vehicle-Killed \"%s\" and has been eliminated.",RealName[killerid],RealName[playerid]);SendClientMessageToAll(MainColors[2],string);
						}
					}
					SetPlayerLife(playerid,0.0,0.0);
					GetPlayerArmour(playerid,TempHP[playerid][1]);
					GetPlayerFacingAngle(playerid,PlayerPosition[3][playerid]);
					SetSpawnInfo(playerid,playerid,GetPlayerSkin(playerid),X,Y,Z,PlayerPosition[3][playerid],0,0,0,0,0,0);
					Playing[playerid] = true;
					SetPlayingName(playerid);
			    	SpawnAtPlayerPosition[playerid] = 5;
			    	TempHP[playerid][0] = gPlayerHealth[playerid];
			    	TempHP[playerid][1] = gPlayerArmor[playerid];
			    	if(Playing[killerid] == true)
			    	{
			    		DisablePlayerCheckpoint(killerid);
	   					DisablePlayerRaceCheckpoint(killerid);
	   					RemovePlayerMapIcon(killerid,0);
	 					RemovePlayerMapIcon(killerid,1);
			    		SetTimerEx("DestroyVehicleEx",100,0,"i",GetPlayerVehicleID(killerid));
						//SetTimerEx("SetPlayingName",10,0,"i",killerid);
						RemovePlayingName(killerid);
						SetTimerEx("EliminateKiller",500,0,"i",killerid);
					}
				 	return 1;
				}
				UpdatePlayerInactiveSkills(playerid);
	        	GetPlayerEndWeapons(playerid);
	        	//SetTimerEx("SetPlayingName",10,0,"i",playerid);
	        	GetDeathPosition(playerid);
	        	TR_Died[playerid] = true;
	        	TR_KilledWith[playerid] = reason;
	        	SetPlayerWorldBounds(playerid,20000,-20000,20000,-20000);
	        	TR_KilledBy[playerid] = RealName[killerid];
	        	TR_KillersHP[playerid] = H+A;
	        	SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
				UpdateMapName();
			}
	 		if(!IsPlayerConnected(killerid))
			{
				DropWeapons(playerid);
		 		UpdateKD(ModeType,Current,DEATH);
		    	//SpreeUpdate(INVALID_PLAYER_ID,playerid);
		    	SetPlayerName(playerid,NickName[playerid]);
		   		SendDeathMessage(255,playerid,reason);
				SendClientMessage(playerid,CurrentColor[playerid],"Suicide -1");
				TeamTotalDeaths[gTeam[playerid]]++;
				TeamTempDeaths[gTeam[playerid]]++;
				TempDeaths[playerid]++;
				TR_Suicide[playerid] = true;
				TR_Died[playerid] = true;
				TR_KilledWith[playerid] = reason;
				ResetPlayerWeatherAndTime(playerid);
				SetPlayerWorldBounds(playerid,20000,-20000,20000,-20000);
				SetTimerEx("Spectate_StartPlayerTeamSpec",20,0,"i",playerid);
           		if(ModeType != TDM)
            	{
					FindPlayerSpawn(playerid,1);
					SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
					DisablePlayerCheckpoint(playerid);
   					DisablePlayerRaceCheckpoint(playerid);
   					RemovePlayerMapIcon(playerid,0);
 					RemovePlayerMapIcon(playerid,1);
 					RemovePlayingName(playerid);
 					UpdatePlayerInactiveSkills(playerid);
 					Playing[playerid] = false;
				}
				foreach(Player,x)
				{
					if(gSpectateID[x] == playerid)
					{
						ShowPlayerNameTagForPlayer(x,gSpectateID[x],1);
						if(gTeam[x] >= 0 && gTeam[x] < ACTIVE_TEAMS)Spectate_AdvanceTeam(x);
						if(gTeam[x] == T_NON)Spectate_Advance(x);
						else Spectate_Stop(x);
					}
				}
				UpdateRoundII();
				return 1;
			}
			if(gTeam[playerid] != gTeam[killerid] && gTeam[killerid] >= 0 && gTeam[killerid] < ACTIVE_TEAMS)
			{
				new winnerfile[64],loserfile[64];
				SetTimerEx("Spectate_StartPlayerTeamSpec",20,0,"i",playerid);
				CheckDeathReason(killerid,reason);
	    		DropWeapons(playerid);
	    		UpdateKD(ModeType,Current,KILL);
	    		UpdateKD(ModeType,Current,DEATH);
	    		//SpreeUpdate(killerid,playerid);
				if(reason >= 0 && reason < 46)
				{
		    		format(string,sizeof(string),"K_%d",reason);dini_IntSet(killerfile,string,dini_Int(killerfile,string) + 1);
					format(string,sizeof(string),"D_%d",reason);dini_IntSet(playerfile,string,dini_Int(playerfile,string) + 1);dini_IntSet(ServerFile(),string,dini_Int(ServerFile(),string) + 1);
				}
				new name[24],Float:p[3],dword[16];
				GetPlayerPos(killerid,p[0],p[1],p[2]);
				TR_KillDist[playerid] = GetPointDistanceToPointEx(X,Y,Z,p[0],p[1],p[2]);
			 	dword = DeathWords[random(DEATH_WORD_SIZE)];
	    		format(string,sizeof(string),"***  \"%s\"  *%s*  \"%s\"  (%s)  (HP: %.0f)  (Dist: %.2f ft)",NickName[killerid],dword,NickName[playerid],WeaponNames[reason],H+A,TR_KillDist[playerid]);
	    		SendClientMessageToAll(TeamActiveColors[gTeam[killerid]],string);
	    		format(name,sizeof(name),"%.0f_%s",H+A,NickName[killerid]);
	    		SetPlayerName(killerid,name);
	    		SetKillMessageTD(playerid,killerid,dword);
	    		PlayerPlaySound(killerid,1095,p[0],p[1],p[2]);
     			TeamTempScore[gTeam[killerid]]++;
     			TeamTotalScore[gTeam[killerid]]++;
     			//TeamCurrentPlayers[gTeam[playerid]]--;
     			TeamTotalDeaths[gTeam[playerid]]++;
     			TeamTempDeaths[gTeam[playerid]]++;
     			TR_Kills[killerid]++;
     			if(DontCountDeaths[playerid] == false)
     			{
     				dini_IntSet(killerfile,"MatchKills",dini_Int(killerfile,"MatchKills") + 1);
     				dini_IntSet(playerfile,"MatchDeaths",dini_Int(playerfile,"MatchDeaths") + 1);
     				format(winnerfile,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[killerid]);format(string,128,"WD_%s",RealName[playerid]);dini_IntSet(winnerfile,string,dini_Int(winnerfile,string) + 1);
					format(loserfile,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);format(string,128,"LD_%s",RealName[killerid]);dini_IntSet(loserfile,string,dini_Int(loserfile,string) + 1);
					dini_IntSet(ServerFile(),"MatchKills",dini_Int(ServerFile(),"MatchKills") + 1);
					dini_IntSet(ServerFile(),"MatchDeaths",dini_Int(ServerFile(),"MatchDeaths") + 1);
				}
	     		TempDeaths[playerid]++;
	     		TempKills[killerid]++;
	     		TR_Died[playerid] = true;
	     		TR_KilledWith[playerid] = reason;
	     		TR_KilledBy[playerid] = RealName[killerid];
	     		TR_KillersHP[playerid] = H+A;
	     		SetPlayerWorldBounds(playerid,20000,-20000,20000,-20000);
	     		ResetPlayerWeatherAndTime(playerid);
				SetPlayerName(playerid,NickName[playerid]);
				SendDeathMessage(killerid,playerid,reason);
				SetPlayerName(killerid,TempName[killerid]);
				if(ModeType != TDM)
	     		{
	     			FindPlayerSpawn(playerid,1);
					Playing[playerid] = false;
					RemovePlayingName(playerid);
					SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
					UpdatePlayerInactiveSkills(playerid);
				}
				foreach(Player,x)
				{
					if(gSpectateID[x] == playerid)
					{
						ShowPlayerNameTagForPlayer(x,gSpectateID[x],1);
						if(gTeam[x] >= 0 && gTeam[x] < ACTIVE_TEAMS)Spectate_AdvanceTeam(x);
						if(gTeam[x] == T_NON)Spectate_Advance(x);
						else Spectate_Stop(x);
					}
				}
				UpdateRoundII();
				return 1;
			}
			if(gTeam[playerid] == gTeam[killerid] && gTeam[killerid] >= 0 && gTeam[killerid] < ACTIVE_TEAMS && gTeam[playerid] >= 0 && gTeam[playerid] < ACTIVE_TEAMS)//TEAM KILL
			{
				SetTimerEx("Spectate_StartPlayerTeamSpec",20,0,"i",playerid);
	    		DropWeapons(playerid);
	    		//TempRemovePlayingName(playerid);
	    		SetPlayerName(playerid,NickName[playerid]);
	    		SendDeathMessage(killerid,playerid,reason);
	    		RemovePlayingName(playerid);
     			TeamTotalDeaths[gTeam[killerid]]++;
     			//TeamCurrentPlayers[gTeam[playerid]]--;
     			TeamTempDeaths[gTeam[playerid]]++;
     			if(DontCountDeaths[playerid] == false)
     			{
     				dini_IntSet(killerfile,"TeamKills",dini_Int(killerfile,"TeamKills") + 1);
     				dini_IntSet(playerfile,"TotalDeaths",dini_Int(playerfile,"TotalDeaths") + 1);
     				dini_IntSet(ServerFile(),"TeamKills",dini_Int(ServerFile(),"TeamKills") + 1);
     				dini_IntSet(ServerFile(),"TotalDeaths",dini_Int(ServerFile(),"TotalDeaths") + 1);
				}
     			TempTKs[killerid]++;
     			TR_Died[playerid] = true;
     			TR_KilledWith[playerid] = reason;
     			TR_KilledBy[playerid] = RealName[killerid];
     			TR_KillersHP[playerid] = H+A;
     			SetPlayerWorldBounds(playerid,20000,-20000,20000,-20000);
     			ResetPlayerWeatherAndTime(playerid);
     			if(ModeType != TDM)
     			{
     			    UpdatePlayerInactiveSkills(playerid);
     			    RemovePlayingName(playerid);
     				FindPlayerSpawn(playerid,1);
     				SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
     				Playing[playerid] = false;
				}
			}
			UpdateRoundII();
			return 1;
		}
		Playing[playerid] = false;
		UpdateRoundII();
		return 1;
	}
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
public OnPlayerText(playerid, text[])
{
    //FunctionLog("OnPlayerText");
    if(Variables[playerid][Muted]) {SendClientMessage(playerid,Colors[2],"You're muted."); return 0;}//muted by admin script
    if(Variables[playerid][LoggedIn] == false && Variables[playerid][Registered] == true)
	{
	    SendClientMessage(playerid,Colors[2],"Please login before chatting.");
	    return 0;
	}
	if(text[0] == '@' && Variables[playerid][Registered] == true && Variables[playerid][Level] >= 4)//higher admin chat
	{
	    new string[128];
		format(string,sizeof(string),"Clan Chat %s > %s",RealName[playerid],text[1]);
		foreach(Player,i)
		{
			if(Variables[i][Registered] == true && Variables[i][Level] >= 4)
			{
				 SendClientMessage(i,0xFF0000FF,string);
			}
		}
	    return 0;
	}
	/*else if(text[0] == '&' && Variables[playerid][Level] >= 1)//trial chat
	{
	    new string[128];
		format(string,sizeof(string),"[Trial%s > %s",RealName[playerid],text[1]);
		foreach(Player,i)
		{
			if(Variables[i][Level] >= 1)
			{
				 SendClientMessage(i,0xE6E600AA,string);
			}
		}
	    return 0;
	}*/
	else if(text[0] == '#' && Variables[playerid][Level] >= 1)//LEVEL 3 normal
	{
	    new string[128];
		format(string,sizeof(string),"Admin Chat %s > %s",RealName[playerid],text[1]);
		foreach(Player,i)
		{
			if(Variables[i][Level] >= 1)
			{
				 SendClientMessage(i,0xE6E600AA,string);
			}
		}
	    return 0;
	}
	
	if(SlideSho == true)return 0;
	if(AFK[playerid] == true)
	{
		SendClientMessage(playerid,MainColors[2],"You must type /BACK before doing anything!");//player is afk
		return 0;
	}
	if(NoText[playerid] == true && !IsPlayerAdmin(playerid))//spam filter for non-admins
	{
		new string[64];
		format(string,sizeof(string),"Sorry, you can only use text once every %d second(s)",TextTime);
		SendClientMessage(playerid,MainColors[2],string);
		return 0;
	}
	else
	{
		NoText[playerid] = true;
		SetTimerEx("AllowText",TextTime*1000,0,"i",playerid);
	}
   	if(PlayerWorld[playerid] != -1 && Playing[playerid] == false)//player is in a special world
	{
	    if(text[0] == ' ')
	    {
	        if(IDnames == true)
			{
				new string[24],name[24];
				GetPlayerName(playerid,name,sizeof(name));
				TempName[playerid] = name;
				format(string,sizeof(string),"[%d]%s",playerid,NickName[playerid]);
				SetPlayerName(playerid,string);
				SetTimerEx("ResetPlayerName",1,0,"i",playerid);
				SendPlayerMessage2All(playerid,text);
				return 0;
			}
			new name[24];
			GetPlayerName(playerid,name,sizeof(name));
			TempName[playerid] = name;
			SetPlayerName(playerid,NickName[playerid]);
			SetTimerEx("ResetPlayerName",1,0,"i",playerid);
			SendPlayerMessage2All(playerid,text);
			return 0;
	    }
	    else
	    {
			SendClientMessageToWorld(playerid,PlayerWorld[playerid],text);
		}
		return 0;
	}
    else if(RoundMuting == true && Current != -1 && text[0] != ' ' && gTeam[playerid] >= 0 && gTeam[playerid] < ACTIVE_TEAMS)//normal chat in rounds is muted (space = global chat)
	{
		Team_SendClientMessage(playerid,gTeam[playerid],text[0]);
		return 0;
	}
    else if(text[0] == '!')//team message
	{
		Team_SendClientMessage(playerid,gTeam[playerid],text[1]);
		return 0;
	}
    if(IDnames == true)
	{
		if(Current != -1 && Playing[playerid] == true && NoNameMode == true)
		{
			new string[24];
			TempName[playerid] = NoNames[playerid];
			format(string,sizeof(string),"[%d]%s",playerid,NickName[playerid]);
			SetPlayerName(playerid,string);
			SetTimerEx("ResetPlayerName",1,0,"i",playerid);
			SendPlayerMessage2All(playerid,text);
			return 0;
		}
		else
		{
			new string[24],name[24];
			GetPlayerName(playerid,name,sizeof(name));
			TempName[playerid] = name;
			format(string,sizeof(string),"[%d]%s",playerid,NickName[playerid]);
			SetPlayerName(playerid,string);
			SetTimerEx("ResetPlayerName",1,0,"i",playerid);
			SendPlayerMessage2All(playerid,text);
			return 0;
		}
	}
	else
	{
		new name[24];
		GetPlayerName(playerid,name,sizeof(name));
		TempName[playerid] = name;
		SetPlayerName(playerid,NickName[playerid]);
		SetTimerEx("ResetPlayerName",1,0,"i",playerid);
		SendPlayerMessage2All(playerid,text);
		return 0;
	}
	//return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

forward OnPlayerPrivmsg(playerid,recieverid,text[]);
public OnPlayerPrivmsg(playerid,recieverid,text[])
{
	if(Ignored[recieverid][playerid] == true)
	{
	    SendClientMessage(playerid,MainColors[2],"This player has chosen to ignore your PMs.");
	    return 0;
	}
    new string[128];
    if(NoText[playerid] == true && !IsPlayerAdmin(playerid))
	{
		format(string,sizeof(string),"Sorry, you can only use text once every %d second(s)",TextTime);
		SendClientMessage(playerid,MainColors[2],string);
		return 0;
	}
	else
	{
		NoText[playerid] = true;
		SetTimerEx("AllowText",TextTime*1000,0,"i",playerid);
	}
	PlayerPlaySound(recieverid,1139,0.0,0.0,0.0);
    foreach(Player,i)
	{
		if(ShowPMs[i] == true && i != playerid && i != recieverid)
		{
			format(string,sizeof(string),"*** [PM]  %s(%d) to %s(%d): %s",NickName[playerid],playerid,NickName[recieverid],recieverid,text);
			SendClientMessage(i,PM_COLOR,string);
	    }
	}
	format(string,sizeof(string),"Private Message sent to %s(%d): %s",NickName[recieverid],recieverid,text);
	SendClientMessage(playerid,MainColors[0],string);
	format(string,sizeof(string),"Private Message from %s(%d): %s",NickName[playerid],playerid,text);
	SendClientMessage(recieverid,MainColors[0],string);
	return 0;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnPlayerDisconnect(playerid, reason)
{
    //FunctionLog("OnPlayerDisconnect");
    Itter_OnPlayerDisconnect(playerid,reason);
    //Sound_OnPlayerDisconnect(playerid);
    new showhp;
    if(Playing[playerid] == true)
    {
        showhp = 1;
        //TeamCurrentPlayers[gTeam[playerid]]--;
    	if(reason == 0 && WatchingBase == false)
    	{
    	    if(AutoPause > 0 && GamePaused == false)
    	    {
    	        GamePaused = true;
		    	foreach(Player,i)
				{
			    	if(Playing[i] == true)
			    	{
 						TogglePlayerControllable(i,0);
 						GameTextForPlayer(i,"~r~Game Paused",6000000,3);
					}
				}
				new string[75];
				format(string,75,"The round has been automatically paused and will resume in %d seconds",AutoPause);
				SendClientMessageToAll(MainColors[0],string);
				SetTimer("UnpauseRound",AutoPause * 1000,0);
				SaveTimedPlayer(playerid);
    	    }
    	    else
    	    {
    	    	AddSubs(playerid);
			}
		}
		UpdateRoundII();
	}
	Players--;
	IsConnected[playerid] = false;
	HighestID = GetHighestID();
	//Misc_GetHighestID();
	new file[64],string[128];
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	SavePlayerTemp(playerid,file,reason,showhp);
	format(string,sizeof(string),"%.3f,%.3f,%.3f,%.3f,%.0f",mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid],mSpawn[3][playerid],mSpawn[4][playerid]);
	dini_Set(file,"mSpawn",string);
	SetTeam(playerid,T_SUB);
	if(IsDueling[playerid] == true){Duel_End(DuelInvitation[playerid],playerid,0);}
    if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
    if(Chase_ChaseID[playerid] != -1)Chase_Finish(playerid,Chase_ChaseID[playerid],255);
    if(gSpectateID[playerid] != -1)SetTimerEx("Spectate_WhoIsWatchingMe",5,0,"i",gSpectateID[playerid]);

	foreach(Player,x)
	{
	    if(Chase_ChaseID[x] == playerid)Chase_Finish(x,playerid,255);
		if(PlayerWorld[x] == playerid)
		{
			SendClientWorldMessage(x,playerid,"*** WORLD: You have been kicked from this world. (owner disconnected)");
	 		PlayerWorld[x] = -1;
			if(Playing[x] == false)SetPlayerVirtualWorld(playerid,0);
		}
		if(gSpectateID[x] == playerid)
		{
			ShowPlayerNameTagForPlayer(x,gSpectateID[x],1);
			if(gTeam[x] >= 0 && gTeam[x] < ACTIVE_TEAMS)Spectate_AdvanceTeam(x);
			if(gTeam[x] == T_NON)Spectate_Advance(x);
			else Spectate_Stop(x);
		}
	}
	
	if(reason == 0){dini_IntSet(ServerFile(),"Timeouts",dini_Int(ServerFile(),"Timeouts") + 1);}
	else if(reason == 2){dini_IntSet(ServerFile(),"Kicks",dini_Int(ServerFile(),"Kicks") + 1);}
	ResetPlayerVars(playerid);
	gState[playerid] = e_STATE_NONE;
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(ViewingResults[playerid] == true && IsDueling[playerid] == false)return 0;
    if(GamePaused == true && Playing[playerid] == true)return 0;
	if(AntiC == true)
	{
		new weapon = GetPlayerWeapon(playerid);
		if(newkeys & KEY_CROUCH && weapon > 21 && weapon < 41)
		{
 			GetPlayerPos(playerid,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid]);
 			SetTimerEx("IsPlayerFalling",75,0,"if",playerid,PlayerPosition[2][playerid]);
			return 1;
		}
	}
	if(EnemyUAV == true)
	{
		if((newkeys & KEY_FIRE || newkeys & KEY_SECONDARY_ATTACK) && newkeys & 128 && Playing[playerid] == true && IsWeaponUAV(GetPlayerWeapon(playerid)) == 1)
		{
	    	new Float:POS[3];GetPlayerPos(playerid,POS[0],POS[1],POS[2]);
	    	ShowPlayerUAV(playerid,POS[0],POS[1],POS[2]);
		}
	}
 	if(newkeys == 160 && (GetPlayerWeapon(playerid) == 0 || GetPlayerWeapon(playerid) == 1) && NoKeys[playerid] == false && !IsPlayerInAnyVehicle(playerid) && gSpectating[playerid] == false && ViewingBase[playerid] == -1 && ViewingArena[playerid] == -1 && AFK[playerid] == false && DuelStarting[playerid] == false)
	{
 		if(AllowSuicide[playerid] == false)return 0;
 		if(DuelSpectating[playerid] != -1 && DuelStarting[playerid] == false)return 0;
 		if(Syncing[playerid] == true)return 1;
 		new Float:Z;GetPlayerPos(playerid,Z,Z,Z);
 		SyncTimer[playerid] = SetTimerEx("Sync",2200,0,"if",playerid,Z);
 		SendClientMessage(playerid,MainColors[3],"...Syncing... do not change weapons!");
		NoKeys[playerid] = true;
		Syncing[playerid] = true;
		ChangedWeapon[playerid] = false;
		LastWeapon[playerid] = GetPlayerWeapon(playerid);
 		return 1;
	}
	if(AFK[playerid] == true || ViewingResults[playerid] == true)return 0;
	if((newkeys & KEY_ACTION || newkeys & KEY_CROUCH) && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && Playing[playerid] == true && PlayerPickup[playerid] != -1)
	{
	    SendClientMessage(playerid,0xFFFFFFFF,"a");
	    new Float:pos[3];GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	    if(!InRange(pos[0],pos[1],pos[2],pickups[PlayerPickup[playerid]][p_x],pickups[PlayerPickup[playerid]][p_y],pickups[PlayerPickup[playerid]][p_z],4.0))
	    {
	        SendClientMessage(playerid,0xFFFFFFFF,"b");
	        new string[128];
	    	format(string,128,"You picked up a(n) %s holding %d ammo.",WeaponNames[pickups[PlayerPickup[playerid]][p_weapon]],pickups[PlayerPickup[playerid]][p_ammo]);
			SendClientMessage(playerid,MainColors[3],string);
			GivePlayerWeapon(playerid,pickups[PlayerPickup[playerid]][p_weapon],pickups[PlayerPickup[playerid]][p_ammo]);//- subtract_ammo[pickups[pickupid][p_weapon]]
			//gPlayerAmmo[playerid][GetWeaponSlot(pickups[PlayerPickup[playerid]][p_weapon])]+=pickups[PlayerPickup[playerid]][p_ammo];
			SetTimerEx("DestroyPickupEx",100,0,"i",PlayerPickup[playerid]);
			PlayerPickup[playerid] = -1;
			SendClientMessage(playerid,0xFFFFFFFF,"c");
	    }
	    SendClientMessage(playerid,0xFFFFFFFF,"d");
	}
	if(newkeys == KEY_JUMP)
	{
 		if(ViewingBase[playerid] >= 0)
 		{
 		    ViewingBase[playerid]++;
 		    new high;high = GetHighestBaseNum();
 		    if(ViewingBase[playerid] >= high) ViewingBase[playerid] = 0;
			if(fexist(Basefile(ViewingBase[playerid])))
  			{
  			    SetPlayerInterior(playerid,Interior[ViewingBase[playerid]][BASE]);
  			    SetPlayerPos(playerid,HomeCP[ViewingBase[playerid]][0],HomeCP[ViewingBase[playerid]][1],HomeCP[ViewingBase[playerid]][2]);
      			SetPlayerCameraLookAt(playerid,HomeCP[ViewingBase[playerid]][0],HomeCP[ViewingBase[playerid]][1],HomeCP[ViewingBase[playerid]][2]);
				SetPlayerCameraPos(playerid,HomeCP[ViewingBase[playerid]][0]+50,HomeCP[ViewingBase[playerid]][1]+50,HomeCP[ViewingBase[playerid]][2]+80);
				new string[128];format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Base: ~w~%d",ViewingBase[playerid]);GameTextForPlayer(playerid,string,5000,3);
				return 1;
   			}
		}
		if(ViewingArena[playerid] >= 0)
 		{
 		    ViewingArena[playerid]++;
 		    new high;high = GetHighestArenaNum();
 		    if(ViewingArena[playerid] >= high) ViewingArena[playerid] = 0;
			if(fexist(Arenafile(ViewingArena[playerid])))
  			{
  			    SetPlayerInterior(playerid,Interior[ViewingArena[playerid]][ARENA]);
  			    SetPlayerPos(playerid,ArenaCP[ViewingArena[playerid]][0],ArenaCP[ViewingArena[playerid]][1],ArenaCP[ViewingArena[playerid]][2]);
      			SetPlayerCameraLookAt(playerid,ArenaCP[ViewingArena[playerid]][0],ArenaCP[ViewingArena[playerid]][1],ArenaCP[ViewingArena[playerid]][2]);
				SetPlayerCameraPos(playerid,ArenaCP[ViewingArena[playerid]][0]+50,ArenaCP[ViewingArena[playerid]][1]+50,ArenaCP[ViewingArena[playerid]][2]+80);
				new string[128];format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Arena: ~w~%d",ViewingArena[playerid]);GameTextForPlayer(playerid,string,5000,3);
				return 1;
   			}
		}
	}
    if(newkeys == KEY_HANDBRAKE)
    {
    	if(ViewingBase[playerid] >= 0)
    	{
     		ViewingBase[playerid]--;
			if(ViewingBase[playerid] <= 0) ViewingBase[playerid] = GetHighestBaseNum();
	 		if(fexist(Basefile(ViewingBase[playerid])))
			{
			    SetPlayerInterior(playerid,Interior[ViewingBase[playerid]][BASE]);
			    SetPlayerPos(playerid,HomeCP[ViewingBase[playerid]][0],HomeCP[ViewingBase[playerid]][1],HomeCP[ViewingBase[playerid]][2]);
				SetPlayerCameraLookAt(playerid,HomeCP[ViewingBase[playerid]][0],HomeCP[ViewingBase[playerid]][1],HomeCP[ViewingBase[playerid]][2]);
				SetPlayerCameraPos(playerid,HomeCP[ViewingBase[playerid]][0]+50,HomeCP[ViewingBase[playerid]][1]+50,HomeCP[ViewingBase[playerid]][2]+80);
				new string[128];format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Base: ~w~%d",ViewingBase[playerid]);GameTextForPlayer(playerid,string,2000,3);
				return 1;
			}
		}
		if(ViewingArena[playerid] >= 0)
    	{
     		ViewingArena[playerid]--;
			if(ViewingArena[playerid] <= 0) ViewingArena[playerid] = GetHighestArenaNum();
	 		if(fexist(Arenafile(ViewingArena[playerid])))
			{
			    SetPlayerInterior(playerid,Interior[ViewingArena[playerid]][ARENA]);
			    SetPlayerPos(playerid,ArenaCP[ViewingArena[playerid]][0],ArenaCP[ViewingArena[playerid]][1],ArenaCP[ViewingArena[playerid]][2]);
				SetPlayerCameraLookAt(playerid,ArenaCP[ViewingArena[playerid]][0],ArenaCP[ViewingArena[playerid]][1],ArenaCP[ViewingArena[playerid]][2]);
				SetPlayerCameraPos(playerid,ArenaCP[ViewingArena[playerid]][0]+50,ArenaCP[ViewingArena[playerid]][1]+50,ArenaCP[ViewingArena[playerid]][2]+80);
				new string[128];format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~r~Arena: ~w~%d",ViewingArena[playerid]);GameTextForPlayer(playerid,string,2000,3);
				return 1;
			}
		}
	}
    if(newkeys == KEY_SPRINT)
    {
        if(ViewingBase[playerid] >= 0 || ViewingArena[playerid] >= 0)
 		{
            SetPlayerPos(playerid,ViewPos[playerid][0],ViewPos[playerid][1],ViewPos[playerid][2]);
			SetPlayerFacingAngle(playerid,ViewPos[playerid][3]);
			SetCameraBehindPlayerEx(playerid);
			TogglePlayerControllable(playerid,1);
			ViewingArena[playerid] = -1;
 			ViewingBase[playerid] = -1;
			return 1;
 		}
    }
    if(newkeys == KEY_CROUCH)
	{
 		if(ViewingBase[playerid] >= 0 || ViewingArena[playerid] >= 0)
 		{
			SetCameraBehindPlayerEx(playerid);
			TogglePlayerControllable(playerid,1);
 			ViewingArena[playerid] = -1;
 			ViewingBase[playerid] = -1;
 			return 1;
 		}
	}
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && gSpectateID[playerid] != INVALID_PLAYER_ID)
	{
		if(newkeys == KEY_JUMP)
		{
		    if(gTeam[playerid] == T_NON)Spectate_Advance(playerid);
		    else Spectate_AdvanceTeam(playerid);
			return 1;
		}
		else if(newkeys == KEY_HANDBRAKE)
		{
	    	if(gTeam[playerid] == T_NON)Spectate_Reverse(playerid);
		    else Spectate_ReverseTeam(playerid);
	    	return 1;
		}
		else if(newkeys == KEY_SPRINT)
		{
	    	Spectate_Stop(playerid);
	    	return 1;
		}
		if(newkeys == KEY_CROUCH)
		{
		    if(GetPlayerState(gSpectateID[playerid]) == PLAYER_STATE_ONFOOT)
			{
				switch(gSpectateType[playerid])
		    	{
					case 1:{gSpectateType[playerid] = 2;PlayerSpectatePlayer(playerid,gSpectateID[playerid],2);}
					case 2:{gSpectateType[playerid] = 3;PlayerSpectatePlayer(playerid,gSpectateID[playerid],3);}
					case 3:{gSpectateType[playerid] = 1;PlayerSpectatePlayer(playerid,gSpectateID[playerid],1);}
					default:{gSpectateType[playerid] = 1;PlayerSpectatePlayer(playerid,gSpectateID[playerid],1);}
				}
			}
		    else if(IsPlayerInAnyVehicle(gSpectateID[playerid]))
		    {
		    	switch(gSpectateType[playerid])
		    	{
					case 1:{gSpectateType[playerid] = 2;PlayerSpectateVehicle(playerid,gSpectateID[playerid],2);}
					case 2:{gSpectateType[playerid] = 3;PlayerSpectateVehicle(playerid,gSpectateID[playerid],3);}
					case 3:{gSpectateType[playerid] = 1;PlayerSpectateVehicle(playerid,gSpectateID[playerid],1);}
					default:{gSpectateType[playerid] = 1;PlayerSpectateVehicle(playerid,gSpectateID[playerid],1);}
				}
			}
		}
	}
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    //FunctionLog("OnPlayerCommandText");
    dcmd(xregister,9,cmdtext);
	dcmd(xlogin,6,cmdtext);
	dcmd(pm,2,cmdtext);
    
//------------------------------------------------------------------------------
//Administration

    new string[128];
	format(string,128,"%s: %s",RealName[playerid],cmdtext);
	CommandLog(string);
	foreach(Player,i)
	{
		if(ShowCommands[i] == true)
		{
			SendClientMessage(i,CMD_COLOR,string);
		}
	}
	if(cmdtext[1] == 'x')
	{
        dcmd(xlogout,7,cmdtext);
        dcmd(xgoto,5,cmdtext);
        dcmd(xbring,6,cmdtext);
        dcmd(xannounce,9,cmdtext);
        dcmd(xsay,4,cmdtext);
        dcmd(xflip,5,cmdtext);
        dcmd(xslap,5,cmdtext);
        dcmd(xmute,5,cmdtext);
        dcmd(xunmute,7,cmdtext);
        dcmd(xkick,5,cmdtext);
        dcmd(xban,4,cmdtext);
        dcmd(xakill,6,cmdtext);
        dcmd(xeject,6,cmdtext);
        dcmd(xfreeze,7,cmdtext);
        dcmd(xunfreeze,9,cmdtext);
        dcmd(xsetint,7,cmdtext);
        dcmd(xsetintall,10,cmdtext);
        dcmd(xrestoreall,11,cmdtext);
        dcmd(xhealall,8,cmdtext);
        dcmd(xsethealth,10,cmdtext);
        dcmd(xskinall,8,cmdtext);
        dcmd(xgunall,7,cmdtext);
        dcmd(xdisarm,7,cmdtext);
        dcmd(xdisarmall,10,cmdtext);
        dcmd(xejectall,9,cmdtext);
        dcmd(xfreezeall,10,cmdtext);
        dcmd(xunfreezeall,12,cmdtext);
        dcmd(xgivegun,8,cmdtext);
        dcmd(xgod,4,cmdtext);
        dcmd(xgodall,7,cmdtext);
        dcmd(xresetscores,12,cmdtext);
        dcmd(xsetlevel,9,cmdtext);
        dcmd(xsetskin,8,cmdtext);
        dcmd(xweather,8,cmdtext);
        dcmd(xweatherall,11,cmdtext);
        dcmd(xsettime,8,cmdtext);
        dcmd(xsettimeall,11,cmdtext);
        dcmd(xsetcash,8,cmdtext);
        dcmd(xgivecash,9,cmdtext);
        dcmd(xsetcashall,11,cmdtext);
        dcmd(xgivecashall,12,cmdtext);
        dcmd(xcar,4,cmdtext);
        dcmd(xsetarmor,9,cmdtext);
        dcmd(xarmorall,9,cmdtext);
        dcmd(xsetscore,9,cmdtext);
        dcmd(xip,3,cmdtext);
        dcmd(xexplode,8,cmdtext);
        dcmd(xforce,6,cmdtext);
        dcmd(xsetwanted,10,cmdtext);
        dcmd(xsetwantedall,13,cmdtext);
        dcmd(xsetworld,9,cmdtext);
        dcmd(xsetworldall,12,cmdtext);
        dcmd(xaddcolor,9,cmdtext);
        dcmd(xcarhealth,10,cmdtext);
        dcmd(xadmins,7,cmdtext);
        dcmd(xcommands,9,cmdtext);
        dcmd(xvr,3,cmdtext);
        dcmd(xkillall,8,cmdtext);
        dcmd(xslapall,8,cmdtext);
        dcmd(xbringall,9,cmdtext);
        dcmd(xfslapall,9,cmdtext);
        dcmd(xskydiveall,11,cmdtext);
        dcmd(xlockall,8,cmdtext);
        dcmd(xkickall,8,cmdtext);
        dcmd(xunlockall,10,cmdtext);
        dcmd(xejectall,9,cmdtext);
        dcmd(xunboundall,11,cmdtext);
        dcmd(xdestroyallcars,15,cmdtext);
        dcmd(xdestroyallobjects,18,cmdtext);
        dcmd(xdestroyallpickups,18,cmdtext);
        dcmd(xfslap,6,cmdtext);
        dcmd(xskydive,8,cmdtext);
        dcmd(xcp,3,cmdtext);
        dcmd(xracecp,7,cmdtext);
        dcmd(xcpoff,6,cmdtext);
        dcmd(xracecpoff,10,cmdtext);
        //dcmd(xrespawncars,12,cmdtext);
        dcmd(xcc,3,cmdtext);
        dcmd(xbound,6,cmdtext);
        dcmd(xann,4,cmdtext);
        dcmd(xunbound,8,cmdtext);
        dcmd(xdcar,5,cmdtext);
        dcmd(xcobject,8,cmdtext);
        dcmd(xdobject,8,cmdtext);
        dcmd(xaddpart,8,cmdtext);
        dcmd(xrempart,8,cmdtext);
        dcmd(xcpickup,8,cmdtext);
        dcmd(xdpickup,8,cmdtext);
        dcmd(xrape,5,cmdtext);
        dcmd(xplaysound,10,cmdtext);
        dcmd(xexplodeall,11,cmdtext);
        //dcmd(xcommands2,10,cmdtext);
        dcmd(xmi,3,cmdtext);
        dcmd(xdr,3,cmdtext);
        dcmd(xmolest,7,cmdtext);
        dcmd(xint,4,cmdtext);
        dcmd(xrcon,5,cmdtext);
        dcmd(xmovexy,7,cmdtext);
        dcmd(xmovez,6,cmdtext);
        dcmd(xgotov,6,cmdtext);
        dcmd(xenterv,7,cmdtext);
        //dcmd(xips,4,cmdtext);
        //dcmd(xmatch,6,cmdtext);
        dcmd(xpaint,6,cmdtext);
        dcmd(xunos,5,cmdtext);
        dcmd(xspoof,6,cmdtext);
        dcmd(xpm,3,cmdtext);
        dcmd(xshowpms,8,cmdtext);
        dcmd(xshowcmds,9,cmdtext);
	}
	
//------------------------------------------------------------------------------
    
    //if(strlen(cmdtext) > 32)return 1;
    dcmd(teams,5,cmdtext);
    dcmd(d,1,cmdtext);
    dcmd(ready,5,cmdtext);
    dcmd(spawn,5,cmdtext);
    if(ViewingResults[playerid] == true)return 0;
	dcmd(pass,4,cmdtext);
	dcmd(back,4,cmdtext);

	if(ViewingResults[playerid] == true && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid,grey,"Please wait until the final results are finished showing.");
	else if(gPlayerSpawned[playerid] == false) return SendClientMessage(playerid,grey,"Please spawn before attempting to use any commands.");
	else if(NoCmds[playerid] == true && !IsPlayerAdmin(playerid)) {format(string,sizeof(string),"Sorry, you can only use commands once every %d second(s)",CmdTime); return SendClientMessage(playerid,MainColors[2],string);}
	else NoCmds[playerid] = true;SetTimerEx("AllowCommands",CmdTime*1000,0,"i",playerid);

	if(AFK[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You must type /BACK before doing anything!");
	
	dcmd(a,1,cmdtext);
	dcmd(b,1,cmdtext);
	dcmd(add,3,cmdtext);
	dcmd(end,3,cmdtext);
	dcmd(fixr,4,cmdtext);
	dcmd(test,4,cmdtext);
	dcmd(swap,4,cmdtext);
	dcmd(load,4,cmdtext);
	//dcmd(tele,4,cmdtext);
	dcmd(saver,5,cmdtext);
	dcmd(pause,5,cmdtext);
	dcmd(allvs,5,cmdtext);
	dcmd(match,5,cmdtext);
	dcmd(config,6,cmdtext);
	dcmd(leader,6,cmdtext);
	dcmd(remove,6,cmdtext);
	dcmd(movecp,6,cmdtext);
	dcmd(delacc,6,cmdtext);
	dcmd(wheels,6,cmdtext);
	dcmd(nickall,7,cmdtext);
	dcmd(unpause,7,cmdtext);
	dcmd(setteam,7,cmdtext);
	dcmd(balance,7,cmdtext);
	dcmd(hosttag,7,cmdtext);
	dcmd(deadtag,7,cmdtext);
	dcmd(setpass,7,cmdtext);
	dcmd(modemin,7,cmdtext);
	dcmd(teammsg,7,cmdtext);
	dcmd(saveloc,7,cmdtext);
	dcmd(gotoloc,7,cmdtext);
	//dcmd(motdtext,8,cmdtext);
	dcmd(resetacc,8,cmdtext);
	dcmd(starttdm,8,cmdtext);
	dcmd(resetall,8,cmdtext);
	dcmd(teamskin,8,cmdtext);
	dcmd(teamlock,8,cmdtext);
	dcmd(teamused,8,cmdtext);
	dcmd(teamname,8,cmdtext);
	dcmd(givemenu,8,cmdtext);
	//dcmd(location,8,cmdtext);
	dcmd(startbase,9,cmdtext);
	dcmd(resettemp,9,cmdtext);
	dcmd(mainspawn,9,cmdtext);
	dcmd(playingtag,10,cmdtext);
	dcmd(resetnicks,10,cmdtext);
	dcmd(startarena,10,cmdtext);
	dcmd(roundlimit,10,cmdtext);
	dcmd(switchteam,10,cmdtext);
	dcmd(resetscores,11,cmdtext);
	dcmd(teamvehcolor,12,cmdtext);
	
	dcmd(t,1,cmdtext);
	dcmd(v,1,cmdtext);
	dcmd(s,1,cmdtext);
	//dcmd(sreset,6,cmdtext);
	dcmd(tp,2,cmdtext);
	dcmd(int,3,cmdtext);
	dcmd(car,3,cmdtext);
	dcmd(afk,3,cmdtext);
	dcmd(sub,3,cmdtext);
	dcmd(kill,4,cmdtext);
	dcmd(sync,4,cmdtext);
	dcmd(view,4,cmdtext);
	dcmd(hide,4,cmdtext);
	dcmd(nick,4,cmdtext);
	dcmd(skin,4,cmdtext);
	dcmd(duel,4,cmdtext);
	dcmd(help,4,cmdtext);
	dcmd(spec,4,cmdtext);
	dcmd(info,4,cmdtext);
	dcmd(give,4,cmdtext);
	dcmd(drop,4,cmdtext);
	dcmd(time,4,cmdtext);
	dcmd(chase,5,cmdtext);
	dcmd(stats,5,cmdtext);
	dcmd(wlist,5,cmdtext);
	dcmd(world,5,cmdtext);
	dcmd(rules,5,cmdtext);
	dcmd(readd,5,cmdtext);
	dcmd(switch,6,cmdtext);
	dcmd(vcolor,6,cmdtext);
	dcmd(scores,6,cmdtext);
	dcmd(getgun,6,cmdtext);
	dcmd(ignore,6,cmdtext);
	dcmd(fstyle,6,cmdtext);
	dcmd(weather,7,cmdtext);
	dcmd(getnick,7,cmdtext);
	dcmd(gunmenu,7,cmdtext);
	dcmd(carlist,7,cmdtext);
	dcmd(gunlist,7,cmdtext);
	dcmd(credits,7,cmdtext);
    dcmd(specoff,7,cmdtext);
    dcmd(myskill,7,cmdtext);
    //dcmd(killmsg,7,cmdtext);
	dcmd(commands,8,cmdtext);
	dcmd(removegun,9,cmdtext);
	dcmd(highscore,9,cmdtext);
	dcmd(worldpass,9,cmdtext);
	dcmd(resetnick,9,cmdtext);
	dcmd(resetguns,9,cmdtext);
	
	dcmd(testcolor,9,cmdtext);
	
	dcmd(ss,2,cmdtext);
	//dcmd(ob,2,cmdtext);
	return 0;
}

dcmd_pm(playerid,params[])
{
    if(!strlen(params))return SendClientMessage(playerid,Colors[2],"Error: /PM <PLAYERID> <MESSAGE>");
	new tmp[128],Index;//,string[128];
	tmp = strtok(params,Index);
	new toid = ReturnPlayerID(tmp,strval(tmp));
	if(!IsPlayerConnected(toid) || toid == playerid)return SendClientMessage(playerid,Colors[2],"Error: /XPM <PLAYERID> <MESSAGE>");
	OnPlayerPrivmsg(playerid,toid,params[strlen(tmp)+1]);
	return 1;
}

/*dcmd_ob(playerid,params[])
{
	    new id[32],obj[32],Index;id = strtok_(params,Index), obj = strtok_(params,Index);
	    if(!strlen(id)||!strlen(obj)) return SendClientMessage(playerid,Colors[2],"Error: /OB <NICK OR ID> <MODEL ID>");
		if(IsPlayerConnected(strval(id)))
		{
		    new Float:ASD[3],object;
		    GetPlayerPos(strval(id),ASD[0],ASD[1],ASD[2]);
		    object = CreateObject(strval(obj),ASD[0],ASD[1],ASD[2],0.0,0.0,0.0);
		    AttachObjectToPlayer(object,strval(id),0.0,0.0,1.5,0.0,0.0,0.0);
		    SendClientMessageToAll(0xFFFFFFFF,"attached");
		}
		return 1;
}*/

//------------------------------------------------------------------------------
//Administration commands
dcmd_xregister(playerid,params[])
{
	if(!strlen(params))return SendClientMessage(playerid,Colors[2],"Error: /XREGISTER <PASSWORD> [Password must be 2+]");
	new index,Password[128],string[128],PlayerFile[64];
	Password = strtok(params,index);
	format(PlayerFile,sizeof(PlayerFile),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	if(!(Variables[playerid][Registered] && Variables[playerid][LoggedIn]))
	{
	    if(strlen(Password) >= 2)
		{
	        format(string,sizeof(string),"Your password is %s and you've been automatically logged in.",Password);
			dini_IntSet(PlayerFile,"Password",udb_hash(Password));
            dini_IntSet(PlayerFile,"Registered",1);
	        Variables[playerid][LoggedIn] = true;
			Variables[playerid][Registered] = true;
			Variables[playerid][Level] = 0;
	        SendClientMessage(playerid,Colors[4],string);
	        new tmp3[50];GetPlayerIp(playerid,tmp3,50);dini_Set(PlayerFile,"IP",tmp3);
	    }
		else SendClientMessage(playerid,Colors[2],"Error: /XREGISTER <PASSWORD> [Password must be 2+]");
	}
	else SendClientMessage(playerid,Colors[2],"Error: Make sure that you have not registered and are logged out.");
	return 1;
}

dcmd_xlogin(playerid,params[])
{
    if(!strlen(params))return SendClientMessage(playerid,Colors[2],"Error: /XLOGIN <PASSWORD>");
	new index,Password[128],string[128],file[64];
	Password = strtok(params,index);
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
    if(Variables[playerid][Registered] == true && Variables[playerid][LoggedIn] == false)
	{
        if(udb_hash(Password) == dini_Int(file,"Password"))
		{
		    Variables[playerid][LoggedIn] = true;
		    Variables[playerid][Level] = dini_Int(file,"Level");
        	format(string,sizeof(string),"You have logged into your account. [Level %d]",Variables[playerid][Level]);
            SendClientMessage(playerid,Colors[4],string);
	        new tmp3[20]; GetPlayerIp(playerid,tmp3,20); dini_Set(file,"IP",tmp3);
        }
		else SendClientMessage(playerid,Colors[2],"Error: /XLOGIN <PASSWORD>");
	}
	else SendClientMessage(playerid,Colors[2],"Error: You must be registered to log in; if you have make sure you haven't already logged in.");
	return 1;
}

dcmd_xlogout(playerid,params[])
{
	#pragma unused params
    if(Variables[playerid][Registered] == true && Variables[playerid][LoggedIn] == true)
	{
		new file[64];
	    format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		SendClientMessage(playerid,Colors[4],"You have logged out of your account. You may log back in later by typing /XLOGIN <PASSWORD>");
	 	Variables[playerid][LoggedIn] = false;
	 	Variables[playerid][Level] = 0;
	}
	else SendClientMessage(playerid,Colors[2],"Error: You must be registered and logged into your account first.");
	return 1;
}

dcmd_xgoto(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    if(!strlen(params))return SendClientMessage(playerid,Colors[2],"Error: /XGOTO <NICK OR ID>");
        new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    SendCommandMessageToAdmins(playerid,"XGOTO");
			new Float:X,Float:Y,Float:Z,Float:angle;
			new gInt = GetPlayerInterior(id);
			SetPlayerInterior(playerid,gInt);
			SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
			GetPlayerPos(id,X,Y,Z);
			if(IsPlayerInAnyVehicle(id))
			{
				angle = GetPosInFrontOfPlayer(id,X,Y, -4.5);
				if(IsPlayerInAnyVehicle(playerid))
				{
				    SetVehiclePos(GetPlayerVehicleID(playerid),X,Y,Z+1);
					SetVehicleZAngle(GetPlayerVehicleID(playerid),angle);
					LinkVehicleToInterior(GetPlayerVehicleID(playerid),gInt);
					SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),GetPlayerVirtualWorld(id));
				}
				else
				{
					SetPlayerPos(playerid,X,Y,Z+1);
					SetPlayerFacingAngle(playerid,angle);
				}
			}
			else
			{
				angle = GetPosInFrontOfPlayer(id, X,Y, -1.0);
				if(IsPlayerInAnyVehicle(playerid))
				{
				    SetVehiclePos(GetPlayerVehicleID(playerid),X,Y,Z+1);
					SetVehicleZAngle(GetPlayerVehicleID(playerid),angle);
					LinkVehicleToInterior(GetPlayerVehicleID(playerid),gInt);
					SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),GetPlayerVirtualWorld(id));
				}
				else
				{
					SetPlayerPos(playerid,X,Y,Z+1);
					SetPlayerFacingAngle(playerid,angle);
				}
			}
  		}
	  	else return SendClientMessage(playerid,Colors[2],"Error: You cannot teleport to yourself or disconnected players.");
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}

dcmd_xbring(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XBRING <NICK OR ID>");
        new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
			SendCommandMessageToAdmins(playerid,"XBRING");
			new Float:X,Float:Y,Float:Z,Float:bAngle;
			new bInt = GetPlayerInterior(playerid);
			SetPlayerInterior(id,bInt);
			SetPlayerVirtualWorld(id,GetPlayerVirtualWorld(playerid));
			GetPlayerPos(playerid,X,Y,Z);
			if(IsPlayerInAnyVehicle(id))
			{
				bAngle = GetPosInFrontOfPlayer(playerid,X,Y, 4.5);
				SetVehiclePos(GetPlayerVehicleID(id),X,Y,Z+1);
				SetVehicleZAngle(GetPlayerVehicleID(id),bAngle);
				LinkVehicleToInterior(GetPlayerVehicleID(id),bInt);
			}
			else
			{
				bAngle = GetPosInFrontOfPlayer(playerid, X,Y, 1.0);
				SetPlayerPos(id,X,Y,Z+1);
				SetPlayerFacingAngle(id,bAngle);
			}
  		}
	  	else return SendClientMessage(playerid,Colors[2],"Error: You cannot teleport yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}

dcmd_xannounce(playerid,params[])
{
    if(IsCmdLvl(playerid,2))
	{
        SendCommandMessageToAdmins(playerid,"XANNOUNCE");
    	if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XANNOUNCE <TEXT>");
		return GameTextForAll(params,5000,3);
    }
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsay(playerid,params[])
{
    if(IsCmdLvl(playerid,1))
	{
        SendCommandMessageToAdmins(playerid,"XSAY");
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XSAY <TEXT>");
		new string[128]; format(string,128,"** Admin %s: %s",RealName[playerid],params);
		return SendClientMessageToAll(Colors[3],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xflip(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    if(!strlen(params))
		{
			if(IsPlayerInAnyVehicle(playerid))
			{
				new Float:X,Float:Y,Float:Z,Float:bAngle;
				GetVehiclePos(GetPlayerVehicleID(playerid),X,Y,Z);
				GetVehicleZAngle(GetPlayerVehicleID(playerid),bAngle);
				SetVehiclePos(GetPlayerVehicleID(playerid),X,Y,Z+2);
				SetVehicleZAngle(GetPlayerVehicleID(playerid),bAngle);
				SetVehicleHealth(GetPlayerVehicleID(playerid),v_Health[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
				return 1;
			}
			else return SendClientMessage(playerid,Colors[2],"Error: /XFLIP <NICK OR ID>");
		}
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
			if(IsPlayerInAnyVehicle(id))
			{
		    	SendCommandMessageToAdmins(playerid,"XFLIP");
				new Float:X,Float:Y,Float:Z,Float:bAngle,string[128];
				GetVehiclePos(GetPlayerVehicleID(id),X,Y,Z);
				GetVehicleZAngle(GetPlayerVehicleID(id),bAngle);
    			SetVehiclePos(GetPlayerVehicleID(id),X,Y,Z+2);
				SetVehicleZAngle(GetPlayerVehicleID(id),bAngle);
				SetVehicleHealth(GetPlayerVehicleID(id),v_Health[GetVehicleModel(GetPlayerVehicleID(id))-400]);
				if(id != playerid)
				{
					format(string,128,"You have flipped %s's vehicle.",RealName[id]);
					SendClientMessage(playerid,Colors[0],string);
				}
				else SendClientMessage(playerid,Colors[0],"You have flipped your vehicle.");
				return true;
			}
			else return SendClientMessage(playerid,Colors[2],"Error: The player must be in a vehicle.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot flip a disconnected player's vehicle.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xslap(playerid,params[])
{
    if(IsCmdLvl(playerid,2))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XSLAP <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to slap that player.");
		    SendCommandMessageToAdmins(playerid,"XSLAP");
		    new string[128];
		    format(string,128,"Administrator %s has slapped player %s.",RealName[playerid],RealName[id]);
		    if(id != playerid) SendClientMessageToAll(Colors[0],string); else SendClientMessage(playerid,Colors[0],"You have slapped yourself.");
			new Float:x, Float:y, Float:z;
   			GetPlayerPos(id, x, y, z);
			return SetPlayerPos(id, x, y, z + 12.5);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xmute(playerid,params[])
{
    if(IsCmdLvl(playerid,3))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XMUTE <NICK OR ID> <REASON>");
        new tmp[128],Index; tmp = strtok(params,Index);
	   	new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    if(!Variables[id][Muted])
			{
			    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to mute that player.");
		        SendCommandMessageToAdmins(playerid,"XMUTE");
			    new string[128];
			    if(!strlen(params[strlen(tmp)+1])) format(string,128,"%s has been muted by Administrator %s.",RealName[id],RealName[playerid]);
				else format(string,128,"%s has been muted by Administrator %s. (Reason: %s)",RealName[id],RealName[playerid],params[strlen(tmp)+1]);
				Variables[id][Muted] = true;
		    	return SendClientMessageToAll(Colors[0],string);
			}
			else return SendClientMessage(playerid,Colors[2],"Error: This player has already been muted.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot mute yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xint(playerid,params[])
{
    if(!IsCmdLvl(playerid,1))return SendLevelErrorMessage(playerid);
	new id = strval(params);
	if(!strlen(params) || id <= 0 || id > 147) return SendClientMessage(playerid,Colors[2],"Error: /XINT <1-147>");
	if(IsPlayerInAnyVehicle(playerid))
	{
 		foreach(Player,i)
 		{
 			if(IsPlayerInVehicle(i,GetPlayerVehicleID(playerid)))
 			{
    			SetPlayerInterior(i, Interiors[id][int_interior]);
 			}
 		}
		SetVehiclePos(GetPlayerVehicleID(playerid), Interiors[id][int_x], Interiors[id][int_y], Interiors[id][int_z]);
		SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), Interiors[id][int_interior]);
		SetCameraBehindPlayer(playerid);
	}
	else
	{
		SetPlayerPos(playerid,Interiors[id][int_x], Interiors[id][int_y], Interiors[id][int_z]);
		SetPlayerFacingAngle(playerid, Interiors[id][int_a]);
		SetPlayerInterior(playerid, Interiors[id][int_interior]);
		SetCameraBehindPlayer(playerid);
	}
	new string[128];
	format(string,sizeof(string),"*** ID: %d, \"%s\", Interior: %d",id,Interiors[id][int_name],Interiors[id][int_interior]);
	SendClientMessage(playerid,0xFFFFFFFF,string);
	return 1;
}

dcmd_xunmute(playerid,params[])
{
    if(IsCmdLvl(playerid,3))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XUNMUTE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[id][Muted])
			{
		        SendCommandMessageToAdmins(playerid,"XUNMUTE");
				Variables[id][Muted] = false;
			    if(id != playerid)
				{
				    new string[128];
					format(string,128,"%s has been unmuted by Administrator %s.",RealName[id],RealName[playerid]);
					return SendClientMessageToAll(Colors[0],string);
				}
			    else return SendClientMessage(playerid,Colors[0],"You have successfully unmuted yourself.");
        	}
			else return SendClientMessage(playerid,Colors[2],"Error: This player is not muted.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot unmute a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xkick(playerid,params[])
{
    if(IsCmdLvl(playerid,3))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XKICK <NICK OR ID> <REASON>");
   		new tmp[128],Index; tmp = strtok(params,Index);
	   	new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to kick that player.");
		    SendCommandMessageToAdmins(playerid,"XKICK");
		    new string[128];
	    	if(!strlen(params[strlen(tmp)+1])) format(string,128,"%s has been kicked by Administrator %s.",RealName[id],RealName[playerid]);
			else format(string,128,"%s has been kicked by Administrator %s. (Reason: %s)",RealName[id],RealName[playerid],params[strlen(tmp)+1]);
			SendClientMessageToAll(Colors[0],string);
			for(new a; a < 50; a++)SendClientMessage(id,0xFFFFFFFF,"\n");
			TD_HidepTextForPlayer(id,id,4);
			TextDrawBoxColor(pText[4][id],0x000000FF);
   			TD_ShowpTextForPlayer(id,id,4);
			return Kick(id);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot kick yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xban(playerid,params[])
{
    if(IsCmdLvl(playerid,4))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XBAN <NICK OR ID> <REASON>");
   		new tmp[128],Index; tmp = strtok(params,Index);
	   	new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    if(Variables[playerid][Level] < Variables[id][Level] || IsPlayerAdmin(id))return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to ban that player.");
		    SendCommandMessageToAdmins(playerid,"XBAN");
		    new string[128],Float:CD[3];
			GetPlayerPos(id,CD[0],CD[1],CD[2]);
		    if(!strlen(params[strlen(tmp)+1])) format(string,128,"%s has been banned by Administrator %s.",RealName[id],RealName[playerid]);
			else format(string,128,"%s has been banned by Administrator %s. (Reason: %s)",RealName[id],RealName[playerid],params[strlen(tmp)+1]);
			SendClientMessageToAll(Colors[0],string);
			CreatePlayerObject(id,300,CD[0],CD[1],CD[2],0.0,0.0,0.0);
			return SetTimerEx("BanIt",200,0,"i",id);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot ban yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

forward BanIt(playerid);
public BanIt(playerid)
{
	Ban(playerid);
	return 1;
}

dcmd_xakill(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XAKILL <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to kill that player.");
		    SendCommandMessageToAdmins(playerid,"XAKILL");
		    if(id == playerid)
			{
				DontCountDeaths[playerid] = true;
			 	return SetPlayerHealthEx(playerid,0.0);
			}
		    new string[128];
		    format(string,128,"You have been killed by Administrator %s.",RealName[playerid]); SendClientMessage(id,Colors[0],string);
		    format(string,128,"You have killed Player %s.",RealName[id]); SendClientMessage(playerid,Colors[0],string);
		    DontCountDeaths[id] = true;
			return SetPlayerHealthEx(id,0.0);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot auto-kill yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xeject(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XEJECT <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(IsPlayerInAnyVehicle(id))
			{
		        SendCommandMessageToAdmins(playerid,"XEJECT");
			    new string[128];  RemovePlayerFromVehicle(id);
			    if(id != playerid)
				{
					format(string,128,"You have been ejected from your vehicle by Administrator %s.",RealName[playerid]); SendClientMessage(id,Colors[0],string);
			    	format(string,128,"You have ejected Player %s.",RealName[id]); return SendClientMessage(playerid,Colors[0],string);
				}
				else return SendClientMessage(playerid,Colors[0],"You have ejected yourself from your vehicle.");
			}
			else return SendClientMessage(playerid,Colors[2],"Error: This player must be in a vehicle.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot eject a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xfreeze(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XFREEZE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to freeze that player.");
		    SendCommandMessageToAdmins(playerid,"XFREEZE");
		    new string[128];
		    TogglePlayerControllable(id,false); format(string,128,"Admnistrator %s has frozen %s.",RealName[playerid],RealName[id]);
		    if(id != playerid) return SendClientMessageToAll(Colors[0],string);
			else return SendClientMessage(playerid,Colors[0],"You have frozen yourself.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot freeze a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xunfreeze(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XUNFREEZE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XUNFREEZE");
		    new string[128];
		    TogglePlayerControllable(id,true);
			format(string,128,"Admnistrator %s has unfrozen %s.",RealName[playerid],RealName[id]);
			if(id != playerid) return SendClientMessageToAll(Colors[0],string);
			else return SendClientMessage(playerid,Colors[0],"You have unfrozen yourself.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot unfreeze a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetint(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XSETINT <NICK OR ID> <INTERIOR ID>");
  		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
			new string[128];
  			SendCommandMessageToAdmins(playerid,"XSETINT");
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your interior to ID %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You have set %s's interior ID to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your interior to ID %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerInterior(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's interior.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetintall(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
		if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XSETINT <INTERIOR ID>");
		SendCommandMessageToAdmins(playerid,"XSETINTALL");
		new string[128];
		foreach(Player,i)SetPlayerInterior(i,strval(params));
		format(string,128,"Everyone's interior has been changed to ID %d.",strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xrestoreall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,5))
	{
	    SendCommandMessageToAdmins(playerid,"XRESTOREALL");
 		foreach(Player,i)
 		{
 		    SetPlayerLife(i,gHealth,gArmor);
		}
 		new string[128];
	    format(string,128,"Everyone's health and armor has been restored by Administrator %s.",RealName[playerid]);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xhealall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XHEALALL");
 		foreach(Player,i)SetPlayerHealthEx(i,gHealth);
 		new string[128];
	    format(string,128,"Everyone has been healed by Administrator %s.",RealName[playerid]);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsethealth(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0)) return SendClientMessage(playerid,Colors[2],"Error: /XSETHEALTH <NICK OR ID> <AMOUNT>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's health.");
		    SendCommandMessageToAdmins(playerid,"XSETHEALTH");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your health to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string);
				format(string,128,"You have set %s's health to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
				if(strval(tmp2) < 1)DontCountDeaths[id] = true;
			}
			else
			{
				format(string,128,"You have set your health to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
				if(strval(tmp2) < 1)DontCountDeaths[playerid] = true;
			}
			return SetPlayerHealthEx(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's health.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xskinall(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XSKINALL <SKIN ID>");
		if(IsSkinValid(strval(params)))
		{
		    SendCommandMessageToAdmins(playerid,"XSKINALL");
			new string[128];foreach(Player,i)SetPlayerSkin(i,strval(params));
			format(string,128,"Everyone's skin has been changed to ID %d.",strval(params));
			return SendClientMessageToAll(Colors[0],string);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: Invalid skin ID.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgunall(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    new tmp[20],tmp2[20],idx; tmp = strtok_(params,idx); tmp2 = strtok_(params,idx);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XGUNALL <NAME OR ID> <AMOUNT>");
		new id = GetWeaponModelIDFromName(tmp);
		if(id == -1)
		{
			id = strval(tmp);
			if(id < 0 || id > 47)
			{
	    		SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon Name");
	    		return 1;
			}
		}
        SendCommandMessageToAdmins(playerid,"XGUNALL");
		new string[128]; foreach(Player,i)GivePlayerWeapon(i,id,strval(tmp2));
		format(string,128,"Everyone has been given %d %s by Administrator %s.",strval(tmp2),WeaponNames[id],RealName[playerid]);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdisarm(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XDISARM <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to disarm that player.");
		    SendCommandMessageToAdmins(playerid,"XDISARM");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has reset your weapons.",RealName[playerid]);
				SendClientMessage(id,Colors[0],string); format(string,128,"You have reset %s's weapons.",RealName[id]);
				SendClientMessage(playerid,Colors[0],string);
			}
			else SendClientMessage(playerid,Colors[0],"You have reset your weapons.");
			return ResetPlayerWeapons(id);
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot reset a disconnected player's weapons.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdisarmall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XDISARMALL");
		new string[128]; foreach(Player,i)ResetPlayerWeapons(i);
		format(string,128,"Administrator %s has reset everyone's weapons.",RealName[playerid]);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetcash(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0)) return SendClientMessage(playerid,Colors[2],"Error: /XSETCASH <NICK OR ID> <AMOUNT>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XSETCASH");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your cash to $%d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You have set %s's cash to $%d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your cash to $%d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			ResetPlayerMoney(id);
			return GivePlayerMoney(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's cash.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgivecash(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 1)) return SendClientMessage(playerid,Colors[2],"Error: /XGIVECASH <NICK OR ID> <AMOUNT>");
   	    new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XGIVECASH");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has given you $%d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You have given %s $%d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have given yourself $%d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return GivePlayerMoney(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot give a disconnected player cash.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetcashall(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params)||!(strval(params)>=0)) return SendClientMessage(playerid,Colors[2],"Error: /XSETCASHALL <AMOUNT>");
        SendCommandMessageToAdmins(playerid,"XSETCASHALL");
		foreach(Player,i)
		{
			ResetPlayerMoney(i);
			GivePlayerMoney(i,strval(params));
		}
		new string[128];
		format(string,128,"Administrator %s has set everyones' cash to $%d.",RealName[playerid],strval(params));
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgivecashall(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params)||!(strval(params)>=0)) return SendClientMessage(playerid,Colors[2],"Error: /XGIVECASHALL <AMOUNT>");
        SendCommandMessageToAdmins(playerid,"XGIVECASHALL");
		foreach(Player,i)GivePlayerMoney(i,strval(params));
		new string[128];
		format(string,128,"Administrator %s has given everyone $%d.",RealName[playerid],strval(params));
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xejectall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XEJECTALL");
	    foreach(Player,i)if(IsPlayerInAnyVehicle(i))RemovePlayerFromVehicle(i);
		new string[128];
		format(string,128,"Administrator %s has ejected everyone from their vehicle.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xfreezeall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XFREEZEALL");
	    foreach(Player,i)TogglePlayerControllable(i,false);
		new string[128];
		format(string,128,"Administrator %s froze everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xunfreezeall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XUNFREEZEALL");
	    foreach(Player,i)TogglePlayerControllable(i,true);
		new string[128];
		format(string,128,"Administrator %s unfroze everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgivegun(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    new tmp[128], tmp2[128], tmp3[128], Index; tmp = strtok(params,Index),tmp2 = strtok(params,Index),tmp3 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!strlen(tmp3)||!IsNumeric(tmp3)) return SendClientMessage(playerid,Colors[2],"Error: /XGIVEGUN <NICK OR ID> <NAME OR ID> <AMOUNT>");
		new id = ReturnPlayerID(tmp,strval(tmp));
		new id2 = ReturnWeaponID(tmp2,strval(tmp2));
        if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
        	if(id2==-1||id2==19||id2==20||id2==21||id2==0) return SendClientMessage(playerid,Colors[2],"Error: You have selected an invalid weapon ID.");
            SendCommandMessageToAdmins(playerid,"XGIVEGUN");
			new string[128];
            if(id != playerid)
			{
				format(string,128,"Administrator %s has given you %d %s.",RealName[playerid],strval(tmp3),WeaponNames[id2]);
				SendClientMessage(id,Colors[0],string); format(string,128,"You have given %s %d %s.",RealName[id],strval(tmp3),WeaponNames[id2]);
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have given yourself %d %s.",strval(tmp3),WeaponNames[id2]);
				SendClientMessage(playerid,Colors[0],string);
			}
			return GivePlayerWeapon(id,id2,strval(tmp3));
	    }
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot give a disconnected player a weapon.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgod(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XGOD <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XGOD");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has given you infinite health.",RealName[playerid]);
				SendClientMessage(id,Colors[0],string); format(string,128,"You have given %s infinite health.",RealName[id]);
				SendClientMessage(playerid,Colors[0],string);
			}
			else SendClientMessage(playerid,Colors[0],"You have given yourself infinite health.");
			return SetPlayerHealthEx(id,99999999);
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot give a disconnected player infinite health.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgodall(playerid,params[])
{
    #pragma unused params
	if(IsCmdLvl(playerid,5))
	{
	    SendCommandMessageToAdmins(playerid,"XGODALL");
		foreach(Player,i)SetPlayerHealthEx(i,99999999);
        new string[128];
		format(string,128,"Administrator %s has given everyone infinite health.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
 	}
	 else return SendLevelErrorMessage(playerid);
}

dcmd_xresetscores(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,3))
	{
	    SendCommandMessageToAdmins(playerid,"XRESETSCORES");
	    foreach(Player,i)SetPlayerScore(i,0);
		new string[128];
		format(string,128,"Administrator %s resetted everyone's score.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetlevel(playerid,params[])
{
	if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,Colors[2],"Error: You must be logged into rcon to use this command.");
 	new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
  	if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0))return SendClientMessage(playerid,Colors[2],"Error: SETLEVEL <NICK OR ID> <LEVEL>");
	new id = ReturnPlayerID(tmp,strval(tmp));
	if(Variables[id][Registered] == false)return SendClientMessage(playerid,Colors[2],"Error: Player is not registered.");
	if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
	{
	    if(IsPlayerAdmin(id) && id != playerid)return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's level (rcon admin).");
		if(Variables[id][Level] == strval(tmp2))return SendClientMessage(playerid,Colors[2],"Error: That player is already that level.");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XSETLEVEL");
		format(string,128,"Administrator %s has %s you to %s [%d].",RealName[playerid],((strval(tmp2) >= Variables[id][Level])?("promoted"):("demoted")),((strval(tmp2))?("Administrator"):("Member Status")),strval(tmp2)); SendClientMessage(id,Colors[0],string);
		format(string,128,"You have %s %s to %s [%d].",((strval(tmp2) >= Variables[id][Level])?("promoted"):("demoted")),RealName[id],((strval(tmp2))?("Administrator"):("Member Status")),strval(tmp2)); SendClientMessage(playerid,Colors[0],string);
		Variables[id][Level] = strval(tmp2);
		new file[64];
		format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[id]);
		return dini_IntSet(file,"Level",strval(tmp2));
	}
	return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's level.");
}

dcmd_xsetskin(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XSETSKIN <NICK OR ID> <SKINID>");
		if(!IsSkinValid(strval(tmp2))) return SendClientMessage(playerid,Colors[2],"Error: Invalid skin ID.");
  		new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
			new string[128];
            SendCommandMessageToAdmins(playerid,"XSETSKIN");
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your skin to ID %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string);
				format(string,128,"You have set %s's skin ID to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your skin ID to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerSkin(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's skin.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetarmor(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0)) return SendClientMessage(playerid,Colors[2],"Error: /XSETARMOR <NICK OR ID> <AMOUNT>");
   		new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's armor.");
		    SendCommandMessageToAdmins(playerid,"XSETARMOR");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your armor to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You have set %s's armor to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your armor to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerArmorEx(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's armor.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xcar(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XCAR <VEHICLEID/NAME>");
	    new idx = ReturnVehicleID(params);
		if(idx == -1)
		{
			idx = strval(params);
			if(idx < 400 || idx > 611)return SendClientMessage(playerid, Colors[2], "Error: Invalid modelid or name.");
		}
  		SendCommandMessageToAdmins(playerid,"XCAR");
  		new string[128];
  		new Float:X,Float:Y,Float:Z,Float:bAngle,car;
		new bInt = GetPlayerInterior(playerid);
		GetPlayerPos(playerid,X,Y,Z);
		bAngle = GetPosInFrontOfPlayer(playerid,X,Y, 4.5);
		car = CreateVehicle(idx,X,Y,Z,bAngle,vColor[0][playerid],vColor[1][playerid],cellmax);
        SetVehicleHealth(car,v_Health[GetVehicleModel(car)-400]);
		LinkVehicleToInterior(GetPlayerVehicleID(car),bInt);
		SetVehicleVirtualWorld(car,GetPlayerVirtualWorld(playerid));
		Vehicles++;
		v_Exists[car] = true;
		v_Destroy[car] = false;
		v_Trailer[car] = -1;
		if(Vehicles > HighestVID)HighestVID = Vehicles;
    	format(string,128,"*** Vehicle spawned: %s (%d)   HP: %d",CarList[idx-400],idx,v_Health[idx-400]);
  		SendClientMessage(playerid,Colors[0],string);
  		return 1;
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xarmorall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,3))
	{
	    SendCommandMessageToAdmins(playerid,"XARMORALL");
 		foreach(Player,i)SetPlayerArmorEx(i,gArmor);
 		new string[128];
	    format(string,128,"Everyone's armor has been restored by Administrator %s.",RealName[playerid]);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetscore(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0)) return SendClientMessage(playerid,Colors[2],"Error: /XSETSCORE <NICK OR ID> <AMOUNT>");
   		new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XSETSCORE");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your score to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You set %s\'s score to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your score to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerScore(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's score.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xip(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XIP");
	    if(!strlen(params))
		{
			new IP[20],string[128];
			GetPlayerIp(playerid,IP,20);
			format(string,128,"Your IP: %s",IP);
			return SendClientMessage(playerid,Colors[0],string);
		}
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to check that player's IP.");
		    new string[128],IP[20]; GetPlayerIp(id,IP,20);
		    format(string,128,"%s's IP: %s",RealName[id],IP);
			return SendClientMessage(playerid,Colors[0],string);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot get the ip of a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xexplode(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XEXPLODE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to explode that player.");
		    SendCommandMessageToAdmins(playerid,"XEXPLODE");
  			new string[128],Float:X,Float:Y,Float:Z;
			if(!IsPlayerInAnyVehicle(id)) GetPlayerPos(id,X,Y,Z);
			else GetVehiclePos(GetPlayerVehicleID(id),X,Y,Z);for(new i = 0; i < 5; i++)CreateExplosion(X,Y,Z,10,0);
		    if(id != playerid)
			{
				format(string,128,"You have been exploded by Administrator %s.",RealName[playerid]); SendClientMessage(id,Colors[0],string);
		    	format(string,128,"You have exploded Player %s.",RealName[id]); return SendClientMessage(playerid,Colors[0],string);
			}
			else return SendClientMessage(playerid,Colors[0],"You have exploded yourself.");
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot explode a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsettime(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128], tmp2[128], tmp3[128], Index; tmp = strtok(params,Index),tmp2 = strtok(params,Index),tmp3 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!strlen(tmp3)||!IsNumeric(tmp2)||!IsNumeric(tmp3)) return SendClientMessage(playerid,Colors[2],"Error: /XSETTIME <NICK OR ID> <HOUR> <MINUTE>");
		new id = ReturnPlayerID(tmp,strval(tmp));
        if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's time.");
            SendCommandMessageToAdmins(playerid,"XSETTIME");
            new string[128],Hour[5],Minute[5];
        	format(Hour,5,"%s%d",((strval(tmp2)<10)?("0"):("")),strval(tmp2)); format(Minute,5,"%s%d",((strval(tmp3)<10)?("0"):("")),strval(tmp3));
            if(id != playerid)
			{
				format(string,128,"Administrator %s has set your time to %s:%s.",RealName[playerid],Hour,Minute);
				SendClientMessage(id,Colors[0],string); format(string,128,"You have set %s's time to %s:%s.",RealName[id],Hour,Minute);
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your time to %s:%s.",Hour,Minute);
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerTime(id,strval(tmp2),strval(tmp3));
	    }
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's time.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsettimeall(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XSETTIMEALL <HOUR> <MINUTE>");
		SendCommandMessageToAdmins(playerid,"XSETTIMEALL");
		new string[128],Hour[5],Minute[5];
        format(Hour,5,"%s%d",((strval(tmp)<10)?("0"):("")),strval(tmp));
		format(Minute,5,"%s%d",((strval(tmp2)<10)?("0"):("")),strval(tmp2));
        format(string,128,"Administrator %s has set everyone's time to %s:%s.",RealName[playerid],Hour,Minute);
		foreach(Player,i)SetPlayerTime(i,strval(tmp),strval(tmp2));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xweather(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XWEATHER <NICK OR ID> <WEATHER ID>");
   		new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's weather.");
		    SendCommandMessageToAdmins(playerid,"XWEATHER");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your weather to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You set %s\'s weather to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your weather to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerWeather(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's weather.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xweatherall(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XWEATHERALL <WEATHER ID>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XWEATHERALL");
        format(string,128,"Administrator %s has set everyone's weather to %d.",RealName[playerid],strval(params));
		foreach(Player,i)SetPlayerWeather(i,strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xforce(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XFORCE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XFORCE");
		    new string[128];
		    ForceClassSelection(id); DontCountDeaths[id] = true; SetPlayerHealthEx(id,0.0); format(string,128,"Admnistrator %s has forced you to the spawn selection screen.",RealName[playerid]);
			SendClientMessage(id,Colors[0],string);
            format(string,128,"You have forced Player %s to the spawn selection screen.",RealName[id]);
			return SendClientMessage(playerid,Colors[0],string);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot force yourself or a disconnected player to the spawn selection screen.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetwanted(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0 && strval(tmp2) <= 6)) return SendClientMessage(playerid,Colors[2],"Error: /XSETWANTED <NICK OR ID> <0-6>");
        new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XSETWANTED");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your wanted level to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You set %s's wanted level to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your wanted level to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetPlayerWantedLevel(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's wanted level.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetwantedall(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params)||!(strval(params) >= 0 && strval(params) <= 6)) return SendClientMessage(playerid,Colors[2],"Error: /XSETWANTEDALL <0-6>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XSETWANTEDALL");
        format(string,128,"Administrator %s has set everyone's wanted level to %d.",RealName[playerid],strval(params));
		foreach(Player,i)SetPlayerWantedLevel(i,strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetworld(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)||!(strval(tmp2) >= 0 && strval(tmp2) <= 255)) return SendClientMessage(playerid,Colors[2],"Error: /XSETWORLD <NICK OR ID> <WORLD ID>");
   		new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's world.");
		    SendCommandMessageToAdmins(playerid,"XSETWORLD");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your virtual world to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You set %s\'s virtual world to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
				if(IsPlayerInAnyVehicle(id))RemovePlayerFromVehicle(id);
			}
			else
			{
				format(string,128,"You have set your virtual world to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
				if(IsPlayerInAnyVehicle(playerid))RemovePlayerFromVehicle(playerid);
			}
			return SetPlayerVirtualWorld(id,strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's virtual world.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xsetworldall(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)||!IsNumeric(params)||!(strval(params) >= 0 && strval(params) <= 255)) return SendClientMessage(playerid,Colors[2],"Error: /XSETWORLDALL <WORLD ID>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XSETWORLDALL");
        format(string,128,"Administrator %s has set everyone's virtual world to %d.",RealName[playerid],strval(params));
		foreach(Player,i)SetPlayerVirtualWorld(i,strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xaddcolor(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)) return SendClientMessage(playerid,Colors[2],"Error: /XADDCOLOR <COLOR 1> <COLOR 2>");
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,Colors[2],"Error: You must be in a vehicle.");
        SendCommandMessageToAdmins(playerid,"XADDCOLOR");
		if(!strlen(tmp2)) tmp2 = tmp;
		new string[128];
		format(string,128,"You have set your color to: [Color 1: %d || Color 2: %d]",strval(tmp),strval(tmp2));
		return ChangeVehicleColor(GetPlayerVehicleID(playerid),strval(tmp),strval(tmp2));
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xcarhealth(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XCARHEALTH <NICK OR ID> <AMOUNT>");
        new id = ReturnPlayerID(tmp,strval(tmp));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(!IsPlayerInAnyVehicle(id)) return SendClientMessage(playerid,Colors[2],"Error: This player must be in a vehicle.");
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to set that player's vehicle health.");
            SendCommandMessageToAdmins(playerid,"XCARHEALTH");
			new string[128];
			if(id != playerid)
			{
				format(string,128,"Administrator %s has set your car's health to %d.",RealName[playerid],strval(tmp2));
				SendClientMessage(id,Colors[0],string); format(string,128,"You have set %s's car's health to %d.",RealName[id],strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			else
			{
				format(string,128,"You have set your car's health to %d.",strval(tmp2));
				SendClientMessage(playerid,Colors[0],string);
			}
			return SetVehicleHealth(GetPlayerVehicleID(id),strval(tmp2));
		}
		return SendClientMessage(playerid,Colors[2],"Error: You cannot set a disconnected player's car health.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xkillall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XKILLALL");
	    foreach(Player,i)
		{
			DontCountDeaths[i] = true;
			SetPlayerHealthEx(i,0.0);
		}
		new string[128];
		format(string,128,"Administrator %s killed everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xmi(playerid,params[])
{
	#pragma unused params
	new Float:pX,Float:pY,Float:pZ,Float:pA,vehicle;
	if(IsCmdLvl(playerid,5))
	{
	    SendCommandMessageToAdmins(playerid,"XMI");
	    GetPlayerPos(playerid,pX,pY,pZ); GetPlayerFacingAngle(playerid,pA);vehicle = CreateVehicle(411,pX,pY,pZ,pA,3,0,cellmax);
	    PutPlayerInVehicle(playerid,vehicle,0); AddVehicleComponent(vehicle,1080); AddVehicleComponent(vehicle,1087); AddVehicleComponent(vehicle,1010); SetVehicleHealth(vehicle,9999999);
	    LinkVehicleToInterior(vehicle, GetPlayerInterior(playerid));
		SetVehicleVirtualWorld(vehicle,GetPlayerVirtualWorld(playerid));
		return 1;
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xskydiveall(playerid,params[])
{
	#pragma unused params
	new Float:pX,Float:pY,Float:pZ;
	if(IsCmdLvl(playerid,5))
	{
	    SendCommandMessageToAdmins(playerid,"XSKYDIVEALL");
	    foreach(Player,i)
		{
			GetPlayerPos(i,pX,pY,pZ);
			SetPlayerPos(i,pX,pY,pZ+750);
			GivePlayerWeapon(i,46,1);
		}
		new string[128];
		format(string,128,"Administrator %s skydived everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xslapall(playerid,params[])
{
	#pragma unused params
	new Float:pX,Float:pY,Float:pZ;
	if(IsCmdLvl(playerid,6))
	{
	    SendCommandMessageToAdmins(playerid,"XSLAPALL");
	    foreach(Player,i)
		{
			if(i != playerid)
			{
				GetPlayerPos(i,pX,pY,pZ);
				SetPlayerPos(i,pX,pY,pZ+5);
				PlayerPlaySound(i,1190,pX,pY,pZ+5);
			}
		}
		new string[128];
		format(string,128,"Administrator %s slapped everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xbringall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XBRINGALL");
		new Float:pX,Float:pY,Float:pZ;
	    GetPlayerPos(playerid,pX,pY,pZ);
	    new Float:XYZ[3];XYZ[0] = pX;XYZ[1] = pY;XYZ[2] = pZ;
		new Float:newXY[2];
		new Float:spin_amt = (360.0 / float(Players));
		new Float:spacing = (float(Players) * 0.05) + 1;
		new Float:spin;
	    foreach(Player,i)
		{
			if(i != playerid)
			{
				newXY[0] = XYZ[0];
				newXY[1] = XYZ[1];
				newXY[0] += (spacing * floatsin(spin, degrees));
				newXY[1] += (spacing * floatcos(spin, degrees));
				SetPlayerPos(i,newXY[0],newXY[1],XYZ[2]);
				SetPlayerFacingAngle(i,spin_amt);
				spin+=spin_amt;
			}
		}
		new string[128];
		format(string,128,"Administrator %s brought everyone to his location.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xfslapall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XFSLAPALL");
	    new Float:pX,Float:pY,Float:pZ;
	    foreach(Player,i)
		{
			if(i != playerid)
			{
				GetPlayerPos(i,pX,pY,pZ);
				SetPlayerPos(i,pX,pY,pZ+10);
				TogglePlayerControllable(i,false);
			}
		}
		new string[128];
		format(string,128,"Administrator %s freeze-slapped everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xlockall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XLOCKALL");
		new i;
		for(new x; x < HighestVID; x++)
		{
            foreachex(Player,i)SetVehicleParamsForPlayer(x,i,false,true);
		}
		new string[128];
		format(string,128,"Administrator %s locked all vehicles.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xunlockall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XUNLOCKALL");
		new i;
		for(new x; x < MAX_SERVER_VEHICLES; x++)
		{
 			foreachex(Player,i)SetVehicleParamsForPlayer(x,i,false,false);
		}
		new string[128];
		format(string,128,"Administrator %s unlocked all vehicles.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xkickall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,5))
	{
	    SendCommandMessageToAdmins(playerid,"XKICKALL");
	    foreach(Player,i) if(i != playerid)Kick(i);
		new string[128];
		format(string,128,"Administrator %s kicked everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xunboundall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
	    SendCommandMessageToAdmins(playerid,"XUNBOUNDALL");
	    foreach(Player,i)SetPlayerWorldBounds(i,20000.000,-20000.000,20000.000,-20000.000);
		new string[128];
		format(string,128,"Administrator %s removed everyone's world boundries.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdestroyallcars(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XDESTROYALLCARS");
		for(new x; x < MAX_SERVER_VEHICLES; x++)
		{
 			if(v_Exists[x])
			{
			 	DestroyVehicleEx(x);
			}
	 	}
	 	Vehicles = 0;
	 	HighestVID = 0;
		new string[128];
		format(string,128,"Administrator %s destroyed all vehicles.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdestroyallobjects(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XDESTROYALLOBJECTS");
		new i;
		for(new x; x < 255; x++)
		{
			DestroyObject(x);
 			foreachex(Player,i)DestroyPlayerObject(i,x);
	 	}
		new string[128];
		format(string,128,"Administrator %s destroyed all objects.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdestroyallpickups(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XDESTROYALLPICKUPS");
		for(new x; x < 400; x++)DestroyPickupEx(x);
		new string[128];
		format(string,128,"Administrator %s destroyed all pickups.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xfslap(playerid,params[])
{
	if(IsCmdLvl(playerid,3))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XFSLAP <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to freeze-slap that player.");
		    SendCommandMessageToAdmins(playerid,"XFSLAP");
		    new string[128],Float:x,Float:y,Float:z;
		    format(string,128,"You have freeze-slapped Player %s.",RealName[id]);
			SendClientMessage(playerid,Colors[0],string);
			GetPlayerPos(id, x, y, z);
			TogglePlayerControllable(id,false);
			return SetPlayerPos(id, x, y, z+10);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot freeze-slap a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xskydive(playerid,params[])
{
    if(IsCmdLvl(playerid,1))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XSKYDIVE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to skydive that player.");
		    SendCommandMessageToAdmins(playerid,"XSKYDIVE");
		    new string[128];
		    format(string,128,"Administrator %s has skydived player %s.",RealName[playerid],RealName[id]);
		    if(id != playerid) SendClientMessageToAll(Colors[0],string); else SendClientMessage(playerid,Colors[0],"You have skydived yourself.");
			new Float:Health, Float:x, Float:y, Float:z; GetPlayerHealth(id,Health);
   			GetPlayerPos(playerid, x, y, z);
   			GivePlayerWeapon(playerid,46,1);
			return SetPlayerPos(playerid, x, y, z + 750);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xcp(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XCP <SIZE>");
		new string[128];
		new Float:pX,Float:pY,Float:pZ;
		SendCommandMessageToAdmins(playerid,"XCP");
        format(string,128,"Administrator %s created a checkpoint.(size %d)",RealName[playerid],strval(params));
		foreach(Player,i)SetPlayerCheckpoint(i,pX,pY,pZ,strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xracecp(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    new Float:pX,Float:pY,Float:pZ;
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XRACECP <TYPE> <SIZE>");
		SendCommandMessageToAdmins(playerid,"XRACECP");
		new string[128],Hour,Minute;
        format(string,128,"Administrator %s created a race checkpoint (type %s, size %s).",RealName[playerid],Hour,Minute);
        GetPlayerPos(playerid,pX,pY,pZ);
		foreach(Player,i)SetPlayerRaceCheckpoint(i,strval(tmp),pX,pY,pZ,pX,pY,pZ,strval(tmp2));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}
dcmd_xcpoff(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,1))
	{
	    SendCommandMessageToAdmins(playerid,"XCPOFF");
	    foreach(Player,i)DisablePlayerCheckpoint(i);
		new string[128];
		format(string,128,"Administrator %s disabled the checkpoint.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xracecpoff(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,1))
	{
	    SendCommandMessageToAdmins(playerid,"XRACECPOFF");
	    foreach(Player,i)DisablePlayerRaceCheckpoint(i);
		new string[128];
		format(string,128,"Administrator %s disabled the checkpoint.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

/*dcmd_xrespawncars(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,4))
	{
		SendCommandMessageToAdmins(playerid,"XRESPAWNCARS");
		for(new x; x < MAX_SERVER_VEHICLES; x++)
		{
 			SetVehicleToRespawn(x);
	 	}
		new string[128];
		format(string,128,"Administrator %s respawned all vehicles.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}*/

dcmd_xcc(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,1))
	{
		SendCommandMessageToAdmins(playerid,"XCC");
		for(new a; a < 50; a++)
		{
 			foreach(Player,i)SendClientMessageToAll(Colors[0],"\n");
	 	}
		new string[128];
		format(string,128,"Administrator %s cleared the chat.",RealName[playerid]);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xbound(playerid,params[])
{
    if(IsCmdLvl(playerid,3))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XBOUND <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to bound that player.");
		    SendCommandMessageToAdmins(playerid,"XBOUND");
		    new string[128];
		    format(string,128,"Admin Chat: Administrator %s has bounded player %s.",RealName[playerid],RealName[id]);
		    if(id != playerid) SendClientMessageToAll(Colors[0],string);
			else SendClientMessage(playerid,Colors[0],"You have bounded yourself.");
			new Float:x, Float:y, Float:z;
   			GetPlayerPos(playerid, x, y, z);
			return SetPlayerWorldBounds(playerid, x+15, y-15, x+15, y-15);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot bound a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xann(playerid,params[])
{
    if(IsCmdLvl(playerid,1))
	{
        SendCommandMessageToAdmins(playerid,"XANN");
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XANN <TEXT>.");
		new string[128];
		format(string,128,"Admin %s~w~: ~n~%s",RealName[playerid],params);
		return GameTextForAll(string,8000,3);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xunbound(playerid,params[])
{
    if(IsCmdLvl(playerid,1))
	{
   		if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XUNBOUND <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID)
		{
		    SendCommandMessageToAdmins(playerid,"XUNBOUND");
		    new string[128];
		    format(string,128,"Admin Chat: Administrator %s has unbounded player %s.",RealName[playerid],RealName[id]);
		    if(id != playerid) SendClientMessageToAll(Colors[0],string);
			else SendClientMessage(playerid,Colors[0],"You have unbounded yourself.");
			return SetPlayerWorldBounds(playerid,20000.000,-20000.000,20000.000,-20000.000);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot unbound a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xcobject(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XCOBJECT <MODEL>");
		new string[128];
		new Float:pX,Float:pY,Float:pZ;
		SendCommandMessageToAdmins(playerid,"XCOBJECT");
        format(string,128,"Administrator %s created an object.(model %d)",RealName[playerid],strval(params));
		foreach(Player,i)CreateObject(strval(params),pX+5,pY,pZ,0,0,0);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdobject(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XDOBJECT <OBJECT ID>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XDOBJECT");
        format(string,128,"Administrator %s destroyed an object.(object %d)",RealName[playerid],strval(params));
		DestroyObject(strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xcpickup(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    new tmp[128],tmp2[128],Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    new Float:pX,Float:pY,Float:pZ;
	    if(!strlen(tmp)||!strlen(tmp2)||!IsNumeric(tmp)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XCPICKUP <MODEL> <TYPE>");
		SendCommandMessageToAdmins(playerid,"XCPICKUP");
		new string[128];
        format(string,128,"Administrator %s created a pickup (type:%d  model:%d).",RealName[playerid],strval(tmp),strval(tmp2));
        GetPlayerPos(playerid,pX,pY,pZ);
		CreatePickup(strval(tmp),strval(tmp2),pX+2,pY,pZ);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdpickup(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XDPICKUP <PICKUP ID>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XDPICKUP");
        format(string,128,"Administrator %s destroyed a pickup.(pickup %d)",RealName[playerid],strval(params));
		DestroyPickup(strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdcar(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)||!IsNumeric(params))
		{
			if(!IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,Colors[2],"Error: /XDCAR <PICKUP ID>");
			else return DestroyVehicleEx(GetPlayerVehicleID(playerid));
		}
		new string[128];
		SendCommandMessageToAdmins(playerid,"XDCAR");
        format(string,128,"Administrator %s destroyed vehicle %d",RealName[playerid],strval(params));
		DestroyVehicleEx(strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xaddpart(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    new tmp2[128],Index; tmp2 = strtok(params,Index);
	    if(!strlen(tmp2)||!IsNumeric(tmp2)) return SendClientMessage(playerid,Colors[2],"Error: /XADDPART <PART ID>");
		if(!IsPartValid(strval(tmp2))) return SendClientMessage(playerid,Colors[2],"Error: Invalid part ID.");
		new string[128];
   		SendCommandMessageToAdmins(playerid,"XADDPART");
		format(string,128,"You added part %d to your vehicle.",strval(tmp2));
		SendClientMessage(playerid,Colors[0],string);
		return AddVehicleComponent(GetPlayerVehicleID(playerid),strval(tmp2));
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xrempart(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XREMPART <PART ID>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XREMPART");
        format(string,128,"Administrator %s removed part %d from his vehicle.",RealName[playerid],strval(params));
		RemoveVehicleComponent(GetPlayerVehicleID(playerid),strval(params));
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xrape(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XRAPE <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to rape that player.");
			SendCommandMessageToAdmins(playerid,"XRAPE");
		    new string[128];
		    format(string,128,"You have RAPED Player %s.",RealName[id]);
			SendClientMessage(playerid,Colors[0],string);
			return SetPlayerPos(id,cellmax,cellmax,cellmax);
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot rape yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xmolest(playerid,params[])
{
	if(IsCmdLvl(playerid,6))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XMOLEST <NICK OR ID>");
   		new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to molest that player.");
		    SendCommandMessageToAdmins(playerid,"XMOLEST");
		    new string[128],Float:CD[3]; GetPlayerPos(id,CD[0],CD[1],CD[2]);
		    format(string,128,"You have MOLESTED Player %s.",RealName[id]); SendClientMessage(playerid,Colors[0],string);
			for(new i = 0; i < 255; i++)
			{
				CreatePlayerObject(id,300,CD[0],CD[1],CD[2]+(float(i)/10.0),0.0,0.0,0.0);
			}
			return 1;
		}
		else return SendClientMessage(playerid,Colors[2],"Error: You cannot moleste yourself or a disconnected player.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xplaysound(playerid,params[])
{
	if(IsCmdLvl(playerid,5))
	{
	    if(!strlen(params)||!IsNumeric(params)) return SendClientMessage(playerid,Colors[2],"Error: /XPLAYSOUND <SOUND ID>");
		new string[128];
		SendCommandMessageToAdmins(playerid,"XPLAYSOUND");
        format(string,128,"Administrator %s played sound %d.",RealName[playerid],strval(params));
        new Float:pX,Float:pY,Float:pZ;GetPlayerPos(playerid,pX,pY,pZ);
		foreach(Player,i)PlayerPlaySound(i,strval(params),pX,pY,pZ+1);
		return SendClientMessageToAll(Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xexplodeall(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,6))
	{
	    new Float:pX,Float:pY,Float:pZ;
	    SendCommandMessageToAdmins(playerid,"XEXPLODEALL");
	    foreach(Player,i)
	    {
			GetPlayerPos(i,pX,pY,pZ);
			CreateExplosion(pX,pY,pZ,12,0);
		}
		new string[128];
		format(string,128,"Administrator %s exploded everyone.",RealName[playerid]);
		return SendClientMessage(playerid,Colors[0],string);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xadmins(playerid,params[])
{
	#pragma unused params
	new string[128],amt;
	string = "Admins: ";
	if(IsPlayerAdmin(playerid) || Variables[playerid][Level] > 6)
	{
		foreach(Player,i)
  		{
    	 	if(Variables[i][Level] < 12 && Variables[i][Level] > 0)
    	 	{
    	 	    format(string,128,"%s  %s(%d)",string,RealName[i],Variables[i][Level]);
    	 	    amt++;
			}
   		}
	}
	else
	{
	    foreach(Player,i)
  		{
    	 	if(Variables[i][Level] < 12 && Variables[i][Level] > 0)
    	 	{
    	 	    format(string,128,"%s  %s",string,RealName[i]);
    	 	    amt++;
			}
   		}
	}
   	if(amt > 0)return SendClientMessage(playerid,Colors[1],string);
   	else return SendClientMessage(playerid,Colors[1],"No admins online.");
}

dcmd_xcommands(playerid,params[])
{
    #pragma unused params
	if(Variables[playerid][Level] >= 0)
	{
	     SendClientMessage(playerid,Colors[0],">> LEVEL+0: xregister, xlogin, xlogout, xcommands, xpaint, xadmins");
	}
	if(Variables[playerid][Level] >= 1)
	{
	     SendClientMessage(playerid,Colors[0],">> LEVEL+1: xsay, xflip");
	}
    if(Variables[playerid][Level] >= 2)
    {
         SendClientMessage(playerid,Colors[0],">> LEVEL+2: xannounce, xslap, xann, xvr, xunbound");
    }
    if(Variables[playerid][Level] >= 3)
	{
	     SendClientMessage(playerid,Colors[0],">> LEVEL+3: xgoto, xbring, xmute, xunmute, xkick, xakill, xdisarm, xgivegun, xresetscores, xsetskin");
         SendClientMessage(playerid,Colors[0],">> LEVEL+3: xsetcash, xgivecash, xresetcash, xsetcashall, xsetcashall, xgivecashall, xcar, xsetarmor, xarmorall, xcarhealth");
         SendClientMessage(playerid,Colors[0],">> LEVEL+3: xskydive, xcp, xdcar, xint, xgotov, xenterv");
 	}
    if(Variables[playerid][Level] >= 4)
    {
         SendClientMessage(playerid,Colors[0],">> LEVEL+4: xeject, xfreeze, xunfreeze, xsetint, xhealall, xsethealth, xdisarmall, xejectall, xfreezeall, xunfreezeall, xweather");
         SendClientMessage(playerid,Colors[0],">> LEVEL+4: xsettime, xsetscore, xip, xexoplode, xsetwanted, xsetwantedall, xsetworld, xsetworldall, xslapall, xkickall, xunlockall");
         SendClientMessage(playerid,Colors[0],">> LEVEL+4: xracecp, xcpoff, xracecpoff, xrespawncars, xcc, xdr xban");
    }
	if(Variables[playerid][Level] >= 5)
	{
	    SendClientMessage(playerid,Colors[0],">> LEVEL+5: xsetintall, xsetintall, xrestoreall, xskinall, xgunall, xgod, xgodall, xweatherall, xsettimeall, xforce, xkillall");
	    SendClientMessage(playerid,Colors[0],">> LEVEL+5: xbringall, xejectall, xdestroyallobjects, xdestroyallpickups, xdobject, xaddpart, xrempart, xplaysound, xmi, xrap, xunos");
	}
    if(Variables[playerid][Level] >= 6)
    {
        SendClientMessage(playerid,Colors[0],">> LEVEL+6: xfslapall, xfslap, xskydiveall, xkickall, xunboundall, xdestroyallcars, xbound, xunbound, xexplodeall, xrcon, xmovexy, xmovez, xmolest");
    }
	return 1;
}

dcmd_xvr(playerid,params[])
{
	#pragma unused params
	if(IsCmdLvl(playerid,1))
	{
    	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,Colors[2],"Error: You must be in a vehicle to repair.");
		SetVehicleHealth(GetPlayerVehicleID(playerid),v_Health[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
		return SendClientMessage(playerid,Colors[0],"You have repaired your vehicle.");
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xdr(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
		new tmp[128],reason,id,id2,Index;
		tmp = strtok(params,Index);reason = strval(tmp);
		if(!reason)return SendClientMessage(playerid,Colors[2],"Error: /XDR <REASON> <KILLERID> <PLAYERID>");
		tmp = strtok(params,Index); id = strval(tmp);
		if(!IsPlayerConnected(id))return SendClientMessage(playerid,Colors[2],"Error: /XDR <REASON> <KILLERID> <PLAYERID>");
		tmp = strtok(params,Index); id2 = strval(tmp);
		if(!IsPlayerConnected(id))return SendClientMessage(playerid,Colors[2],"Error: /XDR <REASON> <KILLERID> <PLAYERID>");
		SendCommandMessageToAdmins(playerid,"XDR");
		SendDeathMessage(id,id2,reason);
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}
dcmd_xrcon(playerid,params[])
{
    if(IsCmdLvl(playerid,6))
	{
        SendCommandMessageToAdmins(playerid,"XRCON");
    	if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XRCON <COMMAND>");
		return SendRconCommand(params);
    }
	else return SendLevelErrorMessage(playerid);
}

dcmd_xspoof(playerid,params[])
{
	if(IsCmdLvl(playerid,6))
	{
	    if(!strlen(params))return SendClientMessage(playerid,Colors[2],"Error: /XSPOOF <PLAYERID> <TEXT>");
		new tmp[128],Index;
		tmp = strtok(params,Index);
		new id = ReturnPlayerID(tmp,strval(tmp));
		if(!IsPlayerConnected(id) || id == playerid)return SendClientMessage(playerid,Colors[2],"Error: /XSPOOF <PLAYERID> <TEXT>");
		if(Variables[playerid][Level] < Variables[id][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to spoof that player.");
		SendCommandMessageToAdmins(playerid,"XSPOOF");
		SendPlayerMessageToAll(id,params[strlen(tmp)+1]);
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}

dcmd_xpm(playerid,params[])
{
	if(IsCmdLvl(playerid,6))
	{
	    if(!strlen(params))return SendClientMessage(playerid,Colors[2],"Error: /XPM <FROM ID> <TO ID> <MESSAGE>");
		new tmp[128],Index,string[128];
		tmp = strtok(params,Index);
		new fromid = ReturnPlayerID(tmp,strval(tmp));
		if(!IsPlayerConnected(fromid) || fromid == playerid)return SendClientMessage(playerid,Colors[2],"Error: /XPM <FROM ID> <TO ID> <MESSAGE>");
        tmp = strtok(params,Index);
		new toid = ReturnPlayerID(tmp,strval(tmp));
		if(!IsPlayerConnected(toid) || toid == playerid)return SendClientMessage(playerid,Colors[2],"Error: /XPM <FROM ID> <TO ID> <MESSAGE>");
		if(Variables[playerid][Level] < Variables[fromid][Level])return SendClientMessage(playerid,Colors[2],"Error: You do not have permission to fake-pm that player.");
		SendCommandMessageToAdmins(playerid,"XPM");
		
    	foreach(Player,i)
		{
			if(ShowPMs[i] == true && i != fromid && i != toid)
			{
				format(string,sizeof(string),"*** [FAKE PM]  %s(%d) to %s(%d): %s",NickName[fromid],fromid,NickName[toid],toid,params[strlen(tmp)+2]);
				SendClientMessage(i,PM_COLOR,string);
		    }
		}
		format(string,sizeof(string),"FAKE PM sent to %s(%d): %s",NickName[toid],toid,params[strlen(tmp)+2]);
		SendClientMessage(playerid,MainColors[0],params[strlen(tmp)+2]);
		format(string,sizeof(string),"PM from %s(%d): %s",NickName[fromid],fromid,params[strlen(tmp)+2]);
		SendClientMessage(toid,MainColors[0],params[strlen(tmp)+2]);
		PlayerPlaySound(toid,1139,0.0,0.0,0.0);
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}

dcmd_saveloc(playerid,params[])
{
    #pragma unused params
	if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're in a round.");
    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
    if(gSpectating[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're spectating.");
	GetPlayerPos(playerid,Loc[0][playerid],Loc[1][playerid],Loc[2][playerid]);
	GetPlayerFacingAngle(playerid,Loc[3][playerid]);
	return SendClientMessage(playerid,Colors[0],"Location Saved");
}

dcmd_gotoloc(playerid,params[])
{
	#pragma unused params
    if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're in a round.");
    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
    if(gSpectating[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're spectating.");
 	SetPlayerPos(playerid,Loc[0][playerid],Loc[1][playerid],Loc[2][playerid]);
	SetPlayerFacingAngle(playerid,Loc[3][playerid]);
	return 1;
}

dcmd_xmovexy(playerid,params[])
{
	if(IsCmdLvl(playerid,6))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XMOVEXY <DISTANCE>");
		new dist = strval(params);
		SendCommandMessageToAdmins(playerid,"XMOVEXY");
		new Float:X,Float:Y,Float:Z;GetPlayerPos(playerid,X,Y,Z);
		SetPlayerPos(playerid,X+dist,Y,Z);
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}

dcmd_xmovez(playerid,params[])
{
	if(IsCmdLvl(playerid,1))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XMOVEZ <DISTANCE>");
		new dist = strval(params);
        SendCommandMessageToAdmins(playerid,"XMOVEZ");
		new Float:X,Float:Y,Float:Z;
		GetPlayerPos(playerid,X,Y,Z);
		return SetPlayerPos(playerid,X,Y,Z+dist);
	}
	else return SendLevelErrorMessage(playerid);
}

dcmd_xgotov(playerid,params[])
{
	if(IsCmdLvl(playerid,6))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XGOTOV <VEHICLE ID>");
    	new id = strval(params);
	    new Float:X,Float:Y,Float:Z;GetVehiclePos(id,X,Y,Z);
     	foreach(Player,i)
 		{
		 	if(GetPlayerVehicleID(i) == id && GetPlayerState(i) != PLAYER_STATE_DRIVER)
		 	{
			 	PutPlayerInVehicle(playerid,id,0);
			 	return SendCommandMessageToAdmins(playerid,"XGOTOV");
	 		}
		 	else
		 	{
			 	SetPlayerPos(playerid,X+0.5,Y+0.5,Z+2);
			 	return SendCommandMessageToAdmins(playerid,"XGOTOV");
		 	}
 		}
	}
	else return SendLevelErrorMessage(playerid);
	return 1;
}

dcmd_xenterv(playerid,params[])
{
	if(IsCmdLvl(playerid,4))
	{
	    if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XENTERV <NICK OR ID>");
        new id = ReturnPlayerID(params,strval(params));
		if(IsPlayerConnected(id) && id != INVALID_PLAYER_ID && id != playerid)
		{
		    if(!IsPlayerInAnyVehicle(id) || GetPlayerState(id) != PLAYER_STATE_DRIVER)return 1;
			PutPlayerInVehicle(playerid,GetPlayerVehicleID(id),1);
			return SendCommandMessageToAdmins(playerid,"XENTERV");
  		}
  		else return SendClientMessage(playerid,Colors[2],"Error: You cannot enter your own vehicle or a disconnected player's vehicle.");
	}
	else return SendLevelErrorMessage(playerid);
}

/*dcmd_xips(playerid,params[])
{
	#pragma unused params
	SendClientMessage(playerid,Colors[2],"This command is disabled");
	return 1;
	if(!IsCmdLvl(playerid,5)) return SendLevelErrorMessage(playerid);
	if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: A player name is required.");
	if(!dini_Isset("/xadmin/PlayerIPs.ini",params)) return SendClientMessage(playerid,Colors[2],"Error: Player not found");
	new playerips[1024],string[128],stramt;
	format(string,sizeof(string),"*** %s's IPs:",params);
	SendClientMessage(playerid,Colors[0],string);
	playerips = dini_Get("/xadmin/PlayerIPs.ini",params);
	printf("len = %d",strlen(playerips));
	if(strlen(playerips) > 128)
	{
		stramt = floatround(float(strlen(playerips)) / 128.0);
		printf("stramt = %d",stramt);
		stramt++;
		new start;
		for(new i; i < stramt; i++)
		{
			strmid(string,playerips,start,start+128,128);
			start += 128;
			SendClientMessage(playerid,Colors[0],string);
		}
	}
	else
	{
    	format(string,sizeof(string),"%s",dini_Get("/xadmin/PlayerIPs.ini",params));
    	SendClientMessage(playerid,Colors[0],string);
	}
	return 1;
}

dcmd_xmatch(playerid,params[])
{
	if(!IsCmdLvl(playerid,5)) return SendLevelErrorMessage(playerid);
	if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: A player ID/Name is required.");
	if(IsNumeric(params) && strval(params) <= HighestID)
	{
	    if(!IsPlayerConnected(strval(params))) return SendClientMessage(playerid,Colors[2],"Error: Player not connected");
	    new IP[20];GetPlayerIp(strval(params),IP,20);
		if(!dini_Isset("/xadmin/IPplayers.ini",IP))return SendClientMessage(playerid,Colors[2],"Error: No matches found");
		new string[256];format(string,sizeof(string),"Matches for %s(ID %d): %s",RealName[strval(params)],strval(params),dini_Get("/xadmin/IPplayers.ini",IP));
		SendClientMessage(playerid,Colors[0],string);
	}
	else
	{
	    if(!dini_Isset("/xadmin/IPplayers.ini",params))return SendClientMessage(playerid,Colors[2],"Error: No matches found");
		new string[128];format(string,sizeof(string),"Matches for %s: %s",params,dini_Get("/xadmin/IPplayers.ini",params));
		SendClientMessage(playerid,Colors[0],string);
	}
	return 1;
}*/

dcmd_xpaint(playerid,params[])
{
    if(IsCmdLvl(playerid,0))
	{
        SendCommandMessageToAdmins(playerid,"XPAINT");
    	if(!strlen(params)) return SendClientMessage(playerid,Colors[2],"Error: /XPAINT <PAINTJOB ID>");
		return ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),strval(params));
    }
	else return SendLevelErrorMessage(playerid);
}

dcmd_xunos(playerid,params[])
{
	#pragma unused params
    if(!IsCmdLvl(playerid,5))return SendLevelErrorMessage(playerid);
    if(unos[playerid] == false){SendClientMessage(playerid,0xFFFFFFFF,"unos on");unos[playerid] = true;}
    else{SendClientMessage(playerid,0xFFFFFFFF,"unos off");unos[playerid] = false;}
	return 1;
}

dcmd_xshowpms(playerid,params[])
{
    #pragma unused params
	if(!IsCmdLvl(playerid,6))return SendLevelErrorMessage(playerid);
	if(ShowPMs[playerid] == false){SendClientMessage(playerid,0xFFFFFFFF,"ShowPMs on");ShowPMs[playerid] = true;}
    else{SendClientMessage(playerid,0xFFFFFFFF,"ShowPMs off");ShowPMs[playerid] = false;}
    return 1;
}

dcmd_xshowcmds(playerid,params[])
{
	#pragma unused params
	if(!IsCmdLvl(playerid,6))return SendLevelErrorMessage(playerid);
	if(ShowCommands[playerid] == false){SendClientMessage(playerid,0xFFFFFFFF,"ShowCommands on");ShowCommands[playerid] = true;}
    else{SendClientMessage(playerid,0xFFFFFFFF,"ShowCommands off");ShowCommands[playerid] = false;}
    return 1;
}

//------------------------------------------------------------------------------

dcmd_ss(playerid,params[])
{
	if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /ss [comment]");
	SaveSelectionScreen(playerid,params);
	//SaveMOTDLoc(playerid,params);
	return 1;
}

dcmd_testcolor(playerid,params[])
{
	//if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0] && Current != -1){return DenyPlayer(playerid);}
	if(!strlen(params) || strlen(params) != 10)return SendClientMessage(playerid,MainColors[1],"Usage: /testcolor [color in hex (ex: 0xFFFFFFFF)]");
	SetPlayerColorEx(playerid,HexToInt(params));
	SetTimerEx("ReSetPlayerColorEx",10000,0,"i",playerid);
	return 1;
}
	
	dcmd_info(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0] && Current != -1){return DenyPlayer(playerid);}
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /info [playerid]");
	    new pid = strval(params);
	    if(!IsPlayerConnected(pid))return SendClientMessage(playerid,MainColors[2],"Invalid player ID.");
	    new string[128],Float:Health,Float:ARM;
	    GetPlayerHealth(pid,Health);
	    GetPlayerArmour(pid,ARM);
	    format(string,128,"*** Info on %s: Health: %.0f | Armor: %.0f | Skin: %d | Team: %s (ID %d)",RealName[pid],Health,ARM,GetPlayerSkin(pid),TeamName[gTeam[pid]],gTeam[pid]);
	    SendClientMessage(playerid,MainColors[3],string);
	    format(string,128,"*** Weapons: %s",DisplayInfoWeapons(pid));
		SendClientMessage(playerid,MainColors[3],string);
	    return 1;
	}
	
	dcmd_delacc(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[2]){return DenyPlayer(playerid);}
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /delacc [account name]");
		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(params));
		if(!fexist(file))return SendClientMessage(playerid,MainColors[2],"No account found by that name");
		new id = FindIDFromName(params);
	    if(IsPlayerConnected(id))return SendClientMessage(playerid,MainColors[2],"Error: Use /resetacc to delete a connected player's account");
		dini_Remove(file);
		format(file,sizeof(file),"%s's account was deleted successfully",params);
		SendClientMessage(playerid,MainColors[3],file);
		dini_IntSet(ServerFile(),"Accounts",dini_Int(ServerFile(),"Accounts") - 1);
	    return 1;
	}
	
	dcmd_resetacc(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[2]){return DenyPlayer(playerid);}
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /resetacc [account name]");
		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(params));
		if(!fexist(file))return SendClientMessage(playerid,MainColors[2],"No account found by that name");
		CreateProfileII(params,dini_Get(file,"IP"));
		format(file,sizeof(file),"%s's account was reset successfully",params);
		SendClientMessage(playerid,MainColors[3],file);
	    return 1;
	}
	
	dcmd_vcolor(playerid,params[])
	{
	    new c1,c2,file[64],tmp[128],idx;
	    format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		tmp = strtok_(params, idx);c1 = strval(tmp);dini_IntSet(file,"vColor1",c1);vColor[0][playerid] = c1;
		tmp = strtok_(params, idx);c2 = strval(tmp);dini_IntSet(file,"vColor2",c2);vColor[1][playerid] = c2;
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			ChangeVehicleColor(GetPlayerVehicleID(playerid),c1,c2);
			PlayerPlaySound(playerid,1134,0.0,0.0,0.0);
		}
		return 1;
	}

	dcmd_teams(playerid,params[])
	{
	    #pragma unused params
	    new string[128],count;
		format(string,128,"*** Main Teams  ||  \"%s\" (%s): %d  ||  \"%s\" (%s): %d  ||  \"%s\"",TeamName[T_HOME],TeamStatusStr[T_HOME],CurrentPlayers[T_HOME],TeamName[T_AWAY],TeamStatusStr[T_AWAY],CurrentPlayers[T_AWAY],NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		
		string = "*** Other Teams";
		for(new i = 2; i < ACTIVE_TEAMS; i++)
		{
		    if(CurrentPlayers[i] > 0)
		    {
		        format(string,128,"%s  ||  \"%s\" %d",string,TeamName[i],CurrentPlayers[i]);
		        count++;
		    }
		}
		if(count > 0)SendClientMessageToAll(MainColors[0],string);
		
	    return 1;
	}

	dcmd_spawn(playerid,params[])
	{
	    if(strlen(params) == 0 && gSelectingClass[playerid] == true && ViewingMOTD[playerid] == false)
		{
			SpawnPlayer(playerid);
			ForceClassSelection(playerid);
			return 1;
		}
		if(ViewingResults[playerid] == true)return 1;
		new gunid[10],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1],"Usage: /spawn [set, reset, deathspot]");
		strmid(gunid, tmp, 0, strlen(params), 128);
		new file[64];
  		format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		if (strcmp(gunid,"set", true, strlen(gunid)) == 0)
		{
			GetPlayerPos(playerid,mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid]);
			mSpawn[4][playerid] = GetPlayerInterior(playerid);
			GetPlayerFacingAngle(playerid,mSpawn[3][playerid]);
			dini_IntSet(file,"SetSpawn",1);
			SetSpawn[playerid] = 1;
			FindPlayerSpawn(playerid,1);
			format(tmp,128,"SPAWN: You will now spawn at: %.4f, %.4f, %.4f, %.4f - Interior %.0f",mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid],mSpawn[3][playerid],mSpawn[4][playerid]);
			SendClientMessage(playerid,MainColors[3],tmp);
			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
			format(tmp,sizeof(tmp),"%.3f,%.3f,%.3f,%.3f,%.0f",mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid],mSpawn[3][playerid],mSpawn[4][playerid]);
			dini_Set(file,"mSpawn",tmp);
		}
		else if (strcmp(gunid,"reset", true, strlen(gunid)) == 0)
		{
			SetSpawn[playerid] = 0;
			mSpawn[4][playerid] = 0;
			FindPlayerSpawn(playerid,1);
			dini_IntSet(file,"SetSpawn",0);
			SendClientMessage(playerid,MainColors[3],"SPAWN: You will now spawn at the atrium");
			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		}
		else if (strcmp(gunid,"deathspot", true, strlen(gunid)) == 0)
		{
			SetSpawn[playerid] = 2;
			dini_IntSet(file,"SetSpawn",2);
			GetPlayerPos(playerid,mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid]);
			mSpawn[4][playerid] = GetPlayerInterior(playerid);
			GetPlayerFacingAngle(playerid,mSpawn[3][playerid]);
			SendClientMessage(playerid,MainColors[3],"SPAWN: You will now spawn where you die");
			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  			format(tmp,sizeof(tmp),"%.3f,%.3f,%.3f,%.3f,%.0f",mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid],mSpawn[3][playerid],mSpawn[4][playerid]);
			dini_Set(file,"mSpawn",tmp);
		}
		return 1;
	}

	dcmd_scores(playerid,params[])
	{
	    #pragma unused params
	    new string[128];
		format(string,128,"*** Current Scores  ||  Team:\"%s\" Wins: %d  ||  Team:\"%s\" Wins: %d  ||  \"%s\"",TeamName[T_HOME],TeamRoundsWon[T_HOME],TeamName[T_AWAY],TeamRoundsWon[T_AWAY],NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
	    return 1;
	}

	dcmd_hide(playerid,params[])
	{
	    #pragma unused params
	    if(Current != -1){HideAllTextDraws(playerid);}
	    else
	    {
	        new i;
	        for(i = 0; i < ACTIVE_TEAMS; i++){TextDrawHideForPlayer(playerid, gFinalText4[i]);TextDrawHideForPlayer(playerid, gFinalText3[i]);TextDrawHideForPlayer(playerid, gFinalText2[i]);TextDrawHideForPlayer(playerid, gFinalText1[i]);}
	        for(i = 0; i < MAIN_TEXT; i++){TD_HideMainTextForPlayer(playerid,i);}
    		for(i = 0; i < TOP_SHOTTA; i++){TextDrawHideForPlayer(playerid,TopShotta[i]);}
    		for(i = 0; i < PTEXT; i++)
    		{
    		    if(i == 14)continue;
    	    	TD_HidepTextForPlayer(playerid,playerid,i);
			}
    	}
	    return 1;
	}

	dcmd_worldpass(playerid,params[])
	{
	    new string[128],tmp[32],idx;
	    tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid,MainColors[2],"Usage: /worldpass [password]");
  		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		format(string,sizeof(string),"Your world password has been set to \"%s\", don't forget it.",tmp);
		SendClientMessage(playerid,MainColors[3],string);
		SendClientMessage(playerid,MainColors[3],"Remove your world password by typing \"/worldpass off\"");
        WorldPass[playerid] = tmp;
		return 1;
	}

	dcmd_world(playerid,params[])
	{
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /world [join, leave, players, kick]");
	    new string[128],gunid[16],tmp[128],idx,tmpworld;
	    tmp = strtok_(params, idx);
		strmid(gunid, tmp, 0, strlen(params), 128);
		if(strcmp(gunid,"players", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))
			{
			    if(PlayerWorld[playerid] >= 0)
				{
		    		DisplayPlayersInWorld(playerid,PlayerWorld[playerid]);
					return 1;
				}
				return 1;
			}
		    tmpworld = strval(tmp);
            if(!IsPlayerConnected(tmpworld))return SendClientMessage(playerid,MainColors[2],"Invalid world ID.");
		    DisplayPlayersInWorld(playerid,tmpworld);
		    return 1;
		}
		else if(strcmp(gunid,"join", true, strlen(gunid)) == 0)
		{
			if(Playing[playerid] == true)return 1;
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))return 1;
		    tmpworld = strval(tmp);
            if(!IsPlayerConnected(tmpworld))return SendClientMessage(playerid,MainColors[2],"Invalid world ID.");
	    	if(tmpworld == playerid)
	    	{
	        	PlayerWorld[playerid] = tmpworld;
    			SetPlayerVirtualWorld(playerid,PlayerWorld[playerid]+MAX_SERVER_PLAYERS);
    			format(string,sizeof(string),"Entered your world (%d)",tmpworld);
		    	SendClientMessage(playerid,MainColors[3],string);
		    	return 1;
	    	}
	    	if(strcmp(WorldPass[tmpworld],"off",false))
	    	{
	    		tmp = strtok_(params, idx);
				if(!strlen(tmp))
				{
		    		SendClientMessage(playerid,MainColors[2],"This world requires a password.");
		    		SendClientMessage(playerid,MainColors[2],"Usage: /world join [world id] [password]");
		    		return 1;
				}
				if(!strcmp(WorldPass[tmpworld],tmp,true,strlen(WorldPass[tmpworld])))
 				{
 		    		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
 		    		format(string,sizeof(string),"Password Accepted! (%s)",tmp);
					SendClientMessage(playerid,MainColors[3],string);
					PlayerWorld[playerid] = tmpworld;
		    		SetPlayerVirtualWorld(playerid ,PlayerWorld[playerid]+MAX_SERVER_PLAYERS);
		    		format(string,sizeof(string),"Entered World %d",tmpworld);
		    		SendClientMessage(playerid,MainColors[3],string);
		    		format(string,sizeof(string),"*** WORLD: %s has entered the world.",NickName[playerid]);
					SendWorldMessage(tmpworld,string);
		    		return 1;
 				}
 				else
		 		{
				 	SendClientMessage(playerid,MainColors[2],"Incorrect password.");
				 	return 1;
				}
			}
  			PlayerWorld[playerid] = tmpworld;
		   	SetPlayerVirtualWorld(playerid,PlayerWorld[playerid]+MAX_SERVER_PLAYERS);
		   	format(string,sizeof(string),"Entered World %d",tmpworld);
		   	SendClientMessage(playerid,MainColors[3],string);
		   	format(string,sizeof(string),"*** WORLD: %s has entered the world.",NickName[playerid]);
			SendWorldMessage(tmpworld,string);
		}
		else if(strcmp(gunid,"leave", true, strlen(gunid)) == 0)
		{
		    if(Playing[playerid] == true)return 1;
            if(PlayerWorld[playerid] >= 0)
		    {
		        format(string,sizeof(string),"*** WORLD: %s has exited the world.",NickName[playerid]);
				SendWorldMessage(PlayerWorld[playerid],string);
				PlayerWorld[playerid] = -1;
		    	SetPlayerVirtualWorld(playerid,0);
		    	SendClientMessage(playerid,MainColors[3],"You are back in the main world");
		    	return 1;
			}
		}
		else if(strcmp(gunid,"kick", true, strlen(gunid)) == 0)
		{
            if(PlayerWorld[playerid] == playerid || IsPlayerAdmin(playerid))
            {
                tmp = strtok_(params, idx);
                new tmpplayer = strval(tmp);
            	if(!IsPlayerConnected(tmpplayer))return SendClientMessage(playerid,MainColors[2],"Player is not connected.");
            	if(PlayerWorld[tmpplayer] == -1)return SendClientMessage(playerid,MainColors[2],"Player is not in a world.");
	    		format(string,sizeof(string),"*** WORLD: %s has exited the world. (Kicked)",NickName[tmpplayer]);
				SendWorldMessage(PlayerWorld[tmpplayer],string);
				PlayerWorld[tmpplayer] = -1;
		    	SetPlayerVirtualWorld(tmpplayer,0);
		    	SendClientMessage(tmpplayer,MainColors[2],"You've been set back to the main world. (Kicked)");
            }
            else SendClientMessage(playerid,MainColors[2],"You are not authorized to use this command");
		}
	    return 1;
	}

	dcmd_int(playerid,params[])
	{
	    if(Playing[playerid] == true)return 1;
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
		new tmp[128],idx;
		tmp = strtok(params, idx);
		new id = strval(tmp);

        if(!strlen(tmp) || id <= 0 || id > 147) { SendClientMessage(playerid,MainColors[1],"Usage: /int [1-147]"); return 1;}
     	if(IsPlayerInAnyVehicle(playerid))
      	{
      	    new vehicleid = GetPlayerVehicleID(playerid);
      	    foreach(Player,i)
      	    {
      	        if(vehicleid == GetPlayerVehicleID(i))
				{
					SetPlayerInterior(i, Interiors[id][int_interior]);
				}
      	    }
			SetVehiclePos(GetPlayerVehicleID(playerid), Interiors[id][int_x], Interiors[id][int_y], Interiors[id][int_z]);
   			SetVehicleZAngle(GetPlayerVehicleID(playerid), 0.0);
        	LinkVehicleToInterior(GetPlayerVehicleID(playerid), Interiors[id][int_interior]);
        	SetCameraBehindPlayerEx(playerid);
        }
       	else
		{
			SetPlayerPos(playerid,Interiors[id][int_x], Interiors[id][int_y], Interiors[id][int_z]);
			SetPlayerFacingAngle(playerid, Interiors[id][int_a]);
			SetPlayerInterior(playerid, Interiors[id][int_interior]);
			SetCameraBehindPlayerEx(playerid);
		}
		new string[128];
		format(string,sizeof(string),"*** \"%s\" has entered interior %d (/int %d)",NickName[playerid],id,id);
 		SendClientMessageToAll(MainColors[0],string);
 		format(string,sizeof(string),"*** Int ID: %d  \"%s\"  Interior: %d",id,Interiors[id][int_name],Interiors[id][int_interior]);
 		SendClientMessage(playerid,0xCCFFFFFF,string);
		return 1;
	}

	dcmd_wlist(playerid,params[])
	{
	    new gunid[16],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid,MainColors[1],"Usage: /wlist ['base' or 'arena']");
		strmid(gunid, tmp, 0, strlen(params), 128);
		if (strcmp(gunid,"base", true, strlen(gunid)) == 0)
		{
		    for(new i = 0; i < 5; i++)
      	    {
      	    	TextDrawHideForPlayer(playerid,WeaponText[i][BASE]);
      	    	TextDrawHideForPlayer(playerid,WeaponText[i][ARENA]);
      	    	TextDrawShowForPlayer(playerid,WeaponText[i][BASE]);
      	    }
		    SetTimerEx("HideWeaponText",15000,0,"ii",playerid,BASE);
		}
		else if (strcmp(gunid,"arena", true, strlen(gunid)) == 0)
		{
		    for(new i = 0; i < 5; i++)
      	    {
      	    	TextDrawHideForPlayer(playerid,WeaponText[i][BASE]);
      	    	TextDrawHideForPlayer(playerid,WeaponText[i][ARENA]);
      	    	TextDrawShowForPlayer(playerid,WeaponText[i][ARENA]);
      	    }
			SetTimerEx("HideWeaponText",15000,0,"ii",playerid,ARENA);
		}
	    return 1;
	}

    dcmd_pass(playerid,params[])
	{
	    new string[128];
		if(!strlen(params))return SendClientMessage(playerid,MainColors[2],"Incorrect password.");
		if(!strcmp(ServerPass,params,true,strlen(ServerPass)))
 		{
 		    SetTimerEx("CreateMOTD",6000,0,"i",playerid);
			//KillFade[playerid] = false;
			FadeIn(playerid,1);
			PlayerPlaySound(playerid,1134,0.0,0.0,0.0);
		
 		    PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
 		    format(string,sizeof(string),"Password Accepted! \"%s\"",params);
			SendClientMessage(playerid,MainColors[3],string);
			CorrectPassword[playerid] = true;

			TD_HidepTextForPlayer(playerid,playerid,4);
 			TextDrawBoxColor(pText[4][playerid],0x00000000);
 			TD_HideMainTextForPlayer(playerid,5);
 		}
 		else SendClientMessage(playerid,MainColors[2],"Incorrect.");
		return 1;
	}

    dcmd_back(playerid,params[])
	{
	    #pragma unused params
	    new string[128];
	    if(AFK[playerid] == false)return SendClientMessage(playerid,MainColors[2],"You are not AFK.");
 		SetPlayerName(playerid,NickName[playerid]);
 		TogglePlayerControllable(playerid,1);
 		SetPlayerColorEx(playerid,TeamActiveColors[2]);
 		AFK[playerid] = false;
 		format(string,sizeof(string),"*** \"%s\" has returned from being AFK",NickName[playerid]);
 		SendClientMessageToAll(MainColors[0],string);
	    return 1;
	}

	dcmd_afk(playerid,params[])
	{
	    #pragma unused params
	    if(IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're in a vehicle.");
		if(IsDueling[playerid] == true || DuelStarting[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(Playing[playerid] == true) return SendClientMessage(playerid,MainColors[2],"Error: You cannot enter AFK mode while active in a round.");
	    new Float:Position[3];
		GetPlayerPos(playerid,Position[0],Position[1],Position[2]);
	    SetTimerEx("SetPlayerAFK",5000,0,"ifff",playerid,Position[0],Position[1],Position[2]);
	    SendClientMessage(playerid,MainColors[3],"Going AFK in 5 seconds...");
		return 1;
	}

	dcmd_switch(playerid,params[])
	{
	    if(IsDueling[playerid] == true || DuelStarting[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(Allowswitch == false) return SendClientMessage(playerid,MainColors[2],"Team switching is disabled.");
	    if(gSpectating[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You must exit spectator mode before using this command.");
	    if(IsPlayerInAnyVehicle(playerid))return 1;
	    if(Playing[playerid] == true)
		{
		    SendClientMessage(playerid, MainColors[2],"You cannot switch teams while you are in a round. Wait until the round ends.");
		    PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    return 1;
		}
		new gunid[16],string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SwitchMenu(playerid);
		strmid(gunid, tmp, 0, strlen(params), 128);
		for(new i; i < MAX_TEAMS; i++)
		{
			if(strcmp(gunid,TeamName[i], true, strlen(gunid)) == 0 && TeamLock[i] == false && TeamUsed[i] == true)
			{
		    	if(i == T_SUB)return SubMenu(playerid);
		    	else if(gTeam[playerid] == i)return 1;
				SetTeam(playerid,i);
            	RespawnPlayerAtPos(playerid,1);
	    		SetPlayerColorEx(playerid,TeamInactiveColors[i]);
	    		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
	    		format(string,sizeof(string),"*** \"%s\" has Switched to Team \"%s\"",NickName[playerid],TeamName[i]);
	    		SendClientMessageToAll(TeamActiveColors[i],string);
	    		UpdatePrefixName(playerid);
	    		return 1;
			}
		}
		SendClientMessage(playerid, MainColors[2], "Invalid team, team is locked, or team is disabled.");
		PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		return 1;
	}
	
    dcmd_fixr(playerid,params[])
	{
		#pragma unused params
		if(!IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,MainColors[2],"Error: You must be in a vehicle");
		FixRadioStart(playerid);
	    return 1;
	}

	dcmd_kill(playerid,params[])
	{
	    #pragma unused params
	    if((ViewingResults[playerid] == true && IsDueling[playerid] == true) || gSpectating[playerid] == true || DuelStarting[playerid] == true)return SendClientMessage(playerid,MainColors[2],"You may not use /kill right now.");
	    if(AllowSuicide[playerid] == false)return 1;
	    if(Playing[playerid] == true)
    	{
    		SetPlayerHealthEx(playerid,0.0);
    		if(ModeType != TDM)
    		{
				RemovePlayingName(playerid);
			}
		}
		else SetPlayerHealthEx(playerid,0.0);
	    return 1;
	}
	
	/*dcmd_sreset(playerid,params[])
	{
	    foreach(Player,i)
		{
		    for(new x; x < S_AMT; x++)
		    {
		        RemovePlayerMapIcon(i,x);
		        DestroyObject(S_OBJ[x]);
			}
		}
	    S_AMT = 0;
	    new File:aFile;aFile = fopen("spawns.pwn", io_append);fwrite(aFile, "\r\n\r\n");fclose(aFile);
	    return 1;
	}*/
	
	dcmd_s(playerid,params[])
	{
	    dcmd_sync(playerid,params);
	    /*S_AMT++;
		new string[128],Float:xx,Float:yy,Float:zz,Float:rr;
		GetPlayerPos(playerid,xx,yy,zz);
		GetPlayerFacingAngle(playerid,rr);
		
		foreach(Player,i)
		{
			SetPlayerMapIcon(i,S_AMT-1,xx,yy,zz,0,0xFF0000FF);
		}
		S_OBJ[S_AMT] = CreateObject(1318,xx,yy,zz,0.0,0.0,0.0);
		format(string,sizeof(string),"\r\n%.2f %.2f %.2f %.2f //%s - %s",xx,yy,zz,rr,RealName[playerid],params);
		new File:aFile;aFile = fopen("spawns.pwn", io_append);fwrite(aFile, string);fclose(aFile);
		printf("%s",string);
		
		format(string,sizeof(string),"*** %s saved a spawn! (#%d) (%s)",RealName[playerid],S_AMT,params);
		SendClientMessageToAll(0xFFFFFFFF,string);*/
	    return 1;
	}

	dcmd_sync(playerid,params[])
	{
	    if(GamePaused == true)return 1;
	    if(IsPlayerInAnyVehicle(playerid) || gSpectating[playerid] == true || ViewingBase[playerid] == 1)return 1;
	    if(ViewingResults[playerid] == true && IsDueling[playerid] == false)return 1;
	    if(AllowSuicide[playerid] == false)return 1;
	    if(DuelSpectating[playerid] != -1)return 1;
	    if(Syncing[playerid] == true)return 1;
	    if(DuelStarting[playerid] == true)return 1;
	    if(strlen(params))
		{
			if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[2])return SendClientMessage(playerid,MainColors[2],"Error: You do not have permission to use a parameter with this command. (use /sync or /s)");
			new tmpplayer = strval(params);
	    	if(!IsPlayerConnected(tmpplayer) || tmpplayer == playerid)return SendClientMessage(playerid,MainColors[2],"Error: Invalid player ID");
	    	if(gPlayerSpawned[tmpplayer] == false)return SendClientMessage(playerid,MainColors[2],"Error: Player isn't spawned.");
	    	if(Syncing[tmpplayer] == true)return SendClientMessage(playerid,MainColors[2],"Error: Player is already in the process of syncing.");
	    	if(IsPlayerInAnyVehicle(tmpplayer) || gSpectating[tmpplayer] == true || ViewingBase[tmpplayer] == 1)return SendClientMessage(playerid,MainColors[2],"Error: Player is either in a vehicle, spectating, or viewing a(n) base/arena.");
	    	if(ViewingResults[tmpplayer] == true && IsDueling[playerid] == false)return SendClientMessage(playerid,MainColors[2],"Error: Player is already in the process of syncing.");
	    	if(AllowSuicide[tmpplayer] == false)return SendClientMessage(playerid,MainColors[2],"Error: Player is temporarily not allowed to sync. (wait 3-4 seconds)");
	    	if(DuelSpectating[tmpplayer] != -1)return SendClientMessage(playerid,MainColors[2],"Error: Player is dueling.");
	    	
	    	new Float:Z;GetPlayerPos(tmpplayer,Z,Z,Z);
 			SyncTimer[tmpplayer] = SetTimerEx("Sync",2200,0,"if",tmpplayer,Z);
 			SendClientMessage(tmpplayer,MainColors[3]," ...Forcing sync; do not change weapons!");
			NoKeys[tmpplayer] = true;
			Syncing[tmpplayer] = true;
			ChangedWeapon[tmpplayer] = false;
			LastWeapon[tmpplayer] = GetPlayerWeapon(tmpplayer);
		}
  		new Float:Z;GetPlayerPos(playerid,Z,Z,Z);
 		SyncTimer[playerid] = SetTimerEx("Sync",2200,0,"if",playerid,Z);
 		SendClientMessage(playerid,MainColors[3]," ... Syncing; do not change weapons!");
		NoKeys[playerid] = true;
		Syncing[playerid] = true;
		ChangedWeapon[playerid] = false;
		LastWeapon[playerid] = GetPlayerWeapon(playerid);
	    return 1;
	}

	dcmd_d(playerid,params[])
	{
	    if(IsPlayerInAnyVehicle(playerid))return 1;
		if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /d [1-4]");
		new dancestyle = strval(params);
		if(dancestyle < 1 || dancestyle > 4)return SendClientMessage(playerid,MainColors[1],"Usage: /d [1-4]");
		if(dancestyle == 1)SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
		else if(dancestyle == 2)SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
		else if(dancestyle == 3)SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
		else if(dancestyle == 4)SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
		return 1;
	}

	dcmd_a(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[1]){return DenyPlayer(playerid);}
	    if(gSpectating[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot be spectating");
	    new string[128],tmp[128],idx,gunid[16],string2[128];
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, MainColors[1],"Usage: /a [type] [optional comment]");
			SendClientMessage(playerid, MainColors[1],"*** HELP, gotoatt, gotodef, gotohome, new, edit, name, done, weather, time");
			return 1;
		}
		new Float:X,Float:Y,Float:Z,inter;
		GetPlayerPos(playerid,X,Y,Z);
		inter = GetPlayerInterior(playerid);
		strmid(gunid, tmp, 0, strlen(params), 128);
		if (strcmp(gunid, "gotoatt", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
            if(!strlen(tmp))
            {
                if(Current != -1)
                {
                    SetPlayerInterior(playerid,Interior[Current][ARENA]);
					SetPlayerPos(playerid,TeamArenaSpawns[Current][0][T_HOME],TeamArenaSpawns[Current][1][T_HOME],TeamArenaSpawns[Current][2][T_HOME]+1);
					return 1;
                }
            }
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			SetPlayerInterior(playerid,Interior[arena][ARENA]);
			SetPlayerPos(playerid,TeamArenaSpawns[arena][0][T_HOME],TeamArenaSpawns[arena][1][T_HOME],TeamArenaSpawns[arena][2][T_HOME]+1);
		}
		else if (strcmp(gunid, "gotodef", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
            if(!strlen(tmp))
            {
                if(Current != -1)
                {
                    SetPlayerInterior(playerid,Interior[Current][ARENA]);
					SetPlayerPos(playerid,TeamArenaSpawns[Current][0][T_AWAY],TeamArenaSpawns[Current][1][T_AWAY],TeamArenaSpawns[Current][2][T_AWAY]+1);
					return 1;
                }
            }
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			SetPlayerInterior(playerid,Interior[arena][ARENA]);
			SetPlayerPos(playerid,TeamArenaSpawns[arena][0][T_AWAY],TeamArenaSpawns[arena][1][T_AWAY],TeamArenaSpawns[arena][2][T_AWAY]+1);
		}
		else if (strcmp(gunid, "gotohome", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))
            {
                if(Current != -1)
                {
                    SetPlayerInterior(playerid,Interior[Current][ARENA]);
					SetPlayerPos(playerid,ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2]+1);
					return 1;
                }
            }
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			SetPlayerInterior(playerid,Interior[arena][ARENA]);
            SetPlayerPos(playerid,ArenaCP[arena][0],ArenaCP[arena][1],ArenaCP[arena][2]+1);
		}
		else if (strcmp(gunid, "done", true, strlen(gunid)) == 0)
		{
            ArenaEditing[playerid] = -1;
		}
		else if (strcmp(gunid, "usemap", true, strlen(gunid)) == 0)
		{
            AllowPlayerTeleport(playerid,1);
		}
		else if (strcmp(gunid, "help", true, strlen(gunid)) == 0)
		{
            SendClientMessage(playerid,MainColors[3],"*** /b new - creates a new arena file");
            SendClientMessage(playerid,MainColors[3],"*** /b edit - opens the edit menu");
		}
		else if (strcmp(gunid, "new", true, strlen(gunid)) == 0)
		{
		    ArenaEditing[playerid] = GetHighestArenaNum();
            format(string2,sizeof(string2),"/attackdefend/%d/arenas/%d.ini",GameMap,ArenaEditing[playerid]);
            format(string,sizeof(string),"Created arena %d",ArenaEditing[playerid]);
            SendClientMessage(playerid,MainColors[3],string);
            
            new tmpstr[384];
            format(tmpstr,384,"\r\nhome=%.3f,%.3f,%.3f\r\nZmax=9000.0,9000.0\r\nZmin=-9000.0,-9000.0\r\nT0=0.0,0.0,0.0\r\nT1=0.0,0.0,0.0\r\nT2=0.0,0.0,0.0\r\nT3=0.0,0.0,0.0\r\nT4=0.0,0.0,0.0\r\nT5=0.0,0.0,0.0\r\nInterior=%d\r\nName=N/A\r\nKills=0\r\nDeaths=0\r\nA_Wins=0\r\nD_Wins=0\r\nPlayed=0\r\nWeather=-1\r\nTime=-1",X,Y,Z,inter);
            new File:aFile;aFile = fopen(string2);fwrite(aFile,tmpstr);fclose(aFile);printf(string);
            newarenas++;
		}
		else if (strcmp(gunid, "edit", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp) && ArenaEditing[playerid] != -1)
			{
                format(string,sizeof(string),"Editing arena %d",ArenaEditing[playerid]);
		    	SendClientMessage(playerid,MainColors[3],string);
		    	EditArena(playerid);
				return 1;
			}
		    if(!strlen(tmp))return SendClientMessage(playerid,MainColors[2],"an arena number is needed");
		    new arena = strval(tmp);
		    if(fexist(Arenafile(arena)))
			{
			    ArenaEditing[playerid] = arena;
		    	format(string,sizeof(string),"Editing arena %d",ArenaEditing[playerid]);
		    	SendClientMessage(playerid,MainColors[3],string);
		    	EditArena(playerid);
				return 1;
			}
			else
			{
				format(string,sizeof(string),"arena %d does not exist",ArenaEditing[playerid]);
                SendClientMessage(playerid,MainColors[2],string);
                return 1;
			}
		}
		else if (strcmp(gunid, "name", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp) || strlen(params) <= strlen(tmp))return 1;
			dini_Set(Arenafile(arena),"Name",params[idx-strlen(tmp)]);
			format(string,128,"Arena %d name: \"%s\"",arena,params[idx-strlen(tmp)]);
			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "weather", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp))return 1;
			dini_IntSet(Arenafile(arena),"Weather",strval(tmp));
			Weather[arena][ARENA] = strval(tmp);
			format(string,128,"Arena %d weather: \"%d\"",arena,strval(tmp));
			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "time", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp))return 1;
			dini_IntSet(Arenafile(arena),"Time",strval(tmp));
			TimeX[arena][ARENA] = strval(tmp);
			format(string,128,"Arena %d time: \"%d\"",arena,strval(tmp));
			SendClientMessage(playerid,MainColors[3],string);
		}
		return 1;
	}

	dcmd_b(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[1]){return DenyPlayer(playerid);}
	    if(gSpectating[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot be spectating");
	    new string[128],tmp[128],idx;
		new gunid[16],string2[128];
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, MainColors[1],"Usage: /b [type] [optional comment]");
			SendClientMessage(playerid, MainColors[1],"*** gotoatt, gotodef, gotohome, new, edit, done, name, weather, time");
			return 1;
		}
		new Float:X,Float:Y,Float:Z,inter;
		GetPlayerPos(playerid,X,Y,Z);
		inter = GetPlayerInterior(playerid);
		strmid(gunid, tmp, 0, strlen(params), 128);
		if (strcmp(gunid, "gotoatt", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
            if(!strlen(tmp))
            {
                if(Current != -1)
                {
                    SetPlayerInterior(playerid,Interior[Current][BASE]);
					SetPlayerPos(playerid,TeamBaseSpawns[Current][0][T_HOME],TeamBaseSpawns[Current][1][T_HOME],TeamBaseSpawns[Current][2][T_HOME]);
					return 1;
                }
            }
		    new base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			SetPlayerInterior(playerid,Interior[base][BASE]);
			SetPlayerPos(playerid,TeamBaseSpawns[base][0][T_HOME],TeamBaseSpawns[base][1][T_HOME],TeamBaseSpawns[base][2][T_HOME]);
		}
		else if (strcmp(gunid, "gotodef", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
            if(!strlen(tmp))
            {
                if(Current != -1)
                {
                    SetPlayerInterior(playerid,Interior[Current][BASE]);
					SetPlayerPos(playerid,TeamBaseSpawns[Current][0][T_AWAY],TeamBaseSpawns[Current][1][T_AWAY],TeamBaseSpawns[Current][2][T_AWAY]);
					return 1;
                }
            }
		    new base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			SetPlayerInterior(playerid,Interior[base][BASE]);
			SetPlayerPos(playerid,TeamBaseSpawns[base][0][T_AWAY],TeamBaseSpawns[base][1][T_AWAY],TeamBaseSpawns[base][2][T_AWAY]);
		}
		else if (strcmp(gunid, "gotohome", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))
            {
                if(Current != -1)
                {
                    SetPlayerInterior(playerid,Interior[Current][BASE]);
            		SetPlayerPos(playerid,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
					return 1;
                }
            }
		    new base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			SetPlayerInterior(playerid,Interior[base][BASE]);
            SetPlayerPos(playerid,HomeCP[base][0],HomeCP[base][1],HomeCP[base][2]);
		}
		else if (strcmp(gunid, "done", true, strlen(gunid)) == 0)
		{
            BaseEditing[playerid] = -1;
		}
		else if (strcmp(gunid, "usemap", true, strlen(gunid)) == 0)
		{
            AllowPlayerTeleport(playerid,1);
		}
		else if (strcmp(gunid, "new", true, strlen(gunid)) == 0)
		{
		    new tmpstr[200];
		    BaseEditing[playerid] = GetHighestBaseNum();
            format(string2,sizeof(string2),"/attackdefend/%d/bases/%d.ini",GameMap,BaseEditing[playerid]);
            format(string,sizeof(string),"Created base %d",BaseEditing[playerid]);
            format(tmpstr,200,"\r\nhome=%.3f,%.3f,%.3f\r\nT1_0=0.0,0.0,0.0\r\nT2_0=0.0,0.0,0.0\r\nInterior=%d\r\nName=N/A\r\nKills=0\r\nDeaths=0\r\nA_Wins=0\r\nD_Wins=0\r\nPlayed=0\r\nWeather=-1\r\nTime=-1",X,Y,Z,inter);
            new File:aFile;aFile = fopen(string2);fwrite(aFile,tmpstr);fclose(aFile);printf(string);
            SendClientMessage(playerid,MainColors[3],string);
            newbases++;
		}
		else if (strcmp(gunid, "edit", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp) && BaseEditing[playerid] != -1)
			{
                format(string,sizeof(string),"Editing base %d",BaseEditing[playerid]);
		    	SendClientMessage(playerid,MainColors[3],string);
		    	EditBase(playerid);
				return 1;
			}
		    if(!strlen(tmp))return SendClientMessage(playerid,MainColors[2],"a base number is needed");
		    new base = strval(tmp);
		    if(fexist(Basefile(base)))
			{
			    BaseEditing[playerid] = base;
		    	format(string,sizeof(string),"Editing base %d",BaseEditing[playerid]);
		    	SendClientMessage(playerid,MainColors[3],string);
		    	EditBase(playerid);
				return 1;
			}
			else
			{
				format(string,sizeof(string),"base %d does not exist",BaseEditing[playerid]);
                SendClientMessage(playerid,MainColors[2],string);
                return 1;
			}
		}
		else if (strcmp(gunid, "name", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new base;
		    base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp))return 1;
			dini_Set(Basefile(base),"Name",params[idx-strlen(tmp)]);
			format(string,128,"Base %d name: \"%s\"",base,params[idx-strlen(tmp)]);
			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "weather", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp))return 1;
			dini_IntSet(Basefile(base),"Weather",strval(tmp));
			Weather[base][BASE] = strval(tmp);
			format(string,128,"Base %d weather: \"%d\"",base,strval(tmp));
			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "time", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp))return 1;
			dini_IntSet(Basefile(base),"Time",strval(tmp));
			TimeX[base][BASE] = strval(tmp);
			format(string,128,"Base %d time: \"%d\"",base,strval(tmp));
			SendClientMessage(playerid,MainColors[3],string);
		}
		return 1;
	}

	/*dcmd_tele(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[1]){return DenyPlayer(playerid);}
	    if(gSpectating[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot be spectating");
	    new string[128],tmp[128],idx,gunid[16],string2[128],TeleEditing;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, MainColors[1],"Usage: /tele [see below]");
			SendClientMessage(playerid, MainColors[1],"*** new - (creates a new teleport at your location)");
			SendClientMessage(playerid, MainColors[1],"*** edit - (changes the teleport to your location)");
			SendClientMessage(playerid, MainColors[1],"*** name - (sets the title of the teleport)");
			return 1;
		}
		new Float:X,Float:Y,Float:Z,inter;
		GetPlayerPos(playerid,X,Y,Z);
		inter = GetPlayerInterior(playerid);
		strmid(gunid, tmp, 0, strlen(params), 128);
		if (strcmp(gunid, "new", true, strlen(gunid)) == 0)
		{
		    TeleEditing = GetHighestTeleNum();
            format(string2,sizeof(string2),"/attackdefend/%d/teleports/%d.ini",GameMap,TeleEditing);
            format(string,sizeof(string),"Created teleport %d",ArenaEditing[playerid]);
            new File:aFile;aFile = fopen(string2);fclose(aFile);printf(string);
            SendClientMessage(playerid,MainColors[3],string);
            format(string,sizeof(string),"%.2f,%.2f,%.2f",X,Y,Z);dini_Set(string2,"XYZ",string);
            dini_IntSet(string2,"Interior",inter);
            dini_Set(string2,"Name","N/A");
		}
		else if (strcmp(gunid, "edit", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))return SendClientMessage(playerid,MainColors[2],"a teleport number is needed");
		    new arena;
		    arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))
			{
                format(string,sizeof(string),"teleport %d does not exist",ArenaEditing[playerid]);
                SendClientMessage(playerid,MainColors[2],string);
                return 1;
			}
            format(string2,sizeof(string2),"/attackdefend/%d/teleports/%d.ini",GameMap,arena);
            format(string,sizeof(string),"Modified teleport %d",arena);
            new File:aFile;aFile = fopen(string2);fclose(aFile);printf(string);
            SendClientMessage(playerid,MainColors[3],string);
            format(string,sizeof(string),"%.2f,%.2f,%.2f",X,Y,Z);dini_Set(string2,"XYZ",string);
            dini_IntSet(string2,"Interior",inter);
		}
		else if (strcmp(gunid, "name", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
		    new arena;
		    arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"teleport does not exist");
			tmp = strtok_(params, idx);
			if(!strlen(tmp))return 1;
			dini_Set(Telefile(arena),"Name",params[idx-strlen(tmp)]);
			format(string,128,"Teleport %d name: \"%s\"",arena,params[idx-strlen(tmp)]);
			SendClientMessage(playerid,MainColors[3],string);
		}
		return 1;
	}*/
	
	dcmd_view(playerid,params[])
	{
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    new tmp[128],idx,gunid[10];
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1],"Usage: /view [base,arena,car] [parameter]");
		strmid(gunid, tmp, 0, strlen(params), 128);
	    if(strcmp(gunid, "base", true, strlen(gunid)) == 0)
		{
		    if(gSpectating[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot be spectating");
	    	if(Playing[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot be active in a round.");
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))return 1;
		    new base = strval(tmp);
		    if(!fexist(Basefile(base)))return SendClientMessage(playerid,MainColors[2],"base does not exist");
			GetPlayerPos(playerid,ViewPos[playerid][0],ViewPos[playerid][1],ViewPos[playerid][2]);
			GetPlayerFacingAngle(playerid,ViewPos[playerid][3]);
			TogglePlayerControllable(playerid,0);
			SendClientMessage(playerid,MainColors[1],"Use the 'JUMP' and 'AIM' to scroll through bases. Use 'CROUCH' spawn inside the base and 'SPRINT' to exit.");
			SetPlayerCameraLookAt(playerid,HomeCP[base][0],HomeCP[base][1],HomeCP[base][2]);
			SetPlayerCameraPos(playerid,HomeCP[base][0]+50,HomeCP[base][1]+50,HomeCP[base][2]+80);
            SetPlayerPos(playerid,HomeCP[base][0],HomeCP[base][1],HomeCP[base][2]);
            SetPlayerInterior(playerid,Interior[base][BASE]);
			ViewingBase[playerid] = base;
		}
		else if(strcmp(gunid, "arena", true, strlen(gunid)) == 0)
		{
		    if(gSpectating[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot be spectating");
	    	if(Playing[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot active in a round.");
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))return 1;
		    new arena = strval(tmp);
		    if(!fexist(Arenafile(arena)))return SendClientMessage(playerid,MainColors[2],"arena does not exist");
			GetPlayerPos(playerid,ViewPos[playerid][0],ViewPos[playerid][1],ViewPos[playerid][2]);
			GetPlayerFacingAngle(playerid,ViewPos[playerid][3]);
			TogglePlayerControllable(playerid,0);
			SendClientMessage(playerid,MainColors[1],"Use the 'JUMP' and 'AIM' to scroll through bases. Use 'CROUCH' spawn inside the arena and 'SPRINT' to exit.");
			SetPlayerCameraLookAt(playerid,ArenaCP[arena][0],ArenaCP[arena][1],ArenaCP[arena][2]);
			SetPlayerCameraPos(playerid,ArenaCP[arena][0]+50,ArenaCP[arena][1]+50,ArenaCP[arena][2]+80);
			SetPlayerPos(playerid,ArenaCP[arena][0],ArenaCP[arena][1],ArenaCP[arena][2]);
			SetPlayerInterior(playerid,Interior[arena][ARENA]);
			ViewingArena[playerid] = arena;
		}
		else if(strcmp(gunid, "config", true, strlen(gunid)) == 0)
		{
	    	new string[128];
			SendClientMessage(playerid,MainColors[3],"*** CURRENT CONFIG ***");
			format(string,128,"*** CP [Used: %d, Size: %d, Time: %d]  Time [Keys: %d, Cmds: %d, Msgs: %d]",CPused,CPsize,CPtime,KeyTime,CmdTime,TextTime);
			SendClientMessage(playerid,MainColors[3],string);
			format(string,128,"*** Global [Weather: %d, Time: %d, Health: %d, Armor: %d] ",gWeather,gTime,gHealth,gArmor);
			SendClientMessage(playerid,MainColors[3],string);
			//format(string,128,"*** Team [Skins: %d,%d,%d,%d  Locked: %d,%d,%d,%d  Names: %s,%s,%s,%s]",TeamSkin[0],TeamSkin[1],TeamSkin[2],TeamSkin[3],TeamLock[0],TeamLock[1],TeamLock[2],TeamLock[3],TeamName[0],TeamName[1],TeamName[2],TeamName[3]);
			//SendClientMessage(playerid,MainColors[3],string);
			format(string,128,"*** Other [Nicks: %d, Switching: %d, TabHP: %d, RoundMuting: %d, IDnames: %d, UseSubs: %d, EnemyUAV: %d, UseClock: %d]",Allownicks,Allowswitch,TabHP,RoundMuting,IDnames,UseSubs,EnemyUAV,UseClock);
			SendClientMessage(playerid,MainColors[3],string);
		}
		else if(strcmp(gunid, "car", true, strlen(gunid)) == 0)
		{
		    new string[128],veh;
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1],"Usage: /view car [Model/Name]");
     		veh = GetVehicleModelIDFromName(tmp);
			if(veh == -1)
			{
				veh = strval(tmp);
				if(veh < 400 || veh > 611)return SendClientMessage(playerid, MainColors[2], "Error: Invalid model or name.");
			}
			format(string,128,"*** VEHICLE INFO: %s  ||  Used: %d  ||  Health: %d",CarList[veh-400],v_Usage[veh-400],v_Health[veh-400]);
			SendClientMessage(playerid,MainColors[3],string);
		}
	    return 1;
	}

	dcmd_config(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[2]){return DenyPlayer(playerid);}
	    new string[128],gunstring[12],tmp[128],idx;
		new gunid[16];
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, MainColors[1],"Usage: /config [variable]");
			SendClientMessage(playerid, MainColors[1],"*** agunammo, agunused, agunlimit, resetgunsa, bgunammo, bgunused, bgunlimit, resetgunsb, cptime, cpsize");
			SendClientMessage(playerid, MainColors[1],"*** cpused, texttime, keytime, cmdtime, counter, allowswitch, modetime, ffire, nicks, tabhp, armor");
			SendClientMessage(playerid, MainColors[1],"*** pgunused, pgunammo, idnames, usesubs, enemyuav, garmor, ghealth, weather, time, useclock, pausing");
			SendClientMessage(playerid, MainColors[1],"*** vpppt, jnp, gravity, automode, vhealth, vused, nonames, autospec, antic, lockmode, pickups, droplifetime");
			SendClientMessage(playerid, MainColors[1],"*** idletime, nametagdist, autopause, debug, showradar, markerfade, mindist, maxdist, randomization, autoswap");
			SendClientMessage(playerid, MainColors[1],"*** maxping, rhealth, rarmor, vspawning, weapons, showteamdmg, usenametags, privatemode");
			return 1;
		}
		strmid(gunid, tmp, 0, strlen(params), 128);
		if (strcmp(gunid, "Agunammo", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config Agunammo [gun ID] [1-10000]");
			new gun,ammo;
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
			ammo = strval(tmp);
			if (ammo > 0 && ammo < 10001)
  			{
  			    GunAmmo[gun][ARENA] = ammo;
  		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
       			new file[64];
  				format(file,64,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
  				format(gunstring,12,"%d",gun);format(string,sizeof(string),"%d,%d,%d",GunAmmo[gun][ARENA],GunUsed[gun][ARENA],GunLimit[gun][ARENA]);dini_Set(file,gunstring,string);
  				format(string,128,"ARENA: Ammo for gun %d set to %d",gun,ammo);
  				SendClientMessage(playerid,MainColors[3],string);
  				UpdateWeaponSetText(ARENA);
			}
		}
		else if (strcmp(gunid, "Agunused", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config Agunused [GunID/Name]");
			new gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
   			GunEdit[playerid][GUN] = gun;
            GunEdit[playerid][1] = ARENA;
            GunUsedMenuI(playerid);
		}
		else if (strcmp(gunid, "Agunlimit", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config Agunlimit [gun ID] [0-100]");
			new gun,ammo;
   			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
			ammo = strval(tmp);
			if (ammo >= 0 && ammo < 101)
  			{
  		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		    	new file[64];
  				format(file,64,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
  				format(string,STR,"L%d",gun);
  				GunLimit[gun][ARENA] = ammo;
  				format(gunstring,12,"%d",gun);format(string,sizeof(string),"%d,%d,%d",GunAmmo[gun][ARENA],GunUsed[gun][ARENA],GunLimit[gun][ARENA]);dini_Set(file,gunstring,string);
  				format(string,128,"ARENA: Limit for gun %d set to %d",gun,ammo);
  				SendClientMessage(playerid,MainColors[3],string);
  				UpdateWeaponSetText(ARENA);
			}
		}
		else if (strcmp(gunid, "Bgunammo", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config Bgunammo [gun ID] [1-10000]");
			new gun,ammo;
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
			ammo = strval(tmp);
			if (ammo > 0 && ammo < 10001)
  			{
  		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		    	new file[64];
  				format(file,64,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
  				format(string,STR,"A%d",gun);
  				GunAmmo[gun][BASE] = ammo;
  				format(gunstring,12,"%d",gun);format(string,sizeof(string),"%d,%d,%d",GunAmmo[gun][BASE],GunUsed[gun][BASE],GunLimit[gun][BASE]);dini_Set(file,gunstring,string);
  				format(string,256,"BASE: Ammo for gun %d set to %d",gun,ammo);
  				SendClientMessage(playerid,MainColors[3],string);
  				UpdateWeaponSetText(BASE);
			}
		}
		else if (strcmp(gunid, "Bgunused", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config Bgunused [GunID/Name]");
			new gun;
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
            GunEdit[playerid][GUN] = gun;
            GunEdit[playerid][1] = BASE;
            GunUsedMenuI(playerid);
		}
		else if (strcmp(gunid, "Bgunlimit", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config Bgunlimit [gun ID] [0-100]");
			new gun,ammo;
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
			ammo = strval(tmp);
			if (ammo >= 0 && ammo < 101)
  			{
  		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		    	new file[64];
  				format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
  				format(string,STR,"L%d",gun);
  				GunLimit[gun][BASE] = ammo;
  				format(gunstring,12,"%d",gun);format(string,sizeof(string),"%d,%d,%d",GunAmmo[gun][BASE],GunUsed[gun][BASE],GunLimit[gun][BASE]);dini_Set(file,gunstring,string);
  				format(string,128,"BASE: Limit for gun %d set to %d",gun,ammo);
  				SendClientMessage(playerid,MainColors[3],string);
  				UpdateWeaponSetText(BASE);
			}
		}
		else if (strcmp(gunid, "cptime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config cptime [5-120]");
			new time = strval(tmp);
			if(time < 5 && time > 120)
			{
		    	SendClientMessage(playerid,MainColors[2],"Invalid time!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			CPtime[1] = time;
			format(string,sizeof(string),"Checkpoint capture time changed to %d",CPtime[1]);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"CPtime",CPtime[1]);
		}
		else if (strcmp(gunid, "cpsize", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config cpsize [1-500]");
			new size = strval(tmp);
			if(size < 1 && size > 500)
			{
		    	SendClientMessage(playerid,MainColors[2],"Invalid size!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			CPsize = size;
			format(string,sizeof(string),"Checkpoint size changed to %d",CPsize);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"CPsize",CPsize);
			if(CPused == true && Current != -1)
			{
			    foreach(Player,i)
				{
			    	DisablePlayerCheckpoint(i);
					DisablePlayerRaceCheckpoint(i);
			    	SetPlayerCheckpoint(i,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],CPsize);
				}
			}
		}
		else if (strcmp(gunid, "cpused", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config cpused [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			CPused = bool:used;
			format(string,sizeof(string),"Checkpoint usage changed to %d",CPused);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"CPused",CPused);
			if(CPused == false)
			{
			    CPtime[0] = CPtime[1];
				foreach(Player,i)
				{
					TD_HideMainTextForPlayer(i,1);
				}
			}
		}
		else if (strcmp(gunid, "texttime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config texttime [1-15]");
			new time = strval(tmp);
			if(time < 1 && time > 15)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			TextTime = time;
			format(string,sizeof(string),"Text interval changed to %d",TextTime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Text",TextTime);
		}
		else if (strcmp(gunid, "keytime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config keytime [1-15]");
			new time = strval(tmp);
			if(time < 1 && time > 15)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			KeyTime = time;
			format(string,sizeof(string),"Keybind interval changed to %d",KeyTime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Key",KeyTime);
		}
		else if (strcmp(gunid, "cmdtime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config cmdtime [1-15]");
			new time = strval(tmp);
			if(time < 1 && time > 15)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			CmdTime = time;
			format(string,sizeof(string),"Command interval changed to %d",CmdTime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Cmd",CmdTime);
		}
		else if (strcmp(gunid, "counter", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config counter [Counter ID] [5-120]");
			new counter,time;
			counter = strval(tmp);
	        if(counter != 0 && counter != 1 && counter != 2)return SendClientMessage(playerid,MainColors[2],"Error: invalid counter ID (0:Base, 1:Arena, 2:Auto Mode)");
			tmp = strtok_(params, idx);
			time = strval(tmp);
			if(time >= 5 && time < 121)
  			{
  		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  				StopCounting[counter][1] = time;
  				format(string,sizeof(string),"%d,%d,%d",StopCounting[BASE][1],StopCounting[ARENA][1],StopCounting[2][1]);dini_Set(gConfigFile(),"Counter",string);
  				format(string,128,"Counter %d set to %d",counter,time);
  				SendClientMessage(playerid,MainColors[3],string);
			}
		}
		else if (strcmp(gunid, "allowswitch", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config allowswitch [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			Allowswitch = bool:time;
			format(string,sizeof(string),"Team Switching changed to %d",Allowswitch);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"Switch",Allowswitch);
		}
		else if (strcmp(gunid, "modetime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config modetime [2-30]");
			new time = strval(tmp);
			if(time < 2 && time > 30)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are from 2 to 30!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			modetime = time;
			format(string,sizeof(string),"mode time changed to %d",modetime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Modetime",modetime);
		}
		else if (strcmp(gunid, "ffire", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config ffire [0 off : 1 on]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			FriendlyFire = bool:time;
			Team_FriendlyFix();
			format(string,sizeof(string),"FriendlyFire set to %d",FriendlyFire);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"FriendlyFire",FriendlyFire);
		}
		else if (strcmp(gunid, "nicks", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config nicks [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			Allownicks = bool:time;
			format(string,sizeof(string),"Non-admin nick changing set to %d",Allownicks);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"Nicknames",Allownicks);
		}
		else if (strcmp(gunid, "tabhp", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config tabhp [0 - 1]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			TabHP = bool:time;
			format(string,sizeof(string),"Health showing on 'tab' set to %d",TabHP);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"TabHP",TabHP);
			if(Current != -1 && TabHP == false)
			{
                foreach(Player,i)SetPlayerScore(i,TempKills[i]);
			}
		}
		else if (strcmp(gunid, "weather", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config weather [weatherid]");
			new time = strval(tmp);
			gWeather = time;
			format(string,sizeof(string),"Weather set to %d",gWeather);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Weather",gWeather);
		}
		else if (strcmp(gunid, "time", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config time [0-24]");
			new time = strval(tmp);
			if(time < 0 || time > 24)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0-24");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			gTime = time;
			format(string,sizeof(string),"GlobalTime set to %d",gTime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Time",gTime);
		}
		else if (strcmp(gunid, "mute", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config mute [0 - 1]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			RoundMuting = bool:time;
			format(string,sizeof(string),"Round muting set to %d",time);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"RoundMuting",time);
		}
		else if (strcmp(gunid, "resetgunsA", true, strlen(gunid)) == 0)
		{
		    new file[64];format(file,64,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
		    for(new i = 0; i < MAX_WEAPONS; i++)
			{
	    		format(gunstring,12,"%d",i);format(string,sizeof(string),"%d,0,%d",GunAmmo[i][ARENA],GunLimit[i][ARENA]);dini_Set(file,gunstring,string);
			}
			UpdateWeaponSetText(ARENA);
			SendClientMessage(playerid,MainColors[3],"All ARENA weapons have been reset");
		}
		else if (strcmp(gunid, "resetgunsB", true, strlen(gunid)) == 0)
		{
            new file[64];format(file,64,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
		    for(new i = 0; i < MAX_WEAPONS; i++)
			{
	    		format(gunstring,12,"%d",i);format(string,sizeof(string),"%d,0,%d",GunAmmo[i][BASE],GunLimit[i][BASE]);dini_Set(file,gunstring,string);
			}
			UpdateWeaponSetText(BASE);
			SendClientMessage(playerid,MainColors[3],"All BASE weapons have been reset");
		}
		else if (strcmp(gunid, "pgunammo", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config pgunammo [gun ID] [1-10000]");
			new gun,ammo;
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
			ammo = strval(tmp);
			if (ammo > 0 && ammo < 10001)
  			{
  			    new file[64];format(file,128,"/attackdefend/%d/config/playerconfig/%d.ini",GameMap,CurrentConfig[PLAYER]);
  			    pGunAmmo[gun] = ammo;
  		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  				format(gunstring,12,"%d",gun);format(string,sizeof(string),"%d,%d",pGunAmmo[gun],pGunUsed[gun]);dini_Set(file,gunstring,string);
  				format(string,128,"PLAYER: Ammo for gun %d set to %d",gun,ammo);
  				SendClientMessage(playerid,MainColors[3],string);
			}
		}
		else if (strcmp(gunid, "pgunused", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config pgunused [gun ID] [0:no 1:yes 2:given to player auto]");
			new gun,used;
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 0 || gun > 47 || (gun == 19 || gun == 20 || gun == 21 || gun == 39 || gun == 40))
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Gun ID/Name");
	    			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	    			return 1;
				}
   			}
			tmp = strtok_(params, idx);
			used = strval(tmp);
			if(used != 1 && used != 0 && used != 2)
			{
				SendClientMessage(playerid,MainColors[2],"options are 0-2");
				PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
				return 1;
			}
			new file[64];format(file,128,"/attackdefend/%d/config/playerconfig/%d.ini",GameMap,CurrentConfig[PLAYER]);
			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  			pGunUsed[gun] = used;
  			format(gunstring,12,"%d",gun);format(string,sizeof(string),"%d,%d",pGunAmmo[gun],pGunUsed[gun]);dini_Set(file,gunstring,string);
  			format(string,128,"PLAYER: Gun %d has been set to %d",gun,used);
  			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "wskill", true, strlen(gunid)) == 0)
		{
			WeaponSkillMenu(playerid);
		}
		else if (strcmp(gunid, "idnames", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config idnames [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			IDnames = bool:used;
			format(string,sizeof(string),"[ID]Name usage changed to %d",IDnames);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"IDnames",IDnames);
		}
		else if (strcmp(gunid, "usesubs", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config usesubs [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			UseSubs = bool:used;
			format(string,sizeof(string),"Sub usage after timeouts set to %d",UseSubs);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"UseSubs",UseSubs);
		}
		else if (strcmp(gunid, "enemyuav", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config enemyuav [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			EnemyUAV = bool:used;
			format(string,sizeof(string),"Enemy UAV set to %d",EnemyUAV);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"EnemyUAV",EnemyUAV);
		}
		else if (strcmp(gunid, "garmor", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config garmor [amount]");
			new time = strval(tmp);
			gArmor = time;
			format(string,sizeof(string),"global amount of spawn armor changed to %d",gArmor);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"gArmor",gArmor);
		}
		else if (strcmp(gunid, "ghealth", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config ghealth [amount]");
			new time = strval(tmp);
			gHealth = time;
			format(string,sizeof(string),"global amount of spawn health changed to %d",gHealth);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"gHealth",gHealth);
		}
		else if (strcmp(gunid, "useclock", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config useclock [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(bool:used == UseClock)return 1;
			UseClock = bool:used;
			format(string,sizeof(string),"Clock usage changed to %d",UseClock);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"UseClock",UseClock);
			if(UseClock == true)XTime();
		}
		else if (strcmp(gunid, "vpppt", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config vpppt [min 1]");
			new time = strval(tmp);
			if(time < 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Invalid amount!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			VPPPT = time;
			format(string,sizeof(string),"Vehicles Per Person Per Team' (VPPPT) changed to %d",VPPPT);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"VPPPT",VPPPT);
		}
		else if (strcmp(gunid, "jnp", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config jnp [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			JnP = bool:used;
			format(string,sizeof(string),"Join and Part messages changed to %d",JnP);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"JnP",JnP);
		}
		else if (strcmp(gunid, "gravity", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config gravity [float: value]");
			new Float:time = floatstr(tmp);
			Gravity = time;
			format(string,sizeof(string),"Gravity changed to %.4f",Gravity);
			SendClientMessage(playerid,MainColors[3],string);
			dini_FloatSet(gConfigFile(),"Gravity",Gravity);
			format(string,sizeof(string),"gravity %f",Gravity);
			SendRconCommand(string);
		}
		else if (strcmp(gunid, "gamemap", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config gamemap [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			GameMap = time;
			format(string,sizeof(string),"Game Map changed to %d",GameMap);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"GameMap",GameMap);
			//PRT();
			LoadBases();
			LoadArenas();
		}
		else if (strcmp(gunid, "automode", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config automode [-1:off 0:base 1:arena 2:tdm]");
			new time = strval(tmp);
			if(time != -1 && time != 0 && time != 1 && time != 2)
			{
		    	SendClientMessage(playerid,MainColors[2],"Invalid mode! (-1,0,1,2)");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(AutoMode != time)
			{
				AutoMode = time;
				format(string,sizeof(string),"AutoMode changed to %d",AutoMode);
				SendClientMessage(playerid,MainColors[3],string);
				dini_IntSet(gConfigFile(),"AutoMode",AutoMode);
				if(AutoModeActive == false && Current == -1 && AutoMode >= 0 && AutoMode < 3)AutoModeInit();
			}
		}
		else if (strcmp(gunid, "vhealth", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config vhealth [Vehicle ID/Name] [health (default 1000)]");
			new veh,used;
			veh = GetVehicleModelIDFromName(tmp);
			if(veh == -1)
			{
				veh = strval(tmp);
				if(veh < 400 || veh > 611)return SendClientMessage(playerid, MainColors[2], "Error: Invalid model or name.");
			}
			tmp = strtok_(params, idx);
			used = strval(tmp);
			
			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  			v_Health[veh-400] = used;
  			format(gunstring,4,"%d",veh);
	  		format(string,sizeof(string),"%d,%d",v_Usage[veh-400],v_Health[veh-400]);dini_Set(VehicleFile(),gunstring,string);
  			format(string,128,"VEHICLE: vHealth for the %s(%d) changed to %d",CarList[veh-400],veh,used);
  			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "vused", true, strlen(gunid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config vused [Vehicle ID/Name] [0 never used, 1 always used, 2 only in rounds, 3 only lobby, 4 admin only]");
			new veh,used;
			veh = GetVehicleModelIDFromName(tmp);
			if(veh == -1)
			{
				veh = strval(tmp);
				if(veh < 400 || veh > 611)return SendClientMessage(playerid, MainColors[2], "Error: Invalid model or name.");
			}
			tmp = strtok_(params, idx);
			used = strval(tmp);
			if(used < 0 && used > 3)
			{
			    SendClientMessage(playerid,MainColors[2],"Invalid parameter (options are 0-3)");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}

			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  			v_Usage[veh-400] = used;
  			format(gunstring,4,"%d",veh);
	  		format(string,sizeof(string),"%d,%d",v_Usage[veh-400],v_Health[veh-400]);dini_Set(VehicleFile(),gunstring,string);
  			format(string,128,"VEHICLE: vehicle usage for the %s(%d) changed to %d",CarList[veh-400],veh,used);
  			SendClientMessage(playerid,MainColors[3],string);
		}
		else if (strcmp(gunid, "nonames", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config nonames [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(bool:used == NoNameMode)return 1;
			NoNameMode = bool:used;
			format(string,sizeof(string),"Name usage changed to %d",NoNameMode);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"NoNameMode",NoNameMode);
		}
		else if (strcmp(gunid, "autospec", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config autospec [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(bool:used == AutoTeamSpec)return 1;
			AutoTeamSpec = bool:used;
			format(string,sizeof(string),"Automatic teammate spectating set to %d",AutoTeamSpec);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"AutoTeamSpec",AutoTeamSpec);
		}
		else if (strcmp(gunid, "antic", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config antic [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(bool:used == AntiC)return 1;
			AntiC = bool:used;
			format(string,sizeof(string),"Crouch Bugging set to %d",AntiC);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"AntiC",AntiC);
		}
		else if (strcmp(gunid, "lockmode", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config lockmode [0-1]");
			new used = strval(tmp);
			if(used != 0 && used != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(bool:used == LockMode)return 1;
			LockMode = bool:used;
			format(string,sizeof(string),"Automatic locking of vehicles in rounds set to %d",LockMode);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"LockMode",LockMode);
		}
		else if (strcmp(gunid, "pickups", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config pickups [-1(not used), 0(bases), 1(arenas), 2(tdms), 3(all)]");
			new used = strval(tmp);
			if(used > 3 || used < -1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are: -1(not used), 0(bases), 1(arenas), 2(tdms), 3(all)");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(used == Pickups)return 1;
			Pickups = used;
			format(string,sizeof(string),"Pickup usage set to %d",Pickups);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"Pickups",Pickups);
		}
		else if(strcmp(gunid, "droplifetime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config droplifetime [time]");
			new time = strval(tmp);
			DropLifeTime = time;
			format(string,sizeof(string),"pickup DropLifeTime changed to %d",DropLifeTime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"DropLifeTime",DropLifeTime);
		}
		else if(strcmp(gunid, "idletime", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config idletime [time]");
			new time = strval(tmp);
			IDLEtime = time;
			format(string,sizeof(string),"IDLE time changed to %d",IDLEtime);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"IDLEtime",IDLEtime);
		}
		else if (strcmp(gunid, "pausing", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config pausing [0 disabled : 1 allowed]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			Pausing = bool:time;
			format(string,sizeof(string),"Pausing set to %d",Pausing);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"Pausing",Pausing);
		}
		else if (strcmp(gunid, "nametagdist", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config nametagdist [5-80]");
			new Float:time = floatstr(tmp);
			if(time < 5 && time > 80)
			{
		    	SendClientMessage(playerid,MainColors[2],"Invalid units!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			nDist = time;
			format(string,sizeof(string),"Nametag distance changed to %.2f",nDist);
			SendClientMessage(playerid,MainColors[3],string);
			dini_FloatSet(gConfigFile(),"nDist",nDist);
		}
		else if (strcmp(gunid, "autopause", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config autopause [0:off / 1 or more will be how long the round is paused for in seconds]");
			new time = strval(tmp);

			AutoPause = bool:time;
			format(string,sizeof(string),"Auto pausing set to %d",AutoPause);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"AutoPause",AutoPause);
		}
		else if (strcmp(gunid, "debug", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config debug [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			Debug = bool:time;
			format(string,sizeof(string),"Debug %d",Debug);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"Debug",Debug);
		}
		else if (strcmp(gunid, "useradar", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config useradar [0 disabled : 1 used]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			UseRadar = bool:time;
			if(UseRadar == true)
			{
				SendClientMessage(playerid,MainColors[3],"The radar will now be used");
				GangZoneHideForAll(BlackRadar);
				if(ModeType > 0)
				{
					GangZoneShowForAll(zone,TeamGZColors[T_AWAY]);
  					GangZoneFlashForAll(zone,TeamGZColors[T_HOME]);
				}
			}
			else
			{
				SendClientMessage(playerid,MainColors[3],"The radar will not be shown");
				if(Current != -1)
				{
				    if(ModeType > 0)GangZoneHideForAll(zone);
					GangZoneShowForAll(BlackRadar,0x000000FF);
				}
			}
			dini_BoolSet(gConfigFile(),"UseRadar",UseRadar);
		}
		else if (strcmp(gunid, "markerfade", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config markerfade [-1(not used), 0(bases), 1(arenas), 2(tdms), 3(all)]");
			new used = strval(tmp);
			if(used > 3 || used < -1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are: -1(not used), 0(bases), 1(arenas), 2(tdms), 3(all)");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			if(used == MarkerFade)return 1;
			MarkerFade = used;
			format(string,sizeof(string),"Marker fade set to %d",MarkerFade);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"MarkerFade",MarkerFade);
		}
		else if (strcmp(gunid, "mindist", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config mindist [float: value]");
			if(floatstr(tmp) > MaxDist)return SendClientMessage(playerid, MainColors[2], "Error: The minimum marker fade-in must be less than the maximum fade-in.");
			MinDist = floatstr(tmp);
			format(string,sizeof(string),"minimum marker fade-in changed to %.4f",MinDist);
			SendClientMessage(playerid,MainColors[3],string);
			dini_FloatSet(gConfigFile(),"MinDist",MinDist);
		}
		else if (strcmp(gunid, "maxdist", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config maxdist [float: value]");
			if(floatstr(tmp) < MinDist)return SendClientMessage(playerid, MainColors[2], "Error: The maximum marker fade-in must be greater than the minimum fade-in.");
			MaxDist = floatstr(tmp);
			format(string,sizeof(string),"maximum marker fade-in changed to %.4f",MaxDist);
			SendClientMessage(playerid,MainColors[3],string);
			dini_FloatSet(gConfigFile(),"MaxDist",MaxDist);
		}
		else if (strcmp(gunid, "randomization", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config randomization [0 disabled : 1 used]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			Randomization = bool:time;
			if(Randomization == true) SendClientMessage(playerid,MainColors[3],"Teams will now be automatically randomized before automode rounds start.");
			else SendClientMessage(playerid,MainColors[3],"Randomization turned off");
			dini_BoolSet(gConfigFile(),"Randomization",Randomization);
		}
		else if (strcmp(gunid, "autoswap", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config autoswap [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			AutoSwap = bool:time;
			if(AutoSwap == true) SendClientMessage(playerid,MainColors[3],"Teams will now be automatically swapped after a round ends.");
			else SendClientMessage(playerid,MainColors[3],"AutoSwap turned off");
			dini_BoolSet(gConfigFile(),"AutoSwap",AutoSwap);
		}
		else if (strcmp(gunid, "maxping", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config maxping [max ping]");
			new time = strval(tmp);
			MaxPing = time;
			format(string,sizeof(string),"MaxPing changed to %d",MaxPing);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"MaxPing",MaxPing);
		}
		//SendClientMessage(playerid, MainColors[1],"*** rhealth, rarmor, vspawning, weapons");
		else if (strcmp(gunid, "rarmor", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config rarmor [amount]");
			new time = strval(tmp);
			rArmor = time;
			format(string,sizeof(string),"round amount of spawn armor changed to %d",rArmor);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"rArmor",rArmor);
		}
		else if (strcmp(gunid, "rhealth", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config rhealth [amount]");
			new time = strval(tmp);
			rHealth = time;
			format(string,sizeof(string),"round amount of spawn health changed to %d",rHealth);
			SendClientMessage(playerid,MainColors[3],string);
			dini_IntSet(gConfigFile(),"rHealth",rHealth);
		}
		else if (strcmp(gunid, "vspawning", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config vspawning [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			v_AllowSpawning = bool:time;
			if(v_AllowSpawning == true) SendClientMessage(playerid,MainColors[3],"Vehicle spawning has been enabled.");
			else SendClientMessage(playerid,MainColors[3],"Vehicle spawning disabled.");
			dini_BoolSet(gConfigFile(),"vSpawning",v_AllowSpawning);
		}
		else if (strcmp(gunid, "showteamdmg", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config showteamdmg [0 off / 1 shows all teams / 2 shows your own team's]");
			new time = strval(tmp);
			if(time != 0 && time != 1 && time != 2)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0,1,2");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			ShowTeamDmg = time;
			format(string,sizeof(string),"Show Team Damage = %d",ShowTeamDmg);
			SendClientMessage(playerid,MainColors[3],string);
			dini_BoolSet(gConfigFile(),"ShowTeamDmg",ShowTeamDmg);
		}
		else if (strcmp(gunid, "usenametags", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config usenametags [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			UseNameTags = bool:time;
			if(UseNameTags == true) SendClientMessage(playerid,MainColors[3],"Name tags enabled.");
			else SendClientMessage(playerid,MainColors[3],"Name tags disabled.");
			dini_BoolSet(gConfigFile(),"UseNameTags",UseNameTags);
		}
		else if (strcmp(gunid, "privatemode", true, strlen(gunid)) == 0)
		{
            tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /config privatemode [0 no : 1 yes]");
			new time = strval(tmp);
			if(time != 0 && time != 1)
			{
		    	SendClientMessage(playerid,MainColors[2],"Options are 0 or 1!");
		    	PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    	return 1;
			}
			PrivateMode = bool:time;
			if(PrivateMode == true) SendClientMessage(playerid,MainColors[3],"PrivateMode enabled.");
			else SendClientMessage(playerid,MainColors[3],"PrivateMode disabled.");
			dini_BoolSet(gConfigFile(),"PrivateMode",PrivateMode);
			UpdateMapName();
		}
		return 1;
	}
	
	dcmd_end(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0]){return DenyPlayer(playerid);}
	    else if(WatchingBase == true) return SendClientMessage(playerid,MainColors[2], "Bitch, No");

	    new string[128];
	    PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** Admin \"%s\" has Ended the round",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		Current = -1;
		nmtimer = false;
		ModeType = NONE;
		TR_DeathPosInt = 0;
		CPtime[0] = CPtime[1];
		SetGlobalTime(gTime);
		GangZoneDestroy(zone);
		GangZoneHideForAll(BlackRadar);
		UpdateMapName();
		ShowNamesAndBlipsForAll();
		UnlockAllVehicles();
		DestroyRoundVehicles();
		ResetAllNames();
		ResetWeaponSets();
		ResetAllColors();
		AutoModeInit();
		DestroyAllPickups();
		DestroyObjects();
		foreach(Player,i)
		{
		    TD_HideTeamDmgText(i);
		    ResetPlayerWeatherAndTime(i);
 			Spectate_Stop(i);
	    	HasPlayed[i] = false;
   			TR_Kills[i] = 0;
   			TR_Died[i] = false;
   			TR_KillersHP[i] = -1;
   			TR_KillDist[i] = 0;
   			FinishedMenu[i] = false;
   			DisablePlayerCheckpoint(i);
   			DisablePlayerRaceCheckpoint(i);
   			RemovePlayerMapIcon(i,0);
 			RemovePlayerMapIcon(i,1);
			SetPlayerScore(i,TempKills[i]);
			HideAllTextDraws(i);
			if(Playing[i] == true)
			{
   				SetCameraBehindPlayer(i);
				ResetPlayerHealth(i);
				Playing[i] = false;
				RemovePlayingName(i);
				TR_Died[i] = false;
				FindPlayerSpawn(i,0);
				SetPlayerWorldBounds(i,20000,-20000,20000,-20000);
				GiveHimHisGuns(i);
				SetPlayerColorEx(i,TeamInactiveColors[gTeam[i]]);
				SetPlayerNewWorld(i);
			}
		}
		return 1;
	}

	dcmd_startbase(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid,MainColors[2],"Please wait until the current round ends before starting another one.");
	    if(CurrentPlayers[T_HOME] < 1 && CurrentPlayers[T_AWAY] < 1) return SendClientMessage(playerid,MainColors[2],"Not enough players.");
	    if(WatchingBase == true) return SendClientMessage(playerid, MainColors[2], "Please wait until the current round ends before starting another one.");
		if(!strlen(params)) return SendClientMessage(playerid, MainColors[1], "Usage: /startbase [baseid]");
		if(CurrentPlayers[T_HOME] < 1 || CurrentPlayers[T_AWAY] < 1)return SendClientMessage(playerid, MainColors[2], "Not enough players.");
		if(strval(params) == -1)
		{
			new rand = random(MAX_EXISTING[BASE]);
			if(!BaseExists[rand])return SendClientMessage(playerid, MainColors[2], "Try again.");
			new string[128];format(string,sizeof(string),"*** Admin \"%s\" has started random base %d.",NickName[playerid],rand);
			SendClientMessageToAll(MainColors[0],string);
			Round_PreStart();
			SetTimerEx("StartRoundBASE",5000,0,"ii",rand,0);
			return 1;
		}
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new baseid = strval(params);
		if(!BaseExists[baseid]) return SendClientMessage(playerid, MainColors[2], "That base doesn't exist");
		new string[128];format(string,sizeof(string),"*** Admin \"%s\" has started base %d.",NickName[playerid],baseid);
		SendClientMessageToAll(MainColors[0],string);
		Round_PreStart();
		SetTimerEx("StartRoundBASE",5000,0,"ii",baseid,0);
	    return 1;
	}

	dcmd_startarena(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid,MainColors[2],"Please wait until the current round ends before starting another one.");
	    if(WatchingBase == true) return SendClientMessage(playerid, MainColors[2], "Please wait until the current round ends before starting another one.");
		if(!strlen(params)) return SendClientMessage(playerid, MainColors[1], "Usage: /startarena [arenaid]");
		if(strval(params) == -1)
		{
			new rand = random(MAX_EXISTING[ARENA]);
			if(!ArenaExists[rand])return SendClientMessage(playerid, MainColors[2], "Try again.");
			Round_PreStart();
			SetTimerEx("StartRoundARENA",2000,0,"iii",rand,ARENA,0);
			new string[128];format(string,sizeof(string),"*** Admin \"%s\" has started random arena %d.",NickName[playerid],rand);
			SendClientMessageToAll(MainColors[0],string);
			return 1;
		}
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new arenaid = strval(params);
		if(!ArenaExists[arenaid]) return SendClientMessage(playerid, MainColors[2], "That arena doesn't exist");
		Round_PreStart();
		SetTimerEx("StartRoundARENA",2000,0,"iii",arenaid,ARENA,0);
		new string[128];format(string,sizeof(string),"*** Admin \"%s\" has started arena %d.",NickName[playerid],arenaid);
		SendClientMessageToAll(MainColors[0],string);
	    return 1;
	}
	
	Round_PreStart()
	{
	    foreach(Player,i)
	    {
	        if(gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
	        {
	            if(gPlayerSpawned[i] == false && gSelectingClass[i] == false)
	            {
	                SetPlayerHealth(i,100);
	                SpawnPlayer(i);
	            }
	            TogglePlayerControllable(i,0);
	            ViewingBase[i] = true;
	            //TextDrawHideForPlayer(i,MoneyBox);
    			//TextDrawHideForPlayer(i,pText[6][i]);
	        }
	    }
	}

	dcmd_starttdm(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid,MainColors[2],"Please wait until the current round ends before starting another one.");
	    if(WatchingBase == true) return SendClientMessage(playerid, MainColors[2], "Please wait until the current round ends before starting another one.");
		if(!strlen(params)) return SendClientMessage(playerid, MainColors[1], "Usage: /starttdm [arenaid]");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new arenaid = strval(params);
		if(!ArenaExists[arenaid]) return SendClientMessage(playerid, MainColors[2], "That arena doesn't exist");
		StartRoundARENA(arenaid,TDM,0);
		new string[128];format(string,sizeof(string),"*** Admin \"%s\" has started TDM %d.",NickName[playerid],arenaid);
		SendClientMessageToAll(MainColors[0],string);
	    return 1;
	}

	dcmd_roundlimit(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0]){return DenyPlayer(playerid);}
		if(!strval(params)) return SendClientMessage(playerid, MainColors[1], "Usage: /roundlimit [number]");
		new string[128];
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		RoundLimit = strval(params);
		dini_IntSet(gConfigFile(),"RoundLimit",RoundLimit);
		format(string,sizeof(string),"RoundLimit changed to %d.",RoundLimit);
		SendClientMessage(playerid,MainColors[3],string);
	    return 1;
	}

	dcmd_resetscores(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= 0){return DenyPlayer(playerid);}
		new string[128];
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** Admin \"%s\" has reset all scores.",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		Team_ResetScores();
	    return 1;
	}

	dcmd_resetall(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= 0){return DenyPlayer(playerid);}
		new string[128],file[64];
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		RoundsPlayed = 0;
		FinalData[F_Type] = "";
		FinalData[F_ID] = "";
		FinalData[F_Winner] = "";
		FinalData[F_Status] = "";
		FinalData[F_Name] = "";
		new i;
		for(i = 0; i < ACTIVE_TEAMS; i++)
		{
			TeamTotalDeaths[i] = 0;
			TeamTempScore[i] = 0;
			TeamTotalScore[i] = 0;
			TeamRoundsWon[i] = 0;
		}
		foreachex(Player,i)
		{
			TR_Died[i] = false;
			TR_Kills[i] = 0;
			TR_KillersHP[i] = -1;
			TR_KillDist[i] = 0;
			TempKills[i] = 0;
			TempDeaths[i] = 0;
			TempTKs[i] = 0;
			SetPlayerScore(i,0);
			format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[i]);
			dini_IntSet(file,"LastConnect",0);
		}
		format(string,sizeof(string),"*** Admin \"%s\" has reset all match data.",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
	    return 1;
	}

    dcmd_resettemp(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= 0){return DenyPlayer(playerid);}
		new string[128];
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** Admin \"%s\" has reset temp scores.",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		Team_ResetTempScores();
	    return 1;
	}

	dcmd_test(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){return DenyPlayer(playerid);}
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		ShowFinalScores(20);
		SaveMatchResults();
	    return 1;
	}

	dcmd_saver(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    else
		{
		    PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		    SaveRoundResults();
			SaveMatchResults();
		}
	    return 1;
	}

	dcmd_pause(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    #pragma unused params
	    new string[128];
	    format(string,sizeof(string),"*** Admin \"%s\" has Paused the round",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		GamePaused = true;
	    foreach(Player,i)
		{
		    if(Playing[i] == true)
		    {
 				TogglePlayerControllable(i,0);
 				GameTextForPlayer(i,"~r~Game Paused",6000000,3);
			}
		}
	    return 1;
	}

	dcmd_unpause(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    #pragma unused params
	    if(GamePaused == false)
		{
			UpdateRoundII();
		}
		else
		{
	    	new string[128];
	    	format(string,sizeof(string),"*** Admin \"%s\" has Unpaused the round",NickName[playerid]);
			SendClientMessageToAll(MainColors[0],string);
			UnpauseRound();
		}
	    return 1;
	}

	dcmd_allvs(playerid,params[])
	{
        if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
        if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /allvs [name/tag]");
        if(Current != -1)return SendClientMessage(playerid,MainColors[2],"You cannot use this command during a round");
        new found;
        new bool:player[MAX_SERVER_PLAYERS];
        foreach(Player,i)
		{
		    	if(strfind(RealName[i],params,true) != -1 && gPlayerSpawned[i] == true && gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS && AFK[i] == false)
		    	{
		    	    found++;
		    	    player[i] = true;
		    	}
		}
		if(found >= 1)
		{
		    new string[128];
	    	format(string,sizeof(string),"*** Admin \"%s\" has stacked the teams: \"%s\" vs ALL",NickName[playerid],params);
		    SendClientMessageToAll(MainColors[0],string);
		    foreach(Player,i)
			{
			    if(gPlayerSpawned[i] == true && gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
			    {
			    	if(player[i] == true && gTeam[i] != T_HOME)
			    	{
		    			GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
						SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
						SetPlayerColorEx(i,TeamInactiveColors[T_HOME]);
						SetTeam(i,T_HOME);
						RespawnPlayerAtPos(i,1);
					}
					else if(player[i] == false && gTeam[i] != T_AWAY)
					{
						GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
						SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
						SetPlayerColorEx(i,TeamInactiveColors[T_AWAY]);
						SetTeam(i,T_AWAY);
						RespawnPlayerAtPos(i,1);
					}
				}
			}
		}
	    return 1;
	}
	
	dcmd_match(playerid,params[])
	{
        if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
        if(Current != -1)return SendClientMessage(playerid,MainColors[2],"You cannot use this command during a round");
        
        new tmp[32],tmp2[32],idx;
		tmp = strtok_(params, idx);
        if(!strlen(tmp))return SendClientMessage(playerid,MainColors[1],"Usage: /match [name/tag 1] [name/tag 2]");
        tmp2 = strtok_(params, idx);
        if(!strlen(tmp2))return SendClientMessage(playerid,MainColors[1],"Usage: /match [name/tag 1] [name/tag 2]");
		new found[2];
        new bool:player[MAX_SERVER_PLAYERS][2];
        foreach(Player,i)
		{
		    if(gPlayerSpawned[i] == true && AFK[i] == false)
		    {
		    	if(strfind(RealName[i],tmp,true) != -1)
		    	{
		        	found[0]++;
		        	player[i][0] = true;
		    	}
		    	else if(strfind(RealName[i],tmp2,true) != -1)
		    	{
		        	found[1]++;
		        	player[i][1] = true;
		    	}
			}
		}
		if(found[0] >= 1 && found[1] >= 1)
		{
		    new string[128];
	    	format(string,sizeof(string),"*** Admin \"%s\" has matched the teams: \"%s\" vs \"%s\"",NickName[playerid],tmp,tmp2);
		    SendClientMessageToAll(MainColors[0],string);
		    foreach(Player,i)
			{
			    if(gPlayerSpawned[i] == true)
			    {
			        if(player[i][0] == false && player[i][1] == false && gTeam[i] != T_NON)
			        {
			            GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
						SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
						SetPlayerColorEx(i,TeamInactiveColors[T_NON]);
						SetTeam(i,T_NON);
						RespawnPlayerAtPos(i,1);
			        }
			    	else if(player[i][0] == true && gTeam[i] != T_HOME)
			    	{
		    			GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
						SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
						SetPlayerColorEx(i,TeamInactiveColors[T_HOME]);
						SetTeam(i,T_HOME);
						RespawnPlayerAtPos(i,1);
					}
					else if(player[i][1] == true && gTeam[i] != T_AWAY)
					{
						GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
						SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
						SetPlayerColorEx(i,TeamInactiveColors[T_AWAY]);
						SetTeam(i,T_AWAY);
						RespawnPlayerAtPos(i,1);
					}
				}
			}
		}
	    return 1;
	}

	dcmd_load(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx,tmp2[128];
		new gunid[16];
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, MainColors[1],"Usage: /load [load what]");
			SendClientMessage(playerid, MainColors[1],"*** HELP, bases, arenas, config, aconfig, bconfig, pconfig, colors, (objects type[] num)");
			return 1;
		}
		strmid(gunid, tmp, 0, strlen(params), 128);
		if (strcmp(gunid, "bases", true, strlen(gunid)) == 0)
		{
            LoadBases();
            SendClientMessage(playerid,MainColors[3],"Loading bases Complete!");
		}
		else if (strcmp(gunid, "colors", true, strlen(gunid)) == 0)
		{
            LoadColors();
            SendClientMessage(playerid,MainColors[3],"Loading colors Complete!");
		}
		else if (strcmp(gunid, "arenas", true, strlen(gunid)) == 0)
		{
            LoadArenas();
            SendClientMessage(playerid,MainColors[3],"Loading arenas Complete!");
		}
		else if (strcmp(gunid, "config", true, strlen(gunid)) == 0)
		{
            //LoadBases();
            //LoadArenas();
            LoadConfig();
            SendClientMessage(playerid,MainColors[3],"Loading all Complete!");
		}
		else if (strcmp(gunid, "bconfig", true, strlen(gunid)) == 0)
		{
		    tmp2 = strtok_(params, idx);
		    if(strlen(tmp2) < 1 || strval(tmp2) != 0)return 1;
		    new num = strval(tmp2);
		    if(fexist(CBfile(num)))
		    {
		        CurrentConfig[BASE] = num;
		        format(string,sizeof(string),"%d,%d,%d",CurrentConfig[BASE],CurrentConfig[ARENA],CurrentConfig[PLAYER]);
				dini_Set(gConfigFile(),"CurrentConfig",string);
				LoadConfigB(num);
				format(string,sizeof(string),"Weapon Config %d Loaded For Bases!",num);
				SendClientMessage(playerid,MainColors[3],string);
		    }
		}
		else if (strcmp(gunid, "aconfig", true, strlen(gunid)) == 0)
		{
            tmp2 = strtok_(params, idx);
            if(strlen(tmp2) < 1 || strval(tmp2) != 0)return 1;
		    if(fexist(CAfile(strval(tmp2))))
		    {
		        CurrentConfig[ARENA] = strval(tmp2);
		        format(string,sizeof(string),"%d,%d,%d",CurrentConfig[BASE],CurrentConfig[ARENA],CurrentConfig[PLAYER]);
				dini_Set(gConfigFile(),"CurrentConfig",string);
				LoadConfigA(strval(tmp2));
				format(string,sizeof(string),"Weapon Config %d Loaded For Arenas!",strval(tmp2));
				SendClientMessage(playerid,MainColors[3],string);
		    }
		    return 1;
		}
		else if (strcmp(gunid, "pconfig", true, strlen(gunid)) == 0)
		{
            tmp2 = strtok_(params, idx);
            if(strlen(tmp2) < 1 || strval(tmp2) != 0)return 1;
		    if(fexist(CPfile(strval(tmp2))))
		    {
		        CurrentConfig[PLAYER] = strval(tmp2);
		        format(string,sizeof(string),"%d,%d,%d",CurrentConfig[BASE],CurrentConfig[ARENA],CurrentConfig[PLAYER]);
				dini_Set(gConfigFile(),"CurrentConfig",string);
				LoadConfigP(strval(tmp2));
				format(string,sizeof(string),"Weapon Config %d Loaded For Players!",strval(tmp2));
				SendClientMessage(playerid,MainColors[3],string);
		    }
		    return 1;
		}
		else if (strcmp(gunid, "objects", true, strlen(gunid)) == 0)
		{
		    tmp2 = strtok_(params, idx);
		    if(!strlen(tmp2))return 1;
		    new type[128]; type = tmp2;
		    
		    tmp2 = strtok_(params, idx);
		    if(!strlen(tmp2))return 1;
		    new num = strval(tmp2);
			ReloadObjectsEx(num,type);
		}
		return 1;
	}

	dcmd_leader(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
			SendClientMessage(playerid, MainColors[1], "Usage: /leader [playerid] [yes: 1  no: 0]");
			return 1;
		}
		new tmpplayer;
		new level;
		if(IsPlayerConnected(tmpplayer))
		{
			tmpplayer = strval(tmp);
		}
		if(AFK[tmpplayer] == true) return 1;
		tmp = strtok_(params, idx);
		level = strval(tmp);

		if(level != 0 && level != 1)
		{
	 		SendClientMessage(playerid,MainColors[2],"Error: 0 or 1");
	 		PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	 		return 1;
		}
		if(level == 0)format(string,sizeof(string),"*** Admin \"%s\" has removed \"%s's\" Leader status",NickName[playerid],NickName[tmpplayer]);
		else format(string,sizeof(string),"*** Admin \"%s\" has given \"%s\" Leader status.",NickName[playerid],NickName[tmpplayer]);
		SendClientMessageToAll(MainColors[0],string);
		SendClientMessage(tmpplayer,MainColors[3],"You will have additional options as attacker");
		if(level == 1)ClanLeader[tmpplayer] = true;
		else ClanLeader[tmpplayer] = false;
		return 1;
	}

	dcmd_setteam(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /setteam [playerid] [team]");
		new tmpplayer = strval(tmp);
		if(IsPlayerConnected(tmpplayer))
		{
			tmpplayer = strval(tmp);
		}
		if(AFK[tmpplayer] == true || gPlayerSpawned[tmpplayer] == false)return SendClientMessage(playerid,MainColors[2],"Error: Player is AFK or not spawned.");
		
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /setteam [playerid] [team]");
		new teamid = GetTeamIDFromName(tmp);
		if(teamid == -1)
		{
			teamid = strval(tmp);
			if(teamid < 0 || teamid > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		format(string,sizeof(string),"*** Admin \"%s\" has switched \"%s\" to team \"%s\".",NickName[playerid],NickName[tmpplayer],TeamName[teamid]);
		SendClientMessageToAll(MainColors[0],string);

		if(Playing[tmpplayer] == true)RemovePlayerFromRound(tmpplayer);
        GetPlayerPos(tmpplayer,PlayerPosition[tmpplayer][0],PlayerPosition[tmpplayer][1],PlayerPosition[tmpplayer][2]);
  		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		SetPlayerColorEx(tmpplayer,TeamInactiveColors[teamid]);
		SetTeam(tmpplayer,teamid);
 		GetPlayerFacingAngle(tmpplayer,PlayerPosition[tmpplayer][3]);
 		SpawnAtPlayerPosition[tmpplayer] = 1;
 		SetSpawnInfo(tmpplayer,tmpplayer,FindPlayerSkin(tmpplayer),PlayerPosition[tmpplayer][0],PlayerPosition[tmpplayer][1],PlayerPosition[tmpplayer][2],PlayerPosition[tmpplayer][3],0,0,0,0,0,0);
		UpdatePrefixName(tmpplayer);
 		if(Current != -1)
		{
			UpdateRoundII();
		}
 		SpawnPlayer(tmpplayer);
		return 1;
	}
	
	dcmd_givemenu(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current == -1) return SendClientMessage(playerid, MainColors[2], "A round must be active.");
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, MainColors[1], "Usage: /givemenu [playerid]");
		new tmpplayer = strval(tmp);
		if(!IsPlayerConnected(tmpplayer))return SendClientMessage(playerid,MainColors[2],"Invalid Player ID");
		if(ModeType == BASE && gTeam[tmpplayer] > 1)return SendClientMessage(playerid, MainColors[2], "Player cannot be given the weapon menu. (invalid team)");
		if(gTeam[tmpplayer] >= 0 && gTeam[tmpplayer] < ACTIVE_TEAMS && gPlayerSpawned[tmpplayer] == true && AFK[tmpplayer] == false && Playing[tmpplayer] == true)
		{
			format(string,sizeof(string),"*** Admin \"%s\" has brought \"%s\" back into the weapon selection menu",NickName[playerid],NickName[tmpplayer]);
			SendClientMessage(tmpplayer,MainColors[0],string);
			GivenMenu[tmpplayer] = true;
			TogglePlayerControllable(tmpplayer,0);
			SetPlayerVirtualWorld(tmpplayer,0);
			ResetPlayerWeapons(tmpplayer);
			ResetPlayerWeaponSet(tmpplayer);
			SetPlayerCameraLookAt(tmpplayer,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
			SetPlayerCameraPos(tmpplayer,HomeCP[Current][0]+50,HomeCP[Current][1]+50,HomeCP[Current][2]+80);
			WeaponSelection(tmpplayer);
			SetTimerEx("AddPlayerFromMenu",15000,0,"i",tmpplayer);
			format(string,128,"*** Admin \"%s\" has put \"%s\" back into the weapon selection menu.",NickName[playerid],NickName[tmpplayer]);
			SendClientMessageToAll(MainColors[0],string);
			SendClientMessage(tmpplayer,MainColors[3],"You have 15 seconds to reselect your weapons");
			SendClientMessage(tmpplayer,MainColors[3],"If you want to skip the wait type '/ready'");
			SelectingWeaps[tmpplayer] = true;
		}
		return 1;
	}

	dcmd_add(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current == -1) return SendClientMessage(playerid, MainColors[2], "A round must be active.");
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, MainColors[1], "Usage: /add [playerid]");
		new tmpplayer;
		tmpplayer = strval(tmp);
		if(IsPlayerConnected(tmpplayer))
		{
			tmpplayer = strval(tmp);
		}
		if(ModeType == BASE && gTeam[tmpplayer] > 1)return SendClientMessage(playerid,MainColors[2],"Cannot add player because he is not on a valid team for base rounds.");
		if(gTeam[tmpplayer] >= 0 && gTeam[tmpplayer] < ACTIVE_TEAMS && gPlayerSpawned[tmpplayer] == true && AFK[tmpplayer] == false && Playing[tmpplayer] == false)
		{
			format(string,sizeof(string),"*** Admin \"%s\" has brought \"%s\" into the round.",NickName[playerid],NickName[tmpplayer]);
			SendClientMessageToAll(MainColors[0],string);
			AddPlayerToRound(tmpplayer);
		}
		else SendClientMessage(playerid,MainColors[2],"Player must be spawned and on a team!");
		return 1;
	}

	dcmd_remove(playerid,params[])
	{
	    if(!strlen(params) && Playing[playerid] == true)
	    {
	        new string[128];
	        format(string,sizeof(string),"*** Player \"%s\" has removed himself from the round.",NickName[playerid]);
			SendClientMessageToAll(MainColors[0],string);
			RemovePlayerFromRound(playerid);
			return 1;
	    }
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current == -1) return SendClientMessage(playerid, MainColors[2], "A round must be active.");
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp)) return SendClientMessage(playerid, MainColors[1], "Usage: /remove [playerid]");
		new tmpplayer;
		tmpplayer = strval(tmp);
		if(Playing[tmpplayer] == true)
		{
			tmpplayer = strval(tmp);
			format(string,sizeof(string),"*** Admin \"%s\" has removed \"%s\" from the round.",NickName[playerid],NickName[tmpplayer]);
			SendClientMessageToAll(MainColors[0],string);
			RemovePlayerFromRound(tmpplayer);
		}
		else SendClientMessage(playerid,MainColors[2],"Invalid playerid.");
		return 1;
	}

	dcmd_swap(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid,MainColors[2],"The round must be ended");
		#pragma unused params
		new string[128];
  		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** Admin \"%s\" has swapped the teams.",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		Team_Swap();
		format(string,128,"*** \"%s\" (%s): %d || \"%s\" (%s): %d",TeamName[T_HOME],TeamStatusStr[T_HOME],CurrentPlayers[T_HOME],TeamName[T_AWAY],TeamStatusStr[T_AWAY],CurrentPlayers[T_AWAY]);
		SendClientMessageToAll(MainColors[0],string);
		return 1;
	}

	dcmd_balance(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid,MainColors[2],"The round must be ended");
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /balance [type 0(2 teams) or 1(all teams)]");
	    if(strval(params) != 0 && strval(params) != 1)return SendClientMessage(playerid,MainColors[1],"Usage: /balance [type 0(2 teams) or 1(all teams)]");
		if(strval(params) == 0)//2 teams
		{
			Team_Randomize2();
			new string[128];
  			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
			format(string,sizeof(string),"*** Admin \"%s\" has balanced the teams. (2 Teams)",NickName[playerid]);
			SendClientMessageToAll(MainColors[0],string);
			return 1;
		}
		new t;
		new teams_balanced;
		for(new i = 0; i < ACTIVE_TEAMS; i++){if(TeamUsed[i] == true)teams_balanced++;}
		foreach(Player,i)
		{
  			if(gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
  			{
  			    if(TeamUsed[t] == false)t++;
				if(t >= ACTIVE_TEAMS-1)t = 0;
				GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
				SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
				SetPlayerColorEx(i,TeamInactiveColors[t]);
				SetTeam(i,t);
				RespawnPlayerAtPos(i,1);
				t++;
			}
		}
		new string[128];
  		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** Admin \"%s\" has balanced the teams. (%d Teams)",NickName[playerid],teams_balanced);
		SendClientMessageToAll(MainColors[0],string);
		return 1;
	}

	dcmd_switchteam(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid,MainColors[2],"The round must be ended");
	    if(!strlen(params))return SendClientMessage(playerid, MainColors[1], "Usage: /switchteam [TeamID/Name] [TeamID/Name]");
	    
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
   	 	new oldteam = GetTeamIDFromName(tmp);
		if(oldteam == -1)
		{
			oldteam = strval(tmp);
			if(oldteam < 0 || oldteam > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /switchteam [TeamID/Name] [TeamID/Name]");
		new newteam = GetTeamIDFromName(tmp);
		if(newteam == -1)
		{
			newteam = strval(tmp);
			if(newteam < 0 || newteam > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		else
		{
		    PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
			format(string,sizeof(string),"*** Admin \"%s\" has switched players from Team \"%s\" onto Team \"%s\"",NickName[playerid],TeamName[oldteam],TeamName[newteam]);
			SendClientMessageToAll(MainColors[0],string);
		    foreach(Player,i)
   			{
				if(gTeam[i] == oldteam && AFK[i] == false && gPlayerSpawned[i] == true)
				{
				    GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
                    SetPlayerColorEx(i,TeamInactiveColors[newteam]);
					SetTeam(i,newteam);
		    		RespawnPlayerAtPos(i,1);
	    			UpdatePrefixName(i);
				}
			}
		}
		return 1;
	}
	
	dcmd_mainspawn(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],Float:XYZI[4];
	    GetPlayerPos(playerid,XYZI[0],XYZI[1],XYZI[2]);
        XYZI[3] = GetPlayerInterior(playerid);
        MainSpawn[0] = XYZI[0];MainSpawn[1] = XYZI[1];MainSpawn[2] = XYZI[2];MainSpawn[3] = XYZI[3];
        
		format(string,sizeof(string),"%.3f,%.3f,%.3f,%.0f",MainSpawn[0],MainSpawn[1],MainSpawn[2],MainSpawn[3]);
		dini_Set(gConfigFile(),"MainSpawn",string);
  		format(string,128,"MainSpawn Coordinates: %.3f,%.3f,%.3f Int: %.0f",MainSpawn[0],MainSpawn[1],MainSpawn[2],MainSpawn[3]);
  		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}

	dcmd_teamskin(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /teamskin [TeamID/Name] [Skin ID]");
		new teamid = GetTeamIDFromName(tmp);
		if(teamid == -1)
		{
			teamid = strval(tmp);
			if(teamid < 0 || teamid > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		tmp = strtok_(params, idx);
		new skin = strval(tmp);
		if(!IsSkinValid(skin) && skin != -1) return SendClientMessage(playerid,MainColors[2],"Invalid Skin ID.");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		TeamSkin[teamid] = skin;
  		for(new i = 0; i < MAX_TEAMS; i++)
		{
			format(string,sizeof(string),"%s%d,",string,TeamSkin[i]);
		}
		dini_Set(gConfigFile(),"TeamSkin",string);
  		format(string,128,"Team %s(%d) skin has been set to %d",TeamName[teamid],teamid,skin);
  		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}

    dcmd_teamlock(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /teamlock [TeamID/Name] [unlocked:0 locked:1]");
		new teamid = GetTeamIDFromName(tmp);
		if(teamid == -1)
		{
			teamid = strval(tmp);
			if(teamid < 0 || teamid > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		tmp = strtok_(params, idx);
		new level = strval(tmp);
		if(level != 0 && level != 1)return SendClientMessage(playerid,MainColors[2],"options are 0 or 1");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		TeamLock[teamid] = bool:level;
  		for(new i = 0; i < MAX_TEAMS; i++)
		{
			format(string,sizeof(string),"%s%d,",string,TeamLock[i]);
		}
		dini_Set(gConfigFile(),"TeamLock",string);
  		format(string,128,"Team %s(%d) - lock status has been set to %d",TeamName[teamid],teamid,level);
  		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}
	
	dcmd_teamused(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    if(Current != -1)return SendClientMessage(playerid, MainColors[2], "Error: You cannot use this command while a round is in progress.");
	    new string[128],tmp[32],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /teamused [TeamID/Name] [not used:0 used:1]");
		new teamid = GetTeamIDFromName(tmp);
		if(teamid == -1)
		{
			teamid = strval(tmp);
			if(teamid < 0 || teamid > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		tmp = strtok_(params, idx);
		new level = strval(tmp);
		if(level != 0 && level != 1)return SendClientMessage(playerid,MainColors[2],"options are 0 or 1");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		TeamUsed[teamid] = bool:level;
  		TeamsBeingUsed = 0;
  		for(new i = 0; i < MAX_TEAMS; i++)
		{
			format(string,sizeof(string),"%s%d,",string,TeamUsed[i]);
			if(i < ACTIVE_TEAMS && TeamUsed[i] == true)
			{
			    TeamsBeingUsed++;
			}
		}
		foreach(Player,i)
		{
		    if(gTeam[i] == teamid)
		    {
		        ForceClassSelection(i);
		        DontCountDeaths[i] = true;
				SetPlayerHealthEx(i,0.0);
			}
		}
		dini_Set(gConfigFile(),"TeamUsed",string);
  		format(string,128,"Team %s(%d) - usage has been set to %d",TeamName[teamid],teamid,level);
  		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}

	dcmd_teamname(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],nametmp[12],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /teamname [team #] [name - 12 characters max]");
		new oldteam = GetTeamIDFromName(tmp);
		if(oldteam == -1)
		{
			oldteam = strval(tmp);
			if(oldteam < 0 || oldteam > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		nametmp = TeamName[oldteam];
		format(TeamName[oldteam],sizeof(TeamName),"%s",params[idx+1]);
		for(new i; i < MAX_TEAMS; i++)
		{
			format(string,sizeof(string),"%s%s,",string,TeamName[i]);
		}
		dini_Set(gConfigFile(),"TeamName",string);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		Team_UpdatePrefixName(oldteam);
		format(string,128,"Team %s(%d) - name changed to \"%s\"",nametmp,oldteam,TeamName[oldteam]);
  		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}
	
	dcmd_teamvehcolor(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /teamvehcolor [TeamID/Name] [color 1] [color 2]");
		new teamid = GetTeamIDFromName(tmp);
		if(teamid == -1)
		{
			teamid = strval(tmp);
			if(teamid < 0 || teamid > 2)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /teamvehcolor [TeamID/Name] [color 1] [color 2]");
		new col = strval(tmp);
		new col2;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))col2 = col;
		else col2 = strval(tmp);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
  		TeamVehColor[teamid][0] = col;
  		TeamVehColor[teamid][1] = col2;
		format(string,sizeof(string),"%d,%d,%d,%d",TeamVehColor[T_HOME][0],TeamVehColor[T_HOME][1],TeamVehColor[T_AWAY][0],TeamVehColor[T_AWAY][1]);
		dini_Set(gConfigFile(),"TeamVehColor",string);
  		format(string,128,"Team %s(%d) vehicle color has been set to %d,%d",TeamName[teamid],teamid,col,col2);
  		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}
	
	/*dcmd_location(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){DenyPlayer(playerid); return 1;}
	    if(!strlen(params))return SendClientMessage(playerid, MainColors[1], "Usage: /location [playerid] [location string]");
		if(!IsPlayerConnected(strval(params)))return SendClientMessage(playerid, MainColors[2], "Error: Player is not connected.");
		new tmp[32],idx,file[64],player;
		player = strval(params);
        tmp = strtok_(params, idx);
        if(strlen(params[idx+1]) > MAX_COUNTRY_NAME-1)return SendClientMessage(playerid, MainColors[2], "Error: Too long.");
        
        format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[player]);
        format(Location[player],MAX_STRING,"%s",params[idx+1]);
		dini_Set(file,"Location",params[idx+1]);
		format(file,64,"%s's location changed to \"%s\"",NickName[player],Location[player]);
		SendClientMessage(playerid,MainColors[3],file);
		return 1;
	}*/

	dcmd_hosttag(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){DenyPlayer(playerid);return 1;}
		format(HostTag,sizeof(HostTag),"%s",params);
		dini_Set(gConfigFile(),"HostTag",params);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new string[64];format(string,64,"Host Tag changed to\"%s\"",HostTag);
		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}
	
	dcmd_playingtag(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){DenyPlayer(playerid);return 1;}
	    format(PlayingTag,sizeof(PlayingTag),"%s",params);
		dini_Set(gConfigFile(),"PlayingTag",params);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new string[64];format(string,64,"PlayingTag changed to \"%s\"",PlayingTag);
		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}
	
	dcmd_deadtag(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){DenyPlayer(playerid);return 1;}
	    format(DeadTag,sizeof(DeadTag),"%s",params);
		dini_Set(gConfigFile(),"DeadTag",params);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new string[64];format(string,64,"DeadTag changed to \"%s\"",DeadTag);
		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}
	
	/*dcmd_motdtext(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[2]){DenyPlayer(playerid);return 1;}
		if(!strlen(params))return SendClientMessage(playerid, MainColors[1], "Usage: /PlayingTag [MAX CHARS 255]");//the real limit is 255 but we can only use around 120 since the message length is limited to 128
		format(MOTDtext,128,"%s",params);
		dini_Set(gConfigFile(),"MOTDtext",params);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new string[128];format(string,128,"MOTD changed to \"%s\"",MOTDtext);
		SendClientMessage(playerid,MainColors[3],string);
		return 1;
	}*/

	dcmd_setpass(playerid,params[])
	{
		if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[1]){DenyPlayer(playerid);return 1;}
		if(!strlen(params))return SendClientMessage(playerid, MainColors[2], "Usage: /setpass [pass] (20 characters max)");
        new string[128];
		format(ServerPass,sizeof(ServerPass),"%s",params);
		format(string,64,"Password set to \"%s\"",ServerPass);
		SendClientMessage(playerid,MainColors[3],string);
		SendClientMessage(playerid,MainColors[3],"Remove the password by typing \"/setpass off\"");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		return 1;
	}

	dcmd_modemin(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx,time;
	    tmp = strtok_(params, idx);
		time = strval(tmp);
		if(time < 1 && time > 100)
		{
			SendClientMessage(playerid,MainColors[2],"Error: /modemin [1-100]");
 			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
 			return 1;
		}
		ModeMin = time;
		format(string,sizeof(string),"mode minute changed to %d",ModeMin);
		SendClientMessage(playerid,MainColors[3],string);
	    return 1;
	}

    dcmd_movecp(playerid,params[])
	{
	    #pragma unused params
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[0]){return DenyPlayer(playerid);}
		if(Current != -1 && ModeType == BASE)
		{
		    GetPlayerPos(playerid,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid]);
		    foreach(Player,i)
   			{
   				DisablePlayerCheckpoint(i);
	  			SetPlayerCheckpoint(i,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid],CPsize);
   			}
		}
	    return 1;
	}
	
	dcmd_nickall(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[1]){return DenyPlayer(playerid);}
		if(!strlen(params) || strlen(params) > 13)return SendClientMessage(playerid, MainColors[2], "Usage: /nickall [nick] (13 CHARS MAX)");
		
		new string[STR];
		format(string,sizeof(string),"*** Admin \"%s\" has renamed everyone to \"%s\"",NickName[playerid],params);
		SendClientMessageToAll(MainColors[0],string);
		
		foreach(Player,i)
		{
			if(CheckNewName(i,params) == 0)continue;
			format(string,sizeof(string),"%s%d",params,i);
			NickName[i] = string;
			ListName[i] = Misc_RemovePlayerTags(NickName[i]);
			SetPlayerName(i,string);
		}
	    return 1;
	}
	
	dcmd_resetnicks(playerid,params[])
	{
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[1]){return DenyPlayer(playerid);}
        #pragma unused params
		new string[128];
		format(string,sizeof(string),"*** Admin \"%s\" has reset all nicks",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);

		foreach(Player,i)
		{
			NickName[i] = RealName[i];
			ListName[i] = Misc_RemovePlayerTags(NickName[i]);
			SetPlayerName(i,RealName[i]);
		}
	    return 1;
	}
	
	dcmd_teammsg(playerid,params[])
	{
	    if(gTeam[playerid] != T_NON && !IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[1])return SendClientMessage(playerid,MainColors[2],"Error: Only referees and admins can send team messages.");
		new tmp[32],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid,MainColors[3],"Usage: /teamsg [teamid/name] [message]");
        new teamid = GetTeamIDFromName(tmp);
		if(teamid == -1)
		{
			teamid = strval(tmp);
			if(teamid < 0 || teamid > MAX_TEAMS-1)return SendClientMessage(playerid, MainColors[2], "Error: Invalid TeamID or Name.");
		}
		new string[128];
		format(string,128,"Team Msg - %s:  %s",NickName[playerid],params[idx+1]);
		foreach(Player,i)
		{
		    if(sTeam[i] == teamid)
		    {
		        SendClientMessage(i,MainColors[0],string);
		    }
		}
		format(string,128,"Msg Sent: (Team: %s - %d) %s",TeamName[teamid],teamid,params[idx+1]);
		SendClientMessage(playerid,MainColors[0],string);
		return 1;
	}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Public Commands

	dcmd_ignore(playerid,params[])
	{
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[3],"Usage: /ignore [playerid/name]");
		new id = ReturnPlayerID(params,strval(params));
		if(!IsPlayerConnected(id))return SendClientMessage(playerid,MainColors[2],"Error: Player is not connected.");
		if(id == playerid)return SendClientMessage(playerid,MainColors[2],"Error: You cannot ignore yourself.");
		if(IsPlayerAdmin(id))return SendClientMessage(playerid,MainColors[2],"Error: You cannot ignore rcon admins.");
		new string[128];
		if(Ignored[playerid][id] == false)
		{
			Ignored[playerid][id] = true;
			format(string,128,"*** %s (ID: %d) has been added to your ignored list!",NickName[id],id);
			SendClientMessage(playerid,MainColors[3],string);
		}
		else
		{
		    Ignored[playerid][id] = false;
			format(string,128,"*** %s (ID: %d) has been removed from your ignored list!",NickName[id],id);
			SendClientMessage(playerid,MainColors[3],string);
		}
		return 1;
	}
	
    dcmd_sub(playerid,params[])
	{
	    if(Current == -1)return SendClientMessage(playerid,MainColors[2],"You can only sub a player during a round");
	    if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[1] && ClanLeader[playerid] == false){return DenyPlayer(playerid);}
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /sub [player ADD] [player REM]");
 		new ADDplayer = strval(tmp);
		if(!IsPlayerConnected(ADDplayer) || Playing[ADDplayer] == true)return 1;
		if(!IsPlayerConnected(playerid) && Variables[playerid][Level] <= aLvl[1] && gTeam[playerid] != gTeam[ADDplayer] && sTeam[playerid] != gTeam[ADDplayer]) return SendClientMessage(playerid, MainColors[2], "You do not have permission to switch other teams");
		
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid, MainColors[1], "Usage: /sub [player ADD] [player REM]");
  		new REMplayer = strval(tmp);
  		if(!IsPlayerAdmin(playerid) && Variables[playerid][Level] <= aLvl[1] && gTeam[playerid] != gTeam[REMplayer] && sTeam[playerid] != gTeam[REMplayer]) return SendClientMessage(playerid, MainColors[2], "You do not have permission to switch other teams");
		if(!IsPlayerConnected(REMplayer) || Playing[REMplayer] == false)
		{
	 		SendClientMessage(playerid,MainColors[2],"Unable to sub player");
	 		PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
	 		return 1;
		}
		format(string,sizeof(string),"*** \"%s\" has substituted \"%s\" (added) for \"%s\" (removed).",NickName[playerid],NickName[ADDplayer],NickName[REMplayer]);
		SendClientMessageToAll(MainColors[0],string);

		new Float:Health,Float:Armor,wAmmo[4],wSet[4],Int;
    	GetPlayerHealth(REMplayer,Health);
		GetPlayerArmour(REMplayer,Armor);
		GetPlayerPos(REMplayer,PlayerPosition[REMplayer][0],PlayerPosition[REMplayer][1],PlayerPosition[REMplayer][2]);
		SetPlayerPos(REMplayer,PlayerPosition[REMplayer][0],PlayerPosition[REMplayer][1],PlayerPosition[REMplayer][2]+2);
		GetPlayerFacingAngle(REMplayer,PlayerPosition[REMplayer][3]);
		Int = GetPlayerInterior(REMplayer);
		wSet[0] = WeaponSet[REMplayer][0][ModeType];
		wSet[1] = WeaponSet[REMplayer][1][ModeType];
		wSet[2] = WeaponSet[REMplayer][2][ModeType];
		wSet[3] = WeaponSet[REMplayer][3][ModeType];
		GetPlayerWeapons(REMplayer);
		for(new i = 1; i < MAX_SLOTS; i++)
		{
			if(WeaponSet[REMplayer][0][ModeType] == TempGuns[REMplayer][i][GUN])wAmmo[0] = TempGuns[REMplayer][i][AMMO];
   			else if(WeaponSet[REMplayer][1][ModeType] == TempGuns[REMplayer][i][GUN])wAmmo[1] = TempGuns[REMplayer][i][AMMO];
   			else if(WeaponSet[REMplayer][2][ModeType] == TempGuns[REMplayer][i][GUN])wAmmo[2] = TempGuns[REMplayer][i][AMMO];
   			else if(WeaponSet[REMplayer][3][ModeType] == TempGuns[REMplayer][i][GUN])wAmmo[3] = TempGuns[REMplayer][i][AMMO];
		}
		
		ResetPlayerWeapons(ADDplayer);
		SetPlayerPos(ADDplayer,PlayerPosition[REMplayer][0],PlayerPosition[REMplayer][1],PlayerPosition[REMplayer][2]);
		gTeam[ADDplayer] = gTeam[REMplayer];
		SetSpawnInfo(ADDplayer,ADDplayer,FindPlayerSkin(ADDplayer),PlayerPosition[REMplayer][0],PlayerPosition[REMplayer][1],PlayerPosition[REMplayer][2],PlayerPosition[REMplayer][3],0,0,0,0,0,0);
		SpawnAtPlayerPosition[ADDplayer] = 2;
		SpawnPlayer(ADDplayer);
		SetPlayerPos(ADDplayer,PlayerPosition[REMplayer][0],PlayerPosition[REMplayer][1],PlayerPosition[REMplayer][2]);
		SetPlayerColorEx(ADDplayer,TeamActiveColors[gTeam[ADDplayer]]);
		SetPlayerInterior(ADDplayer,Int);
		SetCameraBehindPlayer(ADDplayer);
		GivePlayerWeapon(ADDplayer,wSet[0],wAmmo[0]);
		GivePlayerWeapon(ADDplayer,wSet[1],wAmmo[1]);
		GivePlayerWeapon(ADDplayer,wSet[2],wAmmo[2]);
		GivePlayerWeapon(ADDplayer,wSet[3],wAmmo[3]);
		WeaponSet[ADDplayer][0][ModeType] = wSet[0];
		WeaponSet[ADDplayer][1][ModeType] = wSet[1];
		WeaponSet[ADDplayer][2][ModeType] = wSet[2];
		WeaponSet[ADDplayer][3][ModeType] = wSet[3];
		SetPlayerLife(ADDplayer,Health,Armor);
		SetPlayerVirtualWorld(ADDplayer,1);
		TogglePlayerControllable(ADDplayer,1);
		UpdatePrefixName(ADDplayer);
		IsDueling[ADDplayer] = false;
		DuelInvitation[ADDplayer] = -1;
		if(ModeType == BASE)SetPlayerCheckpoint(ADDplayer,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],CPsize);
		else SetPlayerCheckpoint(ADDplayer,ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2],CPsize);
		if(TeamStatus[gTeam[REMplayer]] == ATTACKING)
		{
			SetPlayerMapIcon(ADDplayer,0,TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],31,0xFFFFFFFF);
			SetPlayerMapIcon(ADDplayer,1,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],RandIcon[random(7)],0xFFFFFFFF);
			SetPlayerRaceCheckpoint(ADDplayer,1,TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],30.0);
			RemovePlayerMapIcon(REMplayer,0);
			RemovePlayerMapIcon(REMplayer,1);
			DisablePlayerRaceCheckpoint(REMplayer);
		}
		Playing[ADDplayer] = true;
		
		SetPlayingName(ADDplayer);
		RemovePlayingName(REMplayer);
		
		Playing[REMplayer] = false;
		ResetPlayerWeapons(REMplayer);
		sTeam[REMplayer] = gTeam[REMplayer];
		gTeam[REMplayer] = T_SUB;
        ResetPlayerHealth(REMplayer);
		ResetPlayerArmor(REMplayer);
		TogglePlayerControllable(REMplayer,1);
		SetPlayerColorEx(REMplayer,TeamInactiveColors[gTeam[REMplayer]]);
		SetPlayerNewWorld(REMplayer);
		ResetPlayerWeaponSet(REMplayer);
		FindPlayerSpawn(REMplayer,1);
		SpawnAtPlayerPosition[REMplayer] = 0;
		SpawnPlayer(REMplayer);
		SetCameraBehindPlayer(REMplayer);
		TD_HidepTextForPlayer(REMplayer,REMplayer,1);
		TD_HidepTextForPlayer(REMplayer,REMplayer,13);
		TD_HideMainTextForPlayer(REMplayer,3);
		TD_HidePanoForPlayer(playerid);
		UpdatePrefixName(REMplayer);
		return 1;
	}
	
	dcmd_tp(playerid,params[])
	{
	    if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're in a round.");
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(gSpectating[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're spectating.");
	    new string[64],tmpplayer;
	    tmpplayer = strval(params);
	    if(!IsPlayerConnected(tmpplayer) || tmpplayer == playerid)return SendClientMessage(playerid,MainColors[2],"Invalid player ID");
	    if(Playing[tmpplayer] == true) return SendClientMessage(playerid,MainColors[2],"Player is in a match.");
	    if(IsDueling[tmpplayer] == true)return SendClientMessage(playerid,MainColors[2],"Player is dueling.");
	    if(gSpectating[tmpplayer] == true)return SendClientMessage(playerid,MainColors[2],"Player is spectating.");
	    if(GetPlayerVirtualWorld(tmpplayer) != GetPlayerVirtualWorld(playerid))return SendClientMessage(playerid,MainColors[2],"Player is in a different world.");
	    if(gPlayerSpawned[tmpplayer] == false)return SendClientMessage(playerid,MainColors[2],"Player isn't spawned.");

	    new Float:Pos[4];
	    GetPlayerPos(tmpplayer,Pos[0],Pos[1],Pos[2]);
	    GetPlayerFacingAngle(tmpplayer,Pos[3]);
	    format(string,sizeof(string),"*** %s (ID:%d) has teleported to you!",NickName[playerid],playerid);
  		SendClientMessage(tmpplayer,MainColors[1],string);
  		
  		SetPlayerInterior(playerid,GetPlayerInterior(tmpplayer));
  		if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
  			SetVehicleZAngle(GetPlayerVehicleID(playerid),0.0);
			SetVehiclePos(GetPlayerVehicleID(playerid),Pos[0]+2,Pos[1]+2,Pos[2]+1);
			LinkVehicleToInterior(GetPlayerVehicleID(playerid),GetPlayerInterior(tmpplayer));
		}
		else
		{
			SetPlayerPos(playerid,Pos[0]+0.5,Pos[1]+0.5,Pos[2]+1);
			SetPlayerFacingAngle(playerid,Pos[3]);
		}
	    return 1;
	}
	
	dcmd_t(playerid,params[])
	{
	    if(Playing[playerid] == true) return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're active in a round.");
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    new string[128],tmp[128],idx;
	    tmp = strtok_(params, idx);
		if(!strval(tmp))
		{
      		if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
		    	LinkVehicleToInterior(GetPlayerVehicleID(playerid),floatround(MainSpawn[3]));
  				SetVehicleZAngle(GetPlayerVehicleID(playerid),0.0);
				SetVehiclePos(GetPlayerVehicleID(playerid),MainSpawn[0]+random(20)-10,MainSpawn[1]+random(20)-10,MainSpawn[2]);
				SetPlayerInterior(playerid,floatround(MainSpawn[3]));
			}
			else
			{
                SetPlayerInterior(playerid,floatround(MainSpawn[3]));
				SetPlayerPos(playerid,MainSpawn[0]+random(20)-10,MainSpawn[1]+random(20)-10,MainSpawn[2]);
			}
   			return 1;
		}
  		
  		SetPlayerInterior(playerid,0);
  		if(GameMap == SA)
  		{
  		    if((strval(tmp) < 0 || strval(tmp) > 9) && strval(tmp) != 99)
			{
				SendClientMessage(playerid,MainColors[2],"Invalid TP zone");
				return 1;
			}
  		    format(string,sizeof(string),"*** \"%s\" has teleported to (SA) TP zone %d (/t %d)",NickName[playerid],strval(tmp),strval(tmp));
  			SendClientMessageToAll(MainColors[0],string);
  			if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
		    	LinkVehicleToInterior(GetPlayerVehicleID(playerid),0);
  				SetVehicleZAngle(GetPlayerVehicleID(playerid),0.0);
				SetVehiclePos(GetPlayerVehicleID(playerid),TeleportsSA[strval(tmp)][0]+random(20),TeleportsSA[strval(tmp)][1]+random(20),TeleportsSA[strval(tmp)][2]);
			}
			else SetPlayerPos(playerid,TeleportsSA[strval(tmp)][0]+random(20),TeleportsSA[strval(tmp)][1]+random(20),TeleportsSA[strval(tmp)][2]);
		}
		else
		{
		    if((strval(tmp) < 0 || strval(tmp) > 23) && strval(tmp) != 99)
			{
				SendClientMessage(playerid,MainColors[2],"Invalid TP zone");
				return 1;
			}
		    format(string,sizeof(string),"*** \"%s\" has teleported to (VCLC) TP zone %d (/t %d)",NickName[playerid],strval(tmp),strval(tmp));
  			SendClientMessageToAll(MainColors[0],string);
		    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
		    	LinkVehicleToInterior(GetPlayerVehicleID(playerid),0);
  				SetVehicleZAngle(GetPlayerVehicleID(playerid),0.0);
				SetVehiclePos(GetPlayerVehicleID(playerid),TeleportsVCLC[strval(tmp)][0]+random(10),TeleportsVCLC[strval(tmp)][1]+random(10),TeleportsVCLC[strval(tmp)][2]);
			}
			else SetPlayerPos(playerid,TeleportsVCLC[strval(tmp)][0]+random(10),TeleportsVCLC[strval(tmp)][1]+random(10),TeleportsVCLC[strval(tmp)][2]);
		}
		return 1;
	}
	
	/*dcmd_killmsg(playerid,params[])
	{
	    if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /killmsg [message that displays for other players when you kill them] (2 - 32 CHARACTERS)");
	    if(strlen(params) <= 1)return SendClientMessage(playerid,MainColors[1],"Usage: /killmsg [message that displays for other players when you kill them] (2 - 32 CHARACTERS)");
	    new file[64],string[32];
		format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		format(string,STR,"%s",params);
	    KillMsg[playerid] = string;
		dini_Set(file,"KillMsg",params);
		SendClientMessage(playerid,MainColors[3],"Kill message updated!");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
	    return 1;
	}*/

	dcmd_nick(playerid,params[])
	{
	    if(Allownicks == false && !IsPlayerAdmin(playerid) && Variables[playerid][Level] < aLvl[0])return 1;
	    if(Allownicks == false && Current != -1 && Playing[playerid] == true && NoNameMode == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command while NoNameMode is activated and you are active in a round");
		if(!strlen(params) || strlen(params) > 16)return SendClientMessage(playerid, MainColors[2], "Usage: /nick (16 characters max)");
		foreach(Player,i)
		{
			if(!strcmp(RealName[i],params,true,strlen(RealName[i])) && i != playerid)return SendClientMessage(playerid,MainColors[2],"Error: This name belongs to someone else");
		}
		if(CheckNewName(playerid,params) == 0)return 1;
		
		new string[128],string2[128],file[64];
		format(string,sizeof(string),"*** \"%s\" is now known as \"%s\"",RealName[playerid],params);
		SendClientMessageToAll(MainColors[0],string);

        format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		format(string2,sizeof(string2),"%s",params);
		SetPlayerName(playerid,string2);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		new nname[24];GetPlayerName(playerid,nname,sizeof(nname));
		NickName[playerid] = nname;
		ListName[playerid] = Misc_RemovePlayerTags(NickName[playerid]);
		dini_Set(file,"Nick",nname);
		return 1;
	}

	dcmd_getnick(playerid,params[])
	{
	    #pragma unused params
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid,MainColors[1],"Usage: /getnick [ID]");
		new giveplayerid;
		giveplayerid = strval(tmp);
		if(IsPlayerConnected(giveplayerid))
		{
		    new name[24];GetPlayerName(giveplayerid,name,sizeof(name));
			format(string,sizeof(string),"Original name \"%s\", currently known as \"%s\"",RealName[giveplayerid],NickName[giveplayerid]);
			SendClientMessage(playerid,MainColors[3],string);
			PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
			return 1;
		}
	 	return SendClientMessage(playerid, MainColors[2], "Invalid Player ID");
	}

	dcmd_resetnick(playerid,params[])
	{
	    #pragma unused params
	    if(Allownicks == false)return SendClientMessage(playerid,MainColors[2],"Error: nick commands have been disabled by an admin");
	    new string[128],file[64];
	    format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
        dini_Set(file,"Nick",RealName[playerid]);
	    SetPlayerName(playerid,RealName[playerid]);
	    format(string,sizeof(string),"*** \"%s\" has reset his/her nickname (\"%s\")",NickName[playerid],RealName[playerid]);
	    NickName[playerid] = RealName[playerid];
	    SendClientMessageToAll(MainColors[0],string);
	    return 1;
	}

	dcmd_v(playerid, params[])
	{
		dcmd_car(playerid,params);
		return 1;
	}

	dcmd_car(playerid,params[])
	{
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(DuelSpectating[playerid] != -1)return SendClientMessage(playerid,MainColors[2],"Error: You cannot spawn vehicles while spectating a duel.");
	    if(gSpectating[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot spawn vehicles while in spectate mode.");
	    if(v_AllowSpawning == false && Playing[playerid] == false)return SendClientMessage(playerid,MainColors[2],"Error: Vehicle spawning has been disabled by an admin.");
	    if(IsPlayerInAnyVehicle(playerid))
	    {
	        if(IsTrailerCompatible(GetVehicleModel(GetPlayerVehicleID(playerid))) == 1)
	        {
	            if(Playing[playerid] == false && (Vehicles >= MAX_SERVER_VEHICLES-1))return SendClientMessage(playerid,MainColors[2],"Error: The vehicle limit has been reached. Try again in a couple minutes.");
	        	if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /car [Model/Name]");
	        	new car,vw,inter,iString[128],idx,Float:XYZ[4];
	        	idx = GetVehicleModelIDFromName(params);
				if(idx != -1 && (v_Usage[idx-400] == 0 || v_Usage[idx-400] == 2 || (Playing[playerid] == true && v_Usage[idx-400] == 3)))return SendClientMessage(playerid,MainColors[2],"Error: This vehicle is disabled.");
				if(idx == -1)
				{
					idx = strval(params);
					if(idx < 400 || idx > 611)return SendClientMessage(playerid, MainColors[2], "Error: Invalid model or name.");
					else if(v_Usage[idx-400] == 0)return SendClientMessage(playerid,MainColors[2],"Error: This vehicle is disabled.");
				}
				if(IsVehicleTrailer(idx))
    			{
    			    vw = GetPlayerVirtualWorld(playerid);
					inter = GetPlayerInterior(playerid);
					GetPlayerPos(playerid,XYZ[0],XYZ[1],XYZ[2]);
	    			GetPlayerFacingAngle(playerid,XYZ[3]);
    			    car = CreateVehicle(idx,XYZ[0]+5,XYZ[1],XYZ[2],XYZ[3],vColor[0][playerid],vColor[1][playerid],cellmax);
					SetVehicleHealth(car,v_Health[GetVehicleModel(car)-400]);
					LinkVehicleToInterior(car,inter);
					SetVehicleVirtualWorld(car,vw);
					v_Trailer[car] = GetPlayerVehicleID(playerid);
					if(v_Trailer[car] != -1)AttachTrailerToVehicle(car,v_Trailer[car]);
    				format(iString,128,"*** Trailer spawned: %s (%d)   HP: %d",CarList[idx-400],idx,v_Health[idx-400]);
    				SendClientMessage(playerid,MainColors[3],iString);
                    Vehicles++;
   	 				if(Playing[playerid] == true)
					{
						VehiclesSpawned[gTeam[playerid]]++;
						v_InRound[car] = true;
						if(TeamVehColor[gTeam[playerid]][0] != -1 || TeamVehColor[gTeam[playerid]][1] != -1)ChangeVehicleColor(car,TeamVehColor[gTeam[playerid]][0],TeamVehColor[gTeam[playerid]][1]);
					}
					else
					{
						v_InRound[car] = false;
						OnPlayerSpawnedVehicle(playerid,car);
					}
 				}
    			else return SendClientMessage(playerid,MainColors[2],"You can only spawn a trailer while inside the Roadtrain, Linerunner, or Tanker");
			}
			return 1;
	    }
	    if(Playing[playerid] == true && (TeamStatus[gTeam[playerid]] != ATTACKING || VehiclesSpawned[gTeam[playerid]] >= (CurrentPlayers[gTeam[playerid]] * VPPPT) || ModeType == ARENA || ModeType == TDM || IsPlayerInAnyVehicle(playerid) || Vehicles > 200 || GetPlayerWeapon(playerid) == 46))return SendClientMessage(playerid,MainColors[2],"No.");
	    if(Playing[playerid] == true && Interior[Current][BASE] != 0)return SendClientMessage(playerid,MainColors[2],"Error: This command is disabled for bases that use interiors");
	    if(Playing[playerid] == false)
	    {
	        if(Vehicles >= MAX_SERVER_VEHICLES-1)return SendClientMessage(playerid,MainColors[2],"Error: The vehicle limit has been reached. Try again in a couple minutes.");
	        if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /car [Model/Name]");
	        new car,vw,inter,iString[128],idx,Float:XYZ[4];
        	idx = GetVehicleModelIDFromName(params);
			if(idx != -1 && (v_Usage[idx-400] == 0 || v_Usage[idx-400] == 2))return SendClientMessage(playerid,MainColors[2],"Error: This vehicle is disabled.");
			if(idx == -1)
			{
				idx = strval(params);
				if(idx < 400 || idx > 611)return SendClientMessage(playerid, MainColors[2], "Error: Invalid model or name.");
				if(v_Usage[idx-400] == 0 || v_Usage[idx-400] == 2)return SendClientMessage(playerid,MainColors[2],"Error: This vehicle is disabled.");
				if(IsVehicleTrailer(idx))return SendClientMessage(playerid,MainColors[2],"Error: You must be in a Roadtrain, Linerunner, or Tanker to spawn a trailer.");
			}
			GetPlayerPos(playerid,XYZ[0],XYZ[1],XYZ[2]);
	    	GetPlayerFacingAngle(playerid,XYZ[3]);
			vw = GetPlayerVirtualWorld(playerid);
			inter = GetPlayerInterior(playerid);
			GetPlayerWeaponData(playerid,4,TempGuns[playerid][4][GUN],TempGuns[playerid][4][AMMO]);
			if(TempGuns[playerid][4][AMMO] > 0)GivePlayerWeapon(playerid,TempGuns[playerid][4][GUN],0);
  			car = CreateVehicle(idx,XYZ[0],XYZ[1],XYZ[2],XYZ[3],vColor[0][playerid],vColor[1][playerid],cellmax);
   			if(!IsVehicleTrailer(idx))PutPlayerInVehicle(playerid,car,0);
			SetVehicleHealth(car,v_Health[GetVehicleModel(car)-400]);
			LinkVehicleToInterior(car,inter);
			SetVehicleVirtualWorld(car,vw);
			Vehicles++;
			OnPlayerSpawnedVehicle(playerid,car);
			v_Trailer[car] = -1;
			v_Exists[car] = true;
			v_InRound[car] = false;
			format(iString,128,"*** Vehicle spawned: %s (%d)   HP: %d",CarList[idx-400],idx,v_Health[idx-400]);
			SendClientMessage(playerid,MainColors[3],iString);
			if(IsNosCompatible(idx) == 1)
			{
				AddVehicleComponent(car,1010);
				AddWheelsToVehicle(playerid,car,Wheels[playerid]);
			}
			return 1;
	    }
	    new Float:x,Float:y,Float:z,Float:r;
	    GetPlayerPos(playerid,x,y,z);
	    if(InRange(x,y,z,TeamBaseSpawns[Current][0][T_HOME],TeamBaseSpawns[Current][1][T_HOME],TeamBaseSpawns[Current][2][T_HOME],125.0))return SendClientMessage(playerid,MainColors[2],"Error: You are too far away from spawn (125+ feet)");
	    if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /car [Model/Name]");
	    new car,vw,inter,iString[128],idx;
    	idx = GetVehicleModelIDFromName(params);
		if(idx != -1 && (v_Usage[idx-400] == 0 || v_Usage[idx-400] == 3))return SendClientMessage(playerid,MainColors[2],"Error: This vehicle is disabled.");
		if(idx == -1)
		{
			idx = strval(params);
			if(idx < 400 || idx > 611)return SendClientMessage(playerid, MainColors[2], "Error: Invalid model or name.");
			if(v_Usage[idx-400] == 0)return SendClientMessage(playerid,MainColors[2],"Error: This vehicle is disabled.");
		}
		GetPlayerFacingAngle(playerid,r);
		vw = GetPlayerVirtualWorld(playerid);
		inter = GetPlayerInterior(playerid);
		GetPlayerWeaponData(playerid,4,TempGuns[playerid][4][GUN],TempGuns[playerid][4][AMMO]);
		if(TempGuns[playerid][4][AMMO] > 0)GivePlayerWeapon(playerid,TempGuns[playerid][4][GUN],0);
		car = CreateVehicle(idx,x,y,z,r,vColor[0][playerid],vColor[1][playerid],cellmax);
		if(!IsVehicleTrailer(idx))
		{
		    SetTimerEx("PutHimInVehicle",500,0,"ii",playerid,car);
			//PutPlayerInVehicle(playerid,car,0);
		}
		SetVehicleHealth(car,v_Health[GetVehicleModel(car)-400]);
		LinkVehicleToInterior(car,inter);
		SetVehicleVirtualWorld(car,vw);
		VehiclesSpawned[gTeam[playerid]]++;
		v_Exists[car] = true;
		v_InRound[car] = true;
		v_Destroy[car] = true;
		v_Trailer[car] = -1;
		Vehicles++;
		if(v_Trailer[car] != -1)AttachTrailerToVehicle(car,v_Trailer[car]);
		if(TeamVehColor[gTeam[playerid]][0] != -1 || TeamVehColor[gTeam[playerid]][1] != -1)ChangeVehicleColor(car,TeamVehColor[gTeam[playerid]][0],TeamVehColor[gTeam[playerid]][1]);
		format(iString,128,"*** Vehicle spawned: %s(%d)   HP: %d   Team Total: %d/%d",CarList[idx-400],idx,v_Health[idx-400],VehiclesSpawned[gTeam[playerid]],(CurrentPlayers[gTeam[playerid]] * VPPPT));
		SendClientMessage(playerid,MainColors[3],iString);
		if(IsNosCompatible(idx) == 1)
		{
			AddVehicleComponent(car,1010);
			AddWheelsToVehicle(playerid,car,Wheels[playerid]);
		}
		return 1;
	}
	
	forward PutHimInVehicle(playerid,vehicleid);
	public PutHimInVehicle(playerid,vehicleid)
	{
	    PutPlayerInVehicle(playerid,vehicleid,0);
	    return 1;
	}

	dcmd_skin(playerid,params[])
	{
	    if(Playing[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot change skins during a round");
	    if(TeamSkin[gTeam[playerid]] != -1)return SendClientMessage(playerid,MainColors[2],"You cannot change your skin at this time.");
	    if(IsPlayerInAnyVehicle(playerid))return 1;
	    if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /skin [ID]");
		if(!IsSkinValid(strval(params)))return SendClientMessage(playerid, MainColors[2],"Invalid Skin ID");
		if(strval(params) == Skin[playerid])return 0;
		Skin[playerid] = strval(params);
		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);dini_IntSet(file,"Skin",strval(params));
		RespawnPlayerAtPos(playerid,1);
	    return 1;
	}
	
	dcmd_weather(playerid,params[])
	{
	    if(Playing[playerid] == true) return SendClientMessage(playerid,MainColors[2],"You cannot change skins during a round");
	    if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /weather [weather id]");
		if(strval(params) == pWeather[playerid])return 1;
		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);dini_IntSet(file,"Weather",strval(params));
		SetPlayerNewWeather(playerid,strval(params));
		pWeather[playerid] = strval(params);
		format(file,sizeof(file),"Weather changed to %d.",strval(params));
		SendClientMessage(playerid,MainColors[3],file);
	    return 1;
	}
	
	dcmd_time(playerid,params[])
	{
	    if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"You cannot change your weather in a round.");
	    if(!strlen(params))return SendClientMessage(playerid, MainColors[1],"Usage: /time [0-24]");
		if(strval(params) < 0 && strval(params) > 24)return SendClientMessage(playerid, MainColors[2],"Invalid parameter. (0-24)");
		if(strval(params) == pTime[playerid][0])return 1;
		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);dini_IntSet(file,"Time",strval(params));
		SetPlayerNewTime(playerid,strval(params),0);
		pTime[playerid][0] = strval(params);
		format(file,sizeof(file),"Time changed to %d.",strval(params));
		SendClientMessage(playerid,MainColors[3],file);
	    return 1;
	}
	
	dcmd_myskill(playerid,params[])
	{
	    #pragma unused params
	    if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"You cannot change your skill in a round.");
	    PlayerWeaponSkillMenu(playerid);
	    return 1;
	}
	
	dcmd_fstyle(playerid,params[])
	{
	    #pragma unused params
	    PlayerFightingMenu(playerid);
	    return 1;
	}
	
	dcmd_wheels(playerid,params[])
	{
	    if(!strlen(params))
		{
			if(!IsPlayerInAnyVehicle(playerid))return WheelMenu1(playerid);
			else return SendClientMessage(playerid,MainColors[2],"Error: You cannot use the wheel menu while in a vehicle. Use \"/wheels [name/modelid]\"");
		}
		new id = GetWheelModelIDFromName(params,strval(params));
		OnPlayerChangedWheels(playerid,id);
		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		dini_IntSet(file,"Wheels",id);
	    return 1;
	}
	
	dcmd_readd(playerid,params[])
	{
	    if(!strlen(params) && Playing[playerid] == true)
	    {
	        if(Playing[playerid] == false)return SendClientMessage(playerid,MainColors[2],"Error: You must be active in a round to use this command.");
	        if(AllowGunMenu == false)return SendClientMessage(playerid,MainColors[2],"Error: You can only re-add yourself within 30 seconds of the round being started.");
	        if(SelectingWeaps[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot be selecting weapons.");
	        new string[128];
	        format(string,sizeof(string),"*** Player \"%s\" has re-added himself to the round.",NickName[playerid]);
			SendClientMessageToAll(MainColors[0],string);
			RemovePlayerFromRound(playerid);
			ResetPlayerWeaponSet(playerid);
			AddPlayerToRound(playerid);
			return 1;
	    }
	    else if(IsPlayerAdmin(playerid) || Variables[playerid][Level] >= aLvl[0])
	    {
			new tmpplayer = strval(params);
			if(!IsPlayerConnected(tmpplayer))return SendClientMessage(playerid,MainColors[2],"Invalid Player ID");
			if(ModeType == BASE && gTeam[tmpplayer] > 1)return SendClientMessage(playerid,MainColors[2],"Cannot re-add player because he is not on a valid team for base rounds.");
			if(SelectingWeaps[tmpplayer] == true)return SendClientMessage(playerid,MainColors[2],"Error: The player cannot be selecting weapons.");
			if(gTeam[tmpplayer] >= 0 && gTeam[tmpplayer] < ACTIVE_TEAMS && gPlayerSpawned[tmpplayer] == true && AFK[tmpplayer] == false && Playing[tmpplayer] == true)
			{
			    new string[128];
			    format(string,sizeof(string),"*** Admin \"%s\" has re-added \"%s\" to the round.",NickName[playerid],NickName[tmpplayer]);
				SendClientMessageToAll(MainColors[0],string);
				RemovePlayerFromRound(tmpplayer);
				SetTimerEx("AddPlayerToRound",500,0,"i",tmpplayer);
			}
		}
  		return 1;
	}

	dcmd_gunmenu(playerid,params[])
	{
		#pragma unused params
	    if(AllowGunMenu == false)return SendClientMessage(playerid,MainColors[2],"Error: You can only reselect weapons within 30 seconds of a round starting");
		if(WatchingBase == true)
		{
	        new Menu:asdf = GetPlayerMenu(playerid);
			if(IsValidMenu(asdf)) HideMenuForPlayer(asdf,playerid);
			ResetPlayerWeaponSet(playerid);
	    	WeaponSelection(playerid);
	    	return 1;
	    }
	    GivenMenu[playerid] = true;
		TogglePlayerControllable(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		ResetPlayerWeapons(playerid);
		ResetPlayerWeaponSet(playerid);
		WeaponSelection(playerid);
		SetTimerEx("AddPlayerFromMenu",15000,0,"i",playerid);
		SendClientMessage(playerid,MainColors[3],"You have 15 seconds to reselect your weapons");
		SendClientMessage(playerid,MainColors[3],"If you want to skip the wait type '/ready'");
		SelectingWeaps[playerid] = true;
		
		if(ModeType == BASE)
		{
		    SetPlayerCameraLookAt(playerid,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
			SetPlayerCameraPos(playerid,HomeCP[Current][0]+50,HomeCP[Current][1]+50,HomeCP[Current][2]+80);
		}
		else
		{
		    SetPlayerCameraLookAt(playerid,ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2]);
			SetPlayerCameraPos(playerid,ArenaCP[Current][0]+50,ArenaCP[Current][1]+50,ArenaCP[Current][2]+80);
		}
	    return 1;
	}

	dcmd_carlist(playerid,params[])
	{
	    #pragma unused params
	    new string[128];
		string = "Available Vehicles: ";
	    for(new i = 0; i < MAX_SPAWNABLE_VEHICLES; i++)
	    {
			if(v_Usage[i] != 0)
			{
	        	if(strlen(string) >= 120)
	        	{
	        		SendClientMessage(playerid, MainColors[3], string);
	        		string = "";
	        	}
				format(string,128,"%s%s, ", string, CarList[i]);
	    	}
		}
	    if(strlen(string) > 0) SendClientMessage(playerid, MainColors[3], string);
	    return 1;
	}

	dcmd_gunlist(playerid,params[])
	{
	    #pragma unused params
 		DisplayAllGuns(playerid);
   		return 1;
	}

 	dcmd_duel(playerid,params[])
	{
	    if(Playing[playerid] == true || gSpectating[playerid] == true)
		{
		    SendClientMessage(playerid, MainColors[2],"You cant use duel while in spec or in a round");
		    PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
		    return 1;
		}

		new pid[16],gun,gun2,player;
	    new string[128],tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid, MainColors[1],"Usage: /duel");
			SendClientMessage(playerid, MainColors[1],"** spec, invite, accept, ignore, disable, enable, leave, stats");
			return 1;
		}

		new wname[32],wname2[32];
		strmid(pid, tmp, 0, strlen(params), 128);
		if(strcmp(pid, "spec", true, strlen(pid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp)){return SendClientMessage(playerid,MainColors[1],"Usage: /duel spec [ID]");}
			player = strval(tmp);
			if(IsDueling[player] == false){return SendClientMessage(playerid,MainColors[2],"* DUEL * Player is not dueling.");}
			ShowPlayerNameTagForPlayer(player,playerid,0);
			ShowPlayerNameTagForPlayer(DuelInvitation[player],playerid,0);
            Duel_CreatePlayerArena(playerid,player);
			DuelSpectating[playerid] = player;
			ShowPlayerNameTagForPlayer(player,playerid,0);
			Duel_SetPlayerPos(2,playerid);
			SetPlayerVirtualWorld(playerid,DuelInvitation[player]+MAX_SERVER_PLAYERS * 2);
			SetPlayerInterior(playerid,1);
			ResetPlayerWeapons(playerid);
		}
		else if (strcmp(pid, "leave", true, strlen(pid)) == 0)
		{
		    if(IsDueling[playerid] == true)
		    {
		        Duel_End(DuelInvitation[playerid],playerid,2);
		    }
		    else if(DuelSpectating[playerid] != -1)
		    {
		        Duel_DestroyPlayerArena(playerid);
		        ResetPlayerHealth(playerid);
		        SpawnPlayer(playerid);
		        SetPlayerInterior(playerid,CurrentInt[playerid]);
		        ShowPlayerNameTagForPlayer(DuelSpectating[playerid],playerid,1);
		        DuelSpectating[playerid] = -1;
		    }
		}
		else if (strcmp(pid, "invite", true, strlen(pid)) == 0)
		{
		    if(DuelDisable[playerid] == true){return SendClientMessage(playerid,MainColors[2],"* DUEL * You need to enable dueling before attemting to send a duel invitation (/duel enable)");}
			if(DuelWaiting[playerid] == true){return SendClientMessage(playerid,MainColors[2],"* DUEL * Please wait until your other invitations have expired.");}
		    tmp = strtok_(params, idx);
			if(!strlen(tmp)){return SendClientMessage(playerid,MainColors[1],"Usage: /duel invite [playerid] [gun id]");}
			player = strval(tmp);
			if(DuelIgnored[player][playerid] == true)return SendClientMessage(playerid,MainColors[2],"* DUEL * This player has chosen to ignore your duel requests.");
		    if(player == playerid)return SendClientMessage(playerid,MainColors[2],"* DUEL * You cannot invite yourself.");
		    if(IsDueling[player] == true) return SendClientMessage(playerid,MainColors[2],"* DUEL * Player is already dueling.");
			if(!IsPlayerConnected(player))return SendClientMessage(playerid,MainColors[2],"* DUEL * No such player.");
			if(DuelDisable[player] == true)return SendClientMessage(playerid,MainColors[2],"* DUEL * Player is not accepting duels.");
			if(DuelWaiting[player] == true)return SendClientMessage(playerid,MainColors[2],"* DUEL * Player has already been requested to duel.");

            tmp = strtok_(params, idx);
			if(!strlen(tmp)){return SendClientMessage(playerid,MainColors[1],"Usage: /duel invite [playerid] [gun id]");}
			gun = GetWeaponModelIDFromName(tmp);
			if(gun == -1)
			{
				gun = strval(tmp);
				if(gun < 22 || gun > 39)
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon ID/Name");
	    			return 1;
				}
			}
			wname = WeaponNames[gun];
			Duel_RandomizeSigns(playerid);

   			tmp = strtok_(params, idx);
			if(!strlen(tmp))
			{
				format(string,sizeof(string),"* DUEL * \"%s\" challenges you to a %s duel. Type \"/duel accept\", you have 20 seconds.",NickName[playerid],wname);
				SendClientMessage(playerid,MainColors[4],"* DUEL * invite sent.");
	    		SendClientMessage(player,MainColors[4],string);
	    		DuelWeapon[playerid][0] = gun;
				DuelWeapon[player][0] = gun;
				DuelWeapon[playerid][1] = 0;
				DuelWeapon[player][1] = 0;
	    		DuelInvitation[player] = playerid;
				DuelWaiting[player] = true;
            	DuelInvitation[playerid] = playerid;
	    		DuelWaiting[playerid] = true;
	    		DuelTimer[playerid] = SetTimerEx("Duel_EndWait",20000,0,"ii",playerid,player);
	    		return 1;
			}
			gun2 = GetWeaponModelIDFromName(tmp);
			if(gun2 == -1)
			{
				gun2 = strval(tmp);
				if(gun2 < 22 || gun2 > 39)
				{
	    			SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon ID/Name");
	    			return 1;
				}
			}
			wname2 = WeaponNames[gun2];
			format(string,sizeof(string),"* DUEL * \"%s\" challenges you to a %s & %s duel. Type \"/duel accept\", you have 20 seconds.",NickName[playerid],wname,wname2);
			SendClientMessage(playerid,MainColors[4],"* DUEL * invite sent.");
 			SendClientMessage(player,MainColors[4],string);
	    	DuelWeapon[playerid][0] = gun;
			DuelWeapon[player][0] = gun;
			DuelWeapon[playerid][1] = gun2;
			DuelWeapon[player][1] = gun2;
	    	DuelInvitation[player] = playerid;
			DuelWaiting[player] = true;
           	DuelInvitation[playerid] = playerid;
	    	DuelWaiting[playerid] = true;
	    	SetTimerEx("Duel_EndWait",20000,0,"ii",playerid,player);
	    	return 1;
  		}
		else if (strcmp(pid, "accept", true, strlen(pid)) == 0)
		{
			if(DuelInvitation[playerid] == -1)return SendClientMessage(playerid,MainColors[2],"* DUEL * You have not received an invitation.");
			if(gPlayerSpawned[DuelInvitation[playerid]] == false)return SendClientMessage(playerid,MainColors[2],"* DUEL * You must wait for the player to respawn.");
			if(DuelInvitation[playerid] == playerid)return SendClientMessage(playerid,MainColors[2],"* DUEL * You cannot accept your own invitations.");

			DuelInvitation[DuelInvitation[playerid]] = playerid;
			
			SetTimerEx("Duel_CreatePlayerArena",500,0,"ii",playerid,DuelInvitation[playerid]);
			SetTimerEx("Duel_CreatePlayerArena",500,0,"ii",DuelInvitation[playerid],DuelInvitation[playerid]);
			//Duel_CreatePlayerArena(playerid);
            //Duel_CreatePlayerArena(DuelInvitation[playerid]);
            
            ViewingResults[DuelInvitation[playerid]] = true;
            ViewingResults[playerid] = true;
            
			Duel_Initiate(playerid,DuelInvitation[playerid],10);
			KillTimer(DuelTimer[DuelInvitation[playerid]]);
			KillTimer(DuelTimer[playerid]);

			ResetPlayerWeapons(playerid);
			Duel_SetPlayerPos(0,playerid);
			SetCameraBehindPlayerEx(playerid);
			ResetPlayerHealth(playerid);
			ResetPlayerArmor(playerid);
			SetPlayerInterior(playerid,1);
			DuelWorld[playerid] = playerid+MAX_SERVER_PLAYERS * 2;
			SetPlayerVirtualWorld(playerid,DuelWorld[playerid]);
			SetPlayerInterior(playerid,1);
			IsDueling[playerid] = true;
			TogglePlayerControllable(playerid,0);
			DuelStarting[playerid] = true;

			ResetPlayerWeapons(DuelInvitation[playerid]);
			Duel_SetPlayerPos(1,DuelInvitation[playerid]);
			SetCameraBehindPlayerEx(DuelInvitation[playerid]);
			ResetPlayerHealth(DuelInvitation[playerid]);
			ResetPlayerArmor(DuelInvitation[playerid]);
			SetPlayerInterior(DuelInvitation[playerid],1);
			DuelWorld[DuelInvitation[playerid]] = playerid+MAX_SERVER_PLAYERS * 2;
			SetPlayerVirtualWorld(DuelInvitation[playerid],DuelWorld[playerid]);
			IsDueling[DuelInvitation[playerid]] = true;
			TogglePlayerControllable(DuelInvitation[playerid],0);
			DuelStarting[DuelInvitation[playerid]] = true;

			wname = WeaponNames[DuelWeapon[playerid][0]];
			wname2 = WeaponNames[DuelWeapon[playerid][1]];
			if(DuelWeapon[playerid][1] != 0)format(string,sizeof(string),"* DUEL * Initiating  ...  \"%s\" <VS> \"%s\"  ...  Weapons: %s & %s *** (/duel spec %d)",NickName[playerid],NickName[DuelInvitation[playerid]],wname,wname2,DuelInvitation[playerid]);
			else format(string,sizeof(string),"* DUEL * Initiating  ...  \"%s\"  vs  \"%s\"  ...  Weapon: %s  (/duel spec %d)",NickName[playerid],NickName[DuelInvitation[playerid]],wname,DuelInvitation[playerid]);
			SendClientMessageToAll(MainColors[4],string);

			DuelWaiting[playerid] = false;
			DuelWaiting[DuelInvitation[playerid]] = false;
            if(Chase_ChaseID[DuelInvitation[playerid]] != -1)Chase_Finish(DuelInvitation[playerid],Chase_ChaseID[DuelInvitation[playerid]],255);
            if(Chase_ChaseID[playerid] != -1)Chase_Finish(playerid,Chase_ChaseID[playerid],255);
			foreach(Player,i)
			{
			    if(Chase_ChaseID[i] == playerid)Chase_Finish(i,Chase_ChaseID[playerid],255);
			    if(gSpectateID[i] == playerid || gSpectateID[i] == DuelInvitation[playerid])
			    {
			        SetTimerEx("Spectate_ReSpecPlayer",400,0,"ii",i,gSpectateID[playerid]);
			    }
			}
			return 1;
		}
		else if(strcmp(pid, "ignore", true, strlen(pid)) == 0)
		{
		    tmp = strtok_(params, idx);
			if(!strlen(tmp))return SendClientMessage(playerid,MainColors[3],"Usage: /duel ignore [playerid/name]");
			new id = ReturnPlayerID(tmp,strval(tmp));
			if(!IsPlayerConnected(id))return SendClientMessage(playerid,MainColors[2],"Error: Player is not connected.");
			if(id == playerid)return SendClientMessage(playerid,MainColors[2],"Error: You cannot ignore yourself.");
			if(DuelIgnored[playerid][id] == false)
			{
				DuelIgnored[playerid][id] = true;
				format(string,128,"*** %s (ID: %d) has been added to your duel-ignored list!",NickName[id],id);
				SendClientMessage(playerid,MainColors[3],string);
			}
			else
			{
		    	DuelIgnored[playerid][id] = false;
				format(string,128,"*** %s (ID: %d) has been removed from your duel-ignored list!",NickName[id],id);
				SendClientMessage(playerid,MainColors[3],string);
			}
		}
		else if (strcmp(pid, "disable", true, strlen(pid)) == 0)
		{
		    if(DuelDisable[playerid] == false)DuelDisable[playerid] = true;
			else return SendClientMessage(playerid,MainColors[2],"Dueling is already disabled.");
		}
		else if (strcmp(pid, "enable", true, strlen(pid)) == 0)
		{
		    if(DuelDisable[playerid] == true)DuelDisable[playerid] = false;
			else return SendClientMessage(playerid,MainColors[2],"Dueling is already enabled.");
		}
		else if (strcmp(pid, "stats", true, strlen(pid)) == 0)
		{
		    new dplayer[128],dplayer2[128];
		    tmp = strtok_(params, idx);
		    if(!strlen(tmp))return Duel_ShowStats(playerid,RealName[playerid]);
		    if(strlen(tmp) > 1)
		    {
		        dplayer = tmp;
		        new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(dplayer));
				if(!fexist(file))return SendClientMessage(playerid,MainColors[2],"No account found by that name");
		    }
		    else
		    {
		        if(!IsPlayerConnected(strval(tmp))) return SendClientMessage(playerid,MainColors[2],"Error: Invalid player ID");
		        dplayer = RealName[strval(tmp)];
		    }
		    
            tmp = strtok_(params, idx);
            if(!strlen(tmp))return Duel_ShowStats(playerid,dplayer);
			if(strlen(tmp) > 1)
		    {
		        dplayer2 = tmp;
		        new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(dplayer2));
				if(!fexist(file))return SendClientMessage(playerid,MainColors[2],"No account found by that name");
		    }
		    else
		    {
		        if(!IsPlayerConnected(strval(tmp))) return SendClientMessage(playerid,MainColors[2],"Error: Invalid player ID");
		        dplayer2 = RealName[strval(tmp)];
		    }
			Duel_ShowPvPStats(playerid,dplayer,dplayer2);
		}
		else
		{
			SendClientMessage(playerid, MainColors[2], "Invalid parameters");
			PlayerPlaySound(playerid,denied,0.0,0.0,0.0);
			return 1;
		}
		return 1;
	}
	
	dcmd_help(playerid,params[])
	{
	    #pragma unused params
		SendClientMessage(playerid,MainColors[0],"Welcome to BB Clan Server!");
  		SendClientMessage(playerid,MainColors[1],"BattleGrounds saves your statistics and weapons so you don't lose them when you leave.");
  		SendClientMessage(playerid,MainColors[1],"Make sure you register an account by typing /XREGISTER [PASSWORD]");
  		SendClientMessage(playerid,MainColors[1],"After you register your account will be protected from impersonators and anyone trying to tarnish your stats.");
		SendClientMessage(playerid,MainColors[3],"For more help type /commands and /rules");
	    return 1;
	}

	dcmd_rules(playerid,params[])//make this whatever you want
	{
	    #pragma unused params
	    //ShowMOTD(playerid);
		SendClientMessage(playerid,MainColors[0],"BattleGrounds rules:");
 		SendClientMessage(playerid,MainColors[1],"1st RULE: You do not talk about FIGHT CLUB");
 		SendClientMessage(playerid,MainColors[1],"2nd RULE: You DO NOT talk about FIGHT CLUB.");
 		SendClientMessage(playerid,MainColors[1],"3rd RULE: If someone says \"stop\", goes limp, taps out, the fight is over.");
 		SendClientMessage(playerid,MainColors[1],"4th RULE: Only two guys to a fight.");
 		SendClientMessage(playerid,MainColors[1],"5th RULE: One fight at a time.");
 		SendClientMessage(playerid,MainColors[1],"6th RULE: No shirts, no shoes.");
 		SendClientMessage(playerid,MainColors[1],"7th RULE: Fights will go on as long as they have to.");
 		SendClientMessage(playerid,MainColors[1],"8th RULE: If this is your first night at FIGHT CLUB, you HAVE to fight.");
		SendClientMessage(playerid,MainColors[3],"For help type /help or /commands");
	    return 1;
	}

	dcmd_credits(playerid,params[])
	{
	    #pragma unused params
		SendClientMessage(playerid,0xFFFFFFFF,"The \"BattleGrounds Script\" was originally created by Boylett and [NB]90N1N3 as \"Mission Rumble\" it is now being continued by Cadetz & MozZ_");
		SendClientMessage(playerid,0xFFFFFFFF,"    Other people that contributed to the development of the gamemode are:");
     	SendClientMessage(playerid,MainColors[3],"    Incognito, Eminich, DrVibrator, Lop_Dog, Ryden, Dracoblue, moe, Sneaky, mabako, Simon, SeriouS, SA-MP Team, Utkugur.");
	    return 1;
	}

 	dcmd_highscore(playerid,params[])
	{
	    #pragma unused params
		new highscorer,string[128];
		highscorer = GetPlayerWithHighestScore();
		if(TR_Kills[highscorer] > 0)
		{
			format(string,sizeof(string),"*** Top Shotta: %s  || Kills: %d ***",NickName[highscorer],TR_Kills[highscorer]);
	    	SendClientMessage(playerid,0xFFFFFFFF,string);
		}
	    return 1;
	}

	dcmd_commands(playerid,params[])
	{
	    #pragma unused params
 		if(Variables[playerid][Level] >= aLvl[0] || IsPlayerAdmin(playerid))
 		{
			SendClientMessage(playerid,MainColors[3],"    Admin Commands");
			SendClientMessage(playerid,MainColors[3],"    /a, /b, /add, /end, /test, /swap, /load, /saver, /pause, /config, /leader, /remove, /movecp, /unpause");
			SendClientMessage(playerid,MainColors[3],"    /setteam, /balance, /hosttag, /setpass, /modemin, /starttdm, /resetall, /teamskin, /teamlock, /teamname");
			SendClientMessage(playerid,MainColors[3],"    /givemenu, /startbase, /resettemp, /mainspawn, /startarena, /roundlimit, /switchteam, /resetscores");
			SendClientMessage(playerid,MainColors[3],"    /delacc, /resetacc, /allvs, /match, /nickall, /resetnicks, /playingtag, /teamused, /location, /deadtag");

			SendClientMessage(playerid,MainColors[1],"    Public Commands");
 			SendClientMessage(playerid,MainColors[1],"    /spawn, /afk, /switch, /kill, /sync, /highscore, /view, /world, /worldpass, /fixr, /wheels");
			SendClientMessage(playerid,MainColors[1],"    /int, /wlist, /vcolor, /scores, /hide, /t, /getnick, /nick, /resetnick, /car, /skin, /gunmenu, /chase");
			SendClientMessage(playerid,MainColors[1],"    /carlist, /gunlist, /duel, /help, /rules, /credits, /stats, /resetguns, /getgun, /removegun, /spec");
			SendClientMessage(playerid,MainColors[1],"    /specoff, /teams, /d, /pass, /back, /killmsg, /ready, /give, /drop, /remove, /readd, /teammsg, /ignore");
			SendClientMessage(playerid,MainColors[1],"    /time, /weather, /gotoloc, /saveloc, /myskill, /fstyle");
 			return 1;
		}
		SendClientMessage(playerid,MainColors[1],"    Public Commands");
		SendClientMessage(playerid,MainColors[1],"    /spawn, /afk, /switch, /kill, /sync, /highscore, /view, /world, /worldpass, /fixr, /wheels");
		SendClientMessage(playerid,MainColors[1],"    /int, /wlist, /vcolor, /scores, /hide, /t, /getnick, /nick, /resetnick, /car, /skin, /gunmenu, /chase");
		SendClientMessage(playerid,MainColors[1],"    /carlist, /gunlist, /duel, /help, /rules, /credits, /stats, /resetguns, /getgun, /removegun, /spec");
		SendClientMessage(playerid,MainColors[1],"    /specoff, /teams, /d, /pass, /back, /killmsg, /ready, /give, /drop, /remove, /readd, /teammsg, /ignore");
		SendClientMessage(playerid,MainColors[1],"    /time, /weather, /gotoloc, /saveloc, /myskill, /fstyle");
	    return 1;
	}
	
	dcmd_ready(playerid,params[])
	{
	    #pragma unused params
		if(SelectingWeaps[playerid] == true)
		{
		    SelectingWeaps[playerid] = false;
		    GivenMenu[playerid] = false;
			if(Current == -1)
			{
	    		HideAllTextDraws(playerid);
	    		ResetPlayerHealth(playerid);
				ResetPlayerArmor(playerid);
				Playing[playerid] = false;
				TogglePlayerControllable(playerid,1);
				SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
				SetPlayerNewWorld(playerid);
				ResetPlayerWeaponSet(playerid);
				RemovePlayerFromVehicle(playerid);
				SpawnAtPlayerPosition[playerid] = 0;
				FindPlayerSpawn(playerid,1);
				SpawnPlayer(playerid);
				SetCameraBehindPlayer(playerid);
				new Menu:current = GetPlayerMenu(playerid);
				if(IsValidMenu(current)) HideMenuForPlayer(current, playerid);
				return 1;
			}
			TD_HidepTextForPlayer(playerid,playerid,2);
   		 	TD_HideMainTextForPlayer(playerid,13);
    		TogglePlayerControllable(playerid,1);
    		SetPlayerVirtualWorld(playerid,1);
			ViewingResults[playerid] = false;
			new Menu:current = GetPlayerMenu(playerid);
			if(IsValidMenu(current)) HideMenuForPlayer(current, playerid);
 			StrapUp(playerid);
			ResetPlayerHealth(playerid);
			ResetPlayerArmor(playerid);
			SetPlayerColorEx(playerid,TeamActiveColors[gTeam[playerid]]);
			SetCameraBehindPlayerEx(playerid);
			if(ModeType == TDM || ModeType == ARENA)SpawnAtPlayerPosition[playerid] = 4;
		    return 1;
		}
		return 1;
	}

	dcmd_stats(playerid,params[])
	{
	    #pragma unused params
        new tmp[128],idx;
		new dplayer[128],dplayer2[128];
  		tmp = strtok_(params, idx);
    	if(!strlen(tmp))return ShowStats(playerid,RealName[playerid]);
    	if(strlen(tmp) > 2)//input is longer than 2 characters
    	{
    		dplayer = tmp;
    		new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(dplayer));
			if(!fexist(file))return SendClientMessage(playerid,MainColors[2],"No account found by that name");
  		}
  		else//input is an ID
  		{
  			if(!IsPlayerConnected(strval(tmp)))return SendClientMessage(playerid,MainColors[2],"Error: Invalid player ID");
  			dplayer = RealName[strval(tmp)];
  		}
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return ShowStats(playerid,dplayer);
		if(strlen(tmp) > 1)
		{
			dplayer2 = tmp;
			new file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(dplayer2));
			if(!fexist(file))return SendClientMessage(playerid,MainColors[2],"No account found by that name");
		}
		else
		{
			if(!IsPlayerConnected(strval(tmp)))return SendClientMessage(playerid,MainColors[2],"Error: Invalid player ID");
			dplayer2 = RealName[strval(tmp)];
		}
		ShowPvPRoundStats(playerid,dplayer,dplayer2);
		Duel_ShowPvPStats(playerid,dplayer,dplayer2);
		return 1;
	}

	dcmd_resetguns(playerid,params[])
	{
	    #pragma unused params
	    new file[64],string[10];
		format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		for(new i = 1; i < MAX_SLOTS; i++)
		{
		    PlayerWeapons[playerid][i] = 0;
	    	format(string,sizeof(string),"wS%d",i);
	    	dini_IntSet(file,string,0);
		}
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		SendClientMessage(playerid,MainColors[3],"Guns removed!");
		if(Playing[playerid] == false)
		{
			ResetPlayerWeapons(playerid);
		}
	    return 1;
	}

	dcmd_getgun(playerid,params[])
	{
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"You cannot use this command while you are in a match.");
	    new tmp[128],idx;
		tmp = strtok_(params, idx);
		if(!strlen(tmp))
		{
		    SendClientMessage(playerid,MainColors[1],"Usage: /getgun [gun name]");
		    DisplayGetGuns(playerid);
		    return 1;
		}
		new weaponid = GetWeaponModelIDFromName(tmp);
		if(weaponid == -1)
		{
			weaponid = strval(tmp);
			if(weaponid < 0 || weaponid > 47)
			{
	    		SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon Name");
	    		return 1;
			}
		}
		if(PlayerWeapons[playerid][GetWeaponSlot(weaponid)] == weaponid)return SendClientMessage(playerid,MainColors[2],"You already have that weapon!");
		if(!strlen(params[idx+1]))
		{
		    new slot = GetWeaponSlot(weaponid);
	    	if(slot == -1)return 1;
	    	if(PlayerWeapons[playerid][slot] == weaponid)return 1;
	    	new string[100];
	    	if(pGunUsed[weaponid] == 0)
	    	{
	    	    format(string,sizeof(string),"The \"%s\" is unavailable.",WeaponNames[weaponid]);
				SendClientMessage(playerid,MainColors[2],string);
	    	    return 1;
	    	}
	    	new file[64];
			format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
   			format(string,sizeof(string),"wS%d",GetWeaponSlot(weaponid));
   			dini_IntSet(file,string,weaponid);
   			if(PlayerWeapons[playerid][GetWeaponSlot(weaponid)] == weaponid)
   			{
   			    PlayerPlaySound(playerid,1052,0.0,0.0,0.0);
				GivePlayerWeapon(playerid,weaponid,-pGunAmmo[weaponid]);
				GivePlayerWeapon(playerid,weaponid,1);
				GivePlayerWeapon(playerid,weaponid,pGunAmmo[weaponid]-1);
   			}
   			else
   			{
   			    PlayerWeapons[playerid][GetWeaponSlot(weaponid)] = weaponid;
   			    GivePlayerWeapon(playerid,weaponid,pGunAmmo[weaponid]);
   			}
   			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			format(string,sizeof(string),"*** Weapon Acquired: \"%s\" (ID:%d)  ||  Slot: %d  ||  Ammo: %d",WeaponNames[weaponid],weaponid,GetWeaponSlot(weaponid),pGunAmmo[weaponid]);
			SendClientMessage(playerid,MainColors[3],string);
			return 1;
		}
		return 1;
	}

	dcmd_removegun(playerid,params[])
	{
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"You cannot use this command while you are in a match.");
	    new tmp[128],idx;
		tmp = strtok_(params, idx);

        if(!strlen(tmp))
		{
		    SendClientMessage(playerid,MainColors[1],"Usage: /removegun [gun name]");
		    DisplayPlayerGuns(playerid);
		    return 1;
		}

		new weaponid = GetWeaponModelIDFromName(tmp);
		if(weaponid == -1)
		{
			weaponid = strval(tmp);
			if(weaponid < 0 || weaponid > 46)
			{
	    		SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon name");
	    		return 1;
			}
		}
		if(!strlen(params[idx+1]))
		{
	    	if(GetWeaponSlot(weaponid) == -1)return 1;
	    	new string[64];
	    	if(PlayerWeapons[playerid][GetWeaponSlot(weaponid)] != weaponid)
	    	{
	    	    format(string,sizeof(string),"You don't have a(n) \"%s\".",WeaponNames[weaponid]);
				SendClientMessage(playerid,MainColors[2],string);
	    	    return 1;
	    	}
	    	new file[64];
			format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
   			format(string,sizeof(string),"wS%d",GetWeaponSlot(weaponid));
   			dini_IntSet(file,string,0);
  			PlayerWeapons[playerid][GetWeaponSlot(weaponid)] = 0;
   			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
			ResetPlayerWeapons(playerid);
			GiveHimHisGuns(playerid);
			format(string,sizeof(string),"*** Weapon Removed: \"%s\" (ID:%d)  ||  Slot: %d",WeaponNames[weaponid],weaponid,GetWeaponSlot(weaponid));
			SendClientMessage(playerid,MainColors[3],string);
			return 1;
		}
		return 1;
	}
	
	dcmd_give(playerid,params[])
	{
	    if(Current == -1 || Playing[playerid] == false)return SendClientMessage(playerid,MainColors[2],"Error: You must be active in a round.");
	    new tmp[128],string[128],idx;
		tmp = strtok_(params, idx);
	    if(!strlen(tmp))return SendClientMessage(playerid,MainColors[1],"Usage: /give [ID] [GUN ID/NAME] [AMMO]");
	    new player = strval(tmp);
	    if(!IsPlayerConnected(player))return SendClientMessage(playerid,MainColors[2],"Error: Invalid player ID.");
	    if(player == playerid)return SendClientMessage(playerid,MainColors[2],"Error: Too bad ExPloiTeD, you can't give yourself ammo anymore.");
	    if(Playing[player] == false)return SendClientMessage(playerid,MainColors[2],"Error: Player must be active in a round");
	    if(gTeam[player] != gTeam[playerid])return SendClientMessage(playerid,MainColors[2],"Error: Player must be on the same team as you.");
	    new Float:p[3],Float:p2[3];GetPlayerPos(playerid,p[0],p[1],p[2]);GetPlayerPos(player,p2[0],p2[1],p2[2]);
		if(InRange(p[0],p[1],p[2],p2[0],p2[1],p2[2],7.0))return SendClientMessage(playerid,MainColors[2],"Error: You are too far away (7+ ft)");
		
		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid,MainColors[1],"Usage: /give [ID] [GUN ID/NAME] [AMMO]");
		new weaponid = GetWeaponModelIDFromName(tmp);
		if(weaponid == -1)
		{
			weaponid = strval(tmp);
			if(weaponid <= 0 || weaponid > 46)return SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon ID/NAME");
		}
		new YourGunz[MAX_SLOTS][2],HisGunz[MAX_SLOTS][2],Ammo;
		for(new i = 2; i < MAX_SLOTS-3; i++)
		{
	    	GetPlayerWeaponData(playerid,i,YourGunz[i][GUN],YourGunz[i][AMMO]);
  			GetPlayerWeaponData(player,i,HisGunz[i][GUN],HisGunz[i][AMMO]);
		}
    	for(new i = 1; i < MAX_SLOTS; i++)
		{
	    	if(i > 1 && i < 10)continue;
	    	else
			{
				GetPlayerWeaponData(playerid,i,YourGunz[i][GUN],YourGunz[i][AMMO]);
  				GetPlayerWeaponData(player,i,HisGunz[i][GUN],HisGunz[i][AMMO]);
				if(YourGunz[i][AMMO] > 1)YourGunz[i][AMMO] = 1;
				if(HisGunz[i][AMMO] > 1)HisGunz[i][AMMO] = 1;
			}
		}
		new slot = GetWeaponSlot(weaponid);
  		if(YourGunz[slot][GUN] != weaponid)return SendClientMessage(playerid, MainColors[2], "Error: You do not have this weapon.");
  		if(YourGunz[slot][AMMO] >= 65535 && YourGunz[slot][GUN] >= 16)return SendClientMessage(playerid, MainColors[2], "Error: An error occured while retrieving your weapon data. Please try again.");
  		if(HisGunz[slot][AMMO] >= 65535 && HisGunz[slot][GUN] >= 16)return SendClientMessage(playerid, MainColors[2], "Error: An error occured while retrieving his weapon data. Please try again.");
  		
  		tmp = strtok_(params, idx);
		if(!strlen(tmp))return SendClientMessage(playerid,MainColors[1],"Usage: /give [ID] [GUN ID/NAME] [AMMO]");
		Ammo = strval(tmp);
		if(Ammo > YourGunz[slot][AMMO])return SendClientMessage(playerid, MainColors[2], "Error: You dont have that amount.");
		if(SameWeapon(player,weaponid) == 1)
		{
      		if(WeaponClipSize[weaponid] == 1)return SendClientMessage(playerid, MainColors[2], "Error: Player can only carry one of those.");
      		HisGunz[slot][AMMO]+=Ammo;
      		YourGunz[slot][AMMO]-=Ammo;
      		ResetPlayerWeapons(playerid);
			ResetPlayerWeapons(player);
			new pweap = GetPlayerWeapon(player);
			new pslot = GetWeaponSlot(pweap);
      		for(new i = 1; i < MAX_SLOTS; i++)
			{
				if((HisGunz[i][GUN] > 0 || HisGunz[i][AMMO] > 0) && i != pslot)GivePlayerWeapon(player,HisGunz[i][GUN],HisGunz[i][AMMO]);
				if(YourGunz[i][GUN] > 0 || YourGunz[i][AMMO] > 0)GivePlayerWeapon(playerid,YourGunz[i][GUN],YourGunz[i][AMMO]);
			}
			GivePlayerWeapon(player,HisGunz[pslot][GUN],HisGunz[pslot][AMMO]);
      		format(string,128,"*** \"%s\" has given you %d ammo for your %s",NickName[playerid],Ammo,WeaponNames[weaponid]);
        	SendClientMessage(player,MainColors[1],string);
        	format(string,128,"*** You have given \"%s\" %d ammo for his %s",NickName[player],Ammo,WeaponNames[weaponid]);
       		SendClientMessage(playerid,MainColors[3],string);
         	TR_StartGun[player][slot][AMMO]+=Ammo;
          	TR_StartGun[playerid][slot][AMMO]-=Ammo;
          	if(TR_StartGun[playerid][slot][AMMO] == 0)TR_StartGun[playerid][slot][GUN] = 0;
		}
		else if(SameTypeOfWeaponII(player,slot) == 0)
		{
		    if(weaponid == 16 || weaponid == 17 || weaponid == 18)
		    {
      			HisGunz[slot][AMMO]+=Ammo;
      			YourGunz[slot][AMMO]-=Ammo;
      			ResetPlayerWeapons(playerid);
				ResetPlayerWeapons(player);
				new pweap = GetPlayerWeapon(player);
				new pslot = GetWeaponSlot(pweap);
      			for(new i = 1; i < MAX_SLOTS; i++)
				{
					if((HisGunz[i][GUN] > 0 || HisGunz[i][AMMO] > 0) && i != pslot)GivePlayerWeapon(player,HisGunz[i][GUN],HisGunz[i][AMMO]);
					if(YourGunz[i][GUN] > 0 || YourGunz[i][AMMO] > 0)GivePlayerWeapon(playerid,YourGunz[i][GUN],YourGunz[i][AMMO]);
				}
				GivePlayerWeapon(player,HisGunz[pslot][GUN],HisGunz[pslot][AMMO]);
      			format(string,128,"*** \"%s\" has given you %d ammo for your %s",NickName[playerid],Ammo,WeaponNames[weaponid]);
        		SendClientMessage(player,MainColors[1],string);
        		format(string,128,"*** You have given \"%s\" %d ammo for his %s",NickName[player],Ammo,WeaponNames[weaponid]);
       			SendClientMessage(playerid,MainColors[3],string);
         		TR_StartGun[player][slot][AMMO]+=Ammo;
          		TR_StartGun[playerid][slot][AMMO]-=Ammo;
          		if(TR_StartGun[playerid][slot][AMMO] == 0)TR_StartGun[playerid][slot][GUN] = 0;
		    }
			else if(Ammo != YourGunz[slot][AMMO])
			{
				SendClientMessage(playerid, MainColors[2], "Error: Player does not have a weapon that is compatible with your ammo.");
				format(string,128,"You can give him the weapon by typing \"/give %d %d %d\" (all of your ammo)",player,weaponid,YourGunz[slot][AMMO]);
				SendClientMessage(playerid, MainColors[2],string);
				return 1;
			}
			else if(Ammo == YourGunz[slot][AMMO])
			{
			    HisGunz[slot][AMMO]+=YourGunz[slot][AMMO];
				YourGunz[slot][AMMO] = 0;
				YourGunz[slot][GUN] = 0;
				ResetPlayerWeapons(playerid);
				ResetPlayerWeapons(player);
				new pweap = GetPlayerWeapon(player);
				new pslot = GetWeaponSlot(pweap);
			    for(new i = 1; i < MAX_SLOTS; i++)
				{
    				if(HisGunz[i][GUN] > 0 || HisGunz[i][AMMO] > 0 && i != pslot)GivePlayerWeapon(player,HisGunz[i][GUN],HisGunz[i][AMMO]);
    				if(YourGunz[i][GUN] > 0 || YourGunz[i][AMMO] > 0)GivePlayerWeapon(playerid,YourGunz[i][GUN],YourGunz[i][AMMO]);
				}
				GivePlayerWeapon(player,HisGunz[pslot][GUN],HisGunz[pslot][AMMO]);
				TR_StartGun[player][slot][AMMO] = YourGunz[slot][AMMO];
          		TR_StartGun[player][slot][GUN] = weaponid;
          		TR_StartGun[playerid][slot][GUN] = 0;
          		TR_StartGun[playerid][slot][AMMO] = 0;
				format(string,128,"*** \"%s\" has given you a %s with %d ammo",NickName[playerid],WeaponNames[weaponid],YourGunz[slot][AMMO]);
        		SendClientMessage(player,MainColors[1],string);
        		format(string,128,"*** You have given \"%s\" a %s with %d ammo",NickName[player],WeaponNames[weaponid],Ammo);
        		SendClientMessage(playerid,MainColors[3],string);
			}
		}
	    return 1;
	}
	
	dcmd_drop(playerid,params[])
	{
		if(Current == -1 || Playing[playerid] == false)return SendClientMessage(playerid,MainColors[2],"Error: You must be active in a round.");
		if(!strlen(params))return SendClientMessage(playerid,MainColors[1],"Usage: /drop [GUN ID/NAME]");
		new Float: px, Float: py, Float: pz;
		GetPlayerPos(playerid,px,py,pz);

		new dropweapon = GetWeaponModelIDFromName(params);
		if(dropweapon == -1)
		{
			dropweapon = strval(params);
			if(dropweapon <= 0 || dropweapon > 46)return SendClientMessage(playerid, MainColors[2], "Error: Invalid Weapon ID/NAME");
		}
		if(dropweapon < 16)return SendClientMessage(playerid,MainColors[2],"Error: You cannot drop a melee weapon.");
		
		new weapon,ammo;
		GetPlayerWeaponData(playerid,GetWeaponSlot(dropweapon),weapon,ammo);
		if(weapon != dropweapon)return SendClientMessage(playerid,MainColors[2],"Error: you do not have that weapon.");
		if(ammo >= 65535 && weapon >= 16)return SendClientMessage(playerid,MainColors[2],"An error occurred while retrieving your weapon data.");
		
		new p = CreatePickup(weapons[dropweapon],1,px,py,pz);
		pickups[p][p_x] = px;
		pickups[p][p_y] = py;
		pickups[p][p_z] = pz;
		pickups[p][p_creation_time] = Time();

		if(p == INVALID_PICKUP)
		{
  			DestroyPickupEx(p);
			p = CreatePickup(weapons[dropweapon],1,px,py,pz);
			pickups[p][p_x] = px;
			pickups[p][p_y] = py;
			pickups[p][p_z] = pz;
			pickups[p][p_creation_time] = Time();
		}
		pickups[p][p_weapon] = weapon;
		pickups[p][p_ammo] = ammo;
		#if MAX_DROP_AMOUNT != -1
  		if(pickups[p][p_ammo] > MAX_DROP_AMOUNT)
    	{
    		pickups[p][p_ammo] = MAX_DROP_AMOUNT;
    	}
    	#endif
    	
    	SetPlayerAmmo(playerid,dropweapon,0);
    	new string[128];
    	format(string,128,"You dropped a(n) %s with %d ammo",WeaponNames[dropweapon],ammo);
    	SendClientMessage(playerid,MainColors[3],string);
    	
	    return 1;
	}

 	dcmd_spec(playerid,params[])
	{
	    if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	    if(gTeam[playerid] == T_SUB && sTeam[playerid] == T_SUB)return 0;

		if(!strlen(params))return SendClientMessage(playerid, MainColors[1], "Usage: /spec [playerid]");
		new specid = strval(params);

		if(!IsPlayerConnected(specid)){SendClientMessage(playerid, MainColors[2], "Error: Invalid Player ID");PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return 1;}
		if(specid == playerid){SendClientMessage(playerid, MainColors[2], "Error: You cannot spectate yourself.");PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return 1;}
	 	if((gTeam[specid] != sTeam[playerid] || sTeam[specid] != sTeam[playerid]) && gTeam[playerid] != T_NON){SendClientMessage(playerid, MainColors[2], "Error: You can only spectate your own team.");PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return 1;}
		if(Playing[playerid] == true && gTeam[playerid] != T_NON){SendClientMessage(playerid, MainColors[2], "Error: You can only spectate if you are not in a round.");PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return 1;}
		if(GetPlayerState(specid) == PLAYER_STATE_SPECTATING && gSpectateID[specid] != INVALID_PLAYER_ID){SendClientMessage(playerid, MainColors[2], "Error: Player spectating someone else");PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return 1;}
		if(GetPlayerState(specid) != 1 && GetPlayerState(specid) != 2 && GetPlayerState(specid) != 3){SendClientMessage(playerid, MainColors[2], "Error: Player not spawned");PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return 1;}
		if(IsPlayerConnected(gSpectateID[playerid]))
		{
			ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],1);
			TD_HidepTextForPlayer(playerid,gSpectateID[playerid],1);
			TD_HidepTextForPlayer(playerid,gSpectateID[playerid],13);
			TD_HidepTextForPlayer(playerid,gSpectateID[playerid],14);
		}
		Spectate_Start(playerid, specid);
		SendClientMessage(playerid,MainColors[3],"*** To exit spectator mode type /specoff or 'SPRINT'");
		SendClientMessage(playerid,MainColors[3],"*** Change views by pressing your 'CROUCH' button");
		SendClientMessage(playerid,MainColors[3],"*** Scroll through players with 'AIM' and 'JUMP'");
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		ViewingBase[playerid] = -1;
    	ViewingArena[playerid] = -1;
		foreach(Player,i)
		{
			if(gSpectateID[i] == playerid)
			{
				Spectate_QuickStart(i,playerid,specid);
			}
		}
 		return 1;
	}

 	dcmd_specoff(playerid,params[])
  	{
  	    #pragma unused params
 	    if(gSpectating[playerid] == true && Playing[playerid] == false)
 	    {
			TD_HidepTextForPlayer(playerid,playerid,1);
			TD_HidepTextForPlayer(playerid,playerid,13);
 	    	Spectate_Stop(playerid);
 	    	SpawnPlayer(playerid);
 	    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		}
		return 1;
	}
	
dcmd_chase(playerid,params[])
{
	if(Chase_ChaseID[playerid] != -1)return SendClientMessage(playerid,MainColors[2],"Error: You are already chasing someone.");
	if(Playing[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're in a round.");
	if(IsDueling[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're dueling.");
	if(gSpectating[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot use this command if you're spectating.");
	new tmp[30],idx,tmpplayer;
	tmp = strtok_(params, idx);
	if(!strlen(tmp))return SendClientMessage(playerid,MainColors[3],"Usage: /chase [id] [seconds]");
	tmpplayer = strval(tmp);
	if(!IsPlayerConnected(tmpplayer) || tmpplayer == playerid)return SendClientMessage(playerid,MainColors[2],"Invalid player ID");
	if(Playing[tmpplayer] == true) return SendClientMessage(playerid,MainColors[2],"Player is in a match.");
	if(IsDueling[tmpplayer] == true)return SendClientMessage(playerid,MainColors[2],"Player is dueling.");
	if(gSpectating[tmpplayer] == true)return SendClientMessage(playerid,MainColors[2],"Player is spectating.");
	if(GetPlayerVirtualWorld(tmpplayer) != GetPlayerVirtualWorld(playerid))return SendClientMessage(playerid,MainColors[2],"Player is in a different world.");
	if(gPlayerSpawned[tmpplayer] == false)return SendClientMessage(playerid,MainColors[2],"Player isn't spawned.");
	tmp = strtok_(params, idx);
	if(!strlen(tmp))return SendClientMessage(playerid,MainColors[3],"Usage: /chase [id] [seconds]");
	Chase_Start(playerid,tmpplayer,strval(tmp));
	return 1;
}
//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
// ARENAS - TDM / S&D

forward StartRoundARENA(arenaid,type,autoinit);
public StartRoundARENA(arenaid,type,autoinit)
{
	if(Current != -1)return 1;
	if(autoinit == 1 && AutoMode != ARENA && AutoMode != TDM)return 1;
	if(SlideSho == true && AutoMode >= 0 && AutoMode <= 2 )return AutoModeInit();
	//if(CurrentPlayers[T_HOME] < 1 || CurrentPlayers[T_AWAY] < 1)return AutoModeInit();
    //FunctionLog("StartRoundARENA");
    Current = arenaid;
    ModeType = type;
   	RoundTimerStart();
   	ResetWeaponSets();
   	ResetAllNames();
   	ClearDeathMessages();
   	RoundCode++;
   	dini_IntSet(gConfigFile(),"RoundCode",RoundCode);
   	Team_ResetTextColors();
	TextDrawSetString(MainText[0]," ~n~ ~n~ ~n~ ~n~ ");
	TextDrawColor(MainText[10],TeamActiveColors[T_HOME] | 0x000000FF);
	TextDrawColor(MainText[11],TeamActiveColors[T_AWAY] | 0x000000FF);
	TextDrawColor(StatusText[T_HOME],TeamActiveColors[T_HOME] | 255);
	TextDrawColor(StatusText[T_AWAY],TeamActiveColors[T_AWAY] | 255);
	
	new farena[128];
	format(farena,sizeof(farena),"Arena: %s  ||  Played: %d  ||  Kills: %d  ||  Deaths: %d",dini_Get(Arenafile(Current),"Name"),dini_Int(Arenafile(Current),"Played"),dini_Int(Arenafile(Current),"Kills"),dini_Int(Arenafile(Current),"Deaths"));
	SendClientMessageToAll(MainColors[0],farena);
	
	if(TimeX[arenaid][ARENA] != -1){rWeather = Weather[arenaid][ARENA];}else rWeather = gWeather;
	if(Weather[arenaid][ARENA] != -1){rTime = TimeX[arenaid][ARENA];}else rTime = gTime;
	
	new tracknum = random(sizeof(RandSongs));
	WatchingBase = true;
	farena = Arenafile(arenaid);
	if(UseRadar == true && ArenaZones[Current][2] < 9000.0 && ArenaZones[Current][2] > -9000.0)
	{
    	zone = GangZoneCreate(ArenaZones[Current][2],ArenaZones[Current][3],ArenaZones[Current][0],ArenaZones[Current][1]);
    	GangZoneShowForAll(zone,TeamGZColors[T_AWAY]);
  		GangZoneFlashForAll(zone,TeamGZColors[T_HOME]);
	}
    else GangZoneShowForAll(BlackRadar,0x000000FF);
    foreach(Player,i)
   	{
   	    if(TabHP == true)SetPlayerScore(i,0);
		if(gSelectingClass[i] == false && gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS && TeamUsed[gTeam[i]] == true && gPlayerSpawned[i] == true)
		{
			SetPlayerColorEx(i,TeamActiveColors[gTeam[i]]);
			if(IsPlayerInAnyVehicle(i))
			{
				GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
				SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
			}

			if(Chase_ChaseID[i] != -1)Chase_Finish(i,Chase_ChaseID[i],255);
			if(IsDueling[i] == true)Duel_End(i,DuelInvitation[i],2);
			if(gSpectating[i] == true)Spectate_Stop(i);
			SetPlayerCameraLookAt(i,ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2]);
   		 	TD_ShowMainTextForPlayer(i,3);
			TextDrawShowForPlayer(i,WeaponText[4][ARENA]);
			Playing[i] = true;
			IsDueling[i] = false;
		   	NoCmds[i] = false;
		   	ShowDMG[i] = false;
		   	ViewingResults[i] = false;
			SetPlayingName(i);
  			SetPlayerVirtualWorld(i,1);
  			SpawnPlayer(i);
	   	    ResetPlayerWeapons(i);
		   	DuelInvitation[i] = -1;
		   	SetPlayerLife(i,rHealth,rArmor);
	   	    SetPlayerScore(i,rHealth+rArmor);
		    ResetPlayerWeapons(i);
		   	SetPlayerPos(i,TeamArenaSpawns[Current][0][gTeam[i]]-5+random(5),TeamArenaSpawns[Current][1][gTeam[i]]-5+random(5),TeamArenaSpawns[Current][2][gTeam[i]]+1);
      		SetPlayerCameraLookAt(i,ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2]);
   			SetPlayerCameraPos(i,ArenaCP[Current][0]+50,ArenaCP[Current][1]+50,ArenaCP[Current][2]+80);
   			WeaponSelection(i);
   			SendClientMessage(i,MainColors[3],"*** HINT: To re-enter weapon selection type /GUNMENU whilst viewing the arena.");
   			SendClientMessage(i,MainColors[2],"*** HINT: To TALK in TEAM chat use '!' before your message.");
  	    	SetPlayerInterior(i,Interior[Current][ARENA]);
			if(type == TDM) SpawnAtPlayerPosition[i] = 4;
			else SpawnAtPlayerPosition[i] = 2;
			PlayerPlaySound(i,RandSongs[tracknum],ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2]+80);
			TogglePlayerControllable(i,0);
			SetPlayerSpecialAction(i,SPECIAL_ACTION_DANCE3);
			SetPlayerWeather(i,rWeather);
			SetPlayerTime(i,rTime,0);
			UpdatePlayerActiveSkills(i);
       	}
       	else Playing[i] = false;
   	}
   	TmpCP[0] = ArenaCP[Current][0];TmpCP[1] = ArenaCP[Current][1];TmpCP[2] = ArenaCP[Current][2];
   	RotateBirdView();
   	for(new i = 0; i < ACTIVE_TEAMS; i++)
    {
        if(TeamUsed[i] == true)
        {
            TeamHighestCombo[i][1] = 0.0;
		    TeamHighestCombo[i][0] = 0.0;
        	SpawnPlayersInCircle(i);
		}
    }
	StopCounting[ARENA][0] = StopCounting[ARENA][1];
	SetTimer("RoundInitTimerARENA",0,0);
	return 1;
}

forward RoundInitTimerARENA();
public RoundInitTimerARENA()
{
    //FunctionLog("RoundInitTimerARENA");
	StopCounting[ARENA][0]--;
	new string[128];
	format(string,sizeof(string),"~w~ Arena ~y~%d ~w~starting in ~r~ %d ~w~ seconds ~n~ ~n~ ",Current,StopCounting[ARENA][0]);
	TextDrawSetString(MainText[3],string);
	if(StopCounting[ARENA][0] <= 0)
	{
		WatchingBase = false;
		StopViewingARENA();
		return 1;
	}
	else
	{
        if(StopCounting[ARENA][0] <= 5)
	    {
			foreach(Player,i)
			{
		    	if(gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
				{
					PlayerPlaySound(i,1056,0.0,0.0,0.0);
				}
			}
		}
	}
	return SetTimer("RoundInitTimerARENA",1000,0);
}

StopViewingARENA()
{
    //FunctionLog("StopViewingARENA");
    ReloadObjects();
    new Alive[ACTIVE_TEAMS], AliveTeams;
    foreach(Player,i)
    {
        PlayerPlaySound(i,1069,0.0,0.0,0.0);
        TD_ShowRoundScoreBoard(i);
        if(Playing[i] == true)
        {
            //TextDrawShowForPlayer(i,MoneyBox);
    		//TextDrawShowForPlayer(i,pText[6][i]);
	   	    AllowSuicide[i] = false;
	   		TD_HidePanoForPlayer(i);
	   		TD_HidepTextForPlayer(i,i,1);
	   		TD_HidepTextForPlayer(i,i,13);
	   		TD_HidepTextForPlayer(i,i,2);
			TD_HideMainTextForPlayer(i,3);
			TD_HideMainTextForPlayer(i,13);
			TextDrawHideForPlayer(i,WeaponText[4][ARENA]);
			if(gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
			{
				Alive[gTeam[i]]++;
				TogglePlayerControllable(i,1);
				ResetPlayerWeapons(i);
	  			SetTimerEx("StrapUp",2000,0,"i",i);
				new Menu:asdf = GetPlayerMenu(i);
				if(IsValidMenu(asdf)) HideMenuForPlayer(asdf, i);
				HasPlayed[i] = true;
				SetPlayerLife(i,rHealth,rArmor);
	  			SetCameraBehindPlayerEx(i);
	  			SetPlayerInterior(i,Interior[Current][BASE]);
				SetPlayerWorldBounds(i,ArenaZones[Current][0],ArenaZones[Current][2],ArenaZones[Current][1],ArenaZones[Current][3]);
				SetPlayerInterior(i,Interior[Current][ARENA]);
				ClearAnimations(i);
  				if(ModeType == ARENA)FindPlayerSpawn(i,1);
			}
	   	}
   	}
   	if(TeamsBeingUsed == 2)
	{
		if(Alive[T_HOME] > 0 && Alive[T_AWAY] > 0)
		{
			AliveTeams = 2;
			SpawnPlayersInCircle(T_HOME);
	    	TeamStartingPlayers[T_HOME] = Alive[T_HOME];
 			TeamCurrentPlayers[T_HOME] = Alive[T_HOME];
        	TeamLifeTotal[T_HOME] = Alive[T_HOME] * (rHealth + rArmor);

	 		SpawnPlayersInCircle(T_AWAY);
	 		TeamStartingPlayers[T_AWAY] = Alive[T_AWAY];
	 		TeamCurrentPlayers[T_AWAY] = Alive[T_AWAY];
			TeamLifeTotal[T_AWAY] = Alive[T_AWAY] * (rHealth + rArmor);
		}
	}
	else
	{
   		for(new i; i < ACTIVE_TEAMS; i++)
    	{
    	    if(TeamUsed[i] == true)
    	    {
    	    	TeamStartingPlayers[i] = Alive[i];
    	    	TeamCurrentPlayers[i] = Alive[i];
    	    	SpawnPlayersInCircle(i);
				TeamLifeTotal[i] = Alive[i] * (rHealth + rArmor);
				if(Alive[i] > 0)
				{
					AliveTeams++;
				}
			}
    	}
	}
    
	CreateExplosionSounds(2,2);
   	WatchingBase = false;
   	AllowGunMenu = true;
   	SetTimer("DisableGunMenu",30000,0);
   	SetTimer("RestoreLife",3000,0);
   	nmtimer = true;
 	NameTags();
	MarkerStealth();
	ModeMin = modetime;
   	ModeSec = 0;
   	AssignNoNames();
	
	if(ModeType == TDM)SetTimer("UpdateRoundIII",1000,0);
	if(AliveTeams <= 1)
	{
		foreach(Player,i)
		{
		    if(gSelectingClass[i] == false)
	    	{
				Spectate_Stop(i);
	    		if(Playing[i] == true)
	    		{
	        		Playing[i] = false;
	        		RemovePlayingName(i);
     				ResetPlayerWeapons(i);
					ResetPlayerHealth(i);
					FindPlayerSpawn(i,1);
					SetPlayerWorldBounds(i,20000,-20000,20000,-20000);
					SpawnPlayer(i);
				}
			}
		}
		Current = -1;
		UpdateMapName();
        ResetWeaponSets();
		HideSTextForAll();
		ShowNamesAndBlipsForAll();
		GangZoneDestroy(zone);
		GangZoneHideForAll(BlackRadar);
		AllowSuicides();
  		return 1;
	}
    UpdateMapName();
    SetTimer("AllowSuicides",6000,0);
    //SetTimer("UpdateRoundII",200,0);
   	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//BASES

forward StartRoundBASE(baseid,autoinit);
public StartRoundBASE(baseid,autoinit)
{
    if(Current != -1)return 1;
    if(autoinit == 1 && AutoMode != BASE)return 1;
    if(SlideSho == true && AutoMode >= 0 && AutoMode <= 2)return AutoModeInit();
    if(CurrentPlayers[T_HOME] < 1 || CurrentPlayers[T_AWAY] < 1)return AutoModeInit();
    //FunctionLog("StartRoundBASE");
    Current = baseid;
    ModeType = BASE;
    RoundTimerStart();
    ResetWeaponSets();
    ResetAllNames();
    ClearDeathMessages();
    RoundCode++;
    dini_IntSet(gConfigFile(),"RoundCode",RoundCode);
    TextDrawColor(MainText[10],TeamActiveColors[T_HOME] | 255);
	TextDrawColor(MainText[11],TeamActiveColors[T_AWAY] | 255);
	TextDrawColor(StatusText[T_HOME],TeamActiveColors[T_HOME] | 255);
	TextDrawColor(StatusText[T_AWAY],TeamActiveColors[T_AWAY] | 255);
	TextDrawSetString(MainText[0]," ~n~ ~n~ ~n~ ~n~ ");
    new HOME_A, AWAY_A;
    new tracknum = random(sizeof(RandSongs));
    
    new string[128];
    format(string,sizeof(string),"Base: %s  ||  Played: %d  ||  Att Wins: %d  ||  Def Wins: %d  ||  K/D: %d/%d",LocationName[Current][BASE],dini_Int(Basefile(Current),"Played"),dini_Int(Basefile(Current),"A_Wins"),dini_Int(Basefile(Current),"D_Wins"),dini_Int(Basefile(Current),"Kills"),dini_Int(Basefile(Current),"Deaths"));
	SendClientMessageToAll(MainColors[0],string);
    
    //zone = GangZoneCreate(HomeCP[Current][0]-100,HomeCP[Current][1]-100,HomeCP[Current][0]+100,HomeCP[Current][1]-100);
    zone = GangZoneCreate(-9000,-9000,9000,9000);
    if(UseRadar == false)GangZoneShowForAll(BlackRadar,0x000000FF);
	if(TeamStatus[T_AWAY] == ATTACKING){ZoneCols[0] = T_HOME;ZoneCols[1] = T_AWAY;}
	else {ZoneCols[0] = T_AWAY;ZoneCols[1] = T_HOME;}
	
	if(TimeX[baseid][BASE] != -1){rWeather = Weather[baseid][ARENA];}else rWeather = gWeather;
	if(Weather[baseid][BASE] != -1){rTime = TimeX[baseid][ARENA];}else rTime = gTime;
    
	WatchingBase = true;
    foreach(Player,i)
   	{
   	    if(TabHP == true)SetPlayerScore(i,0);
   		SetPlayerCheckpoint(i,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],CPsize);
   	   	//GangZoneShowForPlayer(i,zone,TeamGZColors[ZoneCols[0]]);
		if(gSelectingClass[i] == false && (gTeam[i] == T_HOME || gTeam[i] == T_AWAY) && gPlayerSpawned[i] == true)
		{
		    DuelSpectating[i] = -1;
		    switch(gTeam[i])
 			{
 				case T_HOME:HOME_A++;
				case T_AWAY:AWAY_A++;
			}
   		 	TD_ShowMainTextForPlayer(i,3);
			TextDrawShowForPlayer(i,StatusText[gTeam[i]]);
			TextDrawShowForPlayer(i,WeaponText[4][BASE]);
			SetPlayerCameraLookAt(i,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
		    if(IsPlayerInAnyVehicle(i))
			{
				GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
				SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
			}
			if(gSpectating[i] == true)Spectate_Stop(i);
			if(IsDueling[i] == true)Duel_End(i,DuelInvitation[i],2);
			if(Chase_ChaseID[i] != -1)Chase_Finish(i,Chase_ChaseID[i],255);
			IsDueling[i] = false;
 			NoCmds[i] = false;
 			ShowDMG[i] = false;
 			ViewingResults[i] = false;
  			Playing[i] = true;
			SetPlayerColorEx(i,TeamActiveColors[gTeam[i]]);
			ResetPlayerWeapons(i);
			SetPlayerInterior(i,Interior[Current][BASE]);
			//SetPlayerHealthEx(i,rHealth);
			TogglePlayerControllable(i,0);
  			SetPlayerVirtualWorld(i,1);
  			DuelInvitation[i] = -1;
  			SetPlayingName(i);
  			SetPlayerScore(i,rArmor+rHealth);
  			WeaponSelection(i);
  			SpawnAtPlayerPosition[i] = 2;
			SpawnPlayer(i);
			SetPlayerCameraLookAt(i,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
			SetPlayerCameraPos(i,HomeCP[Current][0]+50,HomeCP[Current][1]+50,HomeCP[Current][2]+80);
			SetPlayerColorEx(i,TeamActiveColors[gTeam[i]]);
			UpdatePlayerActiveSkills(i);
  			if(TeamStatus[gTeam[i]] == ATTACKING)
  			{
   				SetPlayerMapIcon(i,0,TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],31,0xFFFFFFFF);
				SetPlayerMapIcon(i,1,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],RandIcon[random(7)],0xFFFFFFFF);
				SetPlayerRaceCheckpoint(i,1,TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],30.0);
				SendClientMessage(i,MainColors[3],"*** HINT: Use /CARLIST to view cars and /CAR [CAR NAME] to spawn a vehicle");
				SendClientMessage(i,MainColors[3],"*** HINT: To re-enter weapon selection type /GUNMENU");
				SendClientMessage(i,MainColors[3],"*** HINT: To speak in TEAM chat use '!' before your message");
	  		}
			else SendClientMessage(i,MainColors[3],"*** HINT: To re-enter weapon selection type /GUNMENU whilst viewing the base.");
			PlayerPlaySound(i,RandSongs[tracknum],HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]+80);
			TogglePlayerControllable(i,0);
			SetPlayerSpecialAction(i,SPECIAL_ACTION_DANCE3);
			SetPlayerWeather(i,rWeather);
			SetPlayerTime(i,rTime,0);
		}
		else Playing[i] = false;
   	}
   	if(TeamStatus[T_HOME] == DEFENDING)TextDrawColor(MainText[1],TeamActiveColors[T_HOME] | 0x000000FF);
	else TextDrawColor(MainText[1],TeamActiveColors[T_AWAY] | 0x000000FF);
	TmpCP[0] = HomeCP[Current][0];TmpCP[1] = HomeCP[Current][1];TmpCP[2] = HomeCP[Current][2];
   	RotateBirdView();
	StopCounting[BASE][0] = StopCounting[BASE][1];
	VehiclesSpawned[T_HOME] = CurrentPlayers[T_HOME] * VPPPT;
	VehiclesSpawned[T_AWAY] = CurrentPlayers[T_AWAY] * VPPPT;
	SpawnPlayersInCircle(T_HOME);
	SpawnPlayersInCircle(T_AWAY);
	return RoundInitTimer2();
}

forward RoundInitTimer2();
public RoundInitTimer2()
{
    //FunctionLog("RoundInitTimer2");
	StopCounting[BASE][0]--;
	new string[128];
	format(string,sizeof(string),"~w~ Base ~y~%d ~w~starting in ~r~ %d ~w~ seconds ~n~ ~n~ ",Current,StopCounting[BASE][0]);
	TextDrawSetString(MainText[3],string);
	if(StopCounting[BASE][0] <= 0)
	{
	    WatchingBase = false;
		StopViewingBASE();
		return 0;
	}
	else
	{
	    if(StopCounting[BASE][0] <= 5)
	    {
			foreach(Player,i)
			{
		    	if(gTeam[i] == T_HOME || gTeam[i] == T_AWAY)
				{
					PlayerPlaySound(i,1056,0.0,0.0,0.0);
				}
			}
		}
	}
	return SetTimer("RoundInitTimer2",1000,0);
}

StopViewingBASE()
{
    //FunctionLog("StopViewingBASE");
    ReloadObjects();
	new HOME_A,AWAY_A;
    foreach(Player,i)
    {
        PlayerPlaySound(i,1069,0.0,0.0,0.0);
        TD_ShowRoundScoreBoard(i);
	   	if(Playing[i] == true)
	   	{
	   	    //TextDrawShowForPlayer(i,MoneyBox);
    		//TextDrawShowForPlayer(i,pText[6][i]);
	   	    AllowSuicide[i] = false;
	   	    TD_HidePanoForPlayer(i);
			TD_HidepTextForPlayer(i,i,1);
			TD_HidepTextForPlayer(i,i,13);
			TD_HidepTextForPlayer(i,i,2);
			TD_HideMainTextForPlayer(i,3);
			TD_HideMainTextForPlayer(i,13);
			TextDrawHideForPlayer(i,StatusText[gTeam[i]]);
			TextDrawHideForPlayer(i,WeaponText[4][BASE]);
			if(gTeam[i] == T_HOME || gTeam[i] == T_AWAY)
			{
		    	switch(gTeam[i])
 				{
 					case T_HOME:HOME_A++;
					case T_AWAY:AWAY_A++;
				}
				ResetPlayerWeapons(i);
	  			SetTimerEx("StrapUp",2000,0,"i",i);
				new Menu:asdf = GetPlayerMenu(i);
				if(IsValidMenu(asdf)) HideMenuForPlayer(asdf, i);
				HasPlayed[i] = true;
				SetPlayerLife(i,rHealth,rArmor);
	  			SetCameraBehindPlayerEx(i);
	  			SetPlayerColorEx(i,TeamActiveColors[gTeam[i]]);
	  			SetPlayerInterior(i,Interior[Current][BASE]);
	  			FindPlayerSpawn(i,1);
	  			if(TeamStatus[gTeam[i]] == DEFENDING)ClearAnimations(i);
  				if(ClanLeader[i] == true && TeamStatus[gTeam[i]] == ATTACKING)
	  			{
			  		SelectWeather(i);
			  		SetTimerEx("HidePlayerMenu",15000,0,"i",i);
			  		SendClientMessage(i,MainColors[2],"You have 15 seconds to select the weather and time");
				}
			}
		}
   	}
   	new string[75];
   	TeamStartingPlayers[T_HOME] = HOME_A;
   	TeamCurrentPlayers[T_HOME] = HOME_A;
   	TeamLifeTotal[T_HOME] = HOME_A * (rHealth + rArmor);
   	TeamHighestCombo[T_HOME][1] = 0.0;
	TeamHighestCombo[T_HOME][0] = 0.0;
   	format(string,sizeof(string),"%s ~w~- ~b~~h~~h~Alive: ~w~%d~b~~h~~h~/~w~%d  ~b~~h~~h~Life: ~w~%.0f",TeamName[T_HOME],TeamCurrentPlayers[T_HOME],TeamStartingPlayers[T_HOME],TeamLifeTotal[T_HOME]);
	TextDrawSetString(MainText[10],string);
   	
	TeamStartingPlayers[T_AWAY] = AWAY_A;
	TeamCurrentPlayers[T_AWAY] = AWAY_A;
	TeamLifeTotal[T_AWAY] = AWAY_A * (rHealth + rArmor);
	TeamHighestCombo[T_AWAY][1] = 0.0;
	TeamHighestCombo[T_AWAY][0] = 0.0;
	format(string,sizeof(string),"%s ~w~- ~b~~h~~h~Alive: ~w~%d~b~~h~~h~/~w~%d  ~b~~h~~h~Life: ~w~%.0f",TeamName[T_AWAY],TeamCurrentPlayers[T_AWAY],TeamStartingPlayers[T_AWAY],TeamLifeTotal[T_AWAY]);
	TextDrawSetString(MainText[11],string);

   	CreateExplosionSounds(2,2);
   	WatchingBase = false;
   	AllowGunMenu = true;
   	SetTimer("DisableGunMenu",30000,0);
   	SetTimer("RestoreLife",3000,0);
   	SetTimer("EnableVehicleSpawning",3000,0);
   	nmtimer = true;
 	NameTags();
	MarkerStealth();
	ModeMin = modetime;
   	ModeSec = 0;
   	AssignNoNames();
   	if((HOME_A < 1) || (AWAY_A < 1 ))
    {
    	foreach(Player,i)
		{
 			DisablePlayerCheckpoint(i);
	    	DisablePlayerRaceCheckpoint(i);
			Spectate_Stop(i);
	   		if(Playing[i] == true)
	   		{
	       		Playing[i] = false;
	       		RemovePlayingName(i);
    			ResetPlayerWeapons(i);
				ResetPlayerHealth(i);
				FindPlayerSpawn(i,1);
				SetPlayerWorldBounds(i,20000,-20000,20000,-20000);
				SpawnPlayer(i);
			}
		}
		Current = -1;
		UpdateMapName();
        ResetWeaponSets();
		HideSTextForAll();
		ShowNamesAndBlipsForAll();
		AllowSuicides();
		return 1;
    }
    UpdateMapName();
   	SetTimer("AllowSuicides",6000,0);
   	//SetTimer("UpdateRoundII",200,0);
   	return SetTimer("UpdateRound",1000,0);
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
forward UpdateRound();
public UpdateRound()
{
    /*FunctionLogEx("UpdateRound");*/
	if(Current == -1 || WatchingBase == true)return 1;
	if(GamePaused == false)
	{
		if(CPused == true)//The checkpoint is enabled
		{
		    new stringCP[32], attin, bool:defin;
 			foreach(Player,i)
 			{
				if(Playing[i] == true && IsPlayerInCheckpoint(i) && !IsPlayerInAnyVehicle(i))
				{
					if(TeamStatus[gTeam[i]] == ATTACKING)attin++;
					else
					{
						defin = true;
						break;
					}
				}
			}
			if(attin == 0 || defin == true)
			{
			    if(CPtime[0] < CPtime[1])//CP text is already showing
				{
			 		CPtime[0] = CPtime[1];
					foreach(Player,i)
					{
						TD_HideMainTextForPlayer(i,1);
					}
				}
			}
			else if(attin >= 1)
			{
			    new tmptime = CPtime[0];
			    CPtime[0] = CPtime[0] - attin;
			    format(stringCP,sizeof(stringCP),"Checkpoint Time Left~w~: ~p~%02d",CPtime[0]);
                TextDrawSetString(MainText[1],stringCP);
			    if(tmptime == CPtime[1])//CP text is currently not showing
			    {
			        TextDrawSetString(MainText[1],stringCP);
			    	foreach(Player,i)
					{
		    			if(gPlayerSpawned[i] == true)
   						{
   		 					TD_ShowMainTextForPlayer(i,1);
   						}
					}
				}
		    	PlaySoundForAll(1039);
			    if(TeamStatus[T_AWAY] == DEFENDING){Team_FlashScreen(T_AWAY,T_HOME);}
			    else{Team_FlashScreen(T_HOME,T_AWAY);}
		    
		    	if(CPtime[0] <= 0)
 				{
 				    if(TeamStatus[T_AWAY] == ATTACKING)
		    		{
						Winner = T_AWAY;
  						TeamRoundsWon[T_AWAY]++;
					}
					else
					{
				    	Winner = T_HOME;
  						TeamRoundsWon[T_HOME]++;
					}
					new string3[256],players[256];
					players = Team_DisplayAttackersInCP();
					format(string3, 256, "%s",players);
					format(stringCP,sizeof(stringCP),"%s Captured The Checkpoint~w~!!!",TeamName[Winner]);
					TextDrawColor(MainText[1],TeamActiveColors[Winner] | 0x000000FF);
					TextDrawColor(MainText[2],TeamActiveColors[Winner] | 0x000000FF);
					TextDrawSetString(MainText[1],stringCP);
					TextDrawSetString(MainText[2],string3);
					HideCPText = false;
					foreach(Player,x)
					{
					    if(gPlayerSpawned[x] == true)
					    {
   		 					TD_ShowMainTextForPlayer(x,2);
						}
					}
					SetTimer("HideCheckpointText",6000,0);
     				SetTimer("DisplayWinners",5,0);
 					Team_ResetTempScores();
					return 1;
				}
			}
		}
		ModeSec--;
		UpdateRoundClock();
		if(ModeSec < 0)
    	{
    	    ModeSec = 59;
			ModeMin--;
			if(ModeMin < 0)
			{
			    TR_WinReason = "TIME EXPIRED";
			    dini_IntSet(ServerFile(),"TimeWins",dini_Int(ServerFile(),"TimeWins") + 1);
			    if(TeamStatus[T_AWAY] == DEFENDING)
			    {
					Winner = T_AWAY;
  					TeamRoundsWon[T_AWAY]++;
				}
				else
				{
				    Winner = T_HOME;
  					TeamRoundsWon[T_HOME]++;
				}
 				SetTimer("DisplayWinners",5,0);
 				UpdateRoundClock();
			    return 1;
			}
    	}
	}
    return SetTimer("UpdateRound",1000,0);
}

forward UpdateRoundII();
public UpdateRoundII()
{
    //FunctionLog("UpdateRoundII");
	if(Current == -1 || WatchingBase == true)return 1;
	NameTags();
	if(ModeType == TDM)
    {
        new stringy[32];
        for(new i; i < ACTIVE_TEAMS; i++)
    	{
    	    if(TeamUsed[i] == true)
    	    {
        		format(stringy,64,"%s ~w~- ~b~~h~~h~Kills:~w~ %d",TeamName[i],TeamTempScore[i]);
        		TextDrawSetString(ArenaTxt[i],stringy);
			}
		}
    }
	else if(ModeType == BASE || TeamsBeingUsed == 2)
	{
		UpdateRoundStrings(T_HOME);
	    UpdateRoundStrings(T_AWAY);
	    CheckTeamActivePlayers();
	}
    else if(ModeType == ARENA)
    {
		new AliveTeams, Team;
		for(new i; i < ACTIVE_TEAMS; i++)
		{
			if(TeamUsed[i] == true)
			{
  				UpdateRoundStrings(i);
 				if(TeamCurrentPlayers[i] > 0)
 				{
 					AliveTeams++;
 					Team = i;
 				}
			}
		}
 		if(AliveTeams < 2)
 		{
 			TeamRoundsWon[Team]++;
 			Winner = Team;
 			SetTimer("DisplayWinners",5,0);
		}
    }
	return 1;
}

forward UpdateRoundIII();
public UpdateRoundIII()
{
    //FunctionLog("UpdateRoundIII");
	if(Current == -1 || WatchingBase == true)return 1;
	new string[64];
 	if(ModeType == TDM)
    {
        UpdateRoundClock();
        if(GamePaused == false)ModeSec--;
   	 	if(ModeSec < 0)
   	 	{
   	     	ModeSec = 59;
			ModeMin--;
		}
		if(ModeMin < 0)
		{
			new w = Team_GetTeamWithHighestScore();
   			Winner = w;
			TeamRoundsWon[w]++;
			foreach(Player,i)
			{
				FindPlayerSpawn(i,1);
			}
			SetTimer("DisplayWinners",5,0);
			Team_ResetTempScores();
			UpdateRoundClock();
			return 1;
		}
        for(new i = 0; i < ACTIVE_TEAMS; i++)
    	{
    	    if(TeamUsed[i] == true)
    	    {
        		format(string,64,"%s ~w~- ~b~~h~~h~Kills:~w~ %d",TeamName[i],TeamTempScore[i]);
        		TextDrawSetString(ArenaTxt[i],string);
			}
		}
		foreach(Player,i)
		{
			if(gPlayerSpawned[i] == true)
			{
			    HidenShowArenaTexts(i);
			}
		}
		return SetTimer("UpdateRoundIII",1000,0);
    }
    return 1;
}

forward DisplayWinners();
public DisplayWinners()
{
    //FunctionLog("DisplayWinners");
    if(Current == -1)return 1;
    new string[128],THP;THP = Team_GetHP(Winner);
    format(string,128,"%s ~w~Won The Round! ~y~- ~b~%d Life Remaining",TeamName[Winner],THP);
    TextDrawColor(MainText[0],TeamActiveColors[Winner] | 0x000000FF);
    TextDrawSetString(MainText[0],string);
    if(AutoSwap == true && ModeType == BASE)
    {
        Team_Swap();
		format(string,128,"*** (AUTO-SWAP) *** \"%s\" (%s): %d || \"%s\" (%s): %d",TeamName[T_HOME],TeamStatusStr[T_HOME],CurrentPlayers[T_HOME],TeamName[T_AWAY],TeamStatusStr[T_AWAY],CurrentPlayers[T_AWAY]);
		SendClientMessageToAll(MainColors[0],string);
    }
    foreach(Player,i)
	{
	    TD_HideRoundScoreBoard(i);
 		if(TeamUsed[gTeam[i]] == true && gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
		{
		    if(Stored[i] == false){GetPlayerEndWeapons(i);Stored[i] = true;}
			for(new t = 0; t < ACTIVE_TEAMS; t++){TextDrawHideForPlayer(i,ArenaTxt[t]);}
		}
	}

 	if(RoundsPlayed == 0)
	{
		TR_FirstStart = (TR_Start - Now()) + Now();
		FinalData[F_Type] = "";
		FinalData[F_ID] = "";
		FinalData[F_Winner] = "";
		FinalData[F_Status] = "";
		FinalData[F_Name] = "";
	}
	if(HideCPText == true){SetTimer("HideCheckpointText",1000,0);TR_WinReason = "ELIMINATION";dini_IntSet(ServerFile(),"KillWins",dini_Int(ServerFile(),"KillWins") + 1);}else {TR_WinReason = "CHECKPOINT";dini_IntSet(ServerFile(),"CPWins",dini_Int(ServerFile(),"CPWins") + 1);}
	if(ModeType == BASE)
	{
	    if(TeamStatus[Winner] == ATTACKING){dini_IntSet(ServerFile(),"AttWins",dini_Int(ServerFile(),"AttWins") + 1);}else if(TeamStatus[Winner] == DEFENDING){dini_IntSet(ServerFile(),"DefWins",dini_Int(ServerFile(),"DefWins") + 1);}
		dini_IntSet(ServerFile(),"BasesPlayed",dini_Int(ServerFile(),"BasesPlayed") + 1);
	}
	else if(ModeType == ARENA){dini_IntSet(ServerFile(),"ArenasPlayed",dini_Int(ServerFile(),"ArenasPlayed") + 1);}
	else if(ModeType == TDM){dini_IntSet(ServerFile(),"TDMsPlayed",dini_Int(ServerFile(),"TDMsPlayed") + 1);}
    UpdateFinalRoundInfoStrings();
    HideTeamLifeText(T_HOME);
    HideTeamLifeText(T_AWAY);
	RoundsPlayed++;
	Team_ResetTempScores();
	SaveRoundResults();
 	ShowRoundResults(ModeType);
	nmtimer = false;
	Current = -1;
	TR_DeathPosInt = 0;
	CPtime[0] = CPtime[1];
	ModeType = NONE;
	VehiclesSpawned[T_HOME] = 0;
	VehiclesSpawned[T_AWAY] = 0;
 	UnlockAllVehicles();
 	DestroyAllPickups();
 	DestroyObjects();
 	UpdateInfo(ModeType,Current,Winner);
	UpdateMapName();
	GangZoneDestroy(zone);
	GangZoneHideForAll(BlackRadar);
    foreach(Player,i)
	{
	    UpdatePlayerInactiveSkills(i);
		ResetPlayerWeatherAndTime(i);
	    TD_HideTeamDmgText(i);
		TD_ShowMainTextForPlayer(i,0);
		PlayerPlaySound(i,1068,0.0,0.0,0.0);
    	HideRoundText(i);
		SetPlayerScore(i,TempKills[i]);
 		TR_Died[i] = false;
 		TR_Kills[i] = 0;
 		FinishedMenu[i] = false;
 		Stored[i] = false;
 		DisablePlayerCheckpoint(i);
 		DisablePlayerRaceCheckpoint(i);
 		RemovePlayerMapIcon(i,0);
 		RemovePlayerMapIcon(i,1);
		if(Playing[i] == true)
 		{
 		    RemovePlayingName(i);
			FindPlayerSpawn(i,0);
 			Playing[i] = false;
  			HasPlayed[i] = false;
   			SetPlayerNewWorld(i);
			SetPlayerWorldBounds(i,20000,-20000,20000,-20000);
			ResetPlayerWeapons(i);
			ResetPlayerHealth(i);
			SpawnAtPlayerPosition[i] = 0;
			FindPlayerSpawn(i,1);
			SpawnPlayer(i);
		}
		if(gSpectating[i] == true)
		{
			Spectate_Stop(i);
			SetTimerEx("Spectate_Stop",500,0,"i",i);
		}
	}
	if(RoundsPlayed >= RoundLimit)
	{
		SetTimerEx("ShowFinalScores",5000,0,"i",20);
		SendClientMessageToAll(0xFFFFFFFF,"Match ended, prepare for results to be displayed");
		SaveMatchResults();
	}
	else SetTimer("HideSTextForAll",8000,0);
	HideCPText = true;
 	ResetWeaponSets();
 	ResetAllColors();
 	DestroyRoundVehicles();
 	SetTimer("AutoModeInit",10000,0);
	SetTimer("ResetAllNames",1000,0);
	SetTimer("ShowNamesAndBlipsForAll",1200,0);
    return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Weapon functions

forward StrapUp(playerid);
public StrapUp(playerid)
{
    //FunctionLog("StrapUp");
	new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid,1,1);
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
	    if(GunUsed[i][MODE] == 16)
		{
			GivePlayerWeapon(playerid,i,GunAmmo[i][MODE]);
			gPlayerAmmo[playerid][GetWeaponSlot(i)] = GunAmmo[i][MODE];
			TR_StartGun[playerid][GetWeaponSlot(i)][AMMO] = GunAmmo[i][MODE];
			TR_StartGun[playerid][GetWeaponSlot(i)][GUN] = i;
		}
	}
	GivePlayerWeapon(playerid,WeaponSet[playerid][0][MODE],GunAmmo[WeaponSet[playerid][0][MODE]][MODE]);TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][0][MODE])][AMMO] = GunAmmo[WeaponSet[playerid][0][MODE]][MODE];TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][0][MODE])][GUN] = WeaponSet[playerid][0][MODE];
	GivePlayerWeapon(playerid,WeaponSet[playerid][1][MODE],GunAmmo[WeaponSet[playerid][1][MODE]][MODE]);TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][1][MODE])][AMMO] = GunAmmo[WeaponSet[playerid][1][MODE]][MODE];TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][1][MODE])][GUN] = WeaponSet[playerid][1][MODE];
	GivePlayerWeapon(playerid,WeaponSet[playerid][2][MODE],GunAmmo[WeaponSet[playerid][2][MODE]][MODE]);TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][2][MODE])][AMMO] = GunAmmo[WeaponSet[playerid][2][MODE]][MODE];TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][2][MODE])][GUN] = WeaponSet[playerid][2][MODE];
	GivePlayerWeapon(playerid,WeaponSet[playerid][3][MODE],GunAmmo[WeaponSet[playerid][3][MODE]][MODE]);TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][3][MODE])][AMMO] = GunAmmo[WeaponSet[playerid][3][MODE]][MODE];TR_StartGun[playerid][GetWeaponSlot(WeaponSet[playerid][3][MODE])][GUN] = WeaponSet[playerid][3][MODE];
	SetCameraBehindPlayerEx(playerid);
    return 1;
}

GiveHimHisGuns(playerid)
{
    //FunctionLog("GiveHimHisGuns");
    if(DuelSpectating[playerid] != -1)return 1;
    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid,1,1);
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
	    if(pGunUsed[i] == 2)GivePlayerWeapon(playerid,i,pGunAmmo[i]);
	    else if(pGunUsed[i] == 1 && PlayerWeapons[playerid][GetWeaponSlot(i)] == i)GivePlayerWeapon(playerid,i,pGunAmmo[i]);
	}
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//TextDraw related

new const Float:MOTD_Locations[24][3] = {
{2490.7063,-1668.5127,13.3438}, // grove
{371.6014,-2028.8739,7.6719}, // ferris wheel
{1291.2859,-788.1967,96.4609}, // maddoggs helipad
{-1274.6075,501.4547,18.2344}, // army boat
{-1469.3323,1489.4231,8.2501}, // SF small boat
{-2681.3542,1767.0336,68.4844}, // golden gate bridge
{-2227.2439,2326.7834,7.5469}, // bayside helipad
{1358.5453,2160.1565,11.0156}, // baseball field
{2587.1143,2828.2180,10.8203}, // KACC warehouse
{2737.7966,-1760.2612,44.1487}, // LS stadium top
{2508.8599,-2656.1409,27.0000}, // LS Docks big tank
{2212.0154,-2236.1001,13.5469}, // Grey Imports
{1544.1686,-1352.9142,329.475}, // LS highest building
{756.0528,-1259.2528,13.5647}, // LS house with tennis courts
{725.5969,-1462.0695,22.2109}, // LS building above waterway
{296.8583,-1168.1163,80.9099}, // LS Vincewood big house
{1100.9690,-825.7762,114.4477}, // LS Vinewood saucer house
{-41.0972,78.1380,3.1172}, // Farm
{-1522.9600,-408.1206,7.0781}, // SF airport entrance
{-2378.1323,1551.6788,31.8594}, // SF cargo ship
{-1468.4606,1489.5836,8.2571}, // SF danang boat
{404.7168,2454.6287,16.5000}, // desert airstrip garage
{1240.5667,2794.2168,10.8203}, // golf course
{2428.2427,1811.5505,38.8203} // LV purple dome
};

StartIntro(playerid)
{
    if(GameMap == SA)SetPlayerPos(playerid,sScreenSA[cSelect[playerid]][s_x],sScreenSA[cSelect[playerid]][s_y],sScreenSA[cSelect[playerid]][s_z]);
	else SetPlayerPos(playerid,sScreenGTAU[cSelect[playerid]][s_x],sScreenGTAU[cSelect[playerid]][s_cy],sScreenGTAU[cSelect[playerid]][s_cz]);
	
	MOTDScreen[playerid] = random(sizeof(MOTD_Locations));
	MOTD_Z[playerid] = MOTD_Locations[MOTDScreen[playerid]][2]+1100.0;
	CurLetter[playerid] = 0;
	SetPlayerWeather(playerid,44);
	SetPlayerTime(playerid,6,0);
	SetPlayerInterior(playerid,0);
	TextDrawSetString(MOTD[0][playerid]," ");
	TextDrawShowForPlayer(playerid,MOTD[0][playerid]);
	TextDrawBoxColor(pText[4][playerid], 0x00000000);
	TD_ShowpTextForPlayer(playerid,playerid,4);
	IntroBeat[playerid] = IntroBeats[random(sizeof(IntroBeats))];
	SetTimerEx("SoundAndText",1000,0,"i",playerid);
	UpdateIntro(playerid);
	return 1;
}

forward UpdateIntro(playerid);
public UpdateIntro(playerid)
{
    MOTD_Z[playerid] -= 10.0;
    SetPlayerCameraPos(playerid,MOTD_Locations[MOTDScreen[playerid]][0],MOTD_Locations[MOTDScreen[playerid]][1],MOTD_Z[playerid]);
	SetPlayerCameraLookAt(playerid,MOTD_Locations[MOTDScreen[playerid]][0],MOTD_Locations[MOTDScreen[playerid]][1],MOTD_Locations[MOTDScreen[playerid]][2]-10.0);
	if(MOTD_Z[playerid] <= MOTD_Locations[MOTDScreen[playerid]][2]+5.0)
	{
	    if(GameMap == SA){SetPlayerPos(playerid,sScreenSA[cSelect[playerid]][s_x],sScreenSA[cSelect[playerid]][s_y],sScreenSA[cSelect[playerid]][s_z]);SetPlayerInterior(playerid,sScreenSA[cSelect[playerid]][s_int]);}
		else {SetPlayerPos(playerid,sScreenGTAU[cSelect[playerid]][s_x],sScreenGTAU[cSelect[playerid]][s_cy],sScreenGTAU[cSelect[playerid]][s_cz]);SetPlayerInterior(playerid,sScreenGTAU[cSelect[playerid]][s_int]);}
	    Rotating[playerid] = true;
		RotatePlayer(playerid);
		TextDrawHideForPlayer(playerid,MOTD[0][playerid]);
		FastExplosions(playerid,40);
		HideMOTD(playerid);
		ResetPlayerWeatherAndTime(playerid);
		return 1;
	}
	return SetTimerEx("UpdateIntro",47,0,"i",playerid);
}


forward FadeIn(playerid,amount);
public FadeIn(playerid,amount)
{
	if(KillFade[playerid] == true || !IsPlayerConnected(playerid))return 0;
    TD_HidepTextForPlayer(playerid,playerid,4);
	TextDrawBoxColor(pText[4][playerid],0x00000000 | amount);
	TD_ShowpTextForPlayer(playerid,playerid,4);
	if(amount < 255)return SetTimerEx("FadeIn",50,0,"ii",playerid,amount+3);
	return 1;
}

forward FadeOut(playerid,amount);
public FadeOut(playerid,amount)
{
	if(/*KillFade[playerid] == true || */!IsPlayerConnected(playerid))return 0;
    TD_HidepTextForPlayer(playerid,playerid,4);
	TextDrawBoxColor(pText[4][playerid],0x00000000 | amount);
	TD_ShowpTextForPlayer(playerid,playerid,4);
	if(amount > 75)return SetTimerEx("FadeOut",50,0,"ii",playerid,amount-2);
	else return HideMOTD(playerid);
}

/*forward CreateMOTD(playerid);
public CreateMOTD(playerid)
{
    //FunctionLog("CreateMOTD");
    if(!IsPlayerConnected(playerid))
    {
        KillFade[playerid] = true;
        ViewingMOTD[playerid] = false;
        return 1;
    }
    
    KillFade[playerid] = true;
 	if(GameMap == SA){SetPlayerPos(playerid,sScreenSA[cSelect[playerid]][s_x],sScreenSA[cSelect[playerid]][s_y],sScreenSA[cSelect[playerid]][s_z]);SetPlayerInterior(playerid,sScreenSA[cSelect[playerid]][s_int]);}
	else{SetPlayerPos(playerid,sScreenGTAU[cSelect[playerid]][s_x],sScreenGTAU[cSelect[playerid]][s_cy],sScreenGTAU[cSelect[playerid]][s_cz]);SetPlayerInterior(playerid,sScreenGTAU[cSelect[playerid]][s_int]);}
	
	TD_HidepTextForPlayer(playerid,playerid,0);
	TD_HidepTextForPlayer(playerid,playerid,1);
	TD_HidepTextForPlayer(playerid,playerid,2);
	TD_HidepTextForPlayer(playerid,playerid,13);
	TD_HidepTextForPlayer(playerid,playerid,4);
	TextDrawBoxColor(pText[4][playerid],0x000000FF);
	TD_ShowpTextForPlayer(playerid,playerid,4);
	
	TextDrawShowForPlayer(playerid, MOTD[0][playerid]);
	PlayerPlaySound(playerid,1134,0.0,0.0,0.0);

    //SetTimerEx("HideMOTD", 10000, 0, "i", playerid);
    //SetTimerEx("SoundAndText",500,0,"i",playerid);
    ViewingMOTD[playerid] = true;
    return 1;
}*/

//#define SOUNDD 1002
forward SoundAndText(playerid);
public SoundAndText(playerid)
{
    /*FunctionLogEx("SoundAndText");*/
    CurLetter[playerid]++;
    if(CurLetter[playerid] == 1){TextDrawSetString(MOTD[0][playerid],"B");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 2) {TextDrawSetString(MOTD[0][playerid],"Ba");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 3) {TextDrawSetString(MOTD[0][playerid],"Bat");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 4) {TextDrawSetString(MOTD[0][playerid],"Batt");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 5) {TextDrawSetString(MOTD[0][playerid],"Battl");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 6) {TextDrawSetString(MOTD[0][playerid],"Battle");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 7) {TextDrawSetString(MOTD[0][playerid],"BattleG");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 8) {TextDrawSetString(MOTD[0][playerid],"BattleGr");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 9) {TextDrawSetString(MOTD[0][playerid],"BattleGro");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 10) {TextDrawSetString(MOTD[0][playerid],"BattleGrou");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 11) {TextDrawSetString(MOTD[0][playerid],"BattleGroun");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 12) {TextDrawSetString(MOTD[0][playerid],"BattleGround");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 13) {TextDrawSetString(MOTD[0][playerid],"BattleGrounds");PlayerPlaySound(playerid,IntroBeat[playerid],0.0,0.0,0.0);}
    else if(CurLetter[playerid] == 14) {TextDrawSetString(MOTD[0][playerid],"BattleGrounds");}
	else return 1;
	return SetTimerEx("SoundAndText",150,0,"i",playerid);
}

forward FastExplosions(playerid,amount);
public FastExplosions(playerid,amount)
{
    /*FunctionLogEx("FastExplosions");*/
	amount--;
	PlayPlayerExplosion(playerid);
    if(amount > 1)return SetTimerEx("FastExplosions",51,0,"ii",playerid,amount);
	return 1;
}

/*ShowMOTD(playerid)
{
    //FunctionLog("ShowMOTD");
    TD_HidepTextForPlayer(playerid,playerid,4);
    if(gPlayerSpawned[playerid] == true)TextDrawBoxColor(pText[4][playerid],0x00000066);
    else TextDrawBoxColor(pText[4][playerid],0x000000FF);
	TD_HidepTextForPlayer(playerid,playerid,4);
    TextDrawShowForPlayer(playerid, MOTD[0][playerid]);
    //TextDrawShowForPlayer(playerid, MOTD[1][playerid]);
    //TextDrawShowForPlayer(playerid, MOTD[2][playerid]);
    //TextDrawShowForPlayer(playerid, MOTD[3][playerid]);
    //TextDrawShowForPlayer(playerid, MOTD[4][playerid]);
    SetTimerEx("HideMOTD", 10000, 0, "i", playerid);
}*/

forward HideMOTD(playerid);
public HideMOTD(playerid)
{
    //FunctionLog("HideMOTD");
    if(!IsPlayerConnected(playerid))
    {
        ViewingMOTD[playerid] = false;
        //KillFade[playerid] = true;
        return 1;
    }
	TD_HidepTextForPlayer(playerid,playerid,4);
	TextDrawBoxColor(pText[4][playerid],0x00000000);
	TextDrawHideForPlayer(playerid,MOTD[0][playerid]);
	if(ViewingMOTD[playerid] == true)
	{
	    ViewingMOTD[playerid] = false;
	    OnPlayerRequestClass(playerid,0);
	    //ForceClassSelection(playerid);
	}
	return 1;
}

forward TD_ShowPanoForPlayer(playerid);
public TD_ShowPanoForPlayer(playerid)
{
    //FunctionLog("TD_ShowPanoForPlayer");
    TD_ShowMainTextForPlayer(playerid,Pano_1);
    TD_ShowMainTextForPlayer(playerid,Pano_2);
	return 1;
}

forward TD_HidePanoForPlayer(playerid);
public TD_HidePanoForPlayer(playerid)
{
    //FunctionLog("TD_HidePanoForPlayer");
    TD_HideMainTextForPlayer(playerid,Pano_1);
    TD_HideMainTextForPlayer(playerid,Pano_2);
	return 1;
}

TD_ShowVehTexts(sourceid,playerid)
{
	if(VehInfoShowing[playerid] == false)
	{
	    TD_ShowpTextForPlayer(playerid,sourceid,8);
	    for(new x; x < 4; x++)
		{
			TD_ShowpTextForPlayer(playerid,sourceid,x+9);
		}
		VehInfoShowing[playerid] = true;
	}
}

TD_HideVehTexts(sourceid,playerid)
{
	if(VehInfoShowing[playerid] == true)
	{
	    TD_HidepTextForPlayer(playerid,sourceid,8);
	    for(new x; x < 4; x++)
		{
			TD_HidepTextForPlayer(playerid,sourceid,x+9);
		}
		VehInfoShowing[playerid] = false;
	}
}

TD_Hide2TeamScoreBoard(playerid)
{
	//FunctionLog("TD_Hide2TeamScoreBoard");
	for(new i; i < 10; i++)
	{
	    TextDrawHideForPlayer(playerid,gFinalTeamText[i][0]);
	    TextDrawHideForPlayer(playerid,gFinalTeamText[i][1]);
	    if(i < 8)TextDrawHideForPlayer(playerid,gFinalScoreBoardRounds[i]);
	}
	return 1;
}

TD_Show2TeamScoreBoard(playerid)
{
    //FunctionLog("TD_Show2TeamScoreBoard");
	for(new i; i < 10; i++)
	{
	    TextDrawShowForPlayer(playerid,gFinalTeamText[i][0]);
	    TextDrawShowForPlayer(playerid,gFinalTeamText[i][1]);
	    if(i < 8)TextDrawShowForPlayer(playerid,gFinalScoreBoardRounds[i]);
	}
	return 1;
}

TD_ShowRoundScoreBoard(playerid)
{
	//FunctionLog("TD_ShowRoundScoreBoard");
	if(Current != -1)
	{
	    TD_ShowTeamDmgText(playerid);
	    TD_ShowMainTextForPlayer(playerid,0);
		if(ModeType == BASE || (TeamsBeingUsed == 2 && ModeType != TDM))
		{
   		 	TD_ShowMainTextForPlayer(playerid,10);
   		 	TD_ShowMainTextForPlayer(playerid,11);
		}
		else
		{
			for(new i; i < ACTIVE_TEAMS; i++)
			{
				if(TeamUsed[i] == true)
    			{
    	    		TextDrawShowForPlayer(playerid,ArenaTxt[i]);
				}
			}
		}
	}
	return 1;
}

TD_HideRoundScoreBoard(playerid)
{
    //FunctionLog("TD_HideRoundScoreBoard");
	TD_HideTeamDmgText(playerid);
	TD_HideMainTextForPlayer(playerid,0);
	TD_HideMainTextForPlayer(playerid,10);
	TD_HideMainTextForPlayer(playerid,11);
	for(new i; i < ACTIVE_TEAMS; i++)
	{
		TextDrawHideForPlayer(playerid,ArenaTxt[i]);
	}
	return 1;
}

TD_ShowTeamDmgText(playerid)
{
    //FunctionLog("TD_ShowTeamDmgText");
    if(Current != -1)
    {
		if(ModeType == BASE || (TeamsBeingUsed == 2 && ModeType != TDM))
		{
			if(ShowTeamDmg == 1 && Playing[playerid] == true)
			{
    			TextDrawShowForPlayer(playerid,TeamDmgTextB[gTeam[playerid]]);
			}
			else if(ShowTeamDmg == 2)
			{
			    TextDrawShowForPlayer(playerid,TeamDmgTextB[T_HOME]);
				TextDrawShowForPlayer(playerid,TeamDmgTextB[T_AWAY]);
			}
		}
		else
		{
		    if(ShowTeamDmg == 1 && Playing[playerid] == true)
			{
    			TextDrawShowForPlayer(playerid,TeamDmgTextA[gTeam[playerid]]);
			}
			else if(ShowTeamDmg == 2)
			{
			    for(new i; i < ACTIVE_TEAMS; i++)
			    {
			        if(TeamUsed[i] == true)
			        {
    					TextDrawShowForPlayer(playerid,TeamDmgTextA[i]);
					}
				}
			}
		}
	}
	return 1;
}

TD_HideTeamDmgText(playerid)
{
    //FunctionLog("TD_HideTeamDmgText");
    TextDrawHideForPlayer(playerid,TeamDmgTextB[T_HOME]);
    TextDrawHideForPlayer(playerid,TeamDmgTextB[T_AWAY]);
    for(new i; i < ACTIVE_TEAMS; i++)
	{
		TextDrawHideForPlayer(playerid,TeamDmgTextA[i]);
	}
	return 1;
}

TD_ShowpTextForPlayer(playerid,showid,textid)
{
	if(pTextShowing[playerid][showid][textid] == false)
	{
	    TextDrawShowForPlayer(playerid,pText[textid][showid]);
	    pTextShowing[playerid][showid][textid] = true;
	}
}

TD_HidepTextForPlayer(playerid,hideid,textid)
{
	if(pTextShowing[playerid][hideid][textid] == true)
	{
	    TextDrawHideForPlayer(playerid,pText[textid][hideid]);
	    pTextShowing[playerid][hideid][textid] = false;
	}
}

TD_ShowMainTextForPlayer(playerid,textid)
{
	if(MainTextShowing[playerid][textid] == false)
	{
	    TextDrawShowForPlayer(playerid,MainText[textid]);
	    MainTextShowing[playerid][textid] = true;
	}
}

TD_HideMainTextForPlayer(playerid,textid)
{
	if(MainTextShowing[playerid][textid] == true)
	{
	    TextDrawHideForPlayer(playerid,MainText[textid]);
	    MainTextShowing[playerid][textid] = false;
	}
}

ResetTextDrawColors()
{
    //FunctionLog("ResetTextDrawColors");
	for(new t = 0; t < ACTIVE_TEAMS; t++)
	{
    	TextDrawColor(gFinalText2[t],TeamActiveColors[t] | 0x000000FF);
		TextDrawColor(gFinalText4[t],TeamActiveColors[t] | 0x000000FF);
		TextDrawBoxColor(gFinalText1[t], TeamActiveColors[t] | 0x00000060);
	}
}

CreateGlobalTextdraws()
{
    //FunctionLog("CreateGlobalTextDraws");
    MainText[Pano_1] = TextDrawCreate(320.0, 375, "~n~~n~~n~~n~");
	TextDrawAlignment(MainText[Pano_1], 2);
	TextDrawBoxColor(MainText[Pano_1], 0x000000A0);
	TextDrawColor(MainText[Pano_1], 0x00000000);
	TextDrawFont(MainText[Pano_1], 2);
	TextDrawLetterSize(MainText[Pano_1], 2.2, 4.0);
	TextDrawSetProportional(MainText[Pano_1], 1);
	TextDrawTextSize(MainText[Pano_1], 80.0, 1280.0);
	TextDrawUseBox(MainText[Pano_1], 1);

	MainText[Pano_2] = TextDrawCreate(320.0, 0.0, "~n~  ~n~");
	TextDrawAlignment(MainText[Pano_2], 2);
	TextDrawBoxColor(MainText[Pano_2], 0x000000A0);
	TextDrawColor(MainText[Pano_2], 0x00000000);
	TextDrawFont(MainText[Pano_2], 2);
	TextDrawLetterSize(MainText[Pano_2], 2.2, 4.0);
	TextDrawSetProportional(MainText[Pano_2], 1);
	TextDrawTextSize(MainText[Pano_2], 80.0, 1280.0);
	TextDrawUseBox(MainText[Pano_2], 1);

	MainText[0] = TextDrawCreate(320.0, 436.45, " ~n~ ~n~ ~n~ ~n~ ");//black bar for the scoreboard
	TextDrawAlignment(MainText[0], 2);
	TextDrawBoxColor(MainText[0], 0x00000060);
	TextDrawFont(MainText[0], 3);
	TextDrawLetterSize(MainText[0], 0.30, 1.15);//0.25, 1.10
	TextDrawSetProportional(MainText[0], 1);
	TextDrawSetShadow(MainText[0],1);
	TextDrawTextSize(MainText[0], 40.0, 640.0);
	TextDrawUseBox(MainText[0], 1);
	TextDrawColor(MainText[0],MainColors[3]);
	TextDrawBackgroundColor(MainText[0],0x000000FF);
	TextDrawSetOutline(MainText[0],1);
	
	MainText[10] = TextDrawCreate(160.0, 436.45, " scoreboard T0 ");//team name, players, health
	TextDrawAlignment(MainText[10], 2);
	TextDrawFont(MainText[10], 3);
	TextDrawLetterSize(MainText[10], 0.30, 1.15);
	TextDrawSetProportional(MainText[10], 1);
	TextDrawSetShadow(MainText[10], 1);
	TextDrawColor(MainText[10],0xEC7600FF);
	TextDrawBackgroundColor(MainText[10],0x000000FF);
	TextDrawSetOutline(MainText[10],1);
	
	TeamDmgTextB[0] = TextDrawCreate(160.0, 415.0, " ");//shows team damage (T_HOME)
	TextDrawAlignment(TeamDmgTextB[0], 1);
	TextDrawFont(TeamDmgTextB[0], 2);
	TextDrawLetterSize(TeamDmgTextB[0], 0.8, 2.4);
	TextDrawSetProportional(TeamDmgTextB[0], 1);
	TextDrawColor(TeamDmgTextB[0],0xFF0000FF);
	TextDrawBackgroundColor(TeamDmgTextB[0],0x000000FF);
	TextDrawSetOutline(TeamDmgTextB[0],1);

	MainText[11] = TextDrawCreate(480.0, 436.45, " scoreboard T1 ");//team name, players, health
	TextDrawAlignment(MainText[11], 2);
	TextDrawFont(MainText[11], 3);
	TextDrawLetterSize(MainText[11], 0.30, 1.15);
	TextDrawSetProportional(MainText[11], 1);
	TextDrawColor(MainText[11],0xEC7600FF);
	TextDrawBackgroundColor(MainText[11],0x000000FF);
	TextDrawSetOutline(MainText[11],1);
	
	TeamDmgTextB[1] = TextDrawCreate(480.0, 415.0, " ");//shows team damage (T_AWAY)
	TextDrawAlignment(TeamDmgTextB[1], 1);
	TextDrawFont(TeamDmgTextB[1], 2);
	TextDrawLetterSize(TeamDmgTextB[1], 0.8, 2.4);
	TextDrawSetProportional(TeamDmgTextB[1], 1);
	TextDrawColor(TeamDmgTextB[1],0xFF0000FF);
	TextDrawBackgroundColor(TeamDmgTextB[1],0x000000FF);
	TextDrawSetOutline(TeamDmgTextB[1],1);
	
	gFinalText = TextDrawCreate(295.5, 107.5, "Final Results");
	TextDrawAlignment(gFinalText, 2);
	TextDrawColor(gFinalText, 0xFFFFFFFF);
	TextDrawFont(gFinalText, 0);
	TextDrawLetterSize(gFinalText, 1.2, 2.2);
	TextDrawSetOutline(gFinalText, 1);
	
	StatusText[0] = TextDrawCreate(320.0, 350.0, "Attacking");//attacking / defending  message
	TextDrawAlignment(StatusText[0], 2);
	TextDrawFont(StatusText[0], 3);
	TextDrawLetterSize(StatusText[0], 1.0, 3.0);
	TextDrawSetOutline(StatusText[0], 2);
	TextDrawSetProportional(StatusText[0], 1);
	TextDrawSetOutline(StatusText[0],2);
	TextDrawSetShadow(StatusText[0],2);
	TextDrawBackgroundColor(StatusText[0],0x000000FF);
	
	StatusText[1] = TextDrawCreate(320.0, 350.0, "Defending");//attacking / defending  message
	TextDrawAlignment(StatusText[1], 2);
	TextDrawFont(StatusText[1], 3);
	TextDrawLetterSize(StatusText[1], 1.0, 3.0);
	TextDrawSetOutline(StatusText[1], 2);
	TextDrawSetProportional(StatusText[1], 1);
	TextDrawSetOutline(StatusText[1],2);
	TextDrawSetShadow(StatusText[1],2);
	TextDrawBackgroundColor(StatusText[1],0x000000FF);
	
	for(new t; t < 6; t++)
	{
	    ArenaTxt[t] = TextDrawCreate(5+(110.0*t), 436.45, " ");
		TextDrawAlignment(ArenaTxt[t], 1);
		TextDrawFont(ArenaTxt[t], 3);
		TextDrawLetterSize(ArenaTxt[t], 0.25, 1.00);
		TextDrawSetProportional(ArenaTxt[t], 1);
		TextDrawSetShadow(ArenaTxt[t], 1);
		TextDrawColor(ArenaTxt[t],0xFF0000FF);
		TextDrawBackgroundColor(ArenaTxt[t],0x000000FF);
		TextDrawSetOutline(ArenaTxt[t],1);
		
		TeamDmgTextA[t] = TextDrawCreate(5+(110.0*t), 420.0, " ");
		TextDrawAlignment(TeamDmgTextA[t], 1);
		TextDrawFont(TeamDmgTextA[t], 1);
		TextDrawLetterSize(TeamDmgTextA[t], 0.8, 2.4);
		TextDrawSetProportional(TeamDmgTextA[t], 1);
		TextDrawSetShadow(TeamDmgTextA[t], 1);
		TextDrawColor(TeamDmgTextA[t],0xFF0000FF);
		TextDrawBackgroundColor(TeamDmgTextA[t],0x000000FF);
		TextDrawSetOutline(TeamDmgTextA[t],1);
	
	    gFinalText1[t] = TextDrawCreate(57.0+(t*105.0), 151.6,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~.");//Team  Background
		TextDrawAlignment(gFinalText1[t], 2);
		TextDrawTextSize(gFinalText1[t], 0.0, 98.0);
		TextDrawUseBox(gFinalText1[t], 1);

	    gFinalText2[t] = TextDrawCreate(57.0+(t*105.0), 135.0," ");//Team Header
		TextDrawAlignment(gFinalText2[t], 2);
		TextDrawBoxColor(gFinalText2[t], 0x000000FF);
		TextDrawFont(gFinalText2[t], 2);
		TextDrawLetterSize(gFinalText2[t], 0.3, 1.4);//0.6,1.4
		TextDrawSetOutline(gFinalText2[t], 1);
		TextDrawSetProportional(gFinalText2[t], 2);
		TextDrawTextSize(gFinalText2[t], 0.0, 98.0);
		TextDrawUseBox(gFinalText2[t], 1);

		gFinalText3[t] = TextDrawCreate(57.0+(t*105.0), 151.6," ");//List of Players on Team
		TextDrawAlignment(gFinalText3[t], 2);
		TextDrawBoxColor(gFinalText3[t], 0x00000000);
		TextDrawFont(gFinalText3[t], 1);
		TextDrawLetterSize(gFinalText3[t], 0.2, 1.0);
		TextDrawSetOutline(gFinalText3[t], 1);
		TextDrawSetProportional(gFinalText3[t], 2);
		TextDrawTextSize(gFinalText3[t], 0.0, 98.0);
		TextDrawUseBox(gFinalText3[t], 1);

		gFinalText4[t] = TextDrawCreate(57.0+(t*105.0), 300.0," ");
		TextDrawAlignment(gFinalText4[t], 2);
		TextDrawBoxColor(gFinalText4[t], 0x000000FF);
		TextDrawFont(gFinalText4[t], 2);
		TextDrawLetterSize(gFinalText4[t], 0.2, 1.1);
		TextDrawSetOutline(gFinalText4[t], 1);
		TextDrawSetProportional(gFinalText4[t], 2);
		TextDrawTextSize(gFinalText4[t], 0.0, 98.0);
		TextDrawUseBox(gFinalText4[t], 1);

		if(t < ACTIVE_TEAMS)
		{
			TextDrawColor(gFinalText2[t],TeamActiveColors[t] | 0x000000FF);
			TextDrawColor(gFinalText4[t],TeamActiveColors[t] | 0x000000FF);
			TextDrawBoxColor(gFinalText1[t], TeamActiveColors[t] | 0x00000060);
		}
	}
	
    for(new i; i < MAX_SERVER_PLAYERS; i++)
	{
	    /*pText[6][i] = TextDrawCreate(490.0, 78.0, "HP:     200~n~Team:  teamname");
		TextDrawAlignment(pText[6][i], 1);
		TextDrawColor(pText[6][i], MainColors[3]);
		TextDrawBackgroundColor(pText[6][i],0xFFFFFFFF);
		TextDrawSetShadow(pText[6][i], 0);
		TextDrawFont(pText[6][i], 1);
		TextDrawLetterSize(pText[6][i], 0.4, 1.2);*/
		
	    pText[0][i] = TextDrawCreate(320.0, 370.0, " character selection ");//320,390
		TextDrawAlignment(pText[0][i], 2);
		TextDrawFont(pText[0][i], 1);
		TextDrawLetterSize(pText[0][i], 1.0, 3.0);
		TextDrawSetOutline(pText[0][i], 1);
		//TextDrawSetShadow(pText[0][i], 2);
		TextDrawColor(pText[0][i],0x000000FF);
		//TextDrawBackgroundColor(pText[0][i],0x000000FF);
		//TextDrawSetProportional(pText[0][i], 1);

        pText[1][i] = TextDrawCreate(320.0, 0.0, " spectator ");//name, health, armor, (top spectate TD)
		TextDrawAlignment(pText[1][i], 2);
		TextDrawBackgroundColor(pText[1][i],0x000000FF);
		//TextDrawSetOutline(pText[1][i],1);
		TextDrawFont(pText[1][i], 1);
		TextDrawLetterSize(pText[1][i], 0.40, 1.50);
		TextDrawSetProportional(pText[1][i], 1);
		TextDrawSetShadow(pText[1][i], 1);
		TextDrawTextSize(pText[1][i], 40.0, 640.0);

        pText[2][i] = TextDrawCreate(430,212+100,"Your arsenal");
    	TextDrawBoxColor(pText[2][i],0x00000066);
    	TextDrawTextSize(pText[2][i],570,95);
    	TextDrawAlignment(pText[2][i],1);
    	TextDrawBackgroundColor(pText[2][i],0x000000FF);
    	TextDrawFont(pText[2][i],2);
		TextDrawLetterSize(pText[2][i],0.3,1.2);
		TextDrawColor(pText[2][i],0xFFFFFFFF);
		TextDrawSetOutline(pText[2][i],1);
		TextDrawSetProportional(pText[2][i],1);
		TextDrawUseBox(pText[2][i],1);

        pText[4][i] = TextDrawCreate(320.0, 0.0, " ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ .");//black screen - needs to be per-player since it fades
		TextDrawAlignment(pText[4][i], 2);
		TextDrawColor(pText[4][i], 0x24FF5BA0);
		TextDrawBoxColor(pText[4][i], 0x000000000);
		TextDrawFont(pText[4][i], 2);
		TextDrawLetterSize(pText[4][i], 2.2, 4.0);
		TextDrawSetProportional(pText[4][i], 1);
		TextDrawSetShadow(pText[4][i], 1);
		TextDrawTextSize(pText[4][i], 80.0, 1280.0);
		TextDrawUseBox(pText[4][i], 1);
		
		pText[5][i] = TextDrawCreate(320.0, 370.0, " ");//text that shows who you killed or who killed you
		TextDrawAlignment(pText[5][i], 2);
		TextDrawSetOutline(pText[5][i],1);
		TextDrawBackgroundColor(pText[5][i],0x000000FF);
		TextDrawFont(pText[5][i], 1);
		TextDrawLetterSize(pText[5][i], 0.7, 2.1);
		
		pText[7][i] = TextDrawCreate(10.0, 250.0,"chase info");
		TextDrawFont(pText[7][i],1);
		TextDrawLetterSize(pText[7][i],0.33,1.0);
		TextDrawColor(pText[7][i],0xAAAAAAFF);
		TextDrawSetShadow(pText[7][i],1);
		TextDrawSetOutline(pText[7][i],1);
		TextDrawBackgroundColor(pText[7][i],0x000000C0);
		
		pText[8][i] = TextDrawCreate(150.0, 375.0, " ");//vehicle info (HP, ID, NAME, LOCKED)
		TextDrawLetterSize(pText[8][i], 0.20, 1.00);
		TextDrawSetShadow(pText[8][i],1);
		TextDrawSetOutline(pText[8][i],1);
   	 	TextDrawBoxColor(pText[8][i], 0x000000AA);
   	 	TextDrawColor(pText[8][i],MainColors[3]);
   	 	TextDrawBackgroundColor(pText[8][i],0x000000FF);
		TextDrawFont(pText[8][i],2);
		TextDrawSetProportional(pText[8][i], 1);
    	TextDrawTextSize(pText[8][i], 380, 380);
		TextDrawUseBox(pText[8][i], 1);

		pText[9][i] = TextDrawCreate(150.0, 390.0," ");//vehicle text - driver
		TextDrawFont(pText[9][i],1);
		TextDrawLetterSize(pText[9][i],0.2,0.7);
		TextDrawColor(pText[9][i],0xFFFFFFFF);
		TextDrawSetShadow(pText[9][i],1);
		TextDrawSetOutline(pText[9][i],1);
		TextDrawBackgroundColor(pText[9][i],0x000000FF);
		
		pText[10][i] = TextDrawCreate(150.0, 398.0," ");//vehicle text - passenger 1
		TextDrawFont(pText[10][i],1);
		TextDrawLetterSize(pText[10][i],0.2,0.7);
		TextDrawColor(pText[10][i],0xFFFFFFFF);
		TextDrawSetShadow(pText[10][i],1);
		TextDrawSetOutline(pText[10][i],1);
		TextDrawBackgroundColor(pText[10][i],0x000000FF);
		
		pText[11][i] = TextDrawCreate(150.0, 406.0," ");//vehicle text - passenger 2
		TextDrawFont(pText[11][i],1);
		TextDrawLetterSize(pText[11][i],0.2,0.7);
		TextDrawColor(pText[11][i],0xFFFFFFFF);
		TextDrawSetShadow(pText[11][i],1);
		TextDrawSetOutline(pText[11][i],1);
		TextDrawBackgroundColor(pText[11][i],0x000000FF);
		
		pText[12][i] = TextDrawCreate(150.0, 414.0," ");//vehicle text - passenger 3
		TextDrawFont(pText[12][i],1);
		TextDrawLetterSize(pText[12][i],0.2,0.7);
		TextDrawColor(pText[12][i],0xFFFFFFFF);
		TextDrawSetShadow(pText[12][i],1);
		TextDrawSetOutline(pText[12][i],1);
		TextDrawBackgroundColor(pText[12][i],0x000000FF);
		
		pText[13][i] = TextDrawCreate(10.0, 368.0,"spec weapon info");//spectate weapons (GUNS AND AMMO)
		TextDrawFont(pText[13][i],1);
		TextDrawLetterSize(pText[13][i],0.2,0.7);
		TextDrawColor(pText[13][i],MainColors[1]);
		TextDrawSetShadow(pText[13][i],1);
		TextDrawSetOutline(pText[13][i],1);
		TextDrawBackgroundColor(pText[13][i],0x000000FF);
		
		pText[14][i] = TextDrawCreate(525.0, 390.0," ");//live updating life meter
		TextDrawAlignment(pText[14][i],0);
		TextDrawFont(pText[14][i],3);
		TextDrawLetterSize(pText[14][i],0.50,1.50);
		TextDrawSetOutline(pText[14][i],1);
		TextDrawSetShadow(pText[14][i],1);
		TextDrawBackgroundColor(pText[14][i],0x000000FF);
		TextDrawSetProportional(pText[14][i],1);
		TextDrawColor(pText[14][i],MainColors[2]);
		
		pText[15][i] = TextDrawCreate(560.0, 368.0,"the spectating you textdraw");//"spectating you" list
		TextDrawFont(pText[15][i],1);
		TextDrawLetterSize(pText[15][i],0.2,0.7);
		TextDrawColor(pText[15][i],MainColors[0]);
		TextDrawSetShadow(pText[15][i],1);
		TextDrawSetOutline(pText[15][i],1);
		TextDrawBackgroundColor(pText[15][i],0x000000FF);
		
		MOTD[0][i] = TextDrawCreate(320.0, 175.0, " ");
		TextDrawAlignment(MOTD[0][i], 2);
		TextDrawColor(MOTD[0][i], 0x000000FF);
		TextDrawFont(MOTD[0][i], 3);
		TextDrawLetterSize(MOTD[0][i], 0.8, 2.5);
		TextDrawSetOutline(MOTD[0][i], 2);
		TextDrawBackgroundColor(MOTD[0][i],0x9D0000FF);
		TextDrawSetProportional(MOTD[0][i], 2);
	}

    TopShotta[0] = TextDrawCreate(220.0,119.0,"box 0");
    TextDrawUseBox(TopShotta[0],1);
    TextDrawBoxColor(TopShotta[0],0x0000ff66);
    TextDrawTextSize(TopShotta[0],430.0,0.0);
    TextDrawAlignment(TopShotta[0],0);
    TextDrawBackgroundColor(TopShotta[0],0x000000ff);
    TextDrawFont(TopShotta[0],3);
    TextDrawLetterSize(TopShotta[0],-0.0,14.3);
    TextDrawColor(TopShotta[0],0xffffffff);
    TextDrawSetOutline(TopShotta[0],1);
    TextDrawSetProportional(TopShotta[0],1);
    TextDrawSetShadow(TopShotta[0],1);

	TopShotta[1] = TextDrawCreate(220.0,119.0,"box 1");
 	TextDrawUseBox(TopShotta[1],1);
	TextDrawBoxColor(TopShotta[1],0x000000ff);
 	TextDrawTextSize(TopShotta[1],430.0,0.0);
 	TextDrawAlignment(TopShotta[1],0);
 	TextDrawBackgroundColor(TopShotta[1],0x000000ff);
 	TextDrawFont(TopShotta[1],3);
 	TextDrawLetterSize(TopShotta[1],-0.0,2.899999);
 	TextDrawColor(TopShotta[1],0xffffffff);
 	TextDrawSetOutline(TopShotta[1],1);
 	TextDrawSetProportional(TopShotta[1],1);
 	TextDrawSetShadow(TopShotta[1],1);

	TopShotta[2] = TextDrawCreate(220.0,220.0,"box 2");
 	TextDrawUseBox(TopShotta[2],1);
 	TextDrawBoxColor(TopShotta[2],0x000000ff);
 	TextDrawTextSize(TopShotta[2],430.0,0.0);
 	TextDrawAlignment(TopShotta[2],0);
 	TextDrawBackgroundColor(TopShotta[2],0x000000ff);
 	TextDrawColor(TopShotta[2],0xffffffff);
 	TextDrawSetOutline(TopShotta[2],1);
 	TextDrawSetProportional(TopShotta[2],1);
 	TextDrawSetShadow(TopShotta[2],1);
 	TextDrawFont(TopShotta[2],3);
 	TextDrawLetterSize(TopShotta[2],-0.0,3.099999);

	TopShotta[3] = TextDrawCreate(234.0,160.0,"Defenders ~w~win!");
	TextDrawAlignment(TopShotta[3],0);
	TextDrawBackgroundColor(TopShotta[3],0x000000ff);
	TextDrawFont(TopShotta[3],0);
	TextDrawLetterSize(TopShotta[3],1.0,2.699999);
	TextDrawColor(TopShotta[3],0x0000ffcc);
	TextDrawSetOutline(TopShotta[3],1);
	TextDrawSetProportional(TopShotta[3],1);
	TextDrawSetShadow(TopShotta[3],1);

	TopShotta[4] = TextDrawCreate(328.0,195.0,"~n~~r~Top Shotta~n~~n~~w~[NB]90N1N3 - 10 kill(s)");
	TextDrawAlignment(TopShotta[4],2);
	TextDrawBackgroundColor(TopShotta[4],0x000000ff);
	TextDrawFont(TopShotta[4],1);
	TextDrawLetterSize(TopShotta[4],0.40,1.20);
	TextDrawColor(TopShotta[4],0xffffffff);
	TextDrawSetOutline(TopShotta[4],1);
	TextDrawSetProportional(TopShotta[4],1);
	TextDrawSetShadow(TopShotta[4],1);

	MainText[1] = TextDrawCreate(320.0, 415.0, " checkpoint time ");//checkpoint countdown time
	TextDrawAlignment(MainText[1], 2);
	TextDrawFont(MainText[1], 3);
	TextDrawLetterSize(MainText[1], 0.45, 1.75);//0.25, 1.10
	TextDrawSetProportional(MainText[1], 1);
	TextDrawTextSize(MainText[1], 40.0, 640.0);
	TextDrawColor(MainText[1],0xFF0000E0);
	TextDrawSetOutline(MainText[1],1);

	MainText[2] = TextDrawCreate(320.0, 250.0, " checkpoint holders ");//lists the players that held the checkpoint at the end of a base
	TextDrawAlignment(MainText[2], 2);
	TextDrawColor(MainText[2],0xEABC06FF);
	TextDrawFont(MainText[2], 1);
	TextDrawLetterSize(MainText[2], 0.45, 1.50);//0.25, 1.10
	TextDrawSetProportional(MainText[2], 1);
	TextDrawSetShadow(MainText[2], 1);
	TextDrawTextSize(MainText[2], 40.0, 640.0);
	TextDrawSetOutline(MainText[2],1);

	MainText[3] = TextDrawCreate(320.0, 423.0, " ~n~ ~n~ ~n~ ~n~ ~n~ ~n~ countdown");
	TextDrawAlignment(MainText[3], 2);
	TextDrawBoxColor(MainText[3], 0x000000A0);
	TextDrawFont(MainText[3], 3);
	TextDrawLetterSize(MainText[3], 0.70, 2.50);
	TextDrawSetProportional(MainText[3], 1);
	TextDrawSetShadow(MainText[3], 3);
	TextDrawTextSize(MainText[3], 40.0, 640.0);
	TextDrawUseBox(MainText[3], 1);
	TextDrawColor(MainText[3],0xFF66B3FF);
	TextDrawSetOutline(MainText[3],1);

	/*MoneyBox = TextDrawCreate(610.0, 79.0, " ~n~ ~n~ ");
	TextDrawBoxColor(MoneyBox, 0x000000FF);
	TextDrawTextSize(MoneyBox, 485, 485);
	TextDrawUseBox(MoneyBox, 1);*/

	MainText[5] = TextDrawCreate(320.0, 200.0, "/pass [password]");
	TextDrawAlignment(MainText[5], 2);
	TextDrawFont(MainText[5], 3);
	TextDrawLetterSize(MainText[5], 2.00, 6.00);//0.25, 1.10
	TextDrawSetProportional(MainText[5], 1);
	TextDrawTextSize(MainText[5], 40.0, 640.0);
	TextDrawColor(MainText[5],0xFF0000E0);
	TextDrawSetOutline(MainText[5],1);
	
	/*MainText[8] = TextDrawCreate(500.0, 3.5, "~rwww.teamspainad.es");
	TextDrawAlignment(MainText[8],1);
	TextDrawFont(MainText[8],3);
	TextDrawLetterSize(MainText[8], 0.4, 1.0);
	TextDrawSetProportional(MainText[8], 2);
	TextDrawSetShadow(MainText[8],1);*/
	
	MainText[9] = TextDrawCreate(548.0, 22.0, "00:00");//rounc clock
	TextDrawAlignment(MainText[9], 1);
	TextDrawFont(MainText[9], 3);
	TextDrawLetterSize(MainText[9], 0.56, 2.16);
	TextDrawColor(MainText[9],MainColors[3]);
	TextDrawSetOutline(MainText[9], 2);
	
	MainText[12] = TextDrawCreate(500.0, 10.0,"map info");
	TextDrawAlignment(MainText[12],0);
	TextDrawFont(MainText[12],3);
	TextDrawLetterSize(MainText[12],0.35,0.80);
	TextDrawSetOutline(MainText[12],1);
	TextDrawSetShadow(MainText[12],1);
	TextDrawBackgroundColor(MainText[12],0x000000FF);
	TextDrawSetProportional(MainText[12],1);
	TextDrawColor(MainText[12],MainColors[0]);
	
	MainText[13] = TextDrawCreate(498,298,"Weapons");//text above the box while selecting weapons before a round
	TextDrawAlignment(MainText[13],2);
	TextDrawBackgroundColor(MainText[13],0x000000FF);
	TextDrawFont(MainText[13],3);
	TextDrawLetterSize(MainText[13],0.8,1.4);
	TextDrawColor(MainText[13],0xFF972FFF);
	TextDrawSetOutline(MainText[13],1);
	TextDrawSetProportional(MainText[13],1);
	TextDrawSetShadow(MainText[13],1);

	WeaponText[0][BASE] = TextDrawCreate(10.0, 200.0," ");//base weapon set 1 (/wlist base)
	TextDrawFont(WeaponText[0][BASE],1);
	TextDrawLetterSize(WeaponText[0][BASE],0.4,1.2);
	TextDrawColor(WeaponText[0][BASE],0x0000FFFF);//blue
	TextDrawSetShadow(WeaponText[0][BASE],1);
	TextDrawSetOutline(WeaponText[0][BASE],1);
	TextDrawBackgroundColor(WeaponText[0][BASE],0x000000FF);

	WeaponText[1][BASE] = TextDrawCreate(140.0, 200.0," ");//base weapon set 2 (/wlist base)
	TextDrawFont(WeaponText[1][BASE],1);
	TextDrawLetterSize(WeaponText[1][BASE],0.4,1.2);
	TextDrawColor(WeaponText[1][BASE],0x00FF00FF);//green
	TextDrawSetShadow(WeaponText[1][BASE],1);
	TextDrawSetOutline(WeaponText[1][BASE],1);
	TextDrawBackgroundColor(WeaponText[1][BASE],0x00000065);

	WeaponText[2][BASE] = TextDrawCreate(270.0, 200.0," ");//base weapon set 3 (/wlist base)
	TextDrawFont(WeaponText[2][BASE],1);
	TextDrawLetterSize(WeaponText[2][BASE],0.4,1.2);
	TextDrawColor(WeaponText[2][BASE],0xFF0000FF);//red
	TextDrawSetShadow(WeaponText[2][BASE],1);
	TextDrawSetOutline(WeaponText[2][BASE],1);
	TextDrawBackgroundColor(WeaponText[2][BASE],0x000000FF);

	WeaponText[3][BASE] = TextDrawCreate(400.0, 200.0," ");//base weapon set 4 (/wlist base)
	TextDrawFont(WeaponText[3][BASE],1);
	TextDrawLetterSize(WeaponText[3][BASE],0.4,1.2);
	TextDrawColor(WeaponText[3][BASE],0xFFFF00FF);//yellow
	TextDrawSetShadow(WeaponText[3][BASE],1);
	TextDrawSetOutline(WeaponText[3][BASE],1);
	TextDrawBackgroundColor(WeaponText[3][BASE],0x000000FF);

	WeaponText[4][BASE] = TextDrawCreate(530.0, 200.0," ");//base weapon set auto (/wlist base)
	TextDrawFont(WeaponText[4][BASE],1);
	TextDrawLetterSize(WeaponText[3][BASE],0.4,1.2);
	TextDrawColor(WeaponText[4][BASE],0xFF8000FF);//orange
	TextDrawSetShadow(WeaponText[4][BASE],1);
	TextDrawSetOutline(WeaponText[4][BASE],1);
	TextDrawBackgroundColor(WeaponText[4][BASE],0x000000FF);

	WeaponText[0][ARENA] = TextDrawCreate(10.0, 200.0," ");//arena weapon set 1 (/wlist arena)
	TextDrawFont(WeaponText[0][ARENA],1);
	TextDrawLetterSize(WeaponText[0][ARENA],0.4,1.2);
	TextDrawColor(WeaponText[0][ARENA],0x0000FFFF);//blue
	TextDrawSetShadow(WeaponText[0][ARENA],1);
	TextDrawSetOutline(WeaponText[0][ARENA],1);
	TextDrawBackgroundColor(WeaponText[0][ARENA],0x000000FF);

	WeaponText[1][ARENA] = TextDrawCreate(140.0, 200.0," ");//arena weapon set 2 (/wlist arena)
	TextDrawFont(WeaponText[1][ARENA],1);
	TextDrawLetterSize(WeaponText[1][ARENA],0.4,1.2);
	TextDrawColor(WeaponText[1][ARENA],0x00FF00FF);//green
	TextDrawSetShadow(WeaponText[1][ARENA],1);
	TextDrawSetOutline(WeaponText[1][ARENA],1);
	TextDrawBackgroundColor(WeaponText[1][ARENA],0x000000FF);

	WeaponText[2][ARENA] = TextDrawCreate(270.0, 200.0," ");//arena weapon set 3 (/wlist arena)
	TextDrawFont(WeaponText[2][ARENA],1);
	TextDrawLetterSize(WeaponText[2][ARENA],0.4,1.2);
	TextDrawColor(WeaponText[2][ARENA],0xFF0000FF);//red
	TextDrawSetShadow(WeaponText[2][ARENA],1);
	TextDrawSetOutline(WeaponText[2][ARENA],1);
	TextDrawBackgroundColor(WeaponText[2][ARENA],0x000000FF);

	WeaponText[3][ARENA] = TextDrawCreate(400.0, 200.0," ");//arena weapon set 4 (/wlist arena)
	TextDrawFont(WeaponText[3][ARENA],1);
	TextDrawLetterSize(WeaponText[3][ARENA],0.4,1.2);
	TextDrawColor(WeaponText[3][ARENA],0xFFFF00FF);//yellow
	TextDrawSetShadow(WeaponText[3][ARENA],1);
	TextDrawSetOutline(WeaponText[3][ARENA],1);
	TextDrawBackgroundColor(WeaponText[3][ARENA],0x000000FF);
	
	WeaponText[4][ARENA] = TextDrawCreate(530.0, 200.0," ");//arena weapon set auto (/wlist arena)
	TextDrawFont(WeaponText[4][ARENA],1);
	TextDrawLetterSize(WeaponText[4][ARENA],0.4,1.2);
	TextDrawColor(WeaponText[4][ARENA],0xFF8000FF);//orange
	TextDrawSetShadow(WeaponText[4][ARENA],1);
	TextDrawSetOutline(WeaponText[4][ARENA],1);
	TextDrawBackgroundColor(WeaponText[4][ARENA],0x000000FF);
	return 1;
}

TD_CreateScoreboard()
{
        //FunctionLog("TD_CreateScoreboard");
		new Float:X_Start[2],Float:Y_Start,Float:Size;
		X_Start[0] = 155.0;
		X_Start[1] = 485.0;
		Y_Start = 275.0;
		Size = 250.0;

//------------------------------------------------------------------------------
//TEAM HOME (0)

    	gFinalTeamText[0][0] = TextDrawCreate(X_Start[0], Y_Start,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");//Team  Background
		TextDrawAlignment(gFinalTeamText[0][0], 2);
		TextDrawTextSize(gFinalTeamText[0][0], 0.0, Size);
		TextDrawUseBox(gFinalTeamText[0][0], 1);

		gFinalTeamText[1][0] = TextDrawCreate(X_Start[0], Y_Start-11,"Name              ~w~Kills     Deaths     Ratio");//Team Header
		TextDrawAlignment(gFinalTeamText[1][0], 2);
		TextDrawBoxColor(gFinalTeamText[1][0], 0x000000FF);
		TextDrawFont(gFinalTeamText[1][0], 3);
		TextDrawLetterSize(gFinalTeamText[1][0], 0.3, 1.1);//0.6,1.4
		TextDrawSetOutline(gFinalTeamText[1][0], 1);
		//TextDrawSetProportional(gFinalTeamText[1][0], 2);
		TextDrawTextSize(gFinalTeamText[1][0], 0.0, Size);
		TextDrawUseBox(gFinalTeamText[1][0], 1);

		gFinalTeamText[2][0] = TextDrawCreate(X_Start[0]-115, Y_Start+6,"~w~90NINE~b~Incognito~w~DrVibrator~b~Lop_Dog~w~Man_Hunt~b~Nyo~w~Eminich~b~ExPloiTeD~w~Predator~b~Sam~w~WWE~b~Pacwarz~w~Seb~b~Sneaky~w~Eazy");//List of Players on Team
		TextDrawFont(gFinalTeamText[2][0], 1);
		TextDrawLetterSize(gFinalTeamText[2][0], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[2][0], 1);
		TextDrawTextSize(gFinalTeamText[2][0], 0.0, Size);

		gFinalTeamText[3][0] = TextDrawCreate(X_Start[0], Y_Start+149,"Total__________________________________________");//Team Header
		TextDrawAlignment(gFinalTeamText[3][0], 2);
		TextDrawBoxColor(gFinalTeamText[3][0], 0x000000FF);
		TextDrawFont(gFinalTeamText[3][0], 3);
		TextDrawLetterSize(gFinalTeamText[3][0], 0.3, 1.1);//0.6,1.4
		TextDrawSetOutline(gFinalTeamText[3][0], 1);
		TextDrawTextSize(gFinalTeamText[3][0], 0.0, Size);
		TextDrawUseBox(gFinalTeamText[3][0], 1);

		gFinalTeamText[4][0] = TextDrawCreate(X_Start[0]-12, Y_Start+6,"~w~1~b~2~w~3~b~4~w~5~b~6~w~7~b~8~w~9~b~10~w~11~b~12~w~13~b~14~w~15");//list of player kills
		TextDrawFont(gFinalTeamText[4][0], 1);
		TextDrawLetterSize(gFinalTeamText[4][0], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[4][0], 1);
		TextDrawTextSize(gFinalTeamText[4][0], 0.0, Size);

		gFinalTeamText[5][0] = TextDrawCreate(X_Start[0]+41, Y_Start+6,"~w~5~b~2~w~6~b~1~w~7~b~2~w~1~b~9~w~1~b~2~w~3~b~5~w~2~b~7~w~5");//list of player deaths
		TextDrawFont(gFinalTeamText[5][0], 1);
		TextDrawLetterSize(gFinalTeamText[5][0], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[5][0], 1);
		TextDrawTextSize(gFinalTeamText[5][0], 0.0, Size);

		gFinalTeamText[6][0] = TextDrawCreate(X_Start[0]+90, Y_Start+6,"~w~1.00~b~1.00~w~1.00~b~1.00~w~1.00~b~1.00~w~1.00~b~1.00~w~1.00~b~1.00~w~1.00~b~1.00~w~1.00~b~1.00~w~1.00");//list of player ratios
		TextDrawFont(gFinalTeamText[6][0], 1);
		TextDrawLetterSize(gFinalTeamText[6][0], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[6][0], 1);
		TextDrawTextSize(gFinalTeamText[6][0], 0.0, Size);

		gFinalTeamText[7][0] = TextDrawCreate(X_Start[0]-12, Y_Start+149,"89");//Total Kills (BOTTOM)
		TextDrawFont(gFinalTeamText[7][0], 3);
		TextDrawLetterSize(gFinalTeamText[7][0], 0.3, 1.1);
		TextDrawSetOutline(gFinalTeamText[7][0], 1);
		TextDrawTextSize(gFinalTeamText[7][0], 0.0, Size);

		gFinalTeamText[8][0] = TextDrawCreate(X_Start[0]+41, Y_Start+149,"89");//Total Team Deaths (BOTTOM)
		TextDrawFont(gFinalTeamText[8][0], 3);
		TextDrawLetterSize(gFinalTeamText[8][0], 0.3, 1.1);
		TextDrawSetOutline(gFinalTeamText[8][0], 1);
		TextDrawTextSize(gFinalTeamText[8][0], 0.0, Size);

		gFinalTeamText[9][0] = TextDrawCreate(X_Start[0]+90, Y_Start+149,"4.00");//Total Team Ratio (BOTTOM)
		TextDrawFont(gFinalTeamText[9][0], 3);
		TextDrawLetterSize(gFinalTeamText[9][0], 0.3, 1.1);
		TextDrawSetOutline(gFinalTeamText[9][0], 1);
		TextDrawTextSize(gFinalTeamText[9][0], 0.0, Size);

		TextDrawColor(gFinalTeamText[1][0],TeamActiveColors[T_HOME] | 255);
		TextDrawColor(gFinalTeamText[3][0],TeamActiveColors[T_HOME] | 255);
		TextDrawBoxColor(gFinalTeamText[0][0],TeamActiveColors[T_HOME] | 60);

//------------------------------------------------------------------------------
//TEAM AWAY (1)

		gFinalTeamText[0][1] = TextDrawCreate(X_Start[1], Y_Start,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");//Team  Background
		TextDrawAlignment(gFinalTeamText[0][1], 2);
		TextDrawTextSize(gFinalTeamText[0][1], 0.0, Size);
		TextDrawUseBox(gFinalTeamText[0][1], 1);

		gFinalTeamText[1][1] = TextDrawCreate(X_Start[1], Y_Start-11,"Name              ~w~Kills     Deaths     Ratio");//Team Header
		TextDrawAlignment(gFinalTeamText[1][1], 2);
		TextDrawBoxColor(gFinalTeamText[1][1], 0x000000FF);
		TextDrawFont(gFinalTeamText[1][1], 3);
		TextDrawLetterSize(gFinalTeamText[1][1], 0.3, 1.1);//0.6,1.4
		TextDrawSetOutline(gFinalTeamText[1][1], 1);
		TextDrawTextSize(gFinalTeamText[1][1], 0.0, Size);
		TextDrawUseBox(gFinalTeamText[1][1], 1);

		gFinalTeamText[2][1] = TextDrawCreate(X_Start[1]-115, Y_Start+6,"~w~90NINE~r~Incognito~w~DrVibrator~r~Lop_Dog~w~Man_Hunt~r~Nyo~w~Eminich~r~ExPloiTeD~w~Predator~r~Sam~w~WWE~r~Pacwarz~w~Seb~r~Sneaky~w~Eazy");//List of Players on Team
		TextDrawFont(gFinalTeamText[2][1], 1);
		TextDrawLetterSize(gFinalTeamText[2][1], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[2][1], 1);
		TextDrawTextSize(gFinalTeamText[2][1], 0.0, Size);

		gFinalTeamText[3][1] = TextDrawCreate(X_Start[1], Y_Start+149,"Total__________________________________________");//Team Header
		TextDrawAlignment(gFinalTeamText[3][1], 2);
		TextDrawBoxColor(gFinalTeamText[3][1], 0x000000FF);
		TextDrawFont(gFinalTeamText[3][1], 3);
		TextDrawLetterSize(gFinalTeamText[3][1], 0.3, 1.1);//0.6,1.4
		TextDrawSetOutline(gFinalTeamText[3][1], 1);
		TextDrawTextSize(gFinalTeamText[3][1], 0.0, Size);
		TextDrawUseBox(gFinalTeamText[3][1], 1);

		gFinalTeamText[4][1] = TextDrawCreate(X_Start[1]-12, Y_Start+6,"~w~1~r~2~w~3~r~4~w~5~r~6~w~7~r~8~w~9~r~10~w~11~r~12~w~13~r~14~w~15");//list of player kills
		TextDrawFont(gFinalTeamText[4][1], 1);
		TextDrawLetterSize(gFinalTeamText[4][1], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[4][1], 1);
		TextDrawTextSize(gFinalTeamText[4][1], 0.0, Size);

		gFinalTeamText[5][1] = TextDrawCreate(X_Start[1]+41, Y_Start+6,"~w~5~r~2~w~6~r~1~w~7~r~2~w~1~r~9~w~1~r~2~w~3~r~5~w~2~r~7~w~5");//list of player deaths
		TextDrawFont(gFinalTeamText[5][1], 1);
		TextDrawLetterSize(gFinalTeamText[5][1], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[5][1], 1);
		TextDrawTextSize(gFinalTeamText[5][1], 0.0, Size);

		gFinalTeamText[6][1] = TextDrawCreate(X_Start[1]+90, Y_Start+6,"~w~1.00~r~1.00~w~1.00~r~1.00~w~1.00~r~1.00~w~1.00~r~1.00~w~1.00~r~1.00~w~1.00~r~1.00~w~1.00~r~1.00~w~1.00");//list of player ratios
		TextDrawFont(gFinalTeamText[6][1], 1);
		TextDrawLetterSize(gFinalTeamText[6][1], 0.3, 1.0);
		TextDrawSetOutline(gFinalTeamText[6][1], 1);
		TextDrawTextSize(gFinalTeamText[6][1], 0.0, Size);

		gFinalTeamText[7][1] = TextDrawCreate(X_Start[1]-12, Y_Start+149,"45");//Total Kills (BOTTOM)
		TextDrawFont(gFinalTeamText[7][1], 3);
		TextDrawLetterSize(gFinalTeamText[7][1], 0.3, 1.1);
		TextDrawSetOutline(gFinalTeamText[7][1], 1);
		TextDrawTextSize(gFinalTeamText[7][1], 0.0, Size);

		gFinalTeamText[8][1] = TextDrawCreate(X_Start[1]+41, Y_Start+149,"89");//Total Team Deaths (BOTTOM)
		TextDrawFont(gFinalTeamText[8][1], 3);
		TextDrawLetterSize(gFinalTeamText[8][1], 0.3, 1.1);
		TextDrawSetOutline(gFinalTeamText[8][1], 1);
		TextDrawTextSize(gFinalTeamText[8][1], 0.0, Size);

		gFinalTeamText[9][1] = TextDrawCreate(X_Start[1]+90, Y_Start+149,"2.47");//Total Team Ratio (BOTTOM)
		TextDrawFont(gFinalTeamText[9][1], 3);
		TextDrawLetterSize(gFinalTeamText[9][1], 0.3, 1.1);
		TextDrawSetOutline(gFinalTeamText[9][1], 1);
		TextDrawTextSize(gFinalTeamText[9][1], 0.0, Size);

		TextDrawColor(gFinalTeamText[1][1],TeamActiveColors[T_AWAY] | 255);
		TextDrawColor(gFinalTeamText[3][1],TeamActiveColors[T_AWAY] | 255);
		TextDrawBoxColor(gFinalTeamText[0][1],TeamActiveColors[T_AWAY] | 60);

//------------------------------------------------------------------------------
//ROUND SCOREBOARD
//640x480
		new Float:Y2_Start = 80.0;
		new Float:X2_Start = 320.0;
		new Size2 = 325;

		gFinalScoreBoardRounds[0] = TextDrawCreate(X2_Start, Y2_Start+160,"[NB] Wins ~w~- ~g~10:2");//Winning Header (BOTTOM)
		TextDrawAlignment(gFinalScoreBoardRounds[0], 2);
		TextDrawBoxColor(gFinalScoreBoardRounds[0], 0x000000FF);
		TextDrawFont(gFinalScoreBoardRounds[0], 3);
		TextDrawLetterSize(gFinalScoreBoardRounds[0], 0.3, 1.1);//0.6,1.4
		TextDrawSetOutline(gFinalScoreBoardRounds[0], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[0], 0.0, Size2);
		TextDrawUseBox(gFinalScoreBoardRounds[0], 1);
		TextDrawColor(gFinalScoreBoardRounds[0],0x3C3C3CFF);

		gFinalScoreBoardRounds[1] = TextDrawCreate(X2_Start, Y2_Start,"~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");//background
		TextDrawAlignment(gFinalScoreBoardRounds[1], 2);
		TextDrawTextSize(gFinalScoreBoardRounds[1], 0.0, Size2);
		TextDrawUseBox(gFinalScoreBoardRounds[1], 1);
		TextDrawBoxColor(gFinalScoreBoardRounds[1],0x00000060);

		gFinalScoreBoardRounds[2] = TextDrawCreate(X2_Start, Y2_Start,"Location                ID      Type     Winner     Status");//Header (TOP)
		TextDrawAlignment(gFinalScoreBoardRounds[2], 2);
		TextDrawBoxColor(gFinalScoreBoardRounds[2], 0x000000FF);
		TextDrawFont(gFinalScoreBoardRounds[2], 3);
		TextDrawLetterSize(gFinalScoreBoardRounds[2], 0.3, 1.1);//0.6,1.4
		TextDrawSetOutline(gFinalScoreBoardRounds[2], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[2], 0.0, Size2);
		TextDrawUseBox(gFinalScoreBoardRounds[2], 1);
		TextDrawColor(gFinalScoreBoardRounds[2],0x46FF46FF);

		gFinalScoreBoardRounds[3] = TextDrawCreate(X2_Start-155, Y2_Start+15,"~w~Grey_Imports~y~Area51_Back~w~Area51_Middle~y~Crack_Factory~w~Cargo_Ship~y~Starfish_CarPark~w~SF_Police_Garage~y~Golf_Course~w~10_Story_Garage~y~Danang_Boat~w~Aircraft_Carrier~y~BaySide");//List of Players on Team
		TextDrawFont(gFinalScoreBoardRounds[3], 1);
		TextDrawLetterSize(gFinalScoreBoardRounds[3], 0.3, 1.0);
		TextDrawSetOutline(gFinalScoreBoardRounds[3], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[3], 0.0, Size2);

		gFinalScoreBoardRounds[4] = TextDrawCreate(X2_Start-30, Y2_Start+15,"~w~1~y~24~w~0~y~3~w~5~y~10~w~7~y~2~w~26~y~17~w~6~y~1");//list round ID's
		TextDrawFont(gFinalScoreBoardRounds[4], 1);
		TextDrawLetterSize(gFinalScoreBoardRounds[4], 0.3, 1.0);
		TextDrawSetOutline(gFinalScoreBoardRounds[4], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[4], 0.0, Size2);

		gFinalScoreBoardRounds[5] = TextDrawCreate(X2_Start+10, Y2_Start+15,"~w~Base~y~Base~w~Base~y~Base~w~Base~y~Base~w~Base~y~Base~w~Base~y~Base~w~Base~y~Arena");//list of round Type
		TextDrawFont(gFinalScoreBoardRounds[5], 1);
		TextDrawLetterSize(gFinalScoreBoardRounds[5], 0.3, 1.0);
		TextDrawSetOutline(gFinalScoreBoardRounds[5], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[5], 0.0, Size2);

		gFinalScoreBoardRounds[6] = TextDrawCreate(X2_Start+60, Y2_Start+15,"~w~[NB]~y~[NB]~w~[NB]~y~[BLOW]~w~[NB]~y~[NB]~w~[NB]~y~[BLOW]~w~[NB]~y~[NB]~w~[NB]~y~[NB]");//list of winning teams (TEAM NAMES)
		TextDrawFont(gFinalScoreBoardRounds[6], 1);
		TextDrawLetterSize(gFinalScoreBoardRounds[6], 0.3, 1.0);
		TextDrawSetOutline(gFinalScoreBoardRounds[6], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[6], 0.0, Size2);

		gFinalScoreBoardRounds[7] = TextDrawCreate(X2_Start+125, Y2_Start+15,"~w~Att~y~Def~w~Att~y~Def~w~Att~y~Def~w~Att~y~Def~w~Att~y~Def~w~Att~y~_-");//list of team statuses (ATT/DEF)
		TextDrawFont(gFinalScoreBoardRounds[7], 1);
		TextDrawLetterSize(gFinalScoreBoardRounds[7], 0.3, 1.0);
		TextDrawSetOutline(gFinalScoreBoardRounds[7], 1);
		TextDrawTextSize(gFinalScoreBoardRounds[7], 0.0, Size2);

//------------------------------------------------------------------------------
		return 1;
}

UpdateFinalRoundInfoStrings()
{
    //FunctionLog("UpdateFinalRoundInfoStrings");
	if(Current == -1)return 1;
	if(RoundsPlayed < 15)
	{
		if(ModeType == BASE)
		{
			format(FinalData[F_Type],256,"%s%sBase",FinalData[F_Type],L_Colors[RoundsPlayed]);
			if(TeamStatus[Winner] == ATTACKING)format(FinalData[F_Status],256,"%s%sAtt",FinalData[F_Status],L_Colors[RoundsPlayed]);
        	else format(FinalData[F_Status],256,"%s%sDef",FinalData[F_Status],L_Colors[RoundsPlayed]);
		}
		else if(ModeType == ARENA)
		{
			format(FinalData[F_Type],256,"%s%sArena",FinalData[F_Type],L_Colors[RoundsPlayed]);
			format(FinalData[F_Status],256,"%s%s_-",FinalData[F_Status],L_Colors[RoundsPlayed]);
		}
		else
		{
			format(FinalData[F_Type],256,"%s%sTDM",FinalData[F_Type],L_Colors[RoundsPlayed]);
			format(FinalData[F_Status],256,"%s%s_-",FinalData[F_Status],L_Colors[RoundsPlayed]);
		}
		format(FinalData[F_ID],256,"%s%s%d",FinalData[F_ID],L_Colors[RoundsPlayed],Current);
        format(FinalData[F_Winner],256,"%s%s%s",FinalData[F_Winner],L_Colors[RoundsPlayed],TeamName[Winner]);
        
        new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
        if(strlen(LocationName[Current][MODE]) > 2)
		{
			new str[STR]; str = charrep(LocationName[Current][MODE],' ', '_');
			format(FinalData[F_Name],256,"%s%s%s",FinalData[F_Name],L_Colors[RoundsPlayed],str);
		}
		else format(FinalData[F_Name],256,"%s%sN/A",FinalData[F_Name],L_Colors[RoundsPlayed]);
	}
	return 1;
}

FormatFinalScoreboard()
{
    //FunctionLog("FormatFinalScoreboard");
	new string[256],string2[128],string3[128],string4[256],strings[16],x;
	
	if(TeamRoundsWon[T_HOME] > TeamRoundsWon[T_AWAY])format(string,sizeof(string),"%s Wins ~w~%d:%d",TeamName[T_HOME],TeamRoundsWon[T_HOME],TeamRoundsWon[T_AWAY]);
	else if(TeamRoundsWon[T_HOME] < TeamRoundsWon[T_AWAY])format(string,sizeof(string),"%s Wins ~w~%d:%d",TeamName[T_AWAY],TeamRoundsWon[T_AWAY],TeamRoundsWon[T_HOME]);
	else format(string,sizeof(string),"Draw ~w~%d:%d",TeamRoundsWon[T_AWAY],TeamRoundsWon[T_HOME]);
	
	if(RoundsPlayed > 0)
	{
		TextDrawSetString(gFinalScoreBoardRounds[0],string);
		TextDrawSetString(gFinalScoreBoardRounds[3],FinalData[F_Name]);
		TextDrawSetString(gFinalScoreBoardRounds[4],FinalData[F_ID]);
		TextDrawSetString(gFinalScoreBoardRounds[5],FinalData[F_Type]);
		TextDrawSetString(gFinalScoreBoardRounds[6],FinalData[F_Winner]);
		TextDrawSetString(gFinalScoreBoardRounds[7],FinalData[F_Status]);
	}
	else
	{
	    TextDrawSetString(gFinalScoreBoardRounds[0],string);
		TextDrawSetString(gFinalScoreBoardRounds[3],"_");
		TextDrawSetString(gFinalScoreBoardRounds[4],"_");
		TextDrawSetString(gFinalScoreBoardRounds[5],"_");
		TextDrawSetString(gFinalScoreBoardRounds[6],"_");
		TextDrawSetString(gFinalScoreBoardRounds[7],"_");
	}
	
	new bool:Excluded[MAX_SERVER_PLAYERS], highest_kills = -1, amt, Float:ratio, Float:killz, Float:deathz;
	for(new teamid; teamid < 2; teamid++)
	{
	    string = "";
	    string2 = "";
	    string3 = "";
	    string4 = "";
	    highest_kills = -1;
	    amt = 0;
 		for(new i; i <= HighestID; i++)
		{
	    	if(IsPlayerConnected(i) && Excluded[i] == false && gTeam[i] == teamid && TempKills[i] > highest_kills)
	    	{
        	 	for(x = 0; x <= HighestID; x++)
				{
				    if(Excluded[x] == false && gTeam[x] == teamid && TempKills[x] > TempKills[i] && CurrentPlayers[teamid] > amt)
				    {
				        i = x;
				    }
				}
				Excluded[i] = true;
				highest_kills = -1;
				format(string,sizeof(string),"%s%s%s",string,T_Colors[teamid][amt],ListName[i]); // player list
				format(string2,sizeof(string2),"%s%s%d",string2,T_Colors[teamid][amt],TempKills[i]); // player kills
				format(string3,sizeof(string3),"%s%s%d",string3,T_Colors[teamid][amt],TempDeaths[i]); // player deaths
				killz = TempKills[i];deathz = TempDeaths[i];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
				format(string4,sizeof(string4),"%s%s%.2f",string4,T_Colors[teamid][amt],ratio); // player ratio
				i = 0;
				amt++;
				if(amt > CurrentPlayers[teamid] || amt > 15)break;
	    	}
		}
		if(!amt)
	 	{
	    	string = " ";
	    	string2 = " ";
	    	string3 = " ";
    		string4 = " ";
	  	}
		TextDrawSetString(gFinalTeamText[2][teamid],string); // player list
  		TextDrawSetString(gFinalTeamText[4][teamid],string2); // player kills
		TextDrawSetString(gFinalTeamText[5][teamid],string3); // player deaths
		TextDrawSetString(gFinalTeamText[6][teamid],string4); // player ratios
		
		format(strings,sizeof(strings),"%d",TeamTotalScore[teamid]);
		TextDrawSetString(gFinalTeamText[7][teamid],strings); // team: total kills
		
	    format(strings,sizeof(strings),"%d",TeamTotalDeaths[teamid]);
	    TextDrawSetString(gFinalTeamText[8][teamid],strings); // team: total deaths
	    
	    killz = TeamTotalScore[teamid];deathz = TeamTotalDeaths[teamid];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
	    format(strings,sizeof(strings),"%.2f",ratio);
		TextDrawSetString(gFinalTeamText[9][teamid],strings); // team: total ratio
	}
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

ShowRoundResults(mode)
{
    //FunctionLog("ShowRoundResults");
	new highscorer,string[128],string2[64],Float:ratio[ACTIVE_TEAMS],Float:killz[ACTIVE_TEAMS],Float:deathz[ACTIVE_TEAMS];
	if(mode == BASE || (TeamsBeingUsed == 2 && ModeType != TDM))
    {
		killz[T_HOME] = TeamTotalScore[T_HOME];deathz[T_HOME] = TeamTotalDeaths[T_HOME];ratio[T_HOME] = killz[T_HOME]/deathz[T_HOME];if(deathz[T_HOME] == 0)ratio[T_HOME] = killz[T_HOME];
		killz[T_AWAY] = TeamTotalScore[T_AWAY];deathz[T_AWAY] = TeamTotalDeaths[T_AWAY];ratio[T_AWAY] = killz[T_AWAY]/deathz[T_AWAY];if(deathz[T_AWAY] == 0)ratio[T_AWAY] = killz[T_AWAY];
		format(string,sizeof(string),"***   BattleGrounds  ||  Rounds Played:  %d/%d  ***",RoundsPlayed,RoundLimit);SendClientMessageToAll(0xFFFFFFFF,string);
		format(string,sizeof(string),"***   \"%s\" -- Wins: %d  /  Kills: %d  /  Deaths: %d  /  Ratio: %.2f  ***",TeamName[T_HOME],TeamRoundsWon[T_HOME],TeamTotalScore[T_HOME],TeamTotalDeaths[T_HOME],ratio[T_HOME]);SendClientMessageToAll(TeamActiveColors[T_HOME],string);
		format(string,sizeof(string),"***   \"%s\" -- Wins: %d  /  Kills: %d  /  Deaths: %d  /  Ratio: %.2f  ***",TeamName[T_AWAY],TeamRoundsWon[T_AWAY],TeamTotalScore[T_AWAY],TeamTotalDeaths[T_AWAY],ratio[T_AWAY]);SendClientMessageToAll(TeamActiveColors[T_AWAY],string);
		
		if(Winner == T_NON)format(string,sizeof(string), "~w~No Winner!");
		else if(TeamStatus[Winner] == ATTACKING)format(string,sizeof(string), "~w~Attackers Win!");
		else format(string,sizeof(string), "~w~Defenders Win!");

		format(FinalStr2[0], 32, "%s",TeamName[T_HOME]);
		format(FinalStr3[0], 256, "~w~%s",Team_ListPlayersByTempKills(T_HOME,CurrentPlayers[T_HOME]));
		format(FinalStr4[0], 32, "Wins: %d~n~Kills: %d",TeamRoundsWon[T_HOME],TeamTempScore[T_HOME]);
		format(FinalStr2[5], 32, "%s",TeamName[T_AWAY]);
		format(FinalStr3[5], 256, "~w~%s",Team_ListPlayersByTempKills(T_AWAY,CurrentPlayers[T_AWAY]));
		format(FinalStr4[5], 32, "Wins: %d~n~Kills: %d",TeamRoundsWon[T_AWAY],TeamTempScore[T_AWAY]);
		TextDrawSetString(gFinalText2[0],FinalStr2[0]);
		TextDrawSetString(gFinalText3[0],FinalStr3[0]);
		TextDrawSetString(gFinalText4[0],FinalStr4[0]);
		TextDrawSetString(gFinalText2[5],FinalStr2[5]);
		TextDrawSetString(gFinalText3[5],FinalStr3[5]);
		TextDrawSetString(gFinalText4[5],FinalStr4[5]);
		TextDrawColor(gFinalText2[0],TeamActiveColors[T_HOME] | 0x000000FF);
		TextDrawColor(gFinalText4[0],TeamActiveColors[T_HOME] | 0x000000FF);
		TextDrawBoxColor(gFinalText1[0], TeamActiveColors[T_HOME] | 0x00000060);
		TextDrawColor(gFinalText2[5],TeamActiveColors[T_AWAY] | 0x000000FF);
		TextDrawColor(gFinalText4[5],TeamActiveColors[T_AWAY] | 0x000000FF);
		TextDrawBoxColor(gFinalText1[5], TeamActiveColors[T_AWAY] | 0x00000060);
		if(RoundsPlayed < RoundLimit)
		{
			SetTimer("HideScoreBoardText",8000,0);
		}
 	}
	else
	{
		format(string,sizeof(string),"***   BattleGrounds  ||  Rounds Played:  %d/%d  ***",RoundsPlayed,RoundLimit);SendClientMessageToAll(MainColors[0],string);
	    for(new i = 0; i < ACTIVE_TEAMS; i++)
		{
	    	if(TeamUsed[i] == true)
	    	{
	    	    killz[i] = TeamTotalScore[i];deathz[i] = TeamTotalDeaths[i];ratio[i] = killz[i]/deathz[i];if(deathz[i] == 0)ratio[i] = killz[i];
				format(string,sizeof(string),"***   \"%s\" -- Wins: %d  /  Kills: %d  /  Deaths: %d  /  Ratio: %.2f  ***",TeamName[i],TeamRoundsWon[i],TeamTotalScore[i],TeamTotalDeaths[i],ratio[i]);
				SendClientMessageToAll(TeamActiveColors[i],string);
			}
		}
		if(Winner == T_NON)format(string,sizeof(string), "~w~No Winner!");
		else format(string,sizeof(string), "~w~%s Wins!",TeamName[Winner]);
		//TextDrawColor(TopShotta[3],TeamActiveColors[Winner]);
	}

	highscorer = GetPlayerWithHighestScore();

	if(highscorer != -1 && TR_Kills[highscorer] > 0){format(string2,sizeof(string2),"~n~~r~Top Shotta~n~~n~~w~%s - %d kill(s)",NickName[highscorer],TR_Kills[highscorer]);}
	else{format(string2,sizeof(string2),"~n~~r~Top Shotta~n~~n~~w~N~r~/~w~A");}

	TextDrawSetString(TopShotta[3],string);
	TextDrawSetString(TopShotta[4],string2);
	TextDrawBoxColor(TopShotta[0],TeamGZColors[Winner]);

	foreach(Player,i)
	{
		if(gSelectingClass[i] == false && IsDueling[i] == false && AFK[i] == false && DuelSpectating[i] == -1)
		{
			TextDrawShowForPlayer(i,TopShotta[0]);
  			TextDrawShowForPlayer(i,TopShotta[1]);
  			TextDrawShowForPlayer(i,TopShotta[2]);
  			TextDrawShowForPlayer(i,TopShotta[3]);
  			TextDrawShowForPlayer(i,TopShotta[4]);
  			if(ModeType == BASE || (TeamsBeingUsed == 2 && ModeType != TDM))
  			{
  				TextDrawShowForPlayer(i,gFinalText1[0]);
				TextDrawShowForPlayer(i,gFinalText2[0]);
				TextDrawShowForPlayer(i,gFinalText3[0]);
				TextDrawShowForPlayer(i,gFinalText4[0]);
				TextDrawShowForPlayer(i,gFinalText1[5]);
 				TextDrawShowForPlayer(i,gFinalText2[5]);
 				TextDrawShowForPlayer(i,gFinalText3[5]);
 				TextDrawShowForPlayer(i,gFinalText4[5]);
			}
		}
	}
	return 1;
}

DestroyAllTextDraws()
{
    //FunctionLog("DestroyAllTextDraws");
    TextDrawDestroy(gFinalText);
    for(new i = 0; i < ARENA_TEXT; i++){TextDrawDestroy(ArenaTxt[i]);}
    for(new i = 0; i < WEAPON_TEXT; i++){TextDrawDestroy(WeaponText[i][BASE]);TextDrawDestroy(WeaponText[i][ARENA]);}
    for(new i = 0; i < ACTIVE_TEAMS; i++){TextDrawDestroy(gFinalText4[i]);TextDrawDestroy(gFinalText3[i]);TextDrawDestroy(gFinalText2[i]);TextDrawDestroy(gFinalText1[i]);}
    for(new i = 0; i < MAIN_TEXT; i++){TextDrawDestroy(MainText[i]);}
    for(new i = 0; i < TOP_SHOTTA; i++){TextDrawDestroy(TopShotta[i]);}
    for(new i = 0; i < PTEXT; i++)
    {
        for(new x = 0; x < MAX_SERVER_PLAYERS; x++)
    	{
    	    TextDrawDestroy(pText[i][x]);
    	}
    }
    for(new i; i < MAX_SERVER_PLAYERS; i++)
    {
		TextDrawDestroy(MOTD[0][i]);
    }
    /*for(new i = 0; i < MOTD_TEXT; i++)
    {
        for(new x; x < MAX_SERVER_PLAYERS; x++)
    	{
    	    TextDrawDestroy(MOTD[0][x]);
    	}
    }*/
	return 1;
}

HideRoundText(playerid)
{
    //FunctionLog("HideRoundText");
    for(new i = 0; i < ARENA_TEXT; i++){TextDrawHideForPlayer(playerid,ArenaTxt[i]);}
	TD_HideMainTextForPlayer(playerid,9);
	TD_HideMainTextForPlayer(playerid,10);
	TD_HideMainTextForPlayer(playerid,11);
	TD_HideMainTextForPlayer(playerid,12);
}

forward HideScoreBoardText();
public HideScoreBoardText()
{
    //FunctionLog("HideScoreBoardText");
    SlideSho = false;
    foreach(Player,i)
	{
		if(gSelectingClass[i] == false)
		{
	    	PlayerPlaySound(i,1188,0.0,0.0,0.0);
	    	TD_HidepTextForPlayer(i,i,1);
	    	TD_HidepTextForPlayer(i,i,4);
	    	TD_HidepTextForPlayer(i,i,13);
			TD_HideMainTextForPlayer(i,1);
			TD_HideMainTextForPlayer(i,2);
			TextDrawHideForPlayer(i,gFinalText);
			TD_HidePanoForPlayer(i);
			for(new x = 0; x < ACTIVE_TEAMS; x++)
			{
				TextDrawHideForPlayer(i,gFinalText4[x]);
				TextDrawHideForPlayer(i,gFinalText3[x]);
				TextDrawHideForPlayer(i,gFinalText2[x]);
				TextDrawHideForPlayer(i,gFinalText1[x]);
			}
		}
	}
	return 1;
}

forward HideScoreBoardText2();
public HideScoreBoardText2()
{
    //FunctionLog("HideScoreBoardText2");
    SlideSho = false;
    foreach(Player,i)
	{
	    if(ViewingResults[i] == true)
	    {
	    	PlayerPlaySound(i,1188,0.0,0.0,0.0);
			TD_HidepTextForPlayer(i,i,1);
			TD_HidepTextForPlayer(i,i,4);
			TD_HidepTextForPlayer(i,i,13);
			TD_HideMainTextForPlayer(i,1);
			TD_HideMainTextForPlayer(i,2);
			TextDrawHideForPlayer(i,gFinalText);
			TD_HidePanoForPlayer(i);
			TD_Hide2TeamScoreBoard(i);
		}
	}
	return 1;
}

forward ShowFinalScores(time);
public ShowFinalScores(time)
{
    //FunctionLog("ShowFinalScores");
    new count, i;
    ResetTextDrawColors();
    HideSTextForAll();
    HideScoreBoardText();
    ClearDeathMessages();
    SlideSho = true;
    
    new amt;
	for(i = 0; i < ACTIVE_TEAMS; i++)
	{
		if(TeamUsed[i] == true)
		{
			amt += CurrentPlayers[i];
		}
	}
	if(TeamsBeingUsed == 2)
	{
	    FormatFinalScoreboard();
	}
	else
	{
        for(i = 0; i < ACTIVE_TEAMS; i++)
		{
			if(TeamUsed[i] == true)
			{
				format(FinalStr2[i], 32, "%s",TeamName[i]);
				format(FinalStr3[i], 256, "~w~%s",Team_ListPlayersByTotalKills(i,CurrentPlayers[i]));
				format(FinalStr4[i], 32, "Wins: %d~n~Kills: %d",TeamRoundsWon[i],TeamTotalScore[i]);
				TextDrawSetString(gFinalText2[i],FinalStr2[i]);
				TextDrawSetString(gFinalText3[i],FinalStr3[i]);
				TextDrawSetString(gFinalText4[i],FinalStr4[i]);
			}
		}
	}
	
	new Float:newXY[2];
	new Float:spin_amt = (360.0 / float(amt));
	new Float:spacing = (float(amt) * 0.10) + 1;
	new Float:spin;
	
	FinalR_Loc = random(sizeof(FinalResultLocs));
   	TmpCP[0] = FinalResultLocs[FinalR_Loc][0];
   	TmpCP[1] = FinalResultLocs[FinalR_Loc][1];
   	TmpCP[2] = FinalResultLocs[FinalR_Loc][2];

	foreach(Player,z)
	{
 		if(AFK[z] == false && gSelectingClass[z] == false && gTeam[z] < ACTIVE_TEAMS)
		{
		    SetPlayerSpecialAction(z,SPECIAL_ACTION_DANCE3);
    		count++;
    		ResetPlayerHealth(z);
	    	ViewingResults[z] = true;
			ResetPlayerWeapons(z);
		    SetPlayerInterior(z,floatround(FinalResultLocs[FinalR_Loc][3]));
		    TogglePlayerControllable(z,0);
		    PlayerPlaySound(z,1187,0.0,0.0,0.0);

            spin -= spin_amt;
			newXY[0] = TmpCP[0];
			newXY[1] = TmpCP[1];
			newXY[0] += (spacing * floatsin(spin, degrees));
			newXY[1] += (spacing * floatcos(spin, degrees));
			SetPlayerPos(z,newXY[0],newXY[1],TmpCP[2]);
			SetPlayerFacingAngle(z,360 - spin);
			if(TeamsBeingUsed == 2)
			{
			    TD_Show2TeamScoreBoard(z);
			    for(new j; j < 10; j++)
			    {
			        SendClientMessage(z,0xFFFFFFFF," ");
			    }
			}
			else
			{
		    	for(i = 0; i < ACTIVE_TEAMS; i++)
		    	{
		    	 	if(TeamUsed[i] == true)
					{
	    				TextDrawShowForPlayer(z,gFinalText);
            	        TextDrawShowForPlayer(z,gFinalText1[i]);
        				TextDrawShowForPlayer(z,gFinalText2[i]);
        				TextDrawShowForPlayer(z,gFinalText3[i]);
        				TextDrawShowForPlayer(z,gFinalText4[i]);
					}
				}
				TD_ShowPanoForPlayer(z);
			}
   			TD_HidepTextForPlayer(z,z,4);
			TextDrawBoxColor(pText[4][z],0x00000000);
		}
	}
	RotateFinalView();
	if(TeamsBeingUsed == 2)SetTimer("HideScoreBoardText2",time*1000,0);
	else SetTimer("HideScoreBoardText",time*1000,0);
	RoundsPlayed = 0;
}

forward RotateFinalView();
public RotateFinalView()
{
    /*FunctionLogEx("RotateFinalView");*/
	if(SlideSho == false)
 	{
	    foreach(Player,i)
		{
 			if(ViewingResults[i] == true)
			{
			    ViewingResults[i] = false;
			    TD_HidePanoForPlayer(i);
			    TD_HidepTextForPlayer(i,i,1);
			    TD_HidepTextForPlayer(i,i,13);
			    SpawnAtPlayerPosition[i] = 0;
			    FindPlayerSpawn(i,1);
				SpawnPlayer(i);
			}
		}
	    times = 0.0;
		return 1;
	}
	
	new Float:xLoc[2];
	xLoc[0] = TmpCP[0];
	xLoc[1] = TmpCP[1];
	xLoc[0] += (10.0 * floatsin(times, degrees));
	xLoc[1] += (10.0 * floatcos(times, degrees));
	foreach(Player,i)
	{
		if(ViewingResults[i] == true)
		{
			SetPlayerCameraPos(i,xLoc[0],xLoc[1],FinalResultLocs[FinalR_Loc][2]+2.5);
         	SetPlayerCameraLookAt(i,FinalResultLocs[FinalR_Loc][0],FinalResultLocs[FinalR_Loc][1],FinalResultLocs[FinalR_Loc][2]+1);
		}
	}
	if(times >= 360.0)times = 0.0;
	else times++;
	SetTimer("RotateFinalView",49,0);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Team related

Team_ResetTempScores()
{
    //FunctionLog("Team_ResetTempScores");
    for(new i = 0; i < ACTIVE_TEAMS; i++)
	{
    	TeamTempScore[i] = 0;
    	TeamTempDeaths[i] = 0;
	}
}

Team_ResetScores()
{
    //FunctionLog("Team_ResetScores");
    RoundsPlayed = 0;
    for(new i = 0; i < ACTIVE_TEAMS; i++)
	{
	    TeamTotalDeaths[i] = 0;
		TeamTempScore[i] = 0;
		TeamTotalScore[i] = 0;
		TeamRoundsWon[i] = 0;
	}
}

Team_ListPlayersByTotalKills(teamid,listsize)
{
	//FunctionLog("Team_ListPlayersByTotalKills");
	new string[256] =  " ",bool:Excluded[MAX_SERVER_PLAYERS], highest_kills = -1, x, amt;
 	for(new i; i <= HighestID; i++)
	{
	    if(IsPlayerConnected(i) && Excluded[i] == false && gTeam[i] == teamid && TempKills[i] > highest_kills)
	    {
         	for(x = 0; x <= HighestID; x++)
			{
			    if(Excluded[x] == false && gTeam[x] == teamid && TempKills[x] > TempKills[i])
			    {
			        i = x;
			    }
			}
			Excluded[i] = true;
			highest_kills = -1;
			format(string,sizeof(string),"%s%s: %d~n~",string,ListName[i],TempKills[i]);
			i = 0;
			amt++;
			if(amt > CurrentPlayers[teamid] || amt > listsize || amt > 15)break;
	    }
	}
	return string;
}

Team_ListPlayersByTempKills(teamid,listsize)
{
	//FunctionLog("Team_ListPlayersByTotalKills");
	new string[256] =  " ",bool:Excluded[MAX_SERVER_PLAYERS], highest_kills = -1, x, amt;
	for(new i; i <= HighestID; i++)
	{
	    if(IsPlayerConnected(i) && Excluded[i] == false && HasPlayed[i] == true && gTeam[i] == teamid && TR_Kills[i] > highest_kills)
	    {
	        for(x = 0; x <= HighestID; x++)
			{
			    if(Excluded[x] == false && HasPlayed[i] == true && gTeam[x] == teamid && TR_Kills[x] > TR_Kills[i])
			    {
			        i = x;
			    }
			}
			Excluded[i] = true;
			highest_kills = -1;
			format(string,sizeof(string),"%s%s: %d~n~",string,ListName[i],TR_Kills[i]);
			i = 0;
			amt++;
			if(amt > CurrentPlayers[teamid] || amt > listsize || amt > 15)break;
	    }
	}
	return string;
}

/*Team_DisplayPlayers(team)
{
    //FunctionLog("Team_DisplayPlayers");
    new string[256];
	foreach(Player,x)
	{
		if(gTeam[x] == team)
		{
			format(string,sizeof(string),"%s%s: %d~n~",string,NickName[x],TempKills[x]);
		}
	}
	return string;
}

Team_DisplayPlayers2(team)
{
    //FunctionLog("Team_DisplayPlayers2");
    new string[256];
	foreach(Player,x)
	{
		if(gTeam[x] == team)
		{
			format(string,sizeof(string),"%s%s: %d~n~",string,NickName[x],TR_Kills[x]);
		}
	}
	return string;
}*/

Team_DisplayAttackersInCP()
{
    //FunctionLog("Team_DisplayAttackersInCP");
    new string[256],file[64];
    if(TeamStatus[T_HOME] == ATTACKING)
    {
		foreach(Player,x)
		{
			if(IsPlayerInCheckpoint(x) && TeamStatus[gTeam[x]] == ATTACKING && Playing[x] == true)
			{
				format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[x]);
				dini_IntSet(file,"CP",dini_Int(file,"CP") + 1);
				format(string,sizeof(string),"%s%s~n~",string,ListName[x]);
			}
		}
	}
	else
	{
	    foreach(Player,x)
		{
			if(IsPlayerInCheckpoint(x) && TeamStatus[gTeam[x]] == ATTACKING && Playing[x] == true)
			{
			    format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[x]);
				dini_IntSet(file,"CP",dini_Int(file,"CP") + 1);
				format(string,sizeof(string),"%s%s~n~",string,ListName[x]);
			}
		}
	}
	return string;
}

Team_PlaySound(team,sound)
{
    //FunctionLog("Team_PlaySound");
    foreach(Player,x)
	{
	    if(gTeam[x] == team)
	    {
	        PlayerPlaySound(x,sound,0.0,0.0,0.0);
	    }
	}
}

Team_GetTeamWithLowestPlayers()
{
    //FunctionLog("Team_GetTeamWithLowestPlayers");
    new lowest_score = MAX_SERVER_PLAYERS, team_amt = -1, teamid = -1;

    for(new i = 0, j = ACTIVE_TEAMS; i < j; i++)
    {
        if(TeamUsed[i] == true)
        {
            team_amt = CurrentPlayers[i];

            if(team_amt < lowest_score)
            {
                lowest_score = team_amt;
                teamid = i;
            }
        }
    }
	return teamid;
}

Team_ResetTextColors()
{
    //FunctionLog("Team_ResetTextColors");
    for(new i; i < ACTIVE_TEAMS; i++)
	{
	    if(TeamUsed[i] == true)
	    {
	        TextDrawColor(ArenaTxt[i],TeamActiveColors[i] | 0x000000FF);
	    }
	}
}

Team_FriendlyFix()
{
    //FunctionLog("Team_FriendlyFix");
    if(FriendlyFire == true && Current != -1)
    {
		foreach(Player,i)
		{
			if(Playing[i] == true && gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
    		{
				SetPlayerTeam(i,98);
				SetPlayerTeam(i,ffTeam[i]);
			}
		}
	}
	else
	{
		foreach(Player,i)
		{
			SetPlayerTeam(i,99);
			SetPlayerTeam(i,i);
		}
	}
}

forward Team_StopFlash(team);
public Team_StopFlash(team)
{
    //FunctionLog("Team_StopFlash");
    foreach(Player,i)
	{
	    if(gTeam[i] == team)
	    {
	        //GangZoneStopFlashForPlayer(i,zone);
	        GangZoneHideForPlayer(i,zone);
    		TextDrawBoxColor(pText[4][i],0x00000000);
    		TD_HidepTextForPlayer(i,i,4);
		}
	}
}

Team_FlashScreen(team,team2)
{
    //FunctionLog("Team_FlashScreen");
    foreach(Player,i)
	{
	    if(gTeam[i] == team)
	    {
	        //GangZoneFlashForPlayer(i,zone,TeamGZColors[team2]);
	        GangZoneShowForPlayer(i,zone,0xFF000060);
    		TextDrawBoxColor(pText[4][i],TeamActiveColors[team2] | 0x00000025);
    		TD_ShowpTextForPlayer(i,i,4);
		}
	}
	SetTimerEx("Team_StopFlash",450,0,"i",team);
}

Team_SendClientMessage(playerid,team,msg[])
{
    //FunctionLog("Team_SendClientMessage");
    new string[128];
    format(string,128,"<%s - %s> %s",TeamName[gTeam[playerid]], NickName[playerid],msg);
    //TeamChatLog(team,playerid,msg);
    foreach(Player,i)
	{
	    if(sTeam[i] == team && Ignored[playerid][i] == false)
	    {
	        SendClientMessage(i,TeamInactiveColors[team],string);
	        Team_PlaySound(gTeam[playerid],message);
		}
	}
	return 1;
}

Team_GetTeamWithHighestScore()
{
    //FunctionLog("Team_GetTeamWithHighestScore");
    new highest_score = -1, team_score = -1, teamid = T_NON;

    for(new i = 0, j = ACTIVE_TEAMS; i < j; i++)
    {
    	team_score = TeamTempScore[i];
		if(team_score > highest_score)
  		{
  			highest_score = team_score;
  			teamid = i;
  		}
  	}
	return teamid;
}

forward Team_GetHP(team);
public Team_GetHP(team)
{
    //FunctionLog("Team_GetHP");
	new Float:Life,Float:A,Float:H;
    foreach(Player,i)
	{
	    if(Playing[i] == true && gTeam[i] == team)
	    {
	        GetPlayerHealth(i,H);
			GetPlayerArmour(i,A);
			Life += H + A;
	    }
	}
	return floatround(Life);
}

Team_UpdatePrefixName(team)
{
    //FunctionLog("Team_UpdatePrefixName");
    foreach(Player,i)
	{
	    if(gTeam[i] == T_SUB && sTeam[i] == team)
	    {
	        new newname[24];
			format(newname,sizeof(newname),"%s_%s",TeamName[team],NickName[i]);
			SetPlayerName(i,newname);
		}
	}
	return 1;
}

Team_GetFirstSub(team)
{
    //FunctionLog("Team_GetFirstSub");
	new sub = -1;
    foreach(Player,i)
	{
		if(gTeam[i] == T_SUB && sTeam[i] == team)
		{
		    sub = i; break;
		}
	}
	return sub;
}

Team_Randomize2()
{
    //FunctionLog("Team_Randomize2");
    new rand[2];
   	new found;
   	foreach(Player,i)
	{
		if(gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS)
		{
			if(found == 0)
			{
				rand[found] = random(2);
				if(gTeam[i] != rand[found])
				{
					GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
					SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
					SetPlayerColorEx(i,TeamInactiveColors[rand[found]]);
					SetTeam(i,rand[found]);
					RespawnPlayerAtPos(i,1);
				}
				found++;
			}
			else
			{
				if(rand[0] == 0)rand[1] = 1;
				else rand[1] = 0;
				if(gTeam[i] != rand[found])
				{
					GetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]);
					SetPlayerPos(i,PlayerPosition[i][0],PlayerPosition[i][1],PlayerPosition[i][2]+2);
					SetPlayerColorEx(i,TeamInactiveColors[rand[1]]);
					SetTeam(i,rand[1]);
					RespawnPlayerAtPos(i,1);
				}
				found = 0;
			}
		}
	}
}

Team_Swap()
{
    if(TeamStatus[T_HOME] == ATTACKING)
	{
		TeamStatus[T_HOME] = DEFENDING;
		TeamStatusStr[T_HOME] = "Defending";
		TextDrawSetString(StatusText[T_HOME],"Defending");
		
		TeamStatus[T_AWAY] = ATTACKING;
		TeamStatusStr[T_AWAY] = "Attacking";
		TextDrawSetString(StatusText[T_AWAY],"Attacking");
	}
	else
	{
		TeamStatus[T_HOME] = ATTACKING;
		TeamStatusStr[T_HOME] = "Attacking";
		TextDrawSetString(StatusText[T_HOME],"Attacking");

		TeamStatus[T_AWAY] = DEFENDING;
		TeamStatusStr[T_AWAY] = "Defending";
		TextDrawSetString(StatusText[T_AWAY],"Defending");
	}
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//configuration loading

forward LoadArenas();
public LoadArenas()
{
    //FunctionLog("LoadArenas");
	new arenas,string[STR],idx,missed;
	for(new i = 0; i < MAX_BASES; i++)
	{
	    if(missed > 1)break;
		else if(fexist(Arenafile(i)))
		{
		    arenas++;
		    ArenaExists[i] = true;
			idx = 0;string = dini_Get(Arenafile(i),"T0");TeamArenaSpawns[i][0][0] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][1][0] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][2][0] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"T1");TeamArenaSpawns[i][0][1] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][1][1] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][2][1] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"T2");TeamArenaSpawns[i][0][2] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][1][2] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][2][2] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"T3");TeamArenaSpawns[i][0][3] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][1][3] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][2][3] = floatstr(strtok(string,idx,','));
            idx = 0;string = dini_Get(Arenafile(i),"T4");TeamArenaSpawns[i][0][4] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][1][4] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][2][4] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"T5");TeamArenaSpawns[i][0][5] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][1][5] = floatstr(strtok(string,idx,','));TeamArenaSpawns[i][2][5] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"home");ArenaCP[i][0] = floatstr(strtok(string,idx,','));ArenaCP[i][1] = floatstr(strtok(string,idx,','));ArenaCP[i][2] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"Zmax");ArenaZones[i][0] = floatstr(strtok(string,idx,','));ArenaZones[i][1] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Arenafile(i),"Zmin");ArenaZones[i][2] = floatstr(strtok(string,idx,','));ArenaZones[i][3] = floatstr(strtok(string,idx,','));
			Interior[i][ARENA] = dini_Int(Arenafile(i),"Interior");
			LocationName[i][ARENA] = dini_Get(Arenafile(i),"Name");
			if(!dini_Isset(Arenafile(i),"Weather"))Weather[i][ARENA] = -1;else Weather[i][ARENA] = dini_Int(Arenafile(i),"Weather");
			if(!dini_Isset(Arenafile(i),"Time"))TimeX[i][ARENA] = -1;else TimeX[i][ARENA] = dini_Int(Arenafile(i),"Time");
		}
		else
		{
			ArenaExists[i] = false;
			missed++;
		}
	}
	MAX_EXISTING[ARENA] = arenas;
	printf("(%d/%d) Arenas Loaded!",arenas,MAX_BASES);
}

forward LoadBases();
public LoadBases()
{
    //FunctionLog("LoadBases");
	new bases,string[STR],idx,missed;
	for(new i; i < MAX_BASES; i++)
	{
	    if(missed > 1)break;
		else if(fexist(Basefile(i)))
		{
		    bases++;
		    BaseExists[i] = true;
			idx = 0;string = dini_Get(Basefile(i),"T1_0");TeamBaseSpawns[i][0][T_HOME] = floatstr(strtok(string,idx,','));TeamBaseSpawns[i][1][T_HOME] = floatstr(strtok(string,idx,','));TeamBaseSpawns[i][2][T_HOME] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Basefile(i),"T2_0");TeamBaseSpawns[i][0][T_AWAY] = floatstr(strtok(string,idx,','));TeamBaseSpawns[i][1][T_AWAY] = floatstr(strtok(string,idx,','));TeamBaseSpawns[i][2][T_AWAY] = floatstr(strtok(string,idx,','));
			idx = 0;string = dini_Get(Basefile(i),"home");HomeCP[i][0] = floatstr(strtok(string,idx,','));HomeCP[i][1] = floatstr(strtok(string,idx,','));HomeCP[i][2] = floatstr(strtok(string,idx,','));
			Interior[i][BASE] = dini_Int(Basefile(i),"Interior");
			LocationName[i][BASE] = dini_Get(Basefile(i),"Name");
			if(!dini_Isset(Basefile(i),"Weather"))Weather[i][BASE] = -1;else Weather[i][BASE] = dini_Int(Basefile(i),"Weather");
			if(!dini_Isset(Basefile(i),"Time"))TimeX[i][BASE] = -1;else TimeX[i][BASE] = dini_Int(Basefile(i),"Time");
		}
		else
		{
			BaseExists[i] = false;
			missed++;
		}
	}
	MAX_EXISTING[BASE] = bases;
	printf("(%d/%d) Bases Loaded!",bases,MAX_BASES);
}

LoadConfig()
{
    //FunctionLog("LoadConfig");
    GameMap = dini_Int("/attackdefend/g_config.ini","GameMap");//printf("GameMap=%d",GameMap);
	new string[STR],idx,i,file[45];
	format(file,sizeof(file),"/attackdefend/%d/config/gameconfig.ini",GameMap);
	idx = 0;string = dini_Get(file,"wSkill");for(i = 0; i < 11; i++){WeaponSkills[i][s_Level] = strval(strtok(string,idx,','));}
  	idx = 0;string = dini_Get(file,"TeamLock");for(i = 0; i < MAX_TEAMS; i++){TeamLock[i] = bool:strval(strtok(string,idx,','));}
  	idx = 0;string = dini_Get(file,"TeamUsed");for(i = 0; i < MAX_TEAMS; i++){TeamUsed[i] = bool:strval(strtok(string,idx,','));}
  	idx = 0;string = dini_Get(file,"TeamSkin");for(i = 0; i < MAX_TEAMS; i++){TeamSkin[i] = strval(strtok(string,idx,','));}
  	idx = 0;string = dini_Get(file,"TeamName");for(i = 0; i < MAX_TEAMS; i++){format(TeamName[i],sizeof(TeamName),"%s",strtok(string,idx,','));}
	idx = 0;string = dini_Get(file,"MainSpawn");MainSpawn[0] = floatstr(strtok(string,idx,','));MainSpawn[1] = floatstr(strtok(string,idx,','));MainSpawn[2] = floatstr(strtok(string,idx,','));MainSpawn[3] = floatstr(strtok(string,idx,','));
	idx = 0;string = dini_Get(file,"AdminLevels");aLvl[0] = strval(strtok(string,idx,','));aLvl[1] = strval(strtok(string,idx,','));aLvl[2] = strval(strtok(string,idx,','));
	idx = 0;string = dini_Get(file,"Counter");StopCounting[BASE][1] = strval(strtok(string,idx,','));StopCounting[ARENA][1] = strval(strtok(string,idx,','));StopCounting[2][1] = strval(strtok(string,idx,','));
    idx = 0;string = dini_Get(file,"TeamVehColor");TeamVehColor[T_HOME][0] = strval(strtok(string,idx,','));TeamVehColor[T_HOME][1] = strval(strtok(string,idx,','));TeamVehColor[T_AWAY][0] = strval(strtok(string,idx,','));TeamVehColor[T_AWAY][1] = strval(strtok(string,idx,','));
    idx = 0;string = dini_Get(file,"CurrentConfig");CurrentConfig[BASE] = strval(strtok(string,idx,','));CurrentConfig[ARENA] = strval(strtok(string,idx,','));CurrentConfig[PLAYER] = strval(strtok(string,idx,','));

	TextTime = dini_Int(file,"Text");//printf("TextTime=%d",TextTime);
	KeyTime = dini_Int(file,"Keys");//printf("KeyTime=%d",KeyTime);
	CmdTime = dini_Int(file,"Cmds");//printf("CmdTime=%d",CmdTime);
	CPsize = dini_Int(file,"Cpsize");//printf("CPsize=%d",CPsize);
	CPtime[1] = dini_Int(file,"Cptime");//printf("CPtime=%d",CPtime[1]);
	modetime = dini_Int(file,"Modetime");//printf("ModeTime=%d",modetime);
	RoundCode = dini_Int(file,"RoundCode");//printf("RoundCode=%d",RoundCode);
	gWeather = dini_Int(file,"Weather");SetWeather(gWeather);//printf("Weather=%d",gWeather);
	gTime = dini_Int(file,"Time");SetGlobalTime(gTime);//printf("Time=%d",gTime);
	gHealth = dini_Int(file,"gHealth");//printf("gHealth=%d",gHealth);
	gArmor = dini_Int(file,"gArmor");//printf("gArmor=%d",gArmor);
	rHealth = dini_Int(file,"rHealth");//printf("rHealth=%d",rHealth);
	rArmor = dini_Int(file,"rArmor");//printf("rArmor=%d",rArmor);
	VPPPT = dini_Int(file,"VPPPT");//printf("VPPPT=%d",VPPPT);
	RoundLimit = dini_Int(file,"RoundLimit");//printf("RoundLimit=%d",RoundLimit);
	AutoMode = dini_Int(file,"AutoMode");if(AutoMode == 0 || AutoMode == 1 || AutoMode == 2)SetTimer("AutoModeInit",10000,0);//printf("AutoMode=%d",AutoMode);
	Pickups = dini_Int(file,"Pickups");//printf("Pickups=%d",Pickups);
	DropLifeTime = dini_Int(file,"DropLifeTime");//printf("DropLifeTime=%d",DropLifeTime);
	IDLEtime = dini_Int(file,"IDLEtime");//printf("IDLEtime=%d",IDLEtime);
	AutoPause = dini_Int(file,"AutoPause");//printf("AutoPause=%d",AutoPause);
	MarkerFade = dini_Int(file,"MarkerFade");//printf("MarkerFade=%d",MarkerFade);
	MaxPing = dini_Int(file,"MaxPing");//printf("MaxPing=%d",MaxPing);
	ShowTeamDmg = dini_Int(file,"ShowTeamDmg");//printf("ShowTeamDmg=%d",ShowTeamDmg);

	nDist = dini_Float(file,"nDist");//printf("nDist=%f",nDist);
	MaxDist = dini_Float(file,"MaxDist");//printf("MaxDist=%f",MaxDist);
	MinDist = dini_Float(file,"MinDist");//printf("MinDist=%f",MinDist);
	Gravity = dini_Float(file,"Gravity");format(string,sizeof(string),"gravity %f",Gravity);SendRconCommand(string);//printf("Gravity=%0f",Gravity);

	CPused = bool:dini_Int(file,"Cpused");//printf("CPused=%d",CPused);
    RoundMuting = bool:dini_Int(file,"RoundMuting");//printf("RoundMuting=%d",RoundMuting);
    Allowswitch = bool:dini_Int(file,"Switch");//printf("Switch=%d",Allowswitch);
    FriendlyFire = bool:dini_Int(file,"FriendlyFire");//printf("FriendlyFire=%d",FriendlyFire);
	Allownicks = bool:dini_Int(file,"Nicknames");//printf("Nicknames=%d",Allownicks);
	TabHP = bool:dini_Int(file,"TabHP");//printf("TabHP=%d",TabHP);
	IDnames = bool:dini_Int(file,"IDnames");//printf("IDnames=%d",IDnames);
	UseSubs = bool:dini_Int(file,"UseSubs");//printf("UseSubs=%d",UseSubs);
	EnemyUAV = bool:dini_Int(file,"EnemyUAV");//printf("EnemyUAV=%d",EnemyUAV);
	UseClock = bool:dini_Int(file,"UseClock");//printf("UseClock=%d",UseClock);
	NoNameMode = bool:dini_Int(file,"NoNameMode");//printf("NoNameMode=%d",NoNameMode);
	AutoTeamSpec = bool:dini_Int(file,"AutoTeamSpec");//printf("AutoTeamSpec=%d",AutoTeamSpec);
	AntiC = bool:dini_Int(file,"AntiC");//printf("AntiC=%d",AntiC);
	LockMode = bool:dini_Int(file,"LockMode");//printf("LockMode=%d",LockMode);
	Pausing = bool:dini_Int(file,"Pausing");//printf("Pausing=%d",Pausing);
	Debug = bool:dini_Int(file,"Debug");//printf("Debug=%d",Debug);
    UseRadar = bool:dini_Int(file,"UseRadar");//printf("UseRadar=%d",UseRadar);
    Randomization = bool:dini_Int(file,"Randomization");//printf("Randomization=%d",Randomization);
    v_AllowSpawning = bool:dini_Int(file,"vSpawning");//printf("v_AllowSpawning=%d",v_AllowSpawning);
    AutoSwap = bool:dini_Int(file,"AutoSwap");//printf("AutoSwap=%d",AutoSwap);
    UseNameTags = bool:dini_Int(file,"UseNameTags");//printf("UseNameTags=%d",UseNameTags);
    PrivateMode = bool:dini_Int(file,"PrivateMode");//printf("PrivateMode=%d",PrivateMode);

	format(HostTag,sizeof(HostTag),"%s",dini_Get(file,"HostTag"));
	/*if(strlen(HostTag) > sizeof(HostTag))
	{
	    printf("HostTag is too long. (MAX CHARS %d)",sizeof(HostTag));
	    print("Server Shutting Down...");
	    SendRconCommand("exit");
	}*/

	format(PlayingTag,sizeof(PlayingTag),"%s",dini_Get(file,"PlayingTag"));
	format(DeadTag,sizeof(DeadTag),"%s",dini_Get(file,"DeadTag"));


	/*MOTDtext = dini_Get(file,"MOTDtext");
	if(strlen(MOTDtext) > 255)
	{
	    print("MOTD text is too long. (MAX CHARS 255)");
	    MOTDtext = "- No Cheating~n~- No Excessive Spam or Flame~n~- No Infinite Shooting Bugs";
	}*/

	TeamStatus[T_HOME] = ATTACKING;
	TeamStatusStr[T_HOME] = "Attacking";
	TextDrawColor(StatusText[T_HOME],TeamActiveColors[T_HOME] | 255);
	TeamStatus[T_AWAY] = DEFENDING;
	TeamStatusStr[T_AWAY] = "Defending";
	TextDrawColor(StatusText[T_AWAY],TeamActiveColors[T_AWAY] | 255);
	TeamUsed[T_HOME] = true;
	TeamUsed[T_AWAY] = true;
	for(i = 0; i < ACTIVE_TEAMS; i++)
	{
		if(TeamUsed[i] == true)
		{
			TeamsBeingUsed++;
		}
	}
	print("Server Configuration Loaded!");
	return 1;
}

LoadColors()
{
    //FunctionLog("LoadColors");
    new string[STR],idx;
	string = dini_Get(gConfigFile(),"iColors");
	for(new i = 0; i < MAX_TEAMS; i++){TeamInactiveColors[i] = HexToInt(strtok(string,idx,','));}
	
	idx = 0;string = dini_Get(gConfigFile(),"aColors");
	for(new i = 0; i < MAX_TEAMS; i++){TeamActiveColors[i] = HexToInt(strtok(string,idx,','));TeamGZColors[i] = TeamActiveColors[i] | 0x00000080;}
	
	idx = 0;string = dini_Get(gConfigFile(),"MainColors");
	MainColors[0] = HexToInt(strtok(string,idx,','));
	MainColors[1] = HexToInt(strtok(string,idx,','));
	MainColors[2] = HexToInt(strtok(string,idx,','));
	MainColors[3] = HexToInt(strtok(string,idx,','));
	MainColors[4] = HexToInt(strtok(string,idx,','));
	
	idx = 0;string = dini_Get(gConfigFile(),"Colors");
	Colors[0] = HexToInt(strtok(string,idx,','));
	Colors[1] = HexToInt(strtok(string,idx,','));
	Colors[2] = HexToInt(strtok(string,idx,','));
	Colors[3] = HexToInt(strtok(string,idx,','));
	Colors[4] = HexToInt(strtok(string,idx,','));
	ResetAllColors();
	for(new i; i < ACTIVE_TEAMS; i++)
	{
		TextDrawColor(gFinalText2[i],TeamActiveColors[i] | 0x000000FF);
		TextDrawColor(gFinalText4[i],TeamActiveColors[i] | 0x000000FF);
		TextDrawBoxColor(gFinalText1[i], TeamActiveColors[i] | 0x00000060);
	}
}

ResetAllColors()
{
    //FunctionLog("ResetAllColors");
    foreach(Player,i)
	{
		if(Playing[i] == true)SetPlayerColorEx(i,TeamActiveColors[gTeam[i]]);
		else if(gPlayerSpawned[i] == true || (gTeam[i] >= 0 && gTeam[i] < ACTIVE_TEAMS))SetPlayerColorEx(i,TeamInactiveColors[gTeam[i]]);
		else SetPlayerColorEx(i,grey);
	}
}

forward LoadConfigB(num);
public LoadConfigB(num)
{
    //FunctionLog("LoadConfigB");
    new string[STR],file[50],gunstring[6],idx;
    format(file,50,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,num);
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		idx = 0;
		format(gunstring,6,"%d",i);
		string = dini_Get(file,gunstring);
		GunAmmo[i][BASE] = strval(strtok(string,idx,','));
		GunUsed[i][BASE] = strval(strtok(string,idx,','));
		GunLimit[i][BASE] = strval(strtok(string,idx,','));
	}
	UpdateWeaponSetText(BASE);
	printf("Weapon bConfig (#%d) Loaded!",num);
}

forward LoadConfigA(num);
public LoadConfigA(num)
{
    //FunctionLog("LoadConfigA");
    new string[STR],file[50],gunstring[6],idx;
    format(file,50,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,num);
	for(new i; i < MAX_WEAPONS; i++)
	{
		idx = 0;format(gunstring,6,"%d",i);string = dini_Get(file,gunstring);GunAmmo[i][ARENA] = strval(strtok(string,idx,','));GunUsed[i][ARENA] = strval(strtok(string,idx,','));GunLimit[i][ARENA] = strval(strtok(string,idx,','));//printf("A: (%d) Ammo: %d   Used: %d   Limit: %d",i,GunAmmo[i][ARENA],GunUsed[i][ARENA],GunLimit[i][ARENA]);
	}
	UpdateWeaponSetText(ARENA);
	printf("Weapon aConfig (#%d) Loaded!",num);
}

forward LoadConfigP(num);
public LoadConfigP(num)
{
    //FunctionLog("LoadConfigP");
    new string[STR],file[50],gunstring[5],idx;
    format(file,50,"/attackdefend/%d/config/playerconfig/%d.ini",GameMap,num);
	for(new i; i < MAX_WEAPONS; i++)
	{
		idx = 0;format(gunstring,5,"%d",i);string = dini_Get(file,gunstring);pGunAmmo[i] = strval(strtok(string,idx,','));pGunUsed[i] = strval(strtok(string,idx,','));//printf("P: (%d) Ammo: %d   Used: %d",i,pGunAmmo[i],pGunUsed[i]);
	}
	printf("Weapon pConfig (#%d) Loaded!",num);
}

forward LoadVehicleInfo();
public LoadVehicleInfo()
{
    //FunctionLog("LoadVehicleInfo");
    new string[STR],vstr[4],idx;
	for(new i = 400; i < MAX_SPAWNABLE_VEHICLES+400; i++)
	{
		idx= 0;format(vstr,4,"%d",i);string = dini_Get(VehicleFile(),vstr);v_Usage[i-400] = strval(strtok(string,idx,','));v_Health[i-400] = strval(strtok(string,idx,','));
	}
	printf("Vehicle Config Loaded!");
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

forward CreateProfileII(name[],IP[]);
public CreateProfileII(name[],IP[])
{
    //FunctionLog("CreateProfileII");
	new file[64];
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(name));
	new File:aFile,entry[512],entry2[512],both[1024];
	format(entry,sizeof(entry),"IP=%s\r\nRegistered=0\r\nLevel=0\r\nPassword=n/a\r\nMuted=0\r\nWheels=0\r\nNick=%s\r\nWorldPass=off\r\nSetSpawn=0\r\nTimePlayed=0\r\nLastConnect=0\r\nSkin=-1\r\nTotalKills=0\r\nTotalDeaths=0\r\nMatchKills=0\r\nMatchDeaths=0\r\nTeamKills=0\r\nvColor1=0\r\nvColor2=0\r\nwS0=0\r\nwS1=0\r\nwS2=0\r\nwS3=0\r\nwS4=0\r\nwS5=0\r\nwS6=0\r\nwS7=0",IP,name);
	format(entry2,sizeof(entry2),"\r\nwS8=0\r\nwS9=0\r\nwS10=0\r\nwS11=0\r\nwS12=0\r\nK_Spree=0\r\nD_Spree=0\r\nCP=0\r\nmSpawn=0.0,0.0,0.0,0\r\nTS_Kills=0\r\nTS_Deaths=0\r\nTS_TKs=0\r\nHealth=0.0\r\nArmor=0.0\r\nPlaying=0\r\nWeapons=0,0,0,0,0,0,0,0,0,0,0,0,0\r\nAmmo=0,0,0,0,0,0,0,0,0,0,0,0,0\r\nPos=0,0,0,0\r\nTeam=0\r\nRoundCode=0\r\nwSkill=999,999,999,999,999,999,999,999,999,999,999\r\nfStyle=0");
	format(both,sizeof(both),"%s%s",entry,entry2);
	aFile = fopen(file,io_append);fwrite(aFile,both);fclose(aFile);

	both = "\r\nK_0=0";
	for(new i = 1; i < 55; i++){if(i == 19 || i == 20 || i == 21 || i == 47 || i == 48)continue;format(both,sizeof(both),"%s\r\nK_%d=0",both,i);}
	aFile = fopen(file,io_append);fwrite(aFile,both);fclose(aFile);

	both = "\r\nD_0=0";
	for(new i = 1; i < 55; i++){if(i == 19 || i == 20 || i == 21  || i == 47 || i == 48)continue;format(both,sizeof(both),"%s\r\nD_%d=0",both,i);}
	aFile = fopen(file,io_append);fwrite(aFile,both);fclose(aFile);
	dini_IntSet(ServerFile(),"Accounts",dini_Int(ServerFile(),"Accounts") + 1);
}

forward CreateProfile(playerid);
public CreateProfile(playerid)
{
    //FunctionLog("CreateProfile");
	new file[64],IP[16];
	GetPlayerIp(playerid,IP,16);
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	new File:aFile,entry[512],entry2[512],both[1024];
 	format(entry,sizeof(entry),"IP=%s\r\nRegistered=0\r\nLevel=0\r\nPassword=n/a\r\nMuted=0\r\nWheels=0\r\nNick=%s\r\nWorldPass=off\r\nSetSpawn=0\r\nTimePlayed=0\r\nLastConnect=0\r\nSkin=-1\r\nTotalKills=0\r\nTotalDeaths=0\r\nMatchKills=0\r\nMatchDeaths=0\r\nTeamKills=0\r\nvColor1=0\r\nvColor2=0\r\nwS0=0\r\nwS1=0\r\nwS2=0\r\nwS3=0\r\nwS4=0\r\nwS5=0\r\nwS6=0\r\nwS7=0",IP,RealName[playerid]);
	format(entry2,sizeof(entry2),"\r\nwS8=0\r\nwS9=0\r\nwS10=0\r\nwS11=0\r\nwS12=0\r\nK_Spree=0\r\nD_Spree=0\r\nCP=0\r\nmSpawn=0.0,0.0,0.0,0\r\nTS_Kills=0\r\nTS_Deaths=0\r\nTS_TKs=0\r\nHealth=0.0\r\nArmor=0.0\r\nPlaying=0\r\nWeapons=0,0,0,0,0,0,0,0,0,0,0,0,0\r\nAmmo=0,0,0,0,0,0,0,0,0,0,0,0,0\r\nPos=0,0,0,0\r\nTeam=0\r\nRoundCode=0\r\nwSkill=999,999,999,999,999,999,999,999,999,999,999\r\nfStyle=0");
	format(both,sizeof(both),"%s%s",entry,entry2);
	aFile = fopen(file,io_append);fwrite(aFile,both);fclose(aFile);
	
	both = "\r\nK_0=0";
	for(new i = 1; i < 55; i++){if(i == 19 || i == 20 || i == 21 || i == 47 || i == 48)continue;format(both,sizeof(both),"%s\r\nK_%d=0",both,i);}
	aFile = fopen(file,io_append);fwrite(aFile,both);fclose(aFile);
	
	both = "\r\nD_0=0";
	for(new i = 1; i < 55; i++){if(i == 19 || i == 20 || i == 21  || i == 47 || i == 48)continue;format(both,sizeof(both),"%s\r\nD_%d=0",both,i);}
	aFile = fopen(file,io_append);fwrite(aFile,both);fclose(aFile);
	dini_IntSet(ServerFile(),"Accounts",dini_Int(ServerFile(),"Accounts") + 1);
}

SaveMatchResults()
{
    //FunctionLog("SaveMatchResults");
	new string[128],entry2[128];
	new hour,minute,second,year,month,day,time[3];
	new Float:ratio,Float:killz,Float:deathz,kills,deaths,tks;
	new File:bFile;

	gettime(hour,minute,second);
	getdate(year,month,day);

	if(hour > 12){hour = hour-12;time = "PM";}else time = "AM";
	format(string,sizeof(string),"\r\n\r\n\r\n\r\nFinal Results: %d/%d/%d @ %d:%02d:%02d %s (Lasted: %s)",month,day,year,hour,minute,second,time,ConvertToMins(Now() - TR_FirstStart));
	new File:aFile;aFile = fopen(ResultsFile(), io_append);fwrite(aFile, string);fclose(aFile);printf(string);
	
	for(new t = 0; t < ACTIVE_TEAMS; t++)
	{
	    if(TeamUsed[t] == true)
	    {
 			killz = TeamTotalScore[t];deathz = TeamTotalDeaths[t];ratio = killz/deathz;if(deathz == 0)ratio = killz;
 			format(string,sizeof(string),"\r\n\r\n>>>> Team: %s | Wins:%d | Kills:%d | Deaths:%d | Ratio:%.02f",TeamName[t],TeamRoundsWon[t],TeamTotalScore[t],TeamTotalDeaths[t],ratio);
			bFile = fopen(ResultsFile(), io_append);fwrite(bFile, string);fclose(bFile);printf(string);
			foreach(Player,x)
			{
				if(gTeam[x] == t)
				{
					killz = TempKills[x];deathz = TempDeaths[x];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
					kills = TempKills[x];deaths = TempDeaths[x];tks = TempTKs[x];if(kills == 0)ratio = -deaths;
					if(tks == 0)format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d | Deaths: %d | Ratio: %.02f",RealName[x], kills, deaths, ratio);
					else format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d | Deaths: %d | Ratio: %.02f | TK's: %d",RealName[x], kills, deaths, ratio , tks);
					new File:cFile;cFile = fopen(ResultsFile(), io_append);fwrite(cFile, entry2);fclose(cFile);printf(entry2);
				}
			}
		}
	}
	format(string,sizeof(string),"\r\n\r\n>>>> Other Players Online");
	bFile = fopen(ResultsFile(), io_append);fwrite(bFile, string);fclose(bFile);printf(string);
    foreach(Player,x)
	{
		if(gTeam[x] >= ACTIVE_TEAMS)
		{
			
			killz = TempKills[x];deathz = TempDeaths[x];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
			kills = TempKills[x];deaths = TempDeaths[x];tks = TempTKs[x];if(kills == 0)ratio = -deaths;
			if(tks == 0)format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d | Deaths: %d | Ratio: %.02f",RealName[x], kills, deaths, ratio);
			else format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d | Deaths: %d | Ratio: %.02f | TK's: %d",RealName[x], kills, deaths, ratio , tks);
			new File:cFile;cFile = fopen(ResultsFile(), io_append);fwrite(cFile, entry2);printf(entry2);fclose(cFile);
	   	}
   	}
   	new File:dFile;dFile = fopen(ResultsFile(), io_append);
   	fwrite(dFile,"\r\n\r\n\r\n----------------------------------------------------------------");
	fwrite(dFile,"\r\n<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>");
	fwrite(dFile,"\r\n----------------------------------------------------------------\r\n\r\n\r\n");
	fclose(dFile);
}

ShowStats(playerid,target[])
{
    //FunctionLog("ShowStats");
	new string[128],file[64];format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(target));
 	new Float:ratio,Float:killz,Float:deathz;killz = dini_Int(file,"TotalKills");deathz = dini_Int(file,"TotalDeaths");ratio = killz / deathz;
 	new Float:ratio2,Float:killz2,Float:deathz2;killz2 = dini_Int(file,"MatchKills");deathz2 = dini_Int(file,"MatchDeaths");ratio2 = killz2 / deathz2;
	if(deathz == 0){ratio = killz;}
	new total = dini_Int(file,"TimePlayed");
	    
	format(string,sizeof(string),">> Statistics for %s",target);SendClientMessage(playerid,MainColors[3],string);
	format(string,sizeof(string),"    TimePlayed: %s",ConvertSeconds(total));SendClientMessage(playerid,MainColors[3],string);
	format(string,sizeof(string),"    TotalKills: %.0f  | TotalDeaths: %.0f  |  Ratio: %.2f",killz,deathz,ratio);SendClientMessage(playerid,MainColors[3],string);
 	format(string,sizeof(string),"    MatchKills: %.0f  | MatchDeaths: %.0f  |  Ratio: %.2f",killz2,deathz2,ratio2);SendClientMessage(playerid,MainColors[3],string);
 	format(string,sizeof(string),"    Taken CP: %d  |  Kill Spree: %d  |  Death Spree: %d  |  Skin: %d",dini_Int(file,"CP"),dini_Int(file,"K_Spree"),dini_Int(file,"D_Spree"),dini_Int(file,"Skin"));SendClientMessage(playerid,MainColors[3],string);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Misc Functions on timers

forward MarkerStealth();
public MarkerStealth()
{
	if(Current == -1)return 1;
	/*FunctionLogEx("MarkerStealth");*/
	if(MarkerFade == ModeType || MarkerFade == 3)
	{
	    new Float:distance,Float:p[3],Float:p2[3],x;
		foreach(Player,i)
		{
      		if(Playing[i] == true)
		    {
				foreachex(Player,x)
				{
    				if(x != i)
					{
						if(Playing[i] == true && sTeam[i] != sTeam[x])
						{
							GetPlayerPos(i,p[0],p[1],p[2]);
							GetPlayerPos(x,p2[0],p2[1],p2[2]);
							if(Playing[x] == false)SetPlayerMarkerForPlayer(i,x,CurrentColor[x] | 0x000000FF);
							else if(InRange(p[0],p[1],p[2],p2[0],p2[1],p2[2],MinDist))SetPlayerMarkerForPlayer(i,x,CurrentColor[x] & 0xFFFFFF00);
							else if(InRange(p[0],p[1],p[2],p2[0],p2[1],p2[2],MaxDist))SetPlayerMarkerForPlayer(i,x,(CurrentColor[x] & 0xFFFFFF00) | floatround((distance - MinDist) * float(0xFF) / (MaxDist - MinDist)));
      					}
      					else SetPlayerMarkerForPlayer(i,x,CurrentColor[x] | 0x000000FF);
    				}
				}
			}
		}
		if(nmtimer == true)return SetTimer("MarkerStealth",1000,0);
	}
	else
	{
	    new x;
		foreach(Player,i)
		{
		    if(Playing[i] == true)
		    {
				foreachex(Player,x)
				{
					if(x != i)
					{
						if(sTeam[i] != sTeam[x])
						{
					   		if(gTeam[x] != T_NON || gTeam[x] != gTeam[i])SetPlayerMarkerForPlayer(i,x,CurrentColor[x] & 0xFFFFFF00);
 							else SetPlayerMarkerForPlayer(i,x,CurrentColor[x] | 0x000000FF);
    	  				}
      					else SetPlayerMarkerForPlayer(i,x,CurrentColor[x] | 0x000000FF);
					}
				}
			}
		}
  		if(nmtimer == true)SetTimer("MarkerStealth",10000,0);
  		return 1;
	}
  	return 1;
}

forward NameTags();
public NameTags()
{
	if(Current == -1)return 1;
	/*FunctionLogEx("NameTags");*/
	if(UseNameTags == true)
	{
		new Float:p1[3],Float:p2[3],x;
		foreach(Player,i)
		{
			foreachex(Player,x)
			{
				if(x != i)
				{
					if(gSpectateID[x] == i){continue;}
					GetPlayerPos(i,p1[0],p1[1],p1[2]);
					GetPlayerPos(x,p2[0],p2[1],p2[2]);
					if(Playing[x] == false && gSpectating[x] == false)ShowPlayerNameTagForPlayer(x,i,1);
  					else if(((gTeam[x] == T_NON || gTeam[x] == gTeam[i]) && (InVehicle[x] == InVehicle[i])) || ((gTeam[x] == T_NON || gTeam[x] == gTeam[i]) && (InVehicle[i] == -1 && (InVehicle[x] != -1))))ShowPlayerNameTagForPlayer(x,i,1);
					else if(InVehicle[i] != -1 && (InVehicle[x] == -1 || InVehicle[i] != InVehicle[x]))ShowPlayerNameTagForPlayer(x,i,0);
					else if(gTeam[x] != gTeam[i] && InRange(p1[0],p1[1],p1[2],p2[0],p2[1],p2[2],nDist))ShowPlayerNameTagForPlayer(x,i,0);
					else ShowPlayerNameTagForPlayer(x,i,1);
				}
			}
		}
  		if(nmtimer == true)return SetTimer("NameTags",495,0);
	}
	else
	{
	    new x;
	    foreach(Player,i)
		{
			foreachex(Player,x)
			{
			    if(x != i)
			    {
					if(Playing[x] == true)ShowPlayerNameTagForPlayer(x,i,0);
					else ShowPlayerNameTagForPlayer(x,i,1);
				}
			}
		}
	}
  	return 1;
}

forward ShowNamesAndBlipsForAll();
public ShowNamesAndBlipsForAll()
{
    //FunctionLog("ShowNamesAndBlipsForAll");
    new x;
    foreach(Player,i)
	{
		foreachex(Player,x)
		{
			ShowPlayerNameTagForPlayer(x,i,1);
			SetPlayerMarkerForPlayer(x,i,CurrentColor[i] | 0x000000FF);
		}
	}
}

forward RestoreLife();
public RestoreLife()
{
    //FunctionLog("RestoreLife");
	foreach(Player,i)
	{
		if(Playing[i] == true)
		{
			ResetPlayerHealth(i);
			ResetPlayerArmor(i);
			ShowDMG[i] = true;
		}
	}
	UpdateRoundII();
	return 1;
}

forward AllowCommands(playerid);public AllowCommands(playerid){/*FunctionLogEx("AllowCommands");*/NoCmds[playerid] = false;}
forward AllowText(playerid);public AllowText(playerid){/*FunctionLogEx("AllowText");*/NoText[playerid] = false;}
forward AllowKeys(playerid);public AllowKeys(playerid){/*FunctionLogEx("AllowKeys");*/NoKeys[playerid] = false;}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Spectate related

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    //FunctionLog("OnPlayerInteriorChange");
	foreach(Player,x)
	{
	    if(IsPlayerConnected(x) && gSpectateID[x] == playerid)
   		{
   		    SetPlayerInterior(x,newinteriorid);
		}
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    /*FunctionLogEx("OnPlayerStateChange");*/
	if(newstate == PLAYER_STATE_WASTED)
	{
	    //new string[50];
		//format(string,sizeof(string),"HP:     -~n~Team: %s", TeamName[gTeam[playerid]]);
		//TextDrawSetString(pText[6][playerid],string);
	    TD_HidepTextForPlayer(playerid,playerid,15);
		TD_ShowPanoForPlayer(playerid);
		ShowDMG[playerid] = false;
		if(Playing[playerid] == true)
		{
		    SetTimer("UpdateRoundII",10,0);
		}
        if(Syncing[playerid] == true)
        {
            KillTimer(SyncTimer[playerid]);
		    SendClientMessage(playerid,MainColors[2],"Sync failed! (you died)");
    		Syncing[playerid] = false;
            NoKeys[playerid] = false;
			ChangedWeapon[playerid] = true;
        }
		if(Playing[playerid] == false && IsDueling[playerid] == false && gPlayerSpawned[playerid] == true)
		{
			if(SetSpawn[playerid] == 2)
			{
	    		GetPlayerPos(playerid,mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid]);
	    		mSpawn[4][playerid] = GetPlayerInterior(playerid);
				GetPlayerFacingAngle(playerid,mSpawn[3][playerid]);
			}
			FindPlayerSpawn(playerid,1);
		}
		gPlayerSpawned[playerid] = false;
	}
	else if(newstate == PLAYER_STATE_SPAWNED)
	{
	    gPlayerSpawned[playerid] = true;
		gSelectingClass[playerid] = false;
		gState[playerid] = e_STATE_ACTIVE;
	    if(WatchingBase == false)SetTimerEx("ShowDamage",500,0,"i",playerid);
	    /*if(KillFade[playerid] == false)
	    {
	        KillFade[playerid] = true;
			TextDrawBoxColor(pText[4][playerid],0x0000000);
			TD_HidepTextForPlayer(playerid,playerid,4);
		}*/
		if(gSpectating[playerid] == false)
		{
			TD_HidePanoForPlayer(playerid);
		}
	}
	/*if(oldstate == PLAYER_STATE_SPAWNED && newstate == PLAYER_STATE_SPAWNED)
	{
	    foreach(Player,x)
		{
			if(gSpectateID[x] == playerid)
			{
				SetTimerEx("Spectate_ReSpecPlayer",400,0,"ii",x,playerid);
			}
		}
	}*/
	if(newstate == PLAYER_STATE_SPECTATING && oldstate != PLAYER_STATE_SPECTATING)
	{
	    gState[playerid] = e_STATE_NONE;
	    //TextDrawHideForPlayer(playerid,MoneyBox);
    	//TextDrawHideForPlayer(playerid,pText[6][playerid]);
	}
	else if(oldstate == PLAYER_STATE_SPECTATING && newstate != PLAYER_STATE_SPECTATING)
	{
	    //AmtSpectating[gSpectateID[playerid]]--;
	    SetTimerEx("Spectate_WhoIsWatchingMe",5,0,"i",gSpectateID[playerid]);
	    ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],1);
	    TD_HidepTextForPlayer(playerid,gSpectateID[playerid],1);
	    TD_HidepTextForPlayer(playerid,gSpectateID[playerid],8);
	    TD_HidepTextForPlayer(playerid,gSpectateID[playerid],13);
	    TD_HidepTextForPlayer(playerid,gSpectateID[playerid],14);
	    TD_HidePanoForPlayer(playerid);
		for(new x = 0; x < 4; x++)
		{
			TD_HidepTextForPlayer(playerid,gSpectateID[playerid],x+9);
		}
		//TextDrawShowForPlayer(playerid,MoneyBox);
    	//TextDrawShowForPlayer(playerid,pText[6][playerid]);
	}
	if((oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) && (newstate != PLAYER_STATE_DRIVER && newstate != PLAYER_STATE_PASSENGER))
	{
	    v_AmtInside[PlayerVehicleID[playerid]]--;
	    UpdateSingleVehicleInfo(PlayerVehicleID[playerid]);
	    TD_HideVehTexts(playerid,playerid);
	    ffTeam[playerid] = gTeam[playerid];
	    if(Current != -1 && ModeType == BASE && Playing[playerid] == true && oldstate == PLAYER_STATE_DRIVER)
		{
			Team_FriendlyFix();
		}
		foreach(Player,i)
		{
		    if(Chase_ChaseID[i] == playerid)SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i,false,false);
	    	if(gSpectateID[i] == playerid)
			{
	        	TogglePlayerSpectating(i,1);
	        	PlayerSpectatePlayer(i,playerid);
	        	gSpectateType[i] = SPECTATE_TYPE_PLAYER;
	        	TD_HideVehTexts(playerid,i);
			}
		}
		if(v_InRound[PlayerVehicleID[playerid]] == true && TeamStatus[gTeam[playerid]] == ATTACKING)
		{
			UnlockVehicle(PlayerVehicleID[playerid]);
			SetTimerEx("AutoLockVehicle",5000,0,"i",PlayerVehicleID[playerid]);
 		}
 		PlayerVehicleID[playerid] = -1;
	    InVehicle[playerid] = -1;
	}
	else if((newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && gSpectating[playerid] == false)
	{
	    PlayerVehicleID[playerid] = GetPlayerVehicleID(playerid);
	    v_AmtInside[PlayerVehicleID[playerid]]++;
	    UpdateSingleVehicleInfo(PlayerVehicleID[playerid]);
	    new model = GetVehicleModel(PlayerVehicleID[playerid]);
	    if(newstate == PLAYER_STATE_DRIVER)
	    {
            new Float:vHP;GetVehicleHealth(PlayerVehicleID[playerid],vHP);
            if(vHP > 250)
            {
 				if(Current != -1 && Playing[playerid] == true && ModeType == BASE)
				{
 					if(gTeam[playerid] == T_HOME)ffTeam[playerid] = T_AWAY;
 					else ffTeam[playerid] = T_HOME;
					Team_FriendlyFix();
				}
				if(IsNosCompatible(GetVehicleModel(PlayerVehicleID[playerid])) == 1)
				{
					AddVehicleComponent(PlayerVehicleID[playerid],1010);
					AddWheelsToVehicle(playerid,PlayerVehicleID[playerid],Wheels[playerid]);
				}
			}
		}
		switch(model)
		{
	   		case 424,430,446,448,452,453,454,457,461,462,463,468,471,472,473,481,485,486,493,509,510,521,522,523,530,568,571,572,574,586,595,606,607,608,609,610,611: InVehicle[playerid] = -1;//these are open vehicles, so we show nametags
	    	default: InVehicle[playerid] = PlayerVehicleID[playerid];//covered vehicle, don't show nametags
		}
		TD_ShowVehTexts(playerid,playerid);
		foreach(Player,x)
		{
		    if(Chase_ChaseID[x] == playerid)SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),x,true,false);
	    	if(gSpectateID[x] == playerid)
			{
	        	TogglePlayerSpectating(x,1);
	        	PlayerSpectateVehicle(x,PlayerVehicleID[playerid]);
	        	gSpectateType[x] = SPECTATE_TYPE_VEHICLE;
	        	TD_ShowVehTexts(playerid,x);
			}
		}
		if(oldstate != PLAYER_STATE_DRIVER)
		{
		    if(v_InRound[PlayerVehicleID[playerid]] == true && TeamStatus[gTeam[playerid]] == ATTACKING)
    		{
        		UnlockVehicle(PlayerVehicleID[playerid]);
        		SetTimerEx("AutoLockVehicle",5000,0,"i",PlayerVehicleID[playerid]);
    	    }
		}
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid)
{
	if(v_Locked[vehicleid] == true && Playing[playerid] == true && TeamStatus[gTeam[playerid]] == DEFENDING)
	{
		new Float:posi[3];
		GetPlayerPos(playerid,posi[0],posi[1],posi[2]);
		SetPlayerPos(playerid,posi[0],posi[1],posi[2]);
	}
	return 1;
}

/*public OnPlayerExitVehicle(playerid, vehicleid)
{

	return 1;
}*/

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//spectate related

forward Spectate_Start(playerid,specid);
public Spectate_Start(playerid,specid)
{
    //TextDrawHideForPlayer(playerid,MoneyBox);
    //TextDrawHideForPlayer(playerid,pText[6][playerid]);
    //FunctionLog("Spectate_Start");
    if(IsPlayerConnected(gSpectateID[playerid]))//hide their old spectate textdraws if they were already spectating
	{
		SetTimerEx("Spectate_WhoIsWatchingMe",5,0,"i",gSpectateID[playerid]);
	    ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],true);
	    Spectate_HideTextDraw(playerid,gSpectateID[playerid]);
	}
	else //we don't need to show the black bars again if they are already showing
	{
  		TD_ShowPanoForPlayer(playerid);
	}
	
    ShowPlayerNameTagForPlayer(playerid,specid,0);
    SetSpectatorWeatherAndTime(playerid,specid);
    TextDrawColor(pText[1][specid],CurrentColor[specid] | 255);
    TD_ShowpTextForPlayer(playerid,specid,14);
    TD_ShowpTextForPlayer(playerid,specid,1);
    TD_ShowpTextForPlayer(playerid,specid,13);
    
	if(IsPlayerInAnyVehicle(specid))
	{
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specid));
		gSpectateType[playerid] = SPECTATE_TYPE_VEHICLE;
		TD_ShowpTextForPlayer(playerid,specid,8);
		TD_ShowpTextForPlayer(playerid,specid,9);
		TD_ShowpTextForPlayer(playerid,specid,10);
		TD_ShowpTextForPlayer(playerid,specid,11);
		TD_ShowpTextForPlayer(playerid,specid,12);
	}
	else
	{
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectatePlayer(playerid, specid);
		gSpectateType[playerid] = SPECTATE_TYPE_PLAYER;
	}
	gSpectateID[playerid] = specid;
	if(IsDueling[specid] == true)Duel_CreatePlayerArena(playerid,specid);
	SetPlayerInterior(playerid,GetPlayerInterior(specid));
	SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(specid));
	gSpectating[playerid] = true;
	Spectate_Update(playerid);
	Spectate_WhoIsWatchingMe(gSpectateID[playerid]);
	return 1;
}

Spectate_Update(playerid)
{
    //FunctionLogEx("Spectate_Update");
    new Float:Armor,Float:Health,string[200];
    GetPlayerHealth(gSpectateID[playerid],Health);
    GetPlayerArmour(gSpectateID[playerid],Armor);
    if(Playing[gSpectateID[playerid]] == true)
    {
        new Float:ratio,Float:killz,Float:deathz;killz = TempKills[gSpectateID[playerid]];deathz = TempDeaths[gSpectateID[playerid]];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
		format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~w~Kills: ~b~%d  ~w~Deaths: ~b~%d  ~w~Ratio: ~b~%.02f ~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[gSpectateID[playerid]],gSpectateID[playerid],TempKills[gSpectateID[playerid]],TempDeaths[gSpectateID[playerid]],ratio,Health,Armor);
		TextDrawSetString(pText[1][gSpectateID[playerid]],string);
		string = " ";
		GetPlayerWeapons(gSpectateID[playerid]);
		for(new x = 1; x < MAX_SLOTS; x++)
		{
			if(TempGuns[gSpectateID[playerid]][x][GUN] > 0 && TempGuns[gSpectateID[playerid]][x][AMMO] > 0)
			{
				format(string,sizeof(string),"%s~n~%s (%d)",string,WeaponNames[TempGuns[gSpectateID[playerid]][x][GUN]],TempGuns[gSpectateID[playerid]][x][AMMO]);
			}
		}
		TextDrawSetString(pText[13][gSpectateID[playerid]],string);
		SetSpectatorWeatherAndTime(playerid,gSpectateID[playerid]);
	}
	else
	{
		format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[gSpectateID[playerid]],gSpectateID[playerid],Health,Armor);
		TextDrawSetString(pText[1][gSpectateID[playerid]],string);
		string = " ";
		GetPlayerWeapons(gSpectateID[playerid]);
		for(new x = 1; x < MAX_SLOTS; x++)
		{
			if(TempGuns[gSpectateID[playerid]][x][GUN] > 0 && TempGuns[gSpectateID[playerid]][x][AMMO] > 0)
			{
				format(string,sizeof(string),"%s~n~%s (%d)",string,WeaponNames[TempGuns[gSpectateID[playerid]][x][GUN]],TempGuns[gSpectateID[playerid]][x][AMMO]);
			}
		}
		TextDrawSetString(pText[13][gSpectateID[playerid]],string);
		SetSpectatorWeatherAndTime(playerid,gSpectateID[playerid]);
	}
}

forward Spectate_Stop(playerid);
public Spectate_Stop(playerid)
{
    //FunctionLog("Spectate_Stop");
    if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)return 1;
    if(IsDueling[gSpectateID[playerid]] == true)Duel_DestroyPlayerArena(playerid);
	SetTimerEx("Spectate_WhoIsWatchingMe",5,0,"i",gSpectateID[playerid]);
    FindPlayerSpawn(playerid,1);
    ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],true);
    TD_HidePanoForPlayer(playerid);
 	Spectate_HideTextDraw(playerid,gSpectateID[playerid]);
	TogglePlayerSpectating(playerid,0);
	gSpectateType[playerid] = SPECTATE_TYPE_NONE;
	gSpectating[playerid] = false;
	gSpectateID[playerid] = -1;
	return 1;
}

forward Spectate_UpdatePlayerAmmo();
public Spectate_UpdatePlayerAmmo()
{
	if(Players < 2)return 1;
	//FunctionLogEx("Spectate_UpdatePlayerAmmo");
	new string[256];
	foreach(Player,i)
	{
	    if(gPlayerSpawned[i] == true && AmtSpectating[i] > 0)
	    {
	        string = " ";
			GetPlayerWeapons(i);
			for(new x = 1; x < MAX_SLOTS; x++)
			{
				if(TempGuns[i][x][GUN] > 0 && TempGuns[i][x][AMMO] > 0)
				{
					format(string,sizeof(string),"%s~n~%s (%d)",string,WeaponNames[TempGuns[i][x][GUN]],TempGuns[i][x][AMMO]);
				}
			}
			TextDrawSetString(pText[13][i],string);
		}
	}
	return 1;
}

Spectate_Advance(playerid)
{
    //FunctionLog("Spectate_Advance");
    if(Players <= 2)return 1;
	if(gSpectating[playerid] == true)
	{
	    new id = gSpectateID[playerid];
	    if(id == HighestID)id = -1;
	    for(new x = id+1; x <= HighestID; x++)
		{
		    if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true){continue;}
			if(x > HighestID)
			{
			    if(playerid == 0)x = 1;
				else x = 0;
			}
			if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true){continue;}
			ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],true);
			Spectate_HideTextDraw(playerid,gSpectateID[playerid]);
			Spectate_Start(playerid, x);
			break;
		}
	}
	return 1;
}

Spectate_Reverse(playerid)
{
    //FunctionLog("Spectate_Reverse");
    if(Players <= 2)return 1;
	if(gSpectating[playerid] == true)
	{
	    new id = gSpectateID[playerid];
	    if(gSpectateID[playerid] == 0)id = HighestID+1;
	    for(new x = id-1; x > -1; x--)
		{
		    if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true){continue;}
	    	if(x < 0)
			{
				if(playerid == HighestID)x = HighestID-1;
				else x = HighestID;
			}
	    	if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true){continue;}
			ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],true);
			Spectate_HideTextDraw(playerid,gSpectateID[playerid]);
			Spectate_Start(playerid, x);
			break;
		}
	}
	return 1;
}

Spectate_AdvanceTeam(playerid)
{
    //FunctionLog("Spectate_AdvanceTeam");
    if(CurrentPlayers[sTeam[playerid]] <= 2)return 1;
    if(Current != -1 && TeamCurrentPlayers[gTeam[playerid]] < 2)
	{
		Spectate_Stop(playerid);
		return 0;
	}
	if(gSpectating[playerid] == true)
	{
	    new id = gSpectateID[playerid];
	    if(gSpectateID[playerid] == HighestID)id = -1;
	    for(new x = id+1; x <= HighestID; x++)
		{
		    if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true || gTeam[x] != gTeam[playerid]){continue;}
	    	if(x > HighestID)
			{
                if(playerid == 0)x = 1;
				else x = 0;
			}
	    	if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true || gTeam[x] != gTeam[playerid]){continue;}
			ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],true);
			Spectate_HideTextDraw(playerid,gSpectateID[playerid]);
			Spectate_Start(playerid,x);
			break;
		}
	}
	return 1;
}

Spectate_ReverseTeam(playerid)
{
    //FunctionLog("Spectate_ReverseTeam");
    if(CurrentPlayers[sTeam[playerid]] <= 2)return 1;
    if(Current != -1 && TeamCurrentPlayers[gTeam[playerid]] < 2)
	{
		Spectate_Stop(playerid);
		return 0;
	}
	if(gSpectating[playerid] == true)
	{
	    new id = gSpectateID[playerid];
	    if(gSpectateID[playerid] == 0)id = HighestID+1;
	    for(new x = id-1; x > -1; x--)
		{
		    if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true || gTeam[x] != gTeam[playerid]){continue;}
	    	if(x < 0)
			{
				if(playerid == HighestID)x = HighestID-1;
				else x = HighestID;
			}
			if(x == playerid || !IsPlayerConnected(x) || gPlayerSpawned[x] == false || gSpectating[x] == true || gTeam[x] != gTeam[playerid]){continue;}
			ShowPlayerNameTagForPlayer(playerid,gSpectateID[playerid],1);
			Spectate_HideTextDraw(playerid,gSpectateID[playerid]);
			Spectate_Start(playerid, x);
			break;
		}
	}
	return 1;
}

forward Spectate_WhoIsWatchingMe(playerid);
public Spectate_WhoIsWatchingMe(playerid)
{
	//FunctionLog("Spectate_WhoIsWatchingMe");
	new string[256] = "Spectating You",amount;
    AmtSpectating[playerid] = 0;
    foreach(Player,x)
	{
	    if(gSpectateID[x] == playerid)
	    {
	        AmtSpectating[playerid]++;
	        if(!IsPlayerAdmin(x))
	        {
			    amount++;
				format(string,sizeof(string),"%s~n~~b~~h~%s (%d)",string,NickName[x],x);
			}
	    }
	}
	if(amount > 0)
	{
		TextDrawSetString(pText[15][playerid],string);
		TD_ShowpTextForPlayer(playerid,playerid,15);
	}
	else
	{
	    TextDrawSetString(pText[15][playerid]," ");
		TD_HidepTextForPlayer(playerid,playerid,15);
	}
	return 1;
}

forward Spectate_QuickStart(playerid,oldspecid,newspecid);
public Spectate_QuickStart(playerid,oldspecid,newspecid)
{
    //FunctionLog("Spectate_QuickStart");
	ShowPlayerNameTagForPlayer(playerid,oldspecid,true);
	Spectate_HideTextDraw(playerid,oldspecid);
	Spectate_Start(playerid,newspecid);
}

Spectate_HideTextDraw(playerid,specid)
{
    //FunctionLog("Spectate_HideTextDraw");
    TD_HidepTextForPlayer(playerid,specid,1);
    TD_HidepTextForPlayer(playerid,specid,8);
    TD_HidepTextForPlayer(playerid,specid,9);
    TD_HidepTextForPlayer(playerid,specid,10);
    TD_HidepTextForPlayer(playerid,specid,11);
    TD_HidepTextForPlayer(playerid,specid,12);
    TD_HidepTextForPlayer(playerid,specid,13);
    TD_HidepTextForPlayer(playerid,specid,14);
}

forward Spectate_ReSpecPlayer(playerid,specid);
public Spectate_ReSpecPlayer(playerid,specid)
{
    //FunctionLog("Spectate_ReSpecPlayer");
    TogglePlayerSpectating(playerid,1);
	PlayerSpectatePlayer(playerid,specid);
	return 1;
}

forward Spectate_StartPlayerTeamSpec(playerid);
public Spectate_StartPlayerTeamSpec(playerid)
{
	if(AutoTeamSpec == false || Current == -1)return 1;
	if(TeamCurrentPlayers[gTeam[playerid]] < 1)return 1;
	if(ModeType == TDM)return 1;
	//FunctionLog("Spectate_StartPlayerTeamSpec");
	if(gPlayerSpawned[playerid] == false)
	{
		foreach(Player,i)
		{
		    if(Playing[i] == true && gTeam[i] == gTeam[playerid] && i != playerid)
		    {
		        Spectate_Start(playerid,i);
		        gPlayerSpawned[playerid] = true;
    			PlayerPlaySound(playerid,death+1,0.0,0.0,0.0);
    			//TextDrawHideForPlayer(playerid,MainText[4]);
		        SetTimerEx("TD_ShowPanoForPlayer",75,0,"i",playerid);
		        break;
		    }
		}
	}
	return 1;
}

//end spectate functions
//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Duels

forward Duel_Initiate(player1,player2,time);
public Duel_Initiate(player1,player2,time)
{
    //FunctionLog("Duel_Initiate");
	new count;
	count = time;
	count = count - 1;
	new string[128];
	format(string,STR,"~n~~n~~n~~n~~n~Starting in~r~... ~r~ %d  ~y~...",count);
	GameTextForPlayer(player1,string,1200,3);
	GameTextForPlayer(player2,string,1200,3);
	if(count <= 0)
	{
	    if(!IsPlayerConnected(player1) || !IsPlayerConnected(player2)) return 1;
	    
		PlayerPlaySound(player1,1057,0.0,0.0,0.0);
		TogglePlayerControllable(player1,1);
		GameTextForPlayer(player1,"~r~FIGHT!",3000,3);
		GivePlayerWeapon(player1,DuelWeapon[player1][0],9900);
		GivePlayerWeapon(player1,DuelWeapon[player1][1],9900);
		IsDueling[player1] = true;
		DuelInvitation[player1] = player2;
		ViewingResults[player1] = false;
		DuelStarting[player1] = false;
		
		PlayerPlaySound(player2,1057,0.0,0.0,0.0);
		TogglePlayerControllable(player2,1);
		GameTextForPlayer(player2,"~r~FIGHT!",3000,3);
		GivePlayerWeapon(player2,DuelWeapon[player1][0],9900);
		GivePlayerWeapon(player2,DuelWeapon[player1][1],9900);
		IsDueling[player2] = true;
		DuelInvitation[player2] = player1;
  		ViewingResults[player2] = false;
  		DuelStarting[player2] = false;
		
		RespawnPlayerAtPos(player1,2);
		RespawnPlayerAtPos(player2,2);
		
		ShowPlayerNameTagForPlayer(player1,player2,1);
		ShowPlayerNameTagForPlayer(player2,player1,1);
	}
	else SetTimerEx("Duel_Initiate",1000,0,"iiii",player1,player2,count);
	return 1;
}

forward Duel_EndWait(player1,player2);
public Duel_EndWait(player1,player2)
{
    //FunctionLog("Duel_EndWait");
	if(IsDueling[player1] == false)
	{
	    SendClientMessage(player1,MainColors[2],"* DUEL * invitation expired.");
	    DuelInvitation[player1] = -1;
		DuelWaiting[player1] = false;
	}
	if(IsDueling[player2] == false)
	{
	    SendClientMessage(player2,MainColors[2],"* DUEL * invitation expired.");
	    DuelInvitation[player2] = -1;
		DuelWaiting[player2] = false;
	}
}

forward Duel_End(winner,loser,reason);
public Duel_End(winner,loser,reason)
{
    //FunctionLog("Duel_End");
    DuelStarting[winner] = false;
    IsDueling[winner] = false;
	NoCmds[winner] = false;
	DuelInvitation[winner] = -1;
	ViewingResults[winner] = false;
	DuelWorld[winner] = 0;
	ResetPlayerHealth(winner);
	ResetPlayerArmor(winner);
	FindPlayerSpawn(winner,1);
	SpawnAtPlayerPosition[winner] = 0;
	SpawnPlayer(winner);
	Duel_DestroyPlayerArena(winner);

	if(IsPlayerConnected(loser))
	{
	    DuelStarting[loser] = false;
    	IsDueling[loser] = false;
		NoCmds[loser] = false;
		DuelInvitation[loser] = -1;
		ViewingResults[loser] = false;
		DuelWorld[loser] = 0;
		ResetPlayerHealth(loser);
		ResetPlayerArmor(loser);
		FindPlayerSpawn(loser,1);
		SpawnAtPlayerPosition[loser] = 0;
		SpawnPlayer(loser);
        Duel_DestroyPlayerArena(loser);
	}

	new hour,minute,second,time[4],time_str[32];
	gettime(hour,minute,second);
	if(hour > 12){hour = hour-12;time = "PM";}else time = "AM";
	format(time_str,32,"\r\n[%2d:%2d:%2d %s]",hour,minute,second,time);
	
	new string[128],File:aFile,winnerfile[64],loserfile[64];
	format(winnerfile,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[winner]);
	format(loserfile,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[loser]);
	
	if(reason == 0)//loser disconnected
	{
	    format(string,sizeof(string),"* DUEL * ...  \"%s\"  %s  \"%s\" ... (disconnected)  (%s & %s)",RealName[winner],DeathWords[random(DEATH_WORD_SIZE)],RealName[loser],RealName[loser],WeaponNames[DuelWeapon[winner][0]],WeaponNames[DuelWeapon[winner][1]]);
		SendClientMessageToAll(MainColors[4],string);
		aFile = fopen(DuelFile(), io_append);fwrite(aFile,"\r\n");fwrite(aFile, string);fclose(aFile);
		format(string,128,"WD_%s",RealName[loser]);dini_IntSet(winnerfile,string,dini_Int(winnerfile,string) + 1);dini_IntSet(loserfile,"DuelLosses",dini_Int(loserfile,"DuelLosses") + 1);
		format(string,128,"LD_%s",RealName[winner]);dini_IntSet(loserfile,string,dini_Int(loserfile,string) + 1);dini_IntSet(winnerfile,"DuelWins",dini_Int(winnerfile,"DuelWins") + 1);
		
	}
	else if(reason == 1)//winner killed loser
	{
	    new Float:H,Float:A;GetPlayerHealth(winner,H);GetPlayerArmour(winner,A);
	    format(string,sizeof(string),"* DUEL * ...  \"%s\"  %s  \"%s\" ... (%.0f HP)  (%s & %s)",RealName[winner],DeathWords[random(DEATH_WORD_SIZE)],RealName[loser],H+A,WeaponNames[DuelWeapon[winner][0]],WeaponNames[DuelWeapon[winner][1]]);
		SendClientMessageToAll(MainColors[4],string);
		aFile = fopen(DuelFile(), io_append);fwrite(aFile,time_str);fwrite(aFile, string);fclose(aFile);
		format(string,128,"WD_%s",RealName[loser]);dini_IntSet(winnerfile,string,dini_Int(winnerfile,string) + 1);dini_IntSet(loserfile,"DuelLosses",dini_Int(loserfile,"DuelLosses") + 1);
		format(string,128,"LD_%s",RealName[winner]);dini_IntSet(loserfile,string,dini_Int(loserfile,string) + 1);dini_IntSet(winnerfile,"DuelWins",dini_Int(winnerfile,"DuelWins") + 1);
	}
	else if(reason == 2)//forfeit
	{
	    format(string,sizeof(string),"* DUEL * ... \"%s\" vs \"%s\" ended ... (%s forfeited)  (%s & %s)",RealName[winner],RealName[loser],RealName[loser],WeaponNames[DuelWeapon[winner][0]],WeaponNames[DuelWeapon[winner][1]]);
		SendClientMessageToAll(MainColors[4],string);
		aFile = fopen(DuelFile(), io_append);fwrite(aFile,time_str);fwrite(aFile, string);fclose(aFile);
		format(string,128,"WD_%s",RealName[loser]);dini_IntSet(winnerfile,string,dini_Int(winnerfile,string) + 1);dini_IntSet(loserfile,"DuelLosses",dini_Int(loserfile,"DuelLosses") + 1);
		format(string,128,"LD_%s",RealName[winner]);dini_IntSet(loserfile,string,dini_Int(loserfile,string) + 1);dini_IntSet(winnerfile,"DuelWins",dini_Int(winnerfile,"DuelWins") + 1);
	}
	else//other reason
	{
	    format(string,sizeof(string),"* DUEL * ... \"%s\" vs \"%s\" ended ... (interference)  (%s & %s)",RealName[winner],RealName[loser],WeaponNames[DuelWeapon[winner][0]],WeaponNames[DuelWeapon[winner][1]]);
		SendClientMessageToAll(MainColors[4],string);
		aFile = fopen(DuelFile(), io_append);fwrite(aFile,time_str);fwrite(aFile, string);fclose(aFile);
	}
	foreach(Player,i)
	{
		if(DuelSpectating[i] == winner || DuelSpectating[i] == loser)
		{
			Duel_DestroyPlayerArena(i);
        	ShowPlayerNameTagForPlayer(winner,i,1);
    		ShowPlayerNameTagForPlayer(loser,i,1);
	    	DuelSpectating[i] = -1;
	    	FindPlayerSpawn(i,1);
	    	ResetPlayerHealth(i);
	    	SpawnPlayer(i);
		}
		else if(gSpectateID[i] == winner || gSpectateID[i] == loser)Duel_DestroyPlayerArena(i);
	}
	return 1;
}

Duel_RandomizeSigns(playerid)
{
    for(new i; i < 97; i++)
	{
	    DuelPlayerSign[playerid][i] = random(10);
	}
	return 1;
}

forward Duel_CreatePlayerArena(playerid,num);
public Duel_CreatePlayerArena(playerid,num)
{
    //FunctionLog("Duel_CreatePlayerArena");
	if(DuelArenaCreated[playerid] == false)
	{
	
	    for(new i; i < 12; i++)
		{
		    pDuelObj[playerid][i] = CreatePlayerObject(playerid,floatround(DuelObj[i][0]),DuelObj[i][1],DuelObj[i][2],DuelObj[i][3],DuelObj[i][4],DuelObj[i][5],DuelObj[i][6]);
		}
		for(new i; i < 97; i++)
		{
		    pDuelObj[playerid][i+12] = CreatePlayerObject(playerid,DuelBillboards[DuelPlayerSign[num][i]],DuelDynamicObj[i][0],DuelDynamicObj[i][1],DuelDynamicObj[i][2],DuelDynamicObj[i][3],DuelDynamicObj[i][4],DuelDynamicObj[i][5]);
		}
		DuelArenaCreated[playerid] = true;
	}
	return 1;
}

Duel_DestroyPlayerArena(playerid)
{
    //FunctionLog("Duel_DestroyPlayerArena");
    if(DuelArenaCreated[playerid] == true)
	{
    	for(new i; i < 109; i++)
		{
			DestroyPlayerObject(playerid,pDuelObj[playerid][i]);
		}
		DuelArenaCreated[playerid] = false;
	}
	return 1;
}

Duel_ShowStats(playerid,pname[])
{
    //FunctionLog("Duel_ShowStats");
	new file[64],string[128],Float:Wins,Float:Losses,Float:ratio;
	format(file,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(pname));
	Wins = dini_Int(file,"DuelWins");
	Losses = dini_Int(file,"DuelLosses");
	ratio = Wins / Losses;
	format(string,128,"*** %s: Duel Wins: %.0f  |  Duel Losses: %.0f  |  Ratio: %.2f",pname,Wins,Losses,ratio);
	SendClientMessage(playerid,MainColors[3],string);
	return 1;
}

Duel_ShowPvPStats(playerid,p1[],p2[])
{
    //FunctionLog("Duel_ShowPvPStats");
	new file[64],string[128],pName[32],Float:Wins,Float:Losses,Float:ratio;
	format(file,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(p1));

	format(pName,32,"WD_%s",p2);Wins = dini_Int(file,pName);
	format(pName,32,"LD_%s",p2);Losses = dini_Int(file,pName);
	ratio = Wins / Losses;
    format(string,128,"***  [DUEL]  %s beat %s %.0f times  //  %s was beat by %s %.0f times  //  Ratio: %.2f",p1,p2,Wins,p1,p2,Losses,ratio);
	SendClientMessage(playerid,MainColors[3],string);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Misc Functions

DenyPlayer(playerid){/*FunctionLogEx("DenyPlayer");*/PlayerPlaySound(playerid,denied,0.0,0.0,0.0);return SendClientMessage(playerid,MainColors[2],"You need to be admin to do that!");}
Basefile(baseid){/*FunctionLogEx("Basefile");*/new string[32];format(string,sizeof(string),"/attackdefend/%d/bases/%d.ini",GameMap,baseid);return string;}
Arenafile(arenaid){/*FunctionLogEx("Arenafile");*/new string[32];format(string,sizeof(string),"/attackdefend/%d/arenas/%d.ini",GameMap,arenaid);return string;}
//DMZfile(dmzid){/*FunctionLogEx("DMZfile");*/new string[32];format(string,sizeof(string),"/attackdefend/%d/dmzones/%d.ini",GameMap,dmzid);return string;}
//Telefile(teleid){/*FunctionLogEx("Telefile");*/new string[32];format(string,sizeof(string),"/attackdefend/%d/teleports/%d.ini",GameMap,teleid);return string;}
CBfile(cid){/*FunctionLogEx("CBfile");*/new string[64];format(string,sizeof(string),"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,cid);return string;}
CAfile(cid){/*FunctionLogEx("CAfile");*/new string[64];format(string,sizeof(string),"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,cid);return string;}
CPfile(cid){/*FunctionLogEx("CPfile");*/new string[64];format(string,sizeof(string),"/attackdefend/%d/config/playerconfig/%d.ini",GameMap,cid);return string;}
ServerFile(){new string[45];format(string,sizeof(string),"/attackdefend/%d/config/serverstats.ini",GameMap);return string;}
gConfigFile(){new string[45];format(string,sizeof(string),"/attackdefend/%d/config/gameconfig.ini",GameMap);return string;}
VehicleFile(){new string[45];format(string,sizeof(string),"/attackdefend/%d/config/vehconfig.ini",GameMap);return string;}
ResultsFile(){new string[55],y,m,d;getdate(y,m,d);format(string,sizeof(string),"/attackdefend/%d/results/%d.%d.%d.ini",GameMap,d,m,y);return string;}
DuelFile(){new string[64],y,m,d;getdate(y,m,d);format(string,sizeof(string),"/attackdefend/%d/results/duels/%d.%d.%d.ini",GameMap,d,m,y);return string;}

/*forward PRT();
public PRT()
{
    new string[64];//,PASS[20];//GetServerVarAsString("password",PASS,sizeof(PASS));
    SetGameModeText(GM_VERSION);
    //SendRconCommand("weburl www.99blazed.com");
    //format(string,64,"worldtime www.99blazed.com                    %s",PASS);SendRconCommand(string);

    if(GameMap == 0) format(string,sizeof(string),"hostname  »»»»»»»  GTA:SA WC - %s  «««««««",HostTag);
    else format(string,sizeof(string),"hostname          »»» GTA:U WC - %s «««",HostTag);
  	SendRconCommand(string);
  	return 1;
}*/

PlayPlayerExplosion(playerid){PlayerPlaySound(playerid, 1159, sScreenSA[cSelect[playerid]][s_cx] - 10 + random(10 * 2), sScreenSA[cSelect[playerid]][s_cy] - 10 + random(10 * 2), sScreenSA[cSelect[playerid]][s_cz]);}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================
//Menus / Menu Functions
WeaponSelection(playerid)
{
    //FunctionLog("WeaponSelection");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    if(GunsOfTypeUsed(1) == 0){WeaponSelectionII(playerid);return 1;}
    new string[47][32],wname[32];
    CurrentMenu[playerid] = 1;
	GunMenu[playerid] = CreateMenu("~b~Set One", 1, 20, 120, 190);
	new Float:percent_used,row;
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(GunUsed[i][MODE] == 1 || GunUsed[i][MODE] == 9 || GunUsed[i][MODE] == 5 || GunUsed[i][MODE] == 3)
		{
		    percent_used = Float:PercentWithWeapon(playerid,i,MODE);
			wname = WeaponNames[i];format(string[i],sizeof(string[]),"~>~ %s ~b~x%d",wname,GunAmmo[i][MODE]);AddMenuItem(GunMenu[playerid], 0, string[i]);
			if(GunLimit[i][MODE] != 0 && percent_used > GunLimit[i][MODE]+0.01)DisableMenuRow(GunMenu[playerid],row);
			row++;
		}
	}
	AddMenuItem(GunMenu[playerid], 0, "Next ~b~>");
	IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	TD_ShowpTextForPlayer(playerid,playerid,2);
	UpdateMenuText(playerid);
	TD_ShowMainTextForPlayer(playerid,13);
	return 1;
}

WeaponSelectionII(playerid)
{
    //FunctionLog("WeaponSelectionII");
	new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    if(GunsOfTypeUsed(2) == 0){WeaponSelectionIII(playerid);return 1;}
    new stringS[47][32],wname[32];
    CurrentMenu[playerid] = 2;
    if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~g~~h~Set Two", 1, 20, 120, 190);
	new Float:percent_used,row;
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
	    if(GunUsed[i][MODE] == 2 || GunUsed[i][MODE] == 10 || GunUsed[i][MODE] == 6 || GunUsed[i][MODE] == 3)
		{
		    percent_used = Float:PercentWithWeapon(playerid,i,MODE);
			wname = WeaponNames[i];format(stringS[i],sizeof(stringS[]),"~>~ %s ~g~~h~x%d",wname,GunAmmo[i][MODE]);AddMenuItem(GunMenu[playerid], 0, stringS[i]);
			if(GunLimit[i][MODE] != 0 && percent_used > GunLimit[i][MODE]+0.01)DisableMenuRow(GunMenu[playerid],row);
			row++;
		}
	}
	AddMenuItem(GunMenu[playerid], 0, "Next ~b~>");
	AddMenuItem(GunMenu[playerid], 0, "Back ~r~<");
	IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	UpdateMenuText(playerid);
	return 1;
}

WeaponSelectionIII(playerid)
{
    //FunctionLog("WeaponSelectionIII");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    if(GunsOfTypeUsed(4) == 0){WeaponSelectionIV(playerid);return 1;}
    new string[47][32],wname[32];
	CurrentMenu[playerid] = 3;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~r~~h~~h~~h~Set Three", 1, 20, 120, 190);
	new Float:percent_used,row;
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
	    if(GunUsed[i][MODE] == 4 || GunUsed[i][MODE] == 12 || GunUsed[i][MODE] == 6 || GunUsed[i][MODE] == 5)
		{
		    percent_used = Float:PercentWithWeapon(playerid,i,MODE);
			wname = WeaponNames[i];format(string[i],sizeof(string[]),"~>~ %s ~r~~h~~h~x%d",wname,GunAmmo[i][MODE]);AddMenuItem(GunMenu[playerid], 0, string[i]);
			if(GunLimit[i][MODE] != 0 && percent_used > GunLimit[i][MODE]+0.01)DisableMenuRow(GunMenu[playerid],row);
			row++;
		}
	}
	AddMenuItem(GunMenu[playerid], 0, "Next ~b~>");
	AddMenuItem(GunMenu[playerid], 0, "Back ~r~<");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	UpdateMenuText(playerid);
	return 1;
}

WeaponSelectionIV(playerid)
{
    //FunctionLog("WeaponSelectionIV");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    if(GunsOfTypeUsed(8) == 0){WeaponSelectionV(playerid);return 1;}
    new string[47][32],wname[32];
	CurrentMenu[playerid] = 4;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~r~~h~Set Four", 1, 20, 120, 190);
	new Float:percent_used,row;
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
	    if(GunUsed[i][MODE] == 8 || GunUsed[i][MODE] == 12 || GunUsed[i][MODE] == 10 || GunUsed[i][MODE] == 9)
	    {
	        percent_used = Float:PercentWithWeapon(playerid,i,MODE);
			wname = WeaponNames[i];format(string[i],sizeof(string[]),"~>~ %s ~r~~h~~h~x%d",wname,GunAmmo[i][MODE]);AddMenuItem(GunMenu[playerid], 0, string[i]);
			if(GunLimit[i][MODE] != 0 && percent_used > GunLimit[i][MODE]+0.01)DisableMenuRow(GunMenu[playerid],row);
			row++;
		}
	}
	AddMenuItem(GunMenu[playerid], 0, "Finish ~b~~>~");
	AddMenuItem(GunMenu[playerid], 0, "Back ~r~~<~");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	UpdateMenuText(playerid);
	return 1;
}

WeaponSelectionV(playerid)
{
    //FunctionLog("WeaponSelectionV");
    if(GunsOfTypeUsed(1) == 0 && GunsOfTypeUsed(2) == 0 && GunsOfTypeUsed(4) == 0 && GunsOfTypeUsed(8) == 0)return 1;
	CurrentMenu[playerid] = 5;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~p~Confirm Setup", 1, 20, 120, 240);
	AddMenuItem(GunMenu[playerid], 0, "No, ~r~Let me start over");
	AddMenuItem(GunMenu[playerid], 0, "Yes, ~g~I am finished");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	UpdateMenuText(playerid);
	return 1;
}

EditArena(playerid)
{
    //FunctionLog("EditArena");
	CurrentMenu[playerid] = 12;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~g~Options", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid], 0, "Team 0 Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Team 1 Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Team 2 Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Team 3 Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Team 4 Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Team 5 Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Middle (top view)");
	AddMenuItem(GunMenu[playerid], 0, "X-Max");
	AddMenuItem(GunMenu[playerid], 0, "X-Min");
	AddMenuItem(GunMenu[playerid], 0, "Interior");
	AddMenuItem(GunMenu[playerid], 0, "Reset Zone");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

EditBase(playerid)
{
    //FunctionLog("EditBase");
	CurrentMenu[playerid] = 6;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~g~Options", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid], 0, "Attacker Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Defender Spawn");
	AddMenuItem(GunMenu[playerid], 0, "Checkpoint");
	AddMenuItem(GunMenu[playerid], 0, "Interior");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

SelectWeather(playerid)
{
    //FunctionLog("SelectWeather");
	CurrentMenu[playerid] = 7;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~b~Weather", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid], 0, "Sunny");//1
	AddMenuItem(GunMenu[playerid], 0, "Overcast");//12
	AddMenuItem(GunMenu[playerid], 0, "Rain");//16
	AddMenuItem(GunMenu[playerid], 0, "Foggy");//9
	AddMenuItem(GunMenu[playerid], 0, "Sand Storm");//19
	AddMenuItem(GunMenu[playerid], 0, "BACK <<");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

SelectTime(playerid)
{
    //FunctionLog("SelectTime");
	CurrentMenu[playerid] = 8;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~y~Time of Day", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid], 0, "0:00");
	AddMenuItem(GunMenu[playerid], 0, "3:00");
	AddMenuItem(GunMenu[playerid], 0, "6:00");
	AddMenuItem(GunMenu[playerid], 0, "9:00");
	AddMenuItem(GunMenu[playerid], 0, "12:00");
	AddMenuItem(GunMenu[playerid], 0, "15:00");
	AddMenuItem(GunMenu[playerid], 0, "17:00");
	AddMenuItem(GunMenu[playerid], 0, "18:00");
	AddMenuItem(GunMenu[playerid], 0, "21:00");
	AddMenuItem(GunMenu[playerid], 0, "24:00");
	AddMenuItem(GunMenu[playerid], 0, "BACK <<");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

LeaderConfirm(playerid)
{
    //FunctionLog("LeaderConfirm");
	CurrentMenu[playerid] = 9;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~y~Confirm Options", 1, 20, 120, 240);
	AddMenuItem(GunMenu[playerid], 0, "No, ~r~Let me start over");
	AddMenuItem(GunMenu[playerid], 0, "Yes, ~g~I am finished");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

SwitchMenu(playerid)
{
    //FunctionLog("SwitchMenu");
	CurrentMenu[playerid] = 10;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~p~Switch Team", 1, 20, 120, 190);
	for(new i = 0; i < MAX_TEAMS; i++)
	{
	    AddMenuItem(GunMenu[playerid], 0,TeamName[i]);
	    if(TeamUsed[i] == false || TeamLock[i] == true)DisableMenuRow(GunMenu[playerid],i);
	}
	AddMenuItem(GunMenu[playerid], 0, "Cancel");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

forward SubMenu(playerid);
public SubMenu(playerid)
{
    //FunctionLog("SubMenu");
	CurrentMenu[playerid] = 11;
	new string[64];
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~p~Sub Menu", 1, 20, 120, 190);
	for(new i = 0; i < ACTIVE_TEAMS; i++)
	{
	    format(string,sizeof(string),"~>~ %s ~w~- %s",TeamName[T_SUB],TeamName[i]);AddMenuItem(GunMenu[playerid], 0, string);
	    if(TeamUsed[i] == false)DisableMenuRow(GunMenu[playerid],i);
	}
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	TogglePlayerControllable(playerid,0);
	gPlayerSpawned[playerid] = false;
	return 1;
}

GunUsedMenuI(playerid)
{
    //FunctionLog("GunUsedMenuI");
	CurrentMenu[playerid] = 13;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~b~Gun Menu 1", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid], 0, "Set One");//
	AddMenuItem(GunMenu[playerid], 0, "Set Two");//
	AddMenuItem(GunMenu[playerid], 0, "Set Three");//
	AddMenuItem(GunMenu[playerid], 0, "Set Four");//
	AddMenuItem(GunMenu[playerid], 0, "Given Auto");//
	AddMenuItem(GunMenu[playerid], 0, "Not Used");//
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

GunUsedMenuII(playerid)
{
    //FunctionLog("GunUsedMenuII");
	CurrentMenu[playerid] = 14;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("~g~Gun Menu 2", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid], 0, "Set One");//
	AddMenuItem(GunMenu[playerid], 0, "Set Two");//
	AddMenuItem(GunMenu[playerid], 0, "Set Three");//
	AddMenuItem(GunMenu[playerid], 0, "Set Four");//
	AddMenuItem(GunMenu[playerid], 0, "Not Used Twice");//
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

WheelMenu1(playerid)
{
    //FunctionLog("WheelMenu1");
	CurrentMenu[playerid] = 15;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("Wheels pg1", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid],0,"Offroad");
	AddMenuItem(GunMenu[playerid],0,"Shadow");
	AddMenuItem(GunMenu[playerid],0,"Mega");
	AddMenuItem(GunMenu[playerid],0,"Rimshine");
	AddMenuItem(GunMenu[playerid],0,"Wires");
	AddMenuItem(GunMenu[playerid],0,"Classic");
	AddMenuItem(GunMenu[playerid],0,"Twist");
	AddMenuItem(GunMenu[playerid],0,"Cutter");
	AddMenuItem(GunMenu[playerid],0,"Switch");
	AddMenuItem(GunMenu[playerid],0,"Grove");
	AddMenuItem(GunMenu[playerid],0,"~>~ Next");
	AddMenuItem(GunMenu[playerid],0,"~<~~>~ Cancel");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

WheelMenu2(playerid)
{
    //FunctionLog("WheelMenu2");
	CurrentMenu[playerid] = 16;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("Wheels pg2", 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid],0,"Import");
	AddMenuItem(GunMenu[playerid],0,"Dollar");
	AddMenuItem(GunMenu[playerid],0,"Trance");
	AddMenuItem(GunMenu[playerid],0,"Atomic");
	AddMenuItem(GunMenu[playerid],0,"Ahab");
	AddMenuItem(GunMenu[playerid],0,"Virtual");
	AddMenuItem(GunMenu[playerid],0,"Access");
	AddMenuItem(GunMenu[playerid],0,"Default");
	AddMenuItem(GunMenu[playerid],0,"Random");
	AddMenuItem(GunMenu[playerid],0,"~<~ Back");
	AddMenuItem(GunMenu[playerid],0,"~<~~>~ Cancel");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

WeaponSkillMenu(playerid)
{
    CurrentMenu[playerid] = 17;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("Weapon Skills", 1, 20, 120, 190);
	new string[40];
	for(new i; i < 11; i++)
	{
		format(string,sizeof(string),"%s - ~b~~h~(%d)",WeaponSkills[i][s_Name],WeaponSkills[i][s_Level]);
		AddMenuItem(GunMenu[playerid],0,string);
	}
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

WeaponSkillMenu2(playerid)
{
    CurrentMenu[playerid] = 18;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	new string[30];
	format(string,sizeof(string),"%s (%d)",WeaponSkills[wSkillEdit[playerid]][s_Name],WeaponSkills[wSkillEdit[playerid]][s_Level]);
	GunMenu[playerid] = CreateMenu(string, 1, 20, 120, 190);
	AddMenuItem(GunMenu[playerid],0,"Poor (0)");
	AddMenuItem(GunMenu[playerid],0,"Gangster (200)");
	AddMenuItem(GunMenu[playerid],0,"Hitman (999)");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

PlayerWeaponSkillMenu(playerid)
{
    CurrentMenu[playerid] = 19;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	GunMenu[playerid] = CreateMenu("Your Skills", 1, 20, 120, 190);
	new string[40];
	for(new i; i < 11; i++)
	{
		format(string,sizeof(string),"%s - ~g~~h~(%d)",WeaponSkills[i][s_Name],wSkill[playerid][i]);
		AddMenuItem(GunMenu[playerid],0,string);
	}
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

PlayerWeaponSkillMenu2(playerid)
{
    CurrentMenu[playerid] = 20;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	new string[30];
	format(string,sizeof(string),"%s (%d)",WeaponSkills[wSkillEdit[playerid]][s_Name],WeaponSkills[wSkillEdit[playerid]][s_Level]);
	GunMenu[playerid] = CreateMenu(string, 1, 20, 200, 190);
	AddMenuItem(GunMenu[playerid],0,"Poor (0)");
	AddMenuItem(GunMenu[playerid],0,"Gangster (200)");
	AddMenuItem(GunMenu[playerid],0,"Hitman (999)");
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

PlayerFightingMenu(playerid)
{
    CurrentMenu[playerid] = 21;
	if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	new string[9];
	GunMenu[playerid] = CreateMenu("Fighting Styles", 1, 20, 200, 200);
	for(new i; i < 6; i++)
	{
		format(string,sizeof(string),"%s",FightStyle[i][f_Name]);
		AddMenuItem(GunMenu[playerid],0,string);
		if(pFightStyle[playerid] == FightStyle[i][f_ID])DisableMenuRow(GunMenu[playerid],i);
	}
    IsPlayerInMenu[playerid] = true;
	ShowMenuForPlayer(GunMenu[playerid],playerid);
	return 1;
}

forward Float:PercentWithWeapon(playerid,weapon,MODE);
public Float:PercentWithWeapon(playerid,weapon,MODE)
{
    //FunctionLog("PercentWithWeapon");
    new Float:percent;
    new Float:players_with_gun = float(GetPlayersWithGun(playerid,weapon,MODE));
    if(GunLimit[weapon][MODE] > 5)
	{
		new Float:active_players = float(TeamCurrentPlayers[gTeam[playerid]]);
		percent = players_with_gun / active_players * 100;
		return percent;
	}
	return players_with_gun;
}

GetPlayersWithGun(playerid,weapon,MODE)
{
    //FunctionLog("GetPlayersWithGun");
	new players = 1;
    foreach(Player,i)
	{
		if(i != playerid && gTeam[i] == gTeam[playerid] && Playing[i] == true && (WeaponSet[i][0][MODE] == weapon || WeaponSet[i][1][MODE] == weapon || WeaponSet[i][2][MODE] == weapon || WeaponSet[i][3][MODE] == weapon))
		{
		    players++;
		}
	}
	if(players == 1)return 0;
	return players;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
    //FunctionLog("OnPlayerSelectedMenuRow");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
	new string[128],string2[128],weapname[32],x = 0,Float:percent_used;
	if (CurrentMenu[playerid] == 1)
	{
	    for(new i = 0; i < MAX_WEAPONS; i++)
		{
 			if(GunUsed[i][MODE] == 1 || GunUsed[i][MODE] == 9 || GunUsed[i][MODE] == 5 || GunUsed[i][MODE] == 3)
 			{
   				x++;
				if(row == (x-1))
				{
				    if(GunLimit[i][MODE] != 0)percent_used = Float:PercentWithWeapon(playerid,i,MODE);
					if(GunLimit[i][MODE] != 0 && percent_used >= float(GunLimit[i][MODE])+0.001)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
					    weapname = WeaponNames[i];
						if(GunLimit[i][MODE] > 5)format(string,sizeof(string),"Error: %.0f%%/%d%% of your team is already using %s",percent_used,GunLimit[i][MODE],weapname);
						else format(string,sizeof(string),"Error: %.0f/%d  players on your team are already using %s",percent_used,GunLimit[i][MODE],weapname);
						SendClientMessage(playerid,MainColors[2],string);
						WeaponSelection(playerid);
						return 0;
					}
					else if(SameTypeOfWeapon(playerid,i) == 1)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
						SendClientMessage(playerid,MainColors[2],"Error: You already have a weapon of the same type, please reselect.");
						WeaponSelection(playerid);
						return 0;
					}
					else
					{
					    WeaponSet[playerid][0][MODE] = i;
						WeaponSelectionII(playerid);
						weapname = WeaponNames[WeaponSet[playerid][0][MODE]];
						PlayerPlaySound(playerid,1054,0.0,0.0,0.0);
						UpdateMenuText(playerid);
					}
				}
			}
		}
		if(row == x)WeaponSelectionII(playerid);
	}
	else if (CurrentMenu[playerid] == 2)
	{
		for(new i = 0; i < MAX_WEAPONS; i++)
		{
 			if(GunUsed[i][MODE] == 2 || GunUsed[i][MODE] == 10 || GunUsed[i][MODE] == 6 || GunUsed[i][MODE] == 3)
 			{
   				x++;
				if(row == (x-1))
				{
                    if(GunLimit[i][MODE] != 0)percent_used = Float:PercentWithWeapon(playerid,i,MODE);
				    if(GunLimit[i][MODE] != 0 && percent_used >= float(GunLimit[i][MODE])+0.001)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
					    weapname = WeaponNames[i];
						if(GunLimit[i][MODE] > 5)format(string,sizeof(string),"Error: %.0f%%/%d%% of your team is already using %s",percent_used,GunLimit[i][MODE],weapname);
						else format(string,sizeof(string),"Error: %.0f/%d  players on your team are already using %s",percent_used,GunLimit[i][MODE],weapname);
						SendClientMessage(playerid,MainColors[2],string);
						WeaponSelectionII(playerid);
						return 0;
					}
					else if(SameTypeOfWeapon(playerid,i) == 1)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
						SendClientMessage(playerid,MainColors[2],"Error: You already have a weapon of the same type, please reselect.");
						WeaponSelectionII(playerid);
						return 0;
					}
					else
					{
					    WeaponSet[playerid][1][MODE] = i;
						WeaponSelectionIII(playerid);
						weapname = WeaponNames[WeaponSet[playerid][1][MODE]];
						PlayerPlaySound(playerid,1054,0.0,0.0,0.0);
						UpdateMenuText(playerid);
					}
				}
			}
		}
		if(row == x)WeaponSelectionIII(playerid);
		if(row == x+1){WeaponSet[playerid][0][MODE] = 0;WeaponSelection(playerid);}
	}
	else if (CurrentMenu[playerid] == 3)
	{
		for(new i = 0; i < MAX_WEAPONS; i++)
		{
 			if(GunUsed[i][MODE] == 4 || GunUsed[i][MODE] == 12 || GunUsed[i][MODE] == 6 || GunUsed[i][MODE] == 5)
 			{
   				x++;
				if(row == (x-1))
				{
                    if(GunLimit[i][MODE] != 0)percent_used = Float:PercentWithWeapon(playerid,i,MODE);
				    if(GunLimit[i][MODE] != 0 && percent_used >= float(GunLimit[i][MODE])+0.001)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
					    weapname = WeaponNames[i];
						if(GunLimit[i][MODE] > 5)format(string,sizeof(string),"Error: %.0f%%/%d%% of your team is already using %s",percent_used,GunLimit[i][MODE],weapname);
						else format(string,sizeof(string),"Error: %.0f/%d  players on your team are already using %s",percent_used,GunLimit[i][MODE],weapname);
						SendClientMessage(playerid,MainColors[2],string);
						WeaponSelectionIII(playerid);
						return 0;
					}
					else if(SameTypeOfWeapon(playerid,i) == 1)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
						SendClientMessage(playerid,MainColors[2],"Error: You already have a weapon of the same type, please reselect.");
						WeaponSelectionIII(playerid);
						return 0;
					}
					else
					{
					    WeaponSet[playerid][2][MODE] = i;
						WeaponSelectionIV(playerid);
						weapname = WeaponNames[WeaponSet[playerid][2][MODE]];
						PlayerPlaySound(playerid,1054,0.0,0.0,0.0);
						UpdateMenuText(playerid);
					}
				}
			}
		}
		if(row == x)WeaponSelectionIV(playerid);
		if(row == x+1){WeaponSet[playerid][1][MODE] = 0;WeaponSelectionII(playerid);}
	}
	else if (CurrentMenu[playerid] == 4)
	{
  		for(new i = 0; i < MAX_WEAPONS; i++)
		{
 			if(GunUsed[i][MODE] == 8 || GunUsed[i][MODE] == 12 || GunUsed[i][MODE] == 10 || GunUsed[i][MODE] == 9)
 			{
   				x++;
				if(row == (x-1))
				{
        			percent_used = Float:PercentWithWeapon(playerid,i,MODE);
				    if(GunLimit[i][MODE] != 0 && percent_used >= float(GunLimit[i][MODE])+0.001)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
					    weapname = WeaponNames[i];
						format(string,sizeof(string),"Error: %.0f%%/%d%% of your team is already using %s",percent_used,GunLimit[i][MODE],weapname);
						SendClientMessage(playerid,MainColors[2],string);
						WeaponSelectionIV(playerid);
						return 0;
					}
					else if(SameTypeOfWeapon(playerid,i) == 1)
					{
					    PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
						SendClientMessage(playerid,MainColors[2],"Error: You already have a weapon of the same type, please reselect.");
						WeaponSelectionIV(playerid);
						return 0;
					}
					else
					{
					    WeaponSet[playerid][3][MODE] = i;
						weapname = WeaponNames[WeaponSet[playerid][3][MODE]];
						PlayerPlaySound(playerid,1054,0.0,0.0,0.0);
						WeaponSelectionV(playerid);
						UpdateMenuText(playerid);
					}
				}
			}
		}
		if(row == x)WeaponSelectionV(playerid);
		if(row == x+1){WeaponSet[playerid][3][MODE] = 0;WeaponSelectionIII(playerid);}
	}
	else if (CurrentMenu[playerid] == 5)
	{
		if(row == 0){WeaponSet[playerid][2][MODE] = 0;WeaponSet[playerid][1][MODE] = 0;WeaponSet[playerid][0][MODE] = 0;WeaponSet[playerid][3][MODE] = 0;WeaponSelection(playerid);}
		else if(row == 1)
		{
			if(IsValidMenu(GunMenu[playerid]))
			{
				HideMenuForPlayer(Menu:GunMenu[playerid],playerid);
				DestroyMenu(Menu:GunMenu[playerid]);
			}
			if(GivenMenu[playerid] == true)
			{
			    GivenMenu[playerid] = false;
			    TD_HidepTextForPlayer(playerid,playerid,1);
			    TD_HidepTextForPlayer(playerid,playerid,2);
			    TD_HidepTextForPlayer(playerid,playerid,13);
				TD_HideMainTextForPlayer(playerid,13);
				TD_HidePanoForPlayer(playerid);
				SetPlayerVirtualWorld(playerid,1);
    			TogglePlayerControllable(playerid,1);
    			StrapUp(playerid);
				SetCameraBehindPlayerEx(playerid);
			    return 1;
			}
		    if(TeamStatus[gTeam[playerid]] == DEFENDING && ModeType == BASE)
		    {
		        TD_HidePanoForPlayer(playerid);
				FinishedMenu[playerid] = true;
				ResetPlayerWeapons(playerid);
				HasPlayed[playerid] = true;
				SetPlayerLife(playerid,rHealth,rArmor);
	  			SetCameraBehindPlayerEx(playerid);
	  			SetPlayerColorEx(playerid,TeamActiveColors[gTeam[playerid]]);
	  			SetPlayerInterior(playerid,Interior[Current][BASE]);
	  			FindPlayerSpawn(playerid,1);
	  			TogglePlayerControllable(playerid,1);
	  			ClearAnimations(playerid);
				new Menu:asdf = GetPlayerMenu(playerid);
				if(IsValidMenu(asdf)) HideMenuForPlayer(asdf, playerid);
  				if(ClanLeader[playerid] == true && TeamStatus[gTeam[playerid]] == ATTACKING)
	  			{
		  			SelectWeather(playerid);
		  			SetTimerEx("HidePlayerMenu",15000,0,"i",playerid);
		  			SendClientMessage(playerid,MainColors[2],"You have 15 seconds to select the weather and time");
				}
			}
		}
	}
	else if (CurrentMenu[playerid] == 7)
	{
	    switch(row)
	    {
	        case 0:{rWeather = 1;format(string,sizeof(string),"Clan leader \"%s\" has changed the weather to \"Sunny\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);SelectTime(playerid);foreach(Player,i){SetPlayerWeather(i,rWeather);}}
	        case 1:{rWeather = 12;format(string,sizeof(string),"Clan leader \"%s\" has changed the weather to \"Overcast\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);SelectTime(playerid);foreach(Player,i){SetPlayerWeather(i,rWeather);}}
	        case 2:{rWeather = 16;format(string,sizeof(string),"Clan leader \"%s\" has changed the weather to \"Rain\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);SelectTime(playerid);foreach(Player,i){SetPlayerWeather(i,rWeather);}}
	        case 3:{rWeather = 9;format(string,sizeof(string),"Clan leader \"%s\" has changed the weather to \"Foggy\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);SelectTime(playerid);foreach(Player,i){SetPlayerWeather(i,rWeather);}}
	        case 4:{rWeather = 19;format(string,sizeof(string),"Clan leader \"%s\" has changed the weather to \"Sand Storm\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);SelectTime(playerid);foreach(Player,i){SetPlayerWeather(i,rWeather);}}
	        case 5:{WeaponSelectionIII(playerid);}
	    }
	}
	else if (CurrentMenu[playerid] == 8)
	{
	    switch(row)
	    {
	        case 0:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"0:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=0;rTime = 1;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 1:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"3:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=3;rTime = 3;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 2:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"6:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=6;rTime = 6;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 3:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"9:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=9;rTime = 9;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 4:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"12:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=12;rTime = 12;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 5:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"15:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=15;rTime = 15;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 6:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"17:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=17;rTime = 17;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 7:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"18:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=18;rTime = 18;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 8:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"21:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=21;rTime = 21;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 9:{format(string,sizeof(string),"Clan leader \"%s\" has changed the world time to \"24:00\"",RealName[playerid]);SendClientMessageToAll(MainColors[0],string);LeaderConfirm(playerid);Xminute=24;rTime = 24;foreach(Player,i){SetPlayerTime(i,rTime,0);}}
	        case 10:SelectWeather(playerid);
	    }
	}
	else if(CurrentMenu[playerid] == 9)
	{
		if(row == 0){SelectWeather(playerid);}
		else if(row == 1)if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	}
	else if(CurrentMenu[playerid] == 10)
	{
	    if(gTeam[playerid] == row || row == MAX_TEAMS)return 1;
		if(row == T_SUB)return SubMenu(playerid);
		if(IsPlayerInAnyVehicle(playerid))
		{
			GetPlayerPos(playerid,PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]);
			SetPlayerPos(playerid,PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]+2);
		}
		SetTeam(playerid,row);
		RespawnPlayerAtPos(playerid,1);
		SetPlayerColorEx(playerid,TeamInactiveColors[row]);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** \"%s\" has Switched to Team \"%s\"",NickName[playerid],TeamName[row]);
		SendClientMessageToAll(TeamActiveColors[row],string);
		UpdatePrefixName(playerid);
		if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
		return 1;
	}
	else if(CurrentMenu[playerid] == 11)
	{
	    CurrentPlayers[gTeam[playerid]]--;
		gTeam[playerid] = T_SUB;
		sTeam[playerid] = row;
		CurrentPlayers[T_SUB]++;
		RespawnPlayerAtPos(playerid,1);
		SetPlayerColorEx(playerid,0xFFFFFFFF);
		PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
		format(string,sizeof(string),"*** \"%s\" is now a %s for team \"%s\"",NickName[playerid],TeamName[T_SUB],TeamName[row]);
		SendClientMessageToAll(0xFFFFFFFF,string);
		UpdatePrefixName(playerid);
		TogglePlayerControllable(playerid,1);
		gPlayerSpawned[playerid] = true;
		HideMenuForPlayer(GunMenu[playerid], playerid);
		return 1;
	}
	else if (CurrentMenu[playerid] == 12)
	{
	    if(ArenaEditing[playerid] == -1)return SendClientMessage(playerid,MainColors[2],"you are not editing an arena");
	    new Float:X,Float:Y,Float:Z,inter;
		GetPlayerPos(playerid,X,Y,Z);
		inter = GetPlayerInterior(playerid);
		format(string2,sizeof(string2),"/attackdefend/%d/arenas/%d.ini",GameMap,ArenaEditing[playerid]);
		switch(row)
		{
		    case 0:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T0",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamArenaSpawns[ArenaEditing[playerid]][0][0] = X;TeamArenaSpawns[ArenaEditing[playerid]][1][0] = Y;TeamArenaSpawns[ArenaEditing[playerid]][2][0] = Z;
            	return 1;
		    }
		    case 1:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T1",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamArenaSpawns[ArenaEditing[playerid]][0][1] = X;TeamArenaSpawns[ArenaEditing[playerid]][1][1] = Y;TeamArenaSpawns[ArenaEditing[playerid]][2][1] = Z;
            	return 1;
		    }
		    case 2:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T2",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamArenaSpawns[ArenaEditing[playerid]][0][2] = X;TeamArenaSpawns[ArenaEditing[playerid]][1][2] = Y;TeamArenaSpawns[ArenaEditing[playerid]][2][2] = Z;
            	return 1;
		    }
		    case 3:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T3",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamArenaSpawns[ArenaEditing[playerid]][0][3] = X;TeamArenaSpawns[ArenaEditing[playerid]][1][3] = Y;TeamArenaSpawns[ArenaEditing[playerid]][2][3] = Z;
            	return 1;
		    }
		    case 4:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T4",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamArenaSpawns[ArenaEditing[playerid]][0][4] = X;TeamArenaSpawns[ArenaEditing[playerid]][1][4] = Y;TeamArenaSpawns[ArenaEditing[playerid]][2][4] = Z;
            	return 1;
		    }
		    case 5:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T5",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamArenaSpawns[ArenaEditing[playerid]][0][5] = X;TeamArenaSpawns[ArenaEditing[playerid]][1][5] = Y;TeamArenaSpawns[ArenaEditing[playerid]][2][5] = Z;
            	return 1;
		    }
		    case 6:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"home",string);
            	dini_IntSet(string2,"Interior",inter);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
				ArenaCP[ArenaEditing[playerid]][0] = X;ArenaCP[ArenaEditing[playerid]][1] = Y;ArenaCP[ArenaEditing[playerid]][2] = Z;Interior[ArenaEditing[playerid]][ARENA] = inter;
				return 1;
		    }
		    case 7:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f //%s",X,Y,RealName[playerid]);
            	dini_Set(string2,"Zmax",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	ArenaZones[ArenaEditing[playerid]][0] = X;ArenaZones[ArenaEditing[playerid]][1] = Y;
            	return 1;
		    }
		    case 8:
		    {
		    	format(string,sizeof(string),"%.3f,%.3f //%s",X,Y,RealName[playerid]);
            	dini_Set(string2,"Zmin",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	ArenaZones[ArenaEditing[playerid]][2] = X;ArenaZones[ArenaEditing[playerid]][2] = Y;
            	return 1;
		    }
		    case 9:
		    {
            	dini_IntSet(string2,"Interior",inter);
            	format(string,sizeof(string),"Arena %d Interior set to %d",ArenaEditing[playerid],inter);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	Interior[ArenaEditing[playerid]][ARENA] = inter;
            	return 1;
		    }
		    case 10:
		    {
                format(string2,sizeof(string2),"/attackdefend/%d/arenas/%d.ini",GameMap,ArenaEditing[playerid]);
            	format(string,sizeof(string),"9000.0000,9000.0000");dini_Set(string2,"Zmax",string);
            	format(string,sizeof(string),"-9000.0000,-9000.0000");dini_Set(string2,"Zmin",string);
	        	SendClientMessage(playerid,MainColors[3],"World bounds removed");
	        	ArenaZones[ArenaEditing[playerid]][0] = 9000.0000;ArenaZones[ArenaEditing[playerid]][1] = 9000.0000;
            	ArenaZones[ArenaEditing[playerid]][2] = -9000.0000;ArenaZones[ArenaEditing[playerid]][2] = -9000.0000;
            	return 1;
		    }
		}
	}
	else if (CurrentMenu[playerid] == 6)
	{
	    if(BaseEditing[playerid] == -1)return SendClientMessage(playerid,MainColors[2],"you are not editing a base");
	    new Float:X,Float:Y,Float:Z,inter;
		GetPlayerPos(playerid,X,Y,Z);
		inter = GetPlayerInterior(playerid);
		switch(row)
		{
		    case 0:
		    {
                format(string2,sizeof(string2),"/attackdefend/%d/bases/%d.ini",GameMap,BaseEditing[playerid]);
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //ATT//%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T1_0",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamBaseSpawns[BaseEditing[playerid]][0][T_HOME] = X;TeamBaseSpawns[BaseEditing[playerid]][1][T_HOME] = Y;TeamBaseSpawns[BaseEditing[playerid]][2][T_HOME] = Z;
            	return 1;
		    }
		    case 1:
		    {
                format(string2,sizeof(string2),"/attackdefend/%d/bases/%d.ini",GameMap,BaseEditing[playerid]);
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //DEF//%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"T2_0",string);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	TeamBaseSpawns[BaseEditing[playerid]][0][T_AWAY] = X;TeamBaseSpawns[BaseEditing[playerid]][1][T_AWAY] = Y;TeamBaseSpawns[BaseEditing[playerid]][2][T_AWAY] = Z;
            	return 1;
		    }
		    case 2:
		    {
                format(string2,sizeof(string2),"/attackdefend/%d/bases/%d.ini",GameMap,BaseEditing[playerid]);
		    	format(string,sizeof(string),"%.3f,%.3f,%.3f //HOME//%s",X,Y,Z,RealName[playerid]);
            	dini_Set(string2,"home",string);
            	dini_IntSet(string2,"Interior",inter);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	HomeCP[BaseEditing[playerid]][0] = X;HomeCP[BaseEditing[playerid]][1] = Y;HomeCP[BaseEditing[playerid]][2] = Z;
            	return 1;
		    }
		    case 3:
			{
                format(string2,sizeof(string2),"/attackdefend/%d/bases/%d.ini",GameMap,BaseEditing[playerid]);
            	dini_IntSet(string2,"Interior",inter);
            	format(string,sizeof(string),"Base %d Interior set to %d",BaseEditing[playerid],inter);
            	SendClientMessage(playerid,MainColors[3],string);printf(string);
            	Interior[BaseEditing[playerid]][BASE] = inter;
            	return 1;
		    }
		}
	}
	else if(CurrentMenu[playerid] == 13)
	{
    	new gunstring[12];
	    switch(row)
		{
		    case 0:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 1;GunEdit[playerid][2] = 1;
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				GunUsedMenuII(playerid);
				return 1;
			}
			case 1:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 2;GunEdit[playerid][2] = 2;
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				GunUsedMenuII(playerid);
				return 1;
			}
			case 2:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 4;GunEdit[playerid][2] = 4;
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				GunUsedMenuII(playerid);
				return 1;
			}
			case 3:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 8;GunEdit[playerid][2] = 8;
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				GunUsedMenuII(playerid);
				return 1;
			}
			case 4:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 16;
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) will be given automatically",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN]);
				else format(string,128,"ARENA: Gun %s (%d) will be given automatically",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				return 1;
			}
			case 5:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 0;
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) is NOT used",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN]);
				else format(string,128,"ARENA: Gun %s (%d) is NOT used",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				return 1;
			}
		}
	}
	else if(CurrentMenu[playerid] == 14)
	{
	    new gunstring[12];
	    switch(row)
		{
		    case 0:
		    {
		    	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 1+GunEdit[playerid][2];
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to 1",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],1+GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				return 1;
			}
			case 1:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 2+GunEdit[playerid][2];
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],2+GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				return 1;
			}
			case 2:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 4+GunEdit[playerid][2];
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],4+GunEdit[playerid][2]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],4+GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				return 1;
			}
			case 3:
		    {
				PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
				new file[64];
				if(GunEdit[playerid][1] == BASE)format(file,128,"/attackdefend/%d/config/baseconfig/%d.ini",GameMap,CurrentConfig[BASE]);
				else format(file,128,"/attackdefend/%d/config/arenaconfig/%d.ini",GameMap,CurrentConfig[ARENA]);
				format(string,STR,"G%d",GunEdit[playerid][GUN]);
				GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]] = 8+GunEdit[playerid][2];
				format(gunstring,12,"%d",GunEdit[playerid][GUN]);format(string,sizeof(string),"%d,%d,%d",GunAmmo[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunUsed[GunEdit[playerid][GUN]][GunEdit[playerid][1]],GunLimit[GunEdit[playerid][GUN]][GunEdit[playerid][1]]);dini_Set(file,gunstring,string);
				if(GunEdit[playerid][1] == BASE)format(string,128,"BASE: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],8+GunEdit[playerid][2]);
				else format(string,128,"ARENA: Gun %s (%d) set to %d",WeaponNames[GunEdit[playerid][GUN]],GunEdit[playerid][GUN],8+GunEdit[playerid][2]);
				SendClientMessage(playerid,MainColors[3],string);
				UpdateWeaponSetText(GunEdit[playerid][1]);
				return 1;
			}
			case 4: return 1;
		}
	}
	else if(CurrentMenu[playerid] == 15)
	{
	    switch(row)
	    {
	        case 0:OnPlayerChangedWheels(playerid,1);
	        case 1:OnPlayerChangedWheels(playerid,2);
	        case 2:OnPlayerChangedWheels(playerid,3);
	        case 3:OnPlayerChangedWheels(playerid,4);
	        case 4:OnPlayerChangedWheels(playerid,5);
	        case 5:OnPlayerChangedWheels(playerid,6);
	        case 6:OnPlayerChangedWheels(playerid,7);
	        case 7:OnPlayerChangedWheels(playerid,8);
	        case 8:OnPlayerChangedWheels(playerid,9);
	        case 9:OnPlayerChangedWheels(playerid,10);
	        case 10:WheelMenu2(playerid);
	    }
	    if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	    return 1;
	}
	else if(CurrentMenu[playerid] == 16)
	{
	    switch(row)
	    {
	        case 0:OnPlayerChangedWheels(playerid,11);
	        case 1:OnPlayerChangedWheels(playerid,12);
	        case 2:OnPlayerChangedWheels(playerid,13);
	        case 3:OnPlayerChangedWheels(playerid,14);
	        case 4:OnPlayerChangedWheels(playerid,15);
	        case 5:OnPlayerChangedWheels(playerid,16);
	        case 6:OnPlayerChangedWheels(playerid,17);
	        case 7:OnPlayerChangedWheels(playerid,18);
	        case 8:OnPlayerChangedWheels(playerid,0);
	        case 9:WheelMenu1(playerid);
	    }
		if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
	    return 1;
	}
	else if(CurrentMenu[playerid] == 17)
	{
	    wSkillEdit[playerid] = row;
	    WeaponSkillMenu2(playerid);
	}
	else if(CurrentMenu[playerid] == 18)
	{
	    switch(row)
	    {
	        case 0:
	        {
	            if(WeaponSkills[wSkillEdit[playerid]][s_Level] == 0)return 1;
	            WeaponSkills[wSkillEdit[playerid]][s_Level] = 0;
	            SaveWeaponSkills();
	            format(string,sizeof(string),"You have set the round skill for %s to Poor (0)",WeaponSkills[wSkillEdit[playerid]][s_Name]);
	            SendClientMessage(playerid,MainColors[3],string);
	        }
	        case 1:
	        {
	            if(WeaponSkills[wSkillEdit[playerid]][s_Level] == 200)return 1;
	            WeaponSkills[wSkillEdit[playerid]][s_Level] = 200;
	            SaveWeaponSkills();
	            format(string,sizeof(string),"You have set the round skill for %s to Gangster (200)",WeaponSkills[wSkillEdit[playerid]][s_Name]);
	            SendClientMessage(playerid,MainColors[3],string);
	        }
	        case 2:
	        {
	            if(WeaponSkills[wSkillEdit[playerid]][s_Level] == 999)return 1;
	            WeaponSkills[wSkillEdit[playerid]][s_Level] = 999;
	            SaveWeaponSkills();
	            format(string,sizeof(string),"You have set the round skill for %s to Hitman (999)",WeaponSkills[wSkillEdit[playerid]][s_Name]);
	            SendClientMessage(playerid,MainColors[3],string);
	        }
	    }
	    return 1;
	}
	else if(CurrentMenu[playerid] == 19)
	{
	    wSkillEdit[playerid] = row;
	    PlayerWeaponSkillMenu2(playerid);
	}
	else if(CurrentMenu[playerid] == 20)
	{
	    switch(row)
	    {
	        case 0:
	        {
	            if(wSkill[playerid][wSkillEdit[playerid]] == 0)return 1;
	            wSkill[playerid][wSkillEdit[playerid]] = 0;
	            SavePlayerWeaponSkills(playerid);
	            SetPlayerSkillLevel(playerid,wSkillEdit[playerid],wSkill[playerid][wSkillEdit[playerid]]);
	            format(string,sizeof(string),"You have set your skill level for %s to Poor (0)",WeaponSkills[wSkillEdit[playerid]][s_Name]);
	            SendClientMessage(playerid,MainColors[3],string);
	        }
	        case 1:
	        {
	            if(wSkill[playerid][wSkillEdit[playerid]] == 200)return 1;
	            wSkill[playerid][wSkillEdit[playerid]] = 200;
	            SavePlayerWeaponSkills(playerid);
	            SetPlayerSkillLevel(playerid,wSkillEdit[playerid],wSkill[playerid][wSkillEdit[playerid]]);
	            format(string,sizeof(string),"You have set your skill level for %s to Gangster (200)",WeaponSkills[wSkillEdit[playerid]][s_Name]);
	            SendClientMessage(playerid,MainColors[3],string);
	        }
	        case 2:
	        {
	            if(wSkill[playerid][wSkillEdit[playerid]] == 999)return 1;
	            wSkill[playerid][wSkillEdit[playerid]] = 999;
	            SavePlayerWeaponSkills(playerid);
	            SetPlayerSkillLevel(playerid,wSkillEdit[playerid],wSkill[playerid][wSkillEdit[playerid]]);
	            format(string,sizeof(string),"You have set your skill level for %s to Hitman (999)",WeaponSkills[wSkillEdit[playerid]][s_Name]);
	            SendClientMessage(playerid,MainColors[3],string);
	        }
	    }
	    return 1;
	}
	else if(CurrentMenu[playerid] == 21)
	{
		SetPlayerFightingStyle(playerid,FightStyle[row][f_ID]);
		pFightStyle[playerid] = FightStyle[row][f_ID];
		new file[64];
		format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		dini_IntSet(file,"fStyle",pFightStyle[playerid]);
	    return 1;
	}
	if(IsValidMenu(GunMenu[playerid]))ShowMenuForPlayer(GunMenu[playerid], playerid);
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
    //FunctionLog("OnPlayerExitedMenu");
	if(CurrentMenu[playerid] == 11 && gPlayerSpawned[playerid] == false)SubMenu(playerid);
	else if(CurrentMenu[playerid] < 5)WeaponSelectionV(playerid);
	return 1;
}

//==============================================================================
////////////////////////////////////////////////////////////////////////////////
//==============================================================================

GetHighestBaseNum()
{
    //FunctionLog("GetHighestBaseNum");
	new count;
	for(new x; x < MAX_BASES; x++)
	{
	    if(fexist(Basefile(x)))count++;
	}
	return count;
}

GetHighestArenaNum()
{
    //FunctionLog("GetHighestArenaNum");
	new count;
	for(new x; x < MAX_BASES; x++)
	{
	    if(fexist(Arenafile(x)))	count++;
	}
	return count;
}

/*GetHighestTeleNum()
{
    //FunctionLog("GetHighestTeleNum");
	new count;
	for(new x; x < MAX_BASES; x++)
	{
	    if(fexist(Telefile(x)))count++;
	}
	return count;
}*/

forward AddPlayer(playerid);
public AddPlayer(playerid)
{
    //FunctionLog("AddPlayer");
    if(SelectingWeaps[playerid] == false)return 1;
    SelectingWeaps[playerid] = false;
    //TextDrawShowForPlayer(playerid,MoneyBox);
	//TextDrawShowForPlayer(playerid,pText[6][playerid]);
	if(Current == -1)
	{
	    HideAllTextDraws(playerid);
	    ResetPlayerHealth(playerid);
		ResetPlayerArmor(playerid);
		Playing[playerid] = false;
		TogglePlayerControllable(playerid,1);
		SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
		SetPlayerNewWorld(playerid);
		ResetPlayerWeaponSet(playerid);
		RemovePlayerFromVehicle(playerid);
		SpawnAtPlayerPosition[playerid] = 0;
		FindPlayerSpawn(playerid,1);
		SpawnPlayer(playerid);
		SetCameraBehindPlayer(playerid);
		RemovePlayingName(playerid);
		return 1;
	}
    TD_HidepTextForPlayer(playerid,playerid,2);
    TD_HideMainTextForPlayer(playerid,13);
    TogglePlayerControllable(playerid,1);
    SetPlayerVirtualWorld(playerid,1);
	ViewingResults[playerid] = false;
	new Menu:current = GetPlayerMenu(playerid);
	if(IsValidMenu(current)) HideMenuForPlayer(current, playerid);
 	StrapUp(playerid);
	SetPlayerColorEx(playerid,TeamActiveColors[gTeam[playerid]]);
	ResetPlayerHealth(playerid);
	ResetPlayerArmor(playerid);
	SetCameraBehindPlayerEx(playerid);
	if(ModeType == TDM || ModeType == ARENA)SpawnAtPlayerPosition[playerid] = 4;
	return 1;
}

forward AddPlayerFromMenu(playerid);
public AddPlayerFromMenu(playerid)
{
    //FunctionLog("AddPlayerFromMenu");
	if(GivenMenu[playerid] == true && SelectingWeaps[playerid] == true)
	{
	    GivenMenu[playerid] = false;
		TD_HidepTextForPlayer(playerid,playerid,1);
		TD_HidepTextForPlayer(playerid,playerid,2);
		TD_HidepTextForPlayer(playerid,playerid,13);
		TD_HideMainTextForPlayer(playerid,13);
		SetPlayerVirtualWorld(playerid,1);
    	TogglePlayerControllable(playerid,1);
    	new Menu:current = GetPlayerMenu(playerid);
		if(IsValidMenu(current)) {HideMenuForPlayer(current, playerid);}
		StrapUp(playerid);
		SetCameraBehindPlayerEx(playerid);
		SelectingWeaps[playerid] = false;
	}
}

forward HideSTextForAll();
public HideSTextForAll()
{
    //FunctionLog("HideSTextForAll");
	foreach(Player,i)
	{
	    PlayerPlaySound(i,1069,0.0,0.0,0.0);
		TD_HideMainTextForPlayer(i,0);
		TextDrawHideForPlayer(i,TopShotta[0]);
		TextDrawHideForPlayer(i,TopShotta[1]);
		TextDrawHideForPlayer(i,TopShotta[2]);
		TextDrawHideForPlayer(i,TopShotta[3]);
		TextDrawHideForPlayer(i,TopShotta[4]);
	}
	return 1;
}

forward EnableVehicleSpawning();
public EnableVehicleSpawning()
{
    //FunctionLog("EnableVehicleSpawning");
    VehiclesSpawned[T_HOME] = 0;
	VehiclesSpawned[T_AWAY] = 0;
}

/*GetPlayerWithHighestScore()
{
    //FunctionLog("GetPlayerWithHighestScore");
    new highest_score = -1, player_score = -1, playerid = -1;
    for(new i, j = HighestID; i <= j; i++)
    {
        if(IsPlayerConnected(i))
        {
            player_score = TR_Kills[i];

            if(player_score > highest_score)
            {
                highest_score = player_score;
                playerid = i;
            }
        }
    }
	return playerid;
}*/

GetPlayerWithHighestScore()
{
    //FunctionLog("GetPlayerWithHighestScore");
    new highest_score = -1, id = -1;
    foreach(Player,i)
    {
		if(TR_Kills[i] > highest_score)
		{
			highest_score = TR_Kills[i];
			id = i;
		}
    }
	return id;
}

GetDeathPosition(playerid)
{
    //FunctionLog("GetDeathPosition");
    new superscript[3],string[10];
    if(ModeType == TDM)
    {
        TR_DeathPosStr[playerid] = "N/A";
    }
    else
    {
    	TR_DeathPosInt++;
		if(TR_DeathPosInt == 1 && TeamCurrentPlayers[gTeam[playerid]] > 1)
		{
			superscript = "st";
			GameTextForAll("~r~~n~~n~~n~~n~~n~~n~First Blood",5000,3);
		}
		else if(TR_DeathPosInt == 2)superscript = "nd";
		else if(TR_DeathPosInt == 3)superscript = "rd";
		else superscript = "th";
		format(string,10,"%d%s",TR_DeathPosInt,superscript);
		TR_DeathPosStr[playerid] = string;
	}
	return 1;
}

FindPlayerSkin(playerid)
{
    //FunctionLog("FindPlayerSkin");
	if(TeamSkin[gTeam[playerid]] != -1)return TeamSkin[gTeam[playerid]];
	if(Skin[playerid] == -1)return GetPlayerSkin(playerid);
	return Skin[playerid];
}

FindPlayerSpawn(playerid,spawn)
{
    //FunctionLog("FindPlayerSpawn");
    if(IsDueling[playerid] == true)return 1;
	if(spawn == 1)
	{
		if(SetSpawn[playerid] == 0)
		{
			SetSpawnInfo(playerid,playerid,FindPlayerSkin(playerid),MainSpawn[0]-5+random(5),MainSpawn[1]-5+random(5),MainSpawn[2],random(360),0,0,0,0,0,0);
			CurrentInt[playerid] = floatround(MainSpawn[3]);
		}
		else
		{
			SetSpawnInfo(playerid,playerid,FindPlayerSkin(playerid),mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid],mSpawn[3][playerid],0,0,0,0,0,0);
			CurrentInt[playerid] = floatround(mSpawn[4][playerid]);
		}
	}
	else
	{
 		if(SetSpawn[playerid] == 0)
		{
			SetPlayerPos(playerid,MainSpawn[0]-5+random(5),MainSpawn[1]-5+random(5),MainSpawn[2]);
			CurrentInt[playerid] = floatround(MainSpawn[3]);
		}
		else
		{
	    	SetPlayerPos(playerid,mSpawn[0][playerid],mSpawn[1][playerid],mSpawn[2][playerid]);
	    	SetPlayerFacingAngle(playerid,mSpawn[3][playerid]);
	    	CurrentInt[playerid] = floatround(mSpawn[4][playerid]);
		}
		SetPlayerInterior(playerid,CurrentInt[playerid]);
	}
	return 1;
}

RespawnPlayerAtPos(playerid,type)
{
    //FunctionLog("RespawnAtPlayerPos");
    CurrentInt[playerid] = GetPlayerInterior(playerid);
    GetPlayerPos(playerid,PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]);
	GetPlayerFacingAngle(playerid,PlayerPosition[playerid][3]);
	SetSpawnInfo(playerid,playerid,FindPlayerSkin(playerid),PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]-0.90,PlayerPosition[playerid][3],0,0,0,0,0,0);
	SpawnAtPlayerPosition[playerid] = type;
	SpawnPlayer(playerid);
	return 1;
}

forward ResetAllNames();
public ResetAllNames()
{
    //FunctionLog("ResetAllNames");
    foreach(Player,i)
	{
        if(AFK[i] == false)
		{
			SetPlayerName(i,NickName[i]);
			UpdatePrefixName(i);
		}
	}
}

GetWeaponSlot(weaponid)
{
    /*FunctionLogEx("GetWeaponSlot");*/
	switch(weaponid)
	{
		case 0,1:return 0;//fists
		case 2,3,4,5,6,7,8,9:return 1;//melee
		case 22,23,24:return 2;//pistols
		case 25,26,27:return 3;//shotguns
		case 28,29,32:return 4;//SMG's
		case 30,31:return 5;//Assault Rifles
		case 33,34:return 6;//Long Range Rifles
		case 35,36,37,38:return 7;//Heavy
		case 16,17,18,39:return 8;//Projectiles
		case 41,42,43:return 9;//Sprays and Camera
		case 10,11,12,13,14,15:return 10;//Gifts
		case 44,45,46:return 11;//Goggles and Parachute
		case 40:return 12;//Detonator
	}
	return 0;
}

SameTypeOfWeapon(playerid,weaponid)
{
    //FunctionLog("SameTypeOfWeapon");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    for(new i; i < 4; i++)
	{
		if(GetWeaponSlot(weaponid) == GetWeaponSlot(WeaponSet[playerid][i][MODE]) && WeaponSet[playerid][i][MODE] != weaponid)return 1;
	}
	return 0;
}

SameTypeOfWeaponII(playerid,slot)
{
    //FunctionLog("SameTypeOfWeaponII");
    new TMP[MAX_SLOTS][2];
    for(new i = 1; i < MAX_SLOTS; i++)
	{
		GetPlayerWeaponData(playerid,i,TMP[i][GUN],TMP[i][AMMO]);
	}
	if(TMP[slot][GUN] > 0)return 1;
	return 0;
}

SameWeapon(playerid,weaponid)
{
    //FunctionLog("SameWeapon");
    new TMP[MAX_SLOTS][2];
    for(new i = 1; i < MAX_SLOTS; i++)
	{
		GetPlayerWeaponData(playerid,i,TMP[i][GUN],TMP[i][AMMO]);
		if(TMP[i][GUN] == weaponid)return 1;
	}
	return 0;
}

ResetWeaponSets()
{
    //FunctionLog("ResetWeaponSets");
    foreach(Player,i)
	{
	    for(new x = 1; x < MAX_SLOTS; x++)
		{
		    TR_StartGun[i][x][GUN] = 0;
		    TR_EndGun[i][x][GUN] = 0;
		    TR_StartGun[i][x][AMMO] = 0;
		    TR_EndGun[i][x][AMMO] = 0;
		}
    	for(new x = 0; x < 4; x++)
		{
    		WeaponSet[i][x][BASE] = 0;
    		WeaponSet[i][x][ARENA] = 0;
		}
	}
	return 1;
}

ResetPlayerWeaponSet(playerid)
{
    //FunctionLog("ResetPlayerWeaponSet");
	for(new x = 0; x < 4; x++)
	{
		WeaponSet[playerid][x][BASE] = 0;
		WeaponSet[playerid][x][ARENA] = 0;
	}
	return 1;
}

forward HidePlayerMenu(playerid);
public HidePlayerMenu(playerid)
{
    //FunctionLog("HidePlayerMenu");
    if(IsValidMenu(GunMenu[playerid])){HideMenuForPlayer(Menu:GunMenu[playerid],playerid);DestroyMenu(Menu:GunMenu[playerid]);}
}

GunsOfTypeUsed(type)
{
    //FunctionLog("GunsOfTypeUsed");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
	new used = 0;
	new other_type[3];
	switch(type)
	{
	    case 1:{other_type[0] = 9;other_type[1] = 5;other_type[2] = 3;}
	    case 2:{other_type[0] = 10;other_type[1] = 6;other_type[2] = 3;}
	    case 4:{other_type[0] = 12;other_type[1] = 6;other_type[2] = 5;}
	    case 8:{other_type[0] = 12;other_type[1] = 10;other_type[2] = 9;}
	}
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
	    if(GunUsed[i][MODE] == type || GunUsed[i][MODE] == other_type[0] || GunUsed[i][MODE] == other_type[1] || GunUsed[i][MODE] == other_type[2])
	    {
	        used++;
		}
	}
	return used;
}

forward PasswordCheck(playerid);
public PasswordCheck(playerid)
{
    //FunctionLog("PasswordCheck");
	if(CorrectPassword[playerid] == false && !IsPlayerAdmin(playerid))
	{
	    SendClientMessage(playerid,MainColors[2],"YOU DID NOT ENTER THE PASSWORD IN TIME.");
	    Kick(playerid);
	}
	return 1;
}

forward SetPlayerAFK(playerid,Float:X,Float:Y,Float:Z);
public SetPlayerAFK(playerid,Float:X,Float:Y,Float:Z)
{
    //FunctionLog("SetPlayerAFK");
	new Float:Position[3];
	GetPlayerPos(playerid,Position[0],Position[1],Position[2]);
	if(Position[0] == X && Position[1] == Y && Position[2] == Z)
	{
	    new string[128];
    	format(string,sizeof(string),"AFK_%s",NickName[playerid]);
		SetPlayerName(playerid,string);
		format(string,sizeof(string),"*** \"%s\" is now AFK",NickName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		SetTeam(playerid,T_NON);
		AFK[playerid] = true;
		SpawnPlayer(playerid);
		TogglePlayerControllable(playerid,0);
		ResetPlayerWeapons(playerid);
	}
	else SendClientMessage(playerid,MainColors[2],"You moved. Unable to go AFK.");
}

forward HideCheckpointText();
public HideCheckpointText()
{
    //FunctionLog("HideCheckPointText");
    foreach(Player,x)
	{
		TD_HideMainTextForPlayer(x,1);
		TD_HideMainTextForPlayer(x,2);
	}
	return 1;
}

UpdateMenuText(playerid)
{
    //FunctionLog("UpdateMenuText");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
	new string[256],Weapons[4][32],Ammo[4];
	for(new i = 0; i < 4; i++)
	{
		if(WeaponSet[playerid][i][MODE] == 0)
		{
			Weapons[i] = "None";
			Ammo[i] = 0;
		}
		else
		{
			Weapons[i] = WeaponNames[WeaponSet[playerid][i][MODE]];
			Ammo[i] = GunAmmo[WeaponSet[playerid][i][MODE]][MODE];
		}
	}
	format(string,sizeof(string),"~y~- ~w~%s ~y~x%d ~n~- ~w~%s ~y~x%d ~n~- ~w~%s ~y~x%d ~n~- ~w~%s ~y~x%d",Weapons[0],Ammo[0],Weapons[1],Ammo[1],Weapons[2],Ammo[2],Weapons[3],Ammo[3]);
	TextDrawSetString(pText[2][playerid],string);
	return 1;
}

GetHighestVID()
{
    //FunctionLog("GetHighestVID");
	new highest;
	for(new i = MAX_SERVER_VEHICLES-1; i > 0; i--)
	{
		if(v_Exists[i] == true)
		{
			highest = i;
			break;
		}
	}
	return highest;
}

forward DestroyVehicleEx(vehicleid);
public DestroyVehicleEx(vehicleid)
{
    /*FunctionLogEx("DestroyVehicleEx");*/
	Vehicles--;
	v_Exists[vehicleid] = false;
	v_Destroy[vehicleid] = false;
	v_InRound[vehicleid] = false;
	v_Trailer[vehicleid] = -1;
	v_AmtInside[vehicleid] = 0;
	HighestVID = GetHighestVID();
	DestroyVehicle(vehicleid);
	return 1;
}

forward DestroyRoundVehicles();
public DestroyRoundVehicles()
{
    //FunctionLog("DestroyRoundVehicles");
    for(new v; v <= HighestVID; v++)
	{
	    if(v_Exists[v] == true && v_InRound[v] == true)
	    {
			DestroyVehicle(v);
			v_Exists[v] = false;
			v_Destroy[v] = false;
			v_InRound[v] = false;
			v_Trailer[v] = -1;
			v_AmtInside[v] = 0;
			Vehicles--;
		}
	}
	HighestVID = GetHighestVID();
	return 1;
}

forward DestroyEmptyVehicles();
public DestroyEmptyVehicles()
{
    /*FunctionLogEx("DestroyEmptyVehicles");*/
    if(Vehicles == 0)return 1;
	new bool:KeepV[MAX_SERVER_VEHICLES];
    for(new v; v <= HighestVID; v++)
	{
	    if(v_Exists[v] == true)
	    {
	        if(v_Trailer[v] != -1 && v_Exists[v_Trailer[v]] == true)
			{
				if(IsTrailerAttachedToVehicle(v_Trailer[v]) == 1)
				{
					KeepV[v] = true;
				}
			}
	        else
	        {
        		foreach(Player,p)
				{
				    if(IsPlayerInVehicle(p,v))
					{
						KeepV[v] = true;
						break;
					}
				}
			}
			if(v_InRound[v] == false && KeepV[v] == false)
			{
				DestroyVehicleEx(v);
			}
		}
	}
	return 1;
}


forward ResetPlayerName(playerid);
public ResetPlayerName(playerid)
{
    //FunctionLog("ResetPlayerName");
	SetPlayerName(playerid,TempName[playerid]);
}

forward TDMprot(playerid);
public TDMprot(playerid)
{
    //FunctionLog("TDMprot");
    StrapUp(playerid);
    ResetPlayerArmor(playerid);
    ResetPlayerHealth(playerid);
	SetPlayerColorEx(playerid,TeamActiveColors[gTeam[playerid]]);
	ShowDMG[playerid] = true;
	return 1;
}

/*SpreeUpdate(killerid,playerid)
{
    //FunctionLog("SpreeUpdate");
    Spree[KILL][playerid] = 0;
    Spree[DEATH][playerid]++;
	if(Spree[DEATH][playerid] >= MaxSpree[DEATH][playerid])
	{
	    new playerfile[64];//,string[64];
		MaxSpree[DEATH][playerid] = Spree[DEATH][playerid];
		format(playerfile,sizeof(playerfile),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
		dini_IntSet(playerfile,"D_Spree",MaxSpree[DEATH][playerid]);
	}
	if(IsPlayerConnected(killerid))
	{
		Spree[DEATH][killerid] = 0;
		Spree[KILL][killerid]++;
		if(Spree[KILL][killerid] >= MaxSpree[KILL][killerid])
		{
 			new playerfile[64];//,string[64];
			MaxSpree[KILL][killerid] = Spree[KILL][killerid];
			format(playerfile,sizeof(playerfile),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[killerid]);
			dini_IntSet(playerfile,"K_Spree",MaxSpree[KILL][killerid]);
			if(Spree[KILL][killerid] == 5 || Spree[KILL][killerid] == 10 || Spree[KILL][killerid] == 15 || Spree[KILL][killerid] == 20 || Spree[KILL][killerid] == 25 || Spree[KILL][killerid] == 30)
			{
			    new string[128];
			    format(string,sizeof(string),"*** \"%s\" has a kill streak of %d!",NickName[killerid],MaxSpree[KILL][killerid]);
				SendClientMessageToAll(MainColors[3],string);
			}
		}
	}
	return 1;
}*/

UpdateWeaponSetText(mode)
{
    //FunctionLog("UpdateWeaponSetText");
    new gunstring[5][256];gunstring[0] = "Set 1~n~~w~";gunstring[1] = "Set 2~n~~w~";gunstring[2] = "Set 3~n~~w~";gunstring[3] = "Set 4~n~~w~";gunstring[4] = "Given Auto~n~~w~";
    for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(GunUsed[i][mode] == 1 || GunUsed[i][mode] == 9 || GunUsed[i][mode] == 5 || GunUsed[i][mode] == 3)
		{
			if(GunLimit[i][mode] > 0){format(gunstring[0],256,"%s%s ~y~x%d ~p~%d%%~n~~w~",gunstring[0],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
			else{format(gunstring[0],256,"%s%s ~y~x%d~n~~w~",gunstring[0],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
		}
		if(GunUsed[i][mode] == 2 || GunUsed[i][mode] == 10 || GunUsed[i][mode] == 6 || GunUsed[i][mode] == 3)
		{
		    if(GunLimit[i][mode] > 0){format(gunstring[1],256,"%s%s ~y~x%d ~p~%d%%~n~~w~",gunstring[1],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
		    else{format(gunstring[1],256,"%s%s ~y~x%d~n~~w~",gunstring[1],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
		}
		if(GunUsed[i][mode] == 4 || GunUsed[i][mode] == 12 || GunUsed[i][mode] == 6 || GunUsed[i][mode] == 5)
		{
			if(GunLimit[i][mode] > 0){format(gunstring[2],256,"%s%s ~y~x%d ~p~%d%%~n~~w~",gunstring[2],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
			else{format(gunstring[2],256,"%s%s ~y~x%d~n~~w~",gunstring[2],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
		}
		if(GunUsed[i][mode] == 8 || GunUsed[i][mode] == 12 || GunUsed[i][mode] == 10 || GunUsed[i][mode] == 9)
		{
			if(GunLimit[i][mode] > 0){format(gunstring[3],256,"%s%s ~y~x%d ~p~%d%%~n~~w~",gunstring[3],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
			else{format(gunstring[3],256,"%s%s ~y~x%d~n~~w~",gunstring[3],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
		}
		else if(GunUsed[i][mode] == 16)
		{
			if(GunLimit[i][mode] > 0){format(gunstring[4],256,"%s%s ~y~x%d ~p~%d%%~n~~w~",gunstring[4],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
			else{format(gunstring[4],256,"%s%s ~y~x%d~n~~w~",gunstring[4],WeaponNames[i],GunAmmo[i][mode],GunLimit[i][mode]);}
		}
    }
    if(strlen(gunstring[0]) == 13)gunstring[0] = " ";
    if(strlen(gunstring[1]) == 13)gunstring[1] = " ";
    if(strlen(gunstring[2]) == 15)gunstring[2] = " ";
    if(strlen(gunstring[3]) == 14)gunstring[3] = " ";
    if(strlen(gunstring[4]) == 16)gunstring[4] = " ";
    TextDrawSetString(WeaponText[0][mode],gunstring[0]);
    TextDrawSetString(WeaponText[1][mode],gunstring[1]);
    TextDrawSetString(WeaponText[2][mode],gunstring[2]);
    TextDrawSetString(WeaponText[3][mode],gunstring[3]);
    TextDrawSetString(WeaponText[4][mode],gunstring[4]);
    return 1;
}

forward HideWeaponText(playerid,mode);
public HideWeaponText(playerid,mode)
{
    //FunctionLog("HideWeaponText");
    for(new i = 0; i < 5; i++)
    {
   		TextDrawHideForPlayer(playerid,WeaponText[i][mode]);
    }
    return 1;
}

forward ShowMoneyAsHP();
public ShowMoneyAsHP()
{
	if(Players == 0)return 1;
	/*FunctionLogEx("ShowMoneyAsHP");*/
	new oldtime = Ticks,Float:HP[3];
	Ticks++;
	foreach(Player,i)
	{
		if(gSpectating[i] == false && gState[i] == e_STATE_ACTIVE)
 		{
	 		if(gLastUpdate[i] < oldtime)
			{
	 			OnPlayerPause(i);
 			}
		}
		if(ShowDMG[i] == false)
		{
		    ResetPlayerMoney(i);
			GivePlayerMoney(i,-floatround(gArmor + gHealth));
		}
		else
		{
			GetPlayerHealth(i,HP[0]);
			GetPlayerArmour(i,HP[1]);
			HP[2] = HP[0] + HP[1];
			if(HP[2] > 200.0) HP[2] = 200.0;
			if(GetPlayerMoney(i) != -floatround(HP[2]))
			{
			    ResetPlayerMoney(i);
				GivePlayerMoney(i,-floatround(HP[2]));
			}
		}
		/*if(Current != -1 && TabHP == true)//done through OnPlayerUpdate now
		{
			if(Playing[i] == true)
			{
				if(WatchingBase == true || AllowSuicide[i] == false)SetPlayerScore(i,floatround(gArmor + gHealth));
				else SetPlayerScore(i,floatround(HP[2][i]));
			}
			else SetPlayerScore(i,0);
		}*/
	}
	return 1;
}

forward ShowJoinMessages();public ShowJoinMessages(){/*FunctionLogEx("ShowJoinMessages");*/JnP = true;}

forward UpdateInfo(type,id,winner);
public UpdateInfo(type,id,winner)
{
    //FunctionLog("UpdateInfo");
	if(type == BASE)
	{
    	if(!dini_Isset(Basefile(id),"Played"))dini_IntSet(Basefile(id),"Played",1);
    	else dini_IntSet(Basefile(id),"Played",dini_Int(Basefile(id),"Played") + 1);
    	if(TeamStatus[winner] == DEFENDING)
    	{
    		if(!dini_Isset(Basefile(id),"D_Wins"))dini_IntSet(Basefile(id),"D_Wins",1);
    		else dini_IntSet(Basefile(id),"D_Wins",dini_Int(Basefile(id),"D_Wins") + 1);
    		return 1;
		}
		else
		{
    		if(!dini_Isset(Basefile(id),"A_Wins"))dini_IntSet(Basefile(id),"A_Wins",1);
    		else dini_IntSet(Basefile(id),"A_Wins",dini_Int(Basefile(id),"A_Wins") + 1);
    		return 1;
		}
	}
	if(!dini_Isset(Arenafile(id),"Played"))dini_IntSet(Arenafile(id),"Played",1);
	else dini_IntSet(Arenafile(id),"Played",dini_Int(Arenafile(id),"Played") + 1);
	return 1;
}

forward UpdateKD(type,id,stat);
public UpdateKD(type,id,stat)
{
    //FunctionLog("UpdateKD");
	if(type == BASE)
	{
		if(stat == KILL)
		{
	    	if(!dini_Isset(Basefile(id),"Kills"))dini_IntSet(Basefile(id),"Kills",1);
    		else dini_IntSet(Basefile(id),"Kills",dini_Int(Basefile(id),"Kills") + 1);
	    	return 1;
		}
		if(!dini_Isset(Basefile(id),"Deaths"))dini_IntSet(Basefile(id),"Deaths",1);
		else dini_IntSet(Basefile(id),"Deaths",dini_Int(Basefile(id),"Deaths") + 1);
		return 1;
	}
	if(stat == KILL)
	{
		if(!dini_Isset(Arenafile(id),"Kills"))dini_IntSet(Arenafile(id),"Kills",1);
		else dini_IntSet(Arenafile(id),"Kills",dini_Int(Arenafile(id),"Kills") + 1);
 		return 1;
	}
	if(!dini_Isset(Arenafile(id),"Deaths"))dini_IntSet(Arenafile(id),"Deaths",1);
	else dini_IntSet(Arenafile(id),"Deaths",dini_Int(Arenafile(id),"Deaths") + 1);
	return 1;
}

DisplayGetGuns(playerid)
{
    //FunctionLog("DisplayGetGuns");
	new string[128];
	string = "Weapons Available: ";
  	for(new i = 0; i < MAX_WEAPONS; i++)
  	{
     	if(pGunUsed[i] == 1)
     	{
        	if(strlen(string) >= 120)
        	{
        		SendClientMessage(playerid, 0xCCFFFFFF, string);
        		string = " ";
        	}
			format(string,128,"%s  \"%s\" ", string, WeaponNames[i]);
		}
   	}
   	if(strlen(string) > 0)SendClientMessage(playerid, 0xCCFFFFFF, string);
   	return 1;
}

DisplayPlayerGuns(playerid)
{
    //FunctionLog("DisplayPlayerGuns");
	new string[128];
	string = "Your Guns: ";
  	for(new i = 1; i < MAX_SLOTS; i++)
  	{
     	if(PlayerWeapons[playerid][i] > 0)
     	{
        	if(strlen(string) >= 120)
        	{
        		SendClientMessage(playerid, 0xCCFFFFFF, string);
        		string = " ";
        	}
			format(string,128,"%s  \"%s\"", string, WeaponNames[PlayerWeapons[playerid][i]]);
		}
   	}
	if(strlen(string) > 0) SendClientMessage(playerid, 0xCCFFFFFF, string);
   	return 1;
}

DisplayAllGuns(playerid)
{
    //FunctionLog("DisplayAllGuns");
	new string[128];
	string = "Weapon Names and ID's: ";
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if(i == 19 || i == 20 || i == 21 || i == 39 || i == 40 || i >= 43) continue;
		if(strlen(string) >= 120)
		{
			SendClientMessage(playerid, 0xCCFFFFFF, string);
			string = " ";
		}
		format(string,128,"%s  \"%s %d\"", string, WeaponNames[i],i);
	}
	if(strlen(string) > 0) SendClientMessage(playerid, 0xCCFFFFFF, string);
	return 1;
}

GetWeaponModelIDFromName(wname[])
{
    //FunctionLog("GetWeaponModelIDFromName");
    if(strlen(wname) <= 2 && IsNumeric(wname))return -1;
	for(new i; i < 47; i++)
	{
		if(i == 19 || i == 20 || i == 21)continue;
		if(strfind(WeaponNames[i], wname, true) != -1)
		{
			return i;
		}
	}
	return -1;
}

GetWheelModelIDFromName(wname[],value)
{
    //FunctionLog("GetWheelModelIDFromName");
    if(strlen(wname) <= 4 && IsNumeric(wname))
    {
        for(new i; i < 19; i++)
		{
		    if(value == Wheel_Info[i][w_id])
			{
				return i;
			}
		}
    }
	for(new i; i < 19; i++)
	{
		if(strfind(Wheel_Info[i][w_name],wname,true) != -1)
		{
			return i;
		}
	}
	return -1;
}

ResetPlayerVars(playerid)
{
    //FunctionLog("ResetPlayerVars");
	PlayerWorld[playerid] = -1;
	gTeam[playerid] = T_SUB;
	sTeam[playerid] = T_SUB;
	CurrentPlayers[T_SUB]++;
	gSpectateID[playerid] = -1;
	DuelInvitation[playerid] = -1;
	DuelWeapon[playerid][0] = 0;
	DuelWeapon[playerid][1] = 0;
	CurrentMenu[playerid] = 0;
	LockedVehicle[playerid] = -1;
 	ViewingBase[playerid] = -1;
 	ViewingArena[playerid] = -1;
 	BaseEditing[playerid] = -1;
 	ArenaEditing[playerid] = -1;
 	DuelSpectating[playerid] = -1;
 	TR_Kills[playerid] = 0;
	TR_KillersHP[playerid] = -1;
	TR_KillDist[playerid] = 0;
	InVehicle[playerid] = -1;
	PlayerPickup[playerid] = -1;
	pTime[playerid][0] = gTime;
	pTime[playerid][1] = 0;
	pWeather[playerid] = gWeather;
	SetSpawn[playerid] = 0;
	Angle[playerid] = 0.0;
	pClassID[playerid] = 0;
	OldClassID[playerid] = 0;
	Chase_ChaseID[playerid] = -1;
	gState[playerid] = e_STATE_NONE;
	gPlayerHealth[playerid] = gHealth;
	gPlayerArmor[playerid] = gArmor;
	PingChecks[playerid] = 0;
	TotPing[playerid] = 0;
	Variables[playerid][Level] = 0;
	NewVehicle[playerid] = -1;
 	TR_Died[playerid] = false;
 	TR_Suicide[playerid] = false;
 	IsPlayerInMenu[playerid] = false;
 	ViewingResults[playerid] = false;
 	gPlayerSpawned[playerid] = false;
    Playing[playerid] = false;
	AFK[playerid] = false;
 	IsDueling[playerid] = false;
	DuelDisable[playerid] = false;
	DuelWaiting[playerid] = false;
	CorrectPassword[playerid] = false;
	GivenMenu[playerid] = false;
	AllowSuicide[playerid] = true;
	ReAdding[playerid] = false;
	gSpectating[playerid] = false;
	SelectingWeaps[playerid] = false;
	cBugDetect[playerid] = false;
	ShowDMG[playerid] = false;
	GracePeriod[playerid] = true;
	unos[playerid] = false;
	ShowCommands[playerid] = false;
	ShowPMs[playerid] = false;
	DuelArenaCreated[playerid] = false;
	ChangedWeapon[playerid] = true;
	Variables[playerid][Registered] = false;
	Variables[playerid][LoggedIn] = false;
	FirstSelect[playerid] = false;
	PanoShowing[playerid] = false;
	VehInfoShowing[playerid] = false;
	SettingHP[playerid] = false;
	DuelStarting[playerid] = false;
	for(new k; k < MAIN_TEXT; k++)
 	{
		MainTextShowing[playerid][k] = false;
	}
	foreach(Player,i)
	{
	    for(new k; k < PTEXT; k++)
	    {
	    	pTextShowing[playerid][i][k] = false;
		}
	    if(Ignored[i][playerid] == true)
	    {
			Ignored[i][playerid] = false;
		}
		if(DuelIgnored[i][playerid] == true)
	    {
			DuelIgnored[i][playerid] = false;
		}
	}
	
	WorldPass[playerid] = "off";
	AllowPlayerTeleport(playerid,0);
}

SavePlayerTemp(playerid,file[],reason,showhp)
{
    //FunctionLog("SavePlayerTemp");
	new string[128],timeplayed,current,total;
	current = Now() - TimeAtConnect[playerid];
    if(showhp == 1 && Playing[playerid] == true)
    {
        new Float:dh,Float:da;
        GetPlayerHealth(playerid,dh);if(dh > 100.0)dh = 100.0;
        GetPlayerArmour(playerid,da);if(da > 100.0)da = 100.0;
		format(string,sizeof(string),"***  %s  Disconnected  (%s)  (%s)  (Health: %.0f   Armor: %.0f)",RealName[playerid],(reason == 0) ? ("Timeout") : ((reason == 1) ? ("Leaving") : ("Kicked")),ConvertTime(current),dh,da);
		SendClientMessageToAll(grey,string);
    }
    else if(JnP == true)
    {
		format(string,sizeof(string),"***  %s  Disconnected  (%s)  (%s)",RealName[playerid],(reason == 0) ? ("Timeout") : ((reason == 1) ? ("Leaving") : ("Kicked")),ConvertTime(current));
		SendClientMessageToAll(grey,string);
	}
	if(!dini_Isset(file,"TimePlayed"))//first connect
	{
		dini_IntSet(file,"TimePlayed",current);
		dini_IntSet(file,"TS_Kills",TempKills[playerid]);
		dini_IntSet(file,"TS_Deaths",TempDeaths[playerid]);
		dini_IntSet(file,"TS_Tks",TempTKs[playerid]);
		dini_IntSet(file,"LastConnect",Now());
		return 1;
	}
	timeplayed = dini_Int(file,"TimePlayed");
	total = current + timeplayed;
	dini_IntSet(file,"TimePlayed",total);
	dini_IntSet(file,"TS_Kills",TempKills[playerid]);
	dini_IntSet(file,"TS_Deaths",TempDeaths[playerid]);
	dini_IntSet(file,"TS_Tks",TempTKs[playerid]);
	dini_IntSet(file,"LastConnect",Now());
	return 1;
}

LoadPlayerTemp(playerid,file[60])
{
    //FunctionLog("LoadPlayerTemp");
    if(!dini_Isset(file,"LastConnect"))
    {
        TempKills[playerid] = 0;
	    TempDeaths[playerid] = 0;
	    TempTKs[playerid] = 0;
	    dini_IntSet(file,"LastConnect",Now());
		return 1;
    }
    new elapsed = Now() - dini_Int(file,"LastConnect");
	if(elapsed < 1800)
	{
	    TempKills[playerid] = dini_Int(file,"TS_Kills");
	    TempDeaths[playerid] = dini_Int(file,"TS_Deaths");
	    TempTKs[playerid] = dini_Int(file,"TS_TKs");
	}
	else
	{
	    TempKills[playerid] = 0;
	    TempDeaths[playerid] = 0;
	    TempTKs[playerid] = 0;
	}
	dini_IntSet(file,"LastConnect",Now());
	return 1;
}

SendClientMessageToWorld(playerid,world,msg[])
{
    //FunctionLog("SendClientMessageToWorld");
    new string[128];
    format(string,128,"[WORLD %d] %s: %s",world,NickName[playerid],msg);
    foreach(Player,i)
	{
	    if(PlayerWorld[i] == world && Ignored[playerid][i] == false && Playing[i] == false)
	    {
	        SendClientMessage(i,0xFF9A35FF,string);
		}
	}
	return 1;
}

SendWorldMessage(worldid,msg[])
{
    //FunctionLog("SendWorldMessage");
    foreach(Player,i)
	{
	    if(PlayerWorld[i] == worldid)
	    {
	        SendClientMessage(i,MainColors[0],msg);
	    }
	}
	return 1;
}

SendClientWorldMessage(playerid,worldid,msg[])
{
    //FunctionLog("SendClientWorldMessage");
	if(PlayerWorld[playerid] == worldid)SendClientMessage(playerid,MainColors[0],msg);
}

SetPlayerNewWorld(playerid)
{
    //FunctionLog("SetPlayerNewWorld");
	if(PlayerWorld[playerid] == -1)SetPlayerVirtualWorld(playerid,0);
	else SetPlayerVirtualWorld(playerid,PlayerWorld[playerid] + MAX_SERVER_PLAYERS);
}

DisplayPlayersInWorld(playerid,worldid)
{
    //FunctionLog("DisplayPlayersInWorld");
	new string[128];
	string = "Players In World: ";
  	foreach(Player,i)
  	{
     	if(PlayerWorld[i] == worldid)
     	{
        	if(strlen(string) > 128)
        	{
        		SendClientMessage(playerid, 0xCCFFFFFF, string);
        		string = " ";
        	}
			format(string,128,"%s  \"%s\"", string, ListName[i]);
		}
   	}
	if(strlen(string) > 0) SendClientMessage(playerid, 0xCCFFFFFF, string);
   	return 1;
}

ConvertSeconds(seconds)
{
    //FunctionLog("ConvertSeconds");
	new hours,mins,secs,string[100];
	hours = floatround(seconds / 3600);
	mins = floatround((seconds / 60) - (hours * 60));
	secs = floatround(seconds - ((hours * 3600) + (mins * 60)));
	if(hours >= 1)format(string,sizeof(string),"Hours: %d  Minutes: %d  Seconds: %d",hours,mins,secs);
	else if(mins >= 1)format(string,sizeof(string),"Minutes: %d  Seconds: %d",mins,secs);
	else format(string,sizeof(string),"Seconds: %d",secs);
	return string;
}

ConvertTime(seconds)
{
    //FunctionLog("ConvertTime");
	new hours,mins,secs,string[100];
	hours = floatround(seconds / 3600);
	mins = floatround((seconds / 60) - (hours * 60));
	secs = floatround(seconds - ((hours * 3600) + (mins * 60)));
	if(hours >= 1)format(string,sizeof(string),"%d:%02d:%02d",hours,mins,secs);
	else if(mins >= 1)format(string,sizeof(string),"%02d:%02d",mins,secs);
	else format(string,sizeof(string),"%d",secs);
	return string;
}

ConvertToMins(seconds)
{
    //FunctionLog("ConvertToMins");
	new mins,secs,string[10];
	mins = floatround((seconds / 60));
	secs = floatround(seconds - (mins * 60));
	format(string,sizeof(string),"%d:%02d",mins,secs);
	return string;
}

HideAllTextDraws(playerid)
{
    //FunctionLog("HideAllTextDraws");
    new i;
    for(i = 0; i < MAIN_TEXT; i++){TD_HideMainTextForPlayer(playerid,i);}
    for(i = 0; i < PTEXT; i++){if(i != 14 && i != 6)TD_HidepTextForPlayer(playerid,playerid,i);}
	for(i = 0; i < ACTIVE_TEAMS; i++){TextDrawHideForPlayer(playerid, gFinalText4[i]);TextDrawHideForPlayer(playerid, gFinalText3[i]);TextDrawHideForPlayer(playerid, gFinalText2[i]);TextDrawHideForPlayer(playerid, gFinalText1[i]);}
    for(i = 0; i < WEAPON_TEXT; i++){TextDrawHideForPlayer(playerid,WeaponText[i][BASE]);TextDrawHideForPlayer(playerid,WeaponText[i][ARENA]);}
    for(i = 0; i < TOP_SHOTTA; i++){TextDrawHideForPlayer(playerid,TopShotta[i]);}
    for(i = 0; i < ARENA_TEXT; i++){TextDrawHideForPlayer(playerid,ArenaTxt[i]);}
    for(i = 0; i < FINALTEAMTEXT; i++){TextDrawHideForPlayer(playerid,gFinalTeamText[i][0]);TextDrawHideForPlayer(playerid,gFinalTeamText[i][1]);}
    for(i = 0; i < FINALSCOREBOARDTEXT; i++){TextDrawHideForPlayer(playerid,gFinalScoreBoardRounds[i]);}
    PanoShowing[playerid] = false;
	TextDrawHideForPlayer(playerid,MOTD[0][playerid]);
    TextDrawHideForPlayer(playerid,gFinalText);
    TextDrawSetString(MOTD[0][playerid]," ");
}

//FunctionLog(func[])if(Debug == true)print(func);
//FunctionLog(func[])print(func);
//FunctionLogEx(func[])print(func);
CommandLog(cmdtext[])if(Debug == true)print(cmdtext);

RoundTimerStart()
{
    //FunctionLog("RoundTimerStart");
	new string[20],hour,minute,second,time[3];
	gettime(hour,minute,second);
	if(hour > 12){hour = hour-12;time = "PM";}else time = "AM";
	format(string,sizeof(string),"%d:%02d:%02d %s",hour,minute,second,time);
	TR_StartStr = string;
	TR_Start = Now();
}

SaveRoundResults()
{
    //FunctionLog("SaveRoundResults");
	new string[256];
	new hour,minute,second,time[3];
	new Float:ratio,Float:killz,Float:deathz;
	new File:aFile;
	
	new Result[2][5];if(Winner == T_HOME){Result[T_HOME] = "WIN";Result[T_AWAY] = "LOSS";}else{Result[T_HOME] = "LOSS";Result[T_AWAY] = "WIN";}
	
	gettime(hour,minute,second);

	if(hour > 12){hour = hour-12;time = "PM";}else time = "AM";
	format(string,sizeof(string),"\r\n\r\n\r\n\r\nRound %d: Started @ %s, Ended @ %d:%02d:%02d %s (Lasted: %s)",RoundsPlayed,TR_StartStr,hour,minute,second,time,ConvertToMins(Now() - TR_Start));
	aFile = fopen(ResultsFile(), io_append);fwrite(aFile, string);fclose(aFile);printf(string);
    
    if(ModeType == BASE)
    {
		format(string,sizeof(string),"\r\nBase Played: %s (ID %d)",LocationName[Current][BASE],Current);
		aFile = fopen(ResultsFile(), io_append);fwrite(aFile, string);fclose(aFile);printf(string);
		for(new t; t < 2; t++)
		{
			killz = TeamTempScore[t];deathz = TeamTempDeaths[t];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
			if(Winner == t)
			{
 				if(TeamStatus[t] == ATTACKING)format(string,sizeof(string),"\r\n\r\n>>>> Team: %s (%s) | %s (%s)  |  Kills: %d  |  Deaths: %d  |  Ratio: %.02f  |  Life Remaining: %d  |  Vehicles Used: %d  |  Highest Dmg: %.0f (%.0f)",TeamName[t],TeamStatusStr[t],Result[t],TR_WinReason,TeamTempScore[t],TeamTempDeaths[t],ratio,Team_GetHP(t),VehiclesSpawned[t],TeamHighestCombo[t][1],TeamHighestCombo[t][0]);
 				else format(string,sizeof(string),"\r\n\r\n>>>> Team: %s (%s) | %s (%s)  |  Kills: %d  |  Deaths: %d  |  Ratio: %.02f  |  Life Remaining: %d  |  Highest Dmg: %.0f (%.0f)",TeamName[t],TeamStatusStr[t],Result[t],TR_WinReason,TeamTempScore[t],TeamTempDeaths[t],ratio,Team_GetHP(t),TeamHighestCombo[t][1],TeamHighestCombo[t][0]);
			}
			else
			{
				if(TeamStatus[t] == ATTACKING)format(string,sizeof(string),"\r\n\r\n>>>> Team: %s (%s)  |  %s  |  Kills: %d  |  Deaths: %d  |  Ratio: %.02f  |  Vehicles Used: %d  |  Highest Dmg: %.0f (%.0f)",TeamName[t],TeamStatusStr[t],Result[t],TeamTempScore[t],TeamTempDeaths[t],ratio,VehiclesSpawned[t],TeamHighestCombo[t][1],TeamHighestCombo[t][0]);
				else format(string,sizeof(string),"\r\n\r\n>>>> Team: %s (%s)  |  %s  |  Kills: %d  |  Deaths: %d  |  Ratio: %.02f  |  Highest Dmg: %.0f (%.0f)",TeamName[t],TeamStatusStr[t],Result[t],TeamTempScore[t],TeamTempDeaths[t],ratio,TeamHighestCombo[t][1],TeamHighestCombo[t][0]);
			}
			aFile = fopen(ResultsFile(), io_append);fwrite(aFile, string);fclose(aFile);printf(string);
			SaveShit(t);
		}
	}
	else
	{
	    new locc[STR];
	    if(strlen(LocationName[Current][ARENA]))locc = LocationName[Current][ARENA];
	    else locc = "N/A";
	    format(string,sizeof(string),"\r\nMap Played: %s (ID %d)",locc,Current);
		aFile = fopen(ResultsFile(), io_append);fwrite(aFile, string);fclose(aFile);printf(string);
		for(new t = 0; t < ACTIVE_TEAMS; t++)
		{
		    if(TeamUsed[t] == true)
		    {
		    	SaveHeader(t);
	    		SaveShit(t);
			}
		}
	}
	return 1;
}

SaveHeader(t)
{
    //FunctionLog("SaveHeader");
    new string[128],Float:ratio,Float:killz,Float:deathz;
	new Result[5];if(Winner == t)Result = "WIN";else Result = "LOSS";
    killz = TeamTempScore[t];deathz = TeamTempDeaths[t];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
    format(string,sizeof(string),"\r\n\r\n>>>> Team: %s | %s | Kills: %d | Deaths: %d | Ratio: %.02f",TeamName[t],Result,TeamTempScore[t],TeamTempDeaths[t],ratio);
	new File:aFile = fopen(ResultsFile(), io_append);fwrite(aFile, string);fclose(aFile);printf(string);
	return 1;
}

SaveShit(t)
{
    //FunctionLog("SaveShit");
    new bool:Excluded[MAX_SERVER_PLAYERS], highest_kills = -1, x, amt;
    new entry2[128], gstring[256];
    new File:aFile = aFile = fopen(ResultsFile(), io_append);
 	for(new i; i <= HighestID; i++)
	{
	    if(Excluded[i] == false && HasPlayed[i] == true && gTeam[i] == t && TR_Kills[i] > highest_kills)
	    {
         	for(x = 0; x <= HighestID; x++)
			{
			    if(x != i && Excluded[x] == false && HasPlayed[i] == true && gTeam[x] == t && TR_Kills[x] > TR_Kills[i])
			    {
			        i = x;
			    }
			}
			if(TR_Died[i] == false)format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d  |  Died: NO",ListName[i],TR_Kills[i]);
			else if(TR_Suicide[x] == true)format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d  |  Died: YES (SUICIDE)",ListName[i],TR_Kills[i]);
			else format(entry2,sizeof(entry2),"\r\n » %s: Kills: %d  |  Died: YES  |  Killer: %s  (%s)  (HP: %.0f)  (Dist: %.2f FT)",ListName[i],TR_Kills[i],TR_KilledBy[i],DeathReason2Name(TR_KilledWith[i]),TR_KillersHP[i],TR_KillDist[i]);
			fwrite(aFile, entry2);
			printf(entry2);
			
			gstring = "\r\n » Weapon Info:";
			for(new g = 1; g < MAX_SLOTS; g++)
			{
				if(TR_StartGun[i][g][GUN] > 0 && TR_StartGun[i][g][AMMO] == 1)format(gstring,sizeof(gstring),"%s   (%s)",gstring,WeaponNames[TR_StartGun[i][g][GUN]]);
				else if(TR_StartGun[i][g][AMMO] > 1)format(gstring,sizeof(gstring),"%s   (%s, Ammo: %d, Used: %d)",gstring,WeaponNames[TR_StartGun[i][g][GUN]],TR_StartGun[i][g][AMMO],(TR_StartGun[i][g][AMMO] - TR_EndGun[i][g][AMMO]));
			}
			format(gstring,sizeof(gstring),"%s\r\n",gstring);
			fwrite(aFile, gstring);
			printf(gstring);
			
			Excluded[i] = true;
			highest_kills = -1;
			i = 0;
			amt++;
			if(amt > CurrentPlayers[t])break;
	    }
	}
	fclose(aFile);
	return 1;
}

DeathReason2Name(weaponid)
{
    //FunctionLog("DeathReason2Name");
	if(weaponid > 54 || weaponid < 0)return WeaponNames[19];
	else return WeaponNames[weaponid];
}

SetTeam(playerid,teamid)
{
    //FunctionLog("SetTeam");
	if(gTeam[playerid] == teamid && sTeam[playerid] == teamid)return 1;
	CurrentPlayers[gTeam[playerid]]--;
    gTeam[playerid] = teamid;
    sTeam[playerid] = teamid;
    ffTeam[playerid] = teamid;
    CurrentPlayers[teamid]++;
    return 1;
}

forward UpdatePrefixName(playerid);
public UpdatePrefixName(playerid)
{
    //FunctionLog("UpdatePrefixName");
	if(sTeam[playerid] != gTeam[playerid] && gPlayerSpawned[playerid] == true)
	{
    	new newname[24];
		format(newname,sizeof(newname),"%s_%s",TeamName[sTeam[playerid]],NickName[playerid]);
		SetPlayerName(playerid,newname);
	}
	else
	{
	    SetPlayerName(playerid,NickName[playerid]);
	}
}

AddSubs(playerid)
{
    //FunctionLog("AddSubs");
    if(Current == -1)return 1;
	if(UseSubs == true)
	{
	    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    	new Float:Health,Float:Armor;
		new sub = Team_GetFirstSub(gTeam[playerid]);
		if(IsPlayerConnected(sub))
		{
			GetPlayerHealth(playerid,Health);
			GetPlayerArmour(playerid,Armor);
			GetPlayerPos(playerid,PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]);
			GetPlayerFacingAngle(playerid,PlayerPosition[playerid][3]);
			GetPlayerWeapons(playerid);

			if(gSpectating[sub] == true)Spectate_Stop(sub);
			SetPlayerPos(sub,PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]);
			SetPlayerFacingAngle(sub,PlayerPosition[playerid][3]);
			SetCameraBehindPlayerEx(sub);
			ResetPlayerWeapons(sub);
			WeaponSet[sub][0][MODE] = WeaponSet[playerid][0][MODE];
			WeaponSet[sub][1][MODE] = WeaponSet[playerid][1][MODE];
			WeaponSet[sub][2][MODE] = WeaponSet[playerid][2][MODE];
			WeaponSet[sub][3][MODE] = WeaponSet[playerid][3][MODE];
			GivePlayerWeapons(sub,playerid);
			SetPlayerLife(sub,Health,Armor);
			SetPlayerVirtualWorld(sub,1);
			SetPlayerColorEx(sub,TeamActiveColors[sTeam[sub]]);
			TogglePlayerControllable(sub,1);
			SetTeam(sub,sTeam[sub]);
			UpdatePrefixName(sub);
			SetPlayingName(sub);
			Playing[sub] = true;
			
			if(ModeType != BASE)
			{
		    	GangZoneShowForPlayer(sub,zone,TeamGZColors[T_AWAY]);
    			GangZoneFlashForPlayer(sub,zone,TeamGZColors[T_HOME]);
			}
			
			new string[128];
			format(string,sizeof(string),"*** \"%s\" has been substituted for \"%s\" because of a timeout.",NickName[playerid],NickName[sub]);
			SendClientMessageToAll(MainColors[0],string);
			return 1;
		}
	}
	else SaveTimedPlayer(playerid);
	return 1;
}

SaveTimedPlayer(playerid)
{
    if(Current == -1)return 1;
    //FunctionLog("SaveTimedPlayer");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
    new Float:Health,Float:Armor;
    new file[64],string[100];
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	GetPlayerWeapons(playerid);
	GetPlayerHealth(playerid,Health);
	GetPlayerArmour(playerid,Armor);
	GetPlayerPos(playerid,PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2]);
	GetPlayerFacingAngle(playerid,PlayerPosition[playerid][3]);
 	dini_FloatSet(file,"Health",Health);
	dini_FloatSet(file,"Armor",Armor);
	dini_IntSet(file,"Playing",1);
	format(string,sizeof(string),"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",TempGuns[playerid][0][GUN],TempGuns[playerid][1][GUN],TempGuns[playerid][2][GUN],TempGuns[playerid][3][GUN],TempGuns[playerid][4][GUN],TempGuns[playerid][5][GUN],TempGuns[playerid][6][GUN],TempGuns[playerid][7][GUN],TempGuns[playerid][8][GUN],TempGuns[playerid][9][GUN],TempGuns[playerid][10][GUN],TempGuns[playerid][11][GUN],TempGuns[playerid][12][GUN]);
	dini_Set(file,"Weapons",string);
	format(string,sizeof(string),"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",TempGuns[playerid][0][AMMO],TempGuns[playerid][1][AMMO],TempGuns[playerid][2][AMMO],TempGuns[playerid][3][AMMO],TempGuns[playerid][4][AMMO],TempGuns[playerid][5][AMMO],TempGuns[playerid][6][AMMO],TempGuns[playerid][7][AMMO],TempGuns[playerid][8][AMMO],TempGuns[playerid][9][AMMO],TempGuns[playerid][10][AMMO],TempGuns[playerid][11][AMMO],TempGuns[playerid][12][AMMO]);
	dini_Set(file,"Ammo",string);
	format(string,sizeof(string),"%.4f,%.4f,%.4f,%.4f",PlayerPosition[playerid][0],PlayerPosition[playerid][1],PlayerPosition[playerid][2],PlayerPosition[playerid][3]);dini_Set(file,"Pos",string);
	format(string,sizeof(string),"%d,%d,%d,%d",WeaponSet[playerid][0][MODE],WeaponSet[playerid][1][MODE],WeaponSet[playerid][2][MODE],WeaponSet[playerid][3][MODE]);dini_Set(file,"wSets",string);
	dini_IntSet(file,"Team",gTeam[playerid]);
	dini_IntSet(file,"RoundCode",RoundCode);
	Playing[playerid] = false;
	UpdateRoundII();
	SendClientMessageToAll(TeamActiveColors[gTeam[playerid]],"*** Player saved and ready to be re-added.");
	return 1;
}

forward Advert();public Advert(){SendClientMessageToAll(0xFF9224FF,"»»» You are currently playing the \"BattleGrounds\" mode brought to you by [BB] Team Visit us at www.theBBClan.com");SendClientMessageToAll(0xFF9224FF,"»»» Use /help, /commands, and /credits for more info.");}
IsWeaponUAV(weaponid){/*FunctionLogEx("IsUAVWeapon");*/switch(weaponid){case 22,24,25,26,27,28,29,30,31,32,33,34,35,36,38:return 1;}return 0;}

forward AllowSuicides();
public AllowSuicides()
{
    //FunctionLog("AllowSuicides");
    foreach(Player,i)
	{
	    AllowSuicide[i] = true;
	}
	UpdateRoundII();
	return 1;
}

UpdateMapName()
{
    //FunctionLog("UpdateMapName");
    if(PrivateMode == true)
    {
        SendRconCommand("mapname Private");
        SendRconCommand("worldtime Private");
    }
	else if(Current != -1)
	{
	    new ModeName[6] = "Base",string[128],string2[64];
	    if(ModeType == ARENA)ModeName = "Arena";
	    else if(ModeType == TDM)ModeName = "TDM";
	    
	    if(ModeType == BASE)
	    {
	        format(string2,64,"%s/%d, %s/%d",TeamName[T_HOME],TeamTotalScore[T_HOME],TeamName[T_AWAY],TeamTotalScore[T_AWAY]);
	    }
	    else
	    {
	    	for(new i = 0; i < ACTIVE_TEAMS; i++)
			{
			    if(TeamUsed[i] == true)
			    {
			        format(string2,64,"%s%s/%d,",string2,TeamName[i],TeamTotalScore[i]);
				}
			}
		}
	    
	    format(string,sizeof(string),"mapname %s: %d(%s)",ModeName,Current,string2);
	    SendRconCommand(string);
		format(string,64,"%s #%d",ModeName,Current);
	    foreach(Player,i)
		{
		    if(gSelectingClass[i] == false)
		    {
				TD_ShowMainTextForPlayer(i,12);
			}
		}
	    TextDrawSetString(MainText[12],string);
	}
	else
	{
	    if(GameMap == SA)SendRconCommand("mapname (SA) Atrium");
	    else SendRconCommand("mapname (VCLC) Atrium");
	}
	return 1;
}

SaveSelectionScreen(playerid,comment[])
{
    //FunctionLog("SaveSelectionScreen");
    new Float:Pos[3],IntR;
	GetPlayerPos(playerid,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid]);
	GetPlayerFacingAngle(playerid,PlayerPosition[3][playerid]);
	IntR = GetPlayerInterior(playerid);
	
	GetPlayerPos(playerid,Pos[0],Pos[1],Pos[2]);
    GetPosInFrontOfPlayer(playerid,Pos[0],Pos[1],4.0);
    
	new string[128];
	format(string,sizeof(string),"\n\r{%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%d}, //%s - %s",PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid],PlayerPosition[3][playerid],Pos[0],Pos[1],Pos[2],IntR,RealName[playerid],comment);
	print(string);
	new File:aFile = fopen("/attackdefend/selection_screens.txt",io_append);fwrite(aFile,string);fclose(aFile);
 	format(string,sizeof(string),"*** Selection Screen Saved! (Int: %d) (%s)",IntR,comment);
	SendClientMessage(playerid,MainColors[3],string);
	return 1;
}

/*SaveMOTDLoc(playerid,comment[])
{
    //FunctionLog("SaveSelectionScreen");
	GetPlayerPos(playerid,PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid]);
	GetPlayerFacingAngle(playerid,PlayerPosition[3][playerid]);
	new string[128];
	format(string,sizeof(string),"{%.3f,%.3f,%.3f}, //%s - %s",PlayerPosition[0][playerid],PlayerPosition[1][playerid],PlayerPosition[2][playerid],PlayerPosition[3][playerid],comment);
	print(string);
 	format(string,sizeof(string),"*** MOTD LOC Saved! (%s)",comment);
	SendClientMessage(playerid,MainColors[3],string);
	return 1;
}*/

forward XTime();
public XTime()
{
    /*FunctionLogEx("XTime");*/
 	Xsecond++;
	if(Xsecond == 59){Xsecond = 0;Xminute++;}
	if(Xminute == 24)Xminute = 0;
    if(UseClock == true)
	{
	    foreach(Player,i)
		{
		    SetPlayerNewTime(i,Xminute,Xsecond);
		}
		SetTimer("XTime",1000,0);
	}
	else SetGlobalTime(gTime);
	return 1;
}

SetGlobalTime(time)
{
    //FunctionLog("SetGlobalTime");
	if(UseClock == false)SetWorldTime(time);
	else Xminute = time;
}

GetPlayerWeapons(playerid)
{
    //FunctionLog("GetPlayerWeapons");
	GetPlayerWeaponData(playerid,2,TempGuns[playerid][2][GUN],TempGuns[playerid][2][AMMO]);
	GetPlayerWeaponData(playerid,3,TempGuns[playerid][3][GUN],TempGuns[playerid][3][AMMO]);
	GetPlayerWeaponData(playerid,4,TempGuns[playerid][4][GUN],TempGuns[playerid][4][AMMO]);
	GetPlayerWeaponData(playerid,5,TempGuns[playerid][5][GUN],TempGuns[playerid][5][AMMO]);
	GetPlayerWeaponData(playerid,6,TempGuns[playerid][6][GUN],TempGuns[playerid][6][AMMO]);
	GetPlayerWeaponData(playerid,7,TempGuns[playerid][7][GUN],TempGuns[playerid][7][AMMO]);
	GetPlayerWeaponData(playerid,8,TempGuns[playerid][8][GUN],TempGuns[playerid][8][AMMO]);
	GetPlayerWeaponData(playerid,9,TempGuns[playerid][9][GUN],TempGuns[playerid][9][AMMO]);
	GetPlayerWeaponData(playerid,10,TempGuns[playerid][10][GUN],TempGuns[playerid][10][AMMO]);
	GetPlayerWeaponData(playerid,1,TempGuns[playerid][1][GUN],TempGuns[playerid][1][AMMO]);if(TempGuns[playerid][1][AMMO] > 1)TempGuns[playerid][1][AMMO] = 1;
	GetPlayerWeaponData(playerid,11,TempGuns[playerid][11][GUN],TempGuns[playerid][11][AMMO]);if(TempGuns[playerid][11][AMMO] > 1)TempGuns[playerid][11][AMMO] = 1;
	GetPlayerWeaponData(playerid,12,TempGuns[playerid][12][GUN],TempGuns[playerid][12][AMMO]);if(TempGuns[playerid][12][AMMO] > 1)TempGuns[playerid][12][AMMO] = 1;
	if(IsPlayerInAnyVehicle(playerid))TempGuns[playerid][4][AMMO] = GetPlayerAmmo(playerid);
	return 1;
}

GetPlayerEndWeapons(playerid)
{
    //FunctionLog("GetPlayerEndWeapons");
    if(Stored[playerid] == true)return 1;
    GetPlayerWeaponData(playerid,2,TR_EndGun[playerid][2][GUN],TR_EndGun[playerid][2][AMMO]);
	GetPlayerWeaponData(playerid,3,TR_EndGun[playerid][3][GUN],TR_EndGun[playerid][3][AMMO]);
	GetPlayerWeaponData(playerid,4,TR_EndGun[playerid][4][GUN],TR_EndGun[playerid][4][AMMO]);
	GetPlayerWeaponData(playerid,5,TR_EndGun[playerid][5][GUN],TR_EndGun[playerid][5][AMMO]);
	GetPlayerWeaponData(playerid,6,TR_EndGun[playerid][6][GUN],TR_EndGun[playerid][6][AMMO]);
	GetPlayerWeaponData(playerid,7,TR_EndGun[playerid][7][GUN],TR_EndGun[playerid][7][AMMO]);
	GetPlayerWeaponData(playerid,8,TR_EndGun[playerid][8][GUN],TR_EndGun[playerid][8][AMMO]);
	GetPlayerWeaponData(playerid,9,TR_EndGun[playerid][9][GUN],TR_EndGun[playerid][9][AMMO]);
	GetPlayerWeaponData(playerid,10,TempGuns[playerid][10][GUN],TR_EndGun[playerid][10][AMMO]);
	GetPlayerWeaponData(playerid,1,TR_EndGun[playerid][1][GUN],TR_EndGun[playerid][1][AMMO]);if(TempGuns[playerid][1][AMMO] > 1)TR_EndGun[playerid][1][AMMO] = 1;
	GetPlayerWeaponData(playerid,11,TR_EndGun[playerid][11][GUN],TR_EndGun[playerid][11][AMMO]);if(TempGuns[playerid][11][AMMO] > 1)TR_EndGun[playerid][11][AMMO] = 1;
	GetPlayerWeaponData(playerid,12,TR_EndGun[playerid][12][GUN],TR_EndGun[playerid][12][AMMO]);if(TempGuns[playerid][12][AMMO] > 1)TR_EndGun[playerid][12][AMMO] = 1;
	Stored[playerid] = true;
	return 1;
}

forward GivePlayerWeapons(giveplayer,getplayer);
public GivePlayerWeapons(giveplayer,getplayer)
{
    //FunctionLog("GivePlayerWeapons");
    if(DuelSpectating[giveplayer] != -1)return 1;
    for(new x = 1; x < MAX_SLOTS; x++)
	{
		if(TempGuns[getplayer][x][AMMO] > 0 && TempGuns[getplayer][x][GUN] > 0)
		{
		    if(TempGuns[getplayer][x][GUN] == LastWeapon[getplayer])GivePlayerWeapon(giveplayer,TempGuns[getplayer][x][GUN],TempGuns[getplayer][x][AMMO] - 1);
			else GivePlayerWeapon(giveplayer,TempGuns[getplayer][x][GUN],TempGuns[getplayer][x][AMMO]);
		}
	}
	GivePlayerWeapon(giveplayer,LastWeapon[giveplayer],1);
	return 1;
}

forward GivePlayerReAddWeapons(playerid);
public GivePlayerReAddWeapons(playerid)
{
    //FunctionLog("GivePlayerReAddWeapons");
    for(new x = 1; x < MAX_SLOTS; x++)
	{
		if(ReAddWeps[playerid][x][AMMO] > 0 && ReAddWeps[playerid][x][GUN] > 0)
		{
		    GivePlayerWeapon(playerid,ReAddWeps[playerid][x][GUN],ReAddWeps[playerid][x][AMMO]);
		}
	}
	SetPlayerVirtualWorld(playerid,1);
	return 1;
}

forward LoadJnP();
public LoadJnP()
{
    //FunctionLog("LoadJnP");
	JnP = bool:dini_Int(gConfigFile(),"JnP");//printf("JnP=%d",JnP);
}

forward DisableGunMenu();
public DisableGunMenu()
{
	AllowGunMenu = false;
}

forward RotateBirdView();
public RotateBirdView()
{
    /*FunctionLogEx("RotateBirdView");*/
	if(WatchingBase == false)
	{
	    foreach(Player,i)
		{
		    if(Playing[i] == true)
		    {
				SetCameraBehindPlayerEx(i);
				TogglePlayerControllable(i,1);
			}
		}
	    times = 0.0;
		return 1;
	}
	new Float:CP[2];CP[0] = TmpCP[0];CP[1] = TmpCP[1];
	CP[0] += (200.0 * floatsin(times, degrees));
	CP[1] += (200.0 * floatcos(times, degrees));
	if(ModeType == BASE)
	{
	    foreach(Player,i)
	    {
		    if(Playing[i] == true && FinishedMenu[i] == false)
		    {
                SetPlayerCameraPos(i,CP[0],CP[1],TmpCP[2]+80);
                SetPlayerCameraLookAt(i,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
			}
		}
	}
	else
	{
		foreach(Player,i)
		{
		    if(Playing[i] == true)
		    {
				SetPlayerCameraPos(i,CP[0],CP[1],TmpCP[2]+80);
				SetPlayerCameraLookAt(i,ArenaCP[Current][0],ArenaCP[Current][1],ArenaCP[Current][2]);
			}
		}
	}
	if(times >= 360.0)times = 0.0;
	else times++;
	SetTimer("RotateBirdView",50,0);
	return 1;
}

SpawnPlayersInCircle(teamid)
{
    //FunctionLog("SpawnPlayersInCircle");
    new Float:XYZ[3];
	if(ModeType == BASE)
	{
		if(TeamStatus[teamid] == ATTACKING){XYZ[0] = TeamBaseSpawns[Current][0][ATTACKING];XYZ[1] = TeamBaseSpawns[Current][1][ATTACKING];XYZ[2] = TeamBaseSpawns[Current][2][ATTACKING];}
		else{XYZ[0] = TeamBaseSpawns[Current][0][DEFENDING];XYZ[1] = TeamBaseSpawns[Current][1][DEFENDING];XYZ[2] = TeamBaseSpawns[Current][2][DEFENDING];}
	}
	else
	{
	    XYZ[0] = TeamArenaSpawns[Current][0][teamid];XYZ[1] = TeamArenaSpawns[Current][1][teamid];XYZ[2] = TeamArenaSpawns[Current][2][teamid];
	}
	new Float:newXY[2];
	new Float:spin_amt = (360.0 / float(CurrentPlayers[teamid]));
	new Float:spacing = (float(CurrentPlayers[teamid]) * 0.10) + 1;
	new Float:spin;
	foreach(Player,i)
	{
 		if(gTeam[i] == teamid)
 		{
 		    spin -= spin_amt;
			newXY[0] = XYZ[0];
			newXY[1] = XYZ[1];
			newXY[0] += (spacing * floatsin(spin, degrees));
			newXY[1] += (spacing * floatcos(spin, degrees));
			//SetSpawnInfo(i,i,FindPlayerSkin(i),newXY[0],newXY[1],XYZ[2],360 - spin,0,0,0,0,0,0);
			SetPlayerPos(i,newXY[0],newXY[1],XYZ[2]);
			SetPlayerFacingAngle(i,360 - spin);
		}
	}
	return 1;
}

forward RotatePlayer(playerid);
public RotatePlayer(playerid)
{
    /*FunctionLogEx("RotatePlayer");*/
	if(!IsPlayerConnected(playerid))return 1;
	Angle[playerid]+=7.5;
	SetPlayerFacingAngle(playerid,Angle[playerid]);
	if(Angle[playerid] >= 360.0)Angle[playerid] = 0.0;
	
	new Float:XY[2];XY[0] = Horiz[playerid][0];XY[1] = Horiz[playerid][1];
	if(GameMap == SA)
 	{
 	    if(VertDirect[playerid] == UP)
 	    {
 	        if(Vert[playerid] > (sScreenSA[cSelect[playerid]][s_cz]+1.4))
	 		{
	 		    VertLookAt[playerid]-=0.01;
	 	    	Vert[playerid]-=0.02;
	 	    	VertDirect[playerid] = DOWN;
	 		}
	 		else
	 		{
	 		    VertLookAt[playerid]+=0.01;
	 	    	Vert[playerid]+=0.02;
	 		}
 	    }
 	    else //DOWN
 	    {
 	        if(Vert[playerid] < (sScreenSA[cSelect[playerid]][s_cz]-0.8))
	 		{
	 		    VertLookAt[playerid]+=0.01;
	 	    	Vert[playerid]+=0.02;
	 	    	VertDirect[playerid] = UP;
	 		}
	 		else
	 		{
	 		    VertLookAt[playerid]-=0.01;
	 	    	Vert[playerid]-=0.02;
	 		}
 	    }
 	    XY[0] += (2.0 * floatsin(rottimes[playerid], degrees));
		XY[1] += (2.0 * floatcos(rottimes[playerid], degrees));
		rottimes[playerid]+=2;
 	    SetPlayerCameraLookAt(playerid,sScreenSA[cSelect[playerid]][s_x],sScreenSA[cSelect[playerid]][s_y],VertLookAt[playerid]);//to make it spin from the center and look around use the camera X and Y
		SetPlayerCameraPos(playerid,XY[0],XY[1],Vert[playerid]);
		if(rottimes[playerid] >= 360.0)rottimes[playerid] = 0.0;
	}
	else
	{
		if(VertDirect[playerid] == UP)
 	    {
 	        if(Vert[playerid] > (sScreenGTAU[cSelect[playerid]][s_cz]+1.4))
	 		{
	 	    	Vert[playerid]-=0.02;
	 	    	VertDirect[playerid] = DOWN;
	 		}
	 		else
	 		{
	 	    	Vert[playerid]+=0.02;
	 		}
 	    }
 	    else //DOWN
 	    {
 	        if(Vert[playerid] < (sScreenGTAU[cSelect[playerid]][s_cz]-0.8))
	 		{
	 	    	Vert[playerid]+=0.02;
	 	    	VertDirect[playerid] = UP;
	 		}
	 		else
	 		{
	 	    	Vert[playerid]-=0.02;
	 		}
 	    }
 	    XY[0] += (2.0 * floatsin(rottimes[playerid], degrees));
		XY[1] += (2.0 * floatcos(rottimes[playerid], degrees));
		rottimes[playerid]++;
		SetPlayerCameraLookAt(playerid,sScreenGTAU[cSelect[playerid]][s_x],sScreenGTAU[cSelect[playerid]][s_y],sScreenGTAU[cSelect[playerid]][s_z]);
		SetPlayerCameraPos(playerid,XY[0],XY[1],Vert[playerid]);
		if(rottimes[playerid] >= 360.0)rottimes[playerid] = 0.0;
	}
	if(gPlayerSpawned[playerid] == false && Rotating[playerid] == true)return SetTimerEx("RotatePlayer",50,0,"i",playerid);
	else return SetCameraBehindPlayer(playerid);
}

forward ReSetPlayerColorEx(playerid);
public ReSetPlayerColorEx(playerid)
{
    //FunctionLog("ReSetPlayerColorEx");
	if(Playing[playerid] == true)return SetPlayerColorEx(playerid,TeamActiveColors[gTeam[playerid]]);
	else if(gPlayerSpawned[playerid] == true)return SetPlayerColorEx(playerid,TeamInactiveColors[gTeam[playerid]]);
	return SetPlayerColorEx(playerid,grey);
}

forward StartAutoMode();
public StartAutoMode()
{
    //FunctionLog("StartAutoMode");
    switch(AutoMode)
	{
	    case BASE:
		{
			new rand = random(MAX_EXISTING[BASE]);
 			if(!BaseExists[rand])return StartAutoMode();
 			if(Randomization == true)
 			{
 				Team_Randomize2();
				return SetTimerEx("StartRoundBASE",500,0,"ii",rand,1);
			}
			StartRoundBASE(rand,1);
		}
	    case ARENA:
		{
		    new rand = random(MAX_EXISTING[ARENA]);
	    	if(!ArenaExists[rand])return StartAutoMode();
	    	StartRoundARENA(rand,ARENA,1);
		}
	    case TDM:
		{
		    new rand = random(MAX_EXISTING[ARENA]);
	    	if(!ArenaExists[rand])return StartAutoMode();
	    	StartRoundARENA(rand,TDM,1);
		}
		default:
		{
			return 1;
		}
	}
	return 1;
}

forward AutoModeInit();
public AutoModeInit()
{
    /*FunctionLogEx("AutoModeInit");*/
	StopCounting[2][0] = StopCounting[2][1];
	TextDrawColor(MainText[0],MainColors[3]);
	AutoModeActive = true;
	return SetTimer("UpdateAutoMode",1000,0);
}

forward UpdateAutoMode();
public UpdateAutoMode()
{
	if(Current != -1)return 1;
    /*FunctionLogEx("UpdateAutoMode");*/
	if(AutoMode == -1)
	{
		AutoModeActive = false;
		foreach(Player,x)
		{
	       	TD_HideMainTextForPlayer(x,0);
		}
		return 1;
	}
	StopCounting[2][0]--;
	if(StopCounting[2][0] <= 0)return StartAutoMode();
	else
	{
		new string[128];
		if(AutoMode == BASE)format(string,128,"Random Base Starting in %d Seconds...",StopCounting[2][0]);
		else if(AutoMode == ARENA)format(string,128,"Random Arena Starting in %d Seconds...",StopCounting[2][0]);
		else format(string,128,"Random TDM Starting in %d Seconds...",StopCounting[2][0]);
		
		TextDrawSetString(MainText[0],string);
		foreach(Player,x)
		{
	    	if(gSelectingClass[x] == false)
	    	{
				TD_ShowMainTextForPlayer(x,0);
			}
		}
	}
	return SetTimer("UpdateAutoMode",1000,0);
}

forward UpdateRoundClock();
public UpdateRoundClock()
{
	if(Current == -1)return 1;
    /*FunctionLogEx("UpdateRoundClock");*/
	new string[20];
	format(string,20,"%02d:%02d",ModeMin,ModeSec);
	TextDrawSetString(MainText[9],string);
    foreach(Player,x)
	{
	    if(gSelectingClass[x] == false)
	    {
			TD_ShowMainTextForPlayer(x,9);
		}
	}
	if(ModeMin == 2 && ModeSec < 3)//2 minute warning
	{
	    foreach(Player,i)
		{
		    if(Playing[i] == true)
		    {
	 			PlayerPlaySound(i,1147,0.0,0.0,0.0);
	 			GameTextForPlayer(i,"~n~~n~~n~~n~~n~~r~2 minute ~y~Warning",3000,3);
			}
		}
	}
	else if(ModeMin == 0 && ModeSec < 11)
	{
	    foreach(Player,i)
		{
		    if(Playing[i] == true)
		    {
	 			PlayerPlaySound(i,1056,0.0,0.0,0.0);
			}
		}
	}
	return 1;
}

Duel_SetPlayerPos(spot,playerid)
{
    //FunctionLog("Duel_SetPlayerPos");
	if(spot == 0)
	{
	    if(GameMap == SA)
	    {
	        SetPlayerPos(playerid,DuelPos[0][0],DuelPos[0][1],DuelPos[0][2]);
			SetPlayerFacingAngle(playerid,DuelPos[0][3]);
	    }
	    else
	    {
	        SetPlayerPos(playerid,DuelPos[3][0],DuelPos[3][1],DuelPos[3][2]);
	        SetPlayerFacingAngle(playerid,DuelPos[3][3]);
		}
	}
	else if(spot == 1)
	{
	    if(GameMap == SA)
	    {
	        SetPlayerPos(playerid,DuelPos[1][0],DuelPos[1][1],DuelPos[1][2]);
			SetPlayerFacingAngle(playerid,DuelPos[1][3]);
	    }
	    else
	    {
	        SetPlayerPos(playerid,DuelPos[4][0],DuelPos[4][1],DuelPos[4][2]);
	        SetPlayerFacingAngle(playerid,DuelPos[4][3]);
		}
	}
	else
	{
	    if(GameMap == SA)
	    {
	        //SetPlayerPos(playerid,DuelPos[2][0],DuelPos[2][1],DuelPos[2][2]);
	        //SetPlayerFacingAngle(playerid,DuelPos[2][3]);
	        new sp = random(12) + 2;
			SetPlayerPos(playerid,DuelPos[sp][0],DuelPos[sp][1],DuelPos[sp][2]);
			SetPlayerFacingAngle(playerid,DuelPos[sp][3]);
	    }
	    else
	    {
	        SetPlayerPos(playerid,DuelPos[5][0],DuelPos[5][1],DuelPos[5][2]);
	        SetPlayerFacingAngle(playerid,DuelPos[5][3]);
		}
	}
	return 1;
}

GetVehicleModelIDFromName(vname[])
{
    //FunctionLog("GetVehicleModelIDFromName");
    if(IsNumeric(vname))return -1;
	for(new i = 0; i <= 211; i++)
	{
		if(strfind(CarList[i],vname,true) != -1)
			return i+400;
	}
	return -1;
}

GetTeamIDFromName(name[])
{
    //FunctionLog("GetVehicleModelIDFromName");
    if(IsNumeric(name))return -1;
	for(new i = 0; i < MAX_TEAMS; i++)
	{
		if(strfind(TeamName[i],name,true) != -1)return i;
	}
	return -1;
}

forward CheckNewName(playerid,nick[]);
public CheckNewName(playerid,nick[])
{
    //FunctionLog("CheckNewName");
	new Name[24];GetPlayerName(playerid,Name,24);
    if(!strcmp(nick,Name,true,strlen(nick)))return 0;
    return 1;
}

public OnVehicleSpawn(vehicleid)
{
    //FunctionLog("OnVehicleSpawn");
	if(v_Destroy[vehicleid] == true)DestroyVehicleEx(vehicleid);
	return 1;
}

public OnVehicleDeath(vehicleid,killerid)
{
    //FunctionLog("OnVehicleDeath");
	new Float:X,Float:Y,Float:Z;
	GetVehiclePos(vehicleid,X,Y,Z);
	CreateExplosion(X,Y+1,Z,13,1.5);
	CreateExplosion(X,Y-1,Z,13,1.5);
	CreateExplosion(X+1,Y,Z,13,1.5);
	CreateExplosion(X-1,Y,Z,13,1.5);
	foreach(Player,i)
	{
		PlayerPlaySound(i,1150,X,Y,Z);
	}
	/*if(v_InRound[vehicleid] == true)
	{
	    if(IsVehicleBoat(GetVehicleModel(vehicleid)) == 1 || IsVehicleHeli(GetVehicleModel(vehicleid)) == 1)
	    {
	        new string[128];
			format(string,sizeof(string),"*** %s-Boom!!!",CarList[GetVehicleModel(vehicleid)-400]);
			SendClientMessageToAll(MainColors[0],string);
			foreach(Player,i)
			{
			    if(IsPlayerInVehicle(i,vehicleid))
			    {
			        RemovePlayerFromVehicle(i);
			    }
			}
			DestroyVehicleEx(vehicleid);
		}
	}*/
	return 1;
}

UpdateSingleVehicleInfo(vehicleid)
{
    if(v_AmtInside[vehicleid] > 0)
	{
		new pGuns[4][256],bool:used[4],color[4],v_m,Float:v_hp,Float:percent,string[128],locked[8],Float:low,Float:med,i;
		for(i = 0; i < 4; i++)
		{
		    pGuns[i] = "Unoccupied";
		    color[i] = MainColors[3];
		}
    	v_m = GetVehicleModel(vehicleid);GetVehicleHealth(vehicleid,v_hp);
		percent = (v_hp-249) / float(v_Health[v_m-400]-249) * 100;if(percent < 0.0){percent = 0.0;v_hp = 0.0;}
		if(v_Locked[vehicleid] == true)locked = "~r~L";else locked = "~g~~h~U";
		low = float(v_Health[v_m-400]-249) / 1.8;med = float(v_Health[v_m-400]-249) / 1.15;
		if(v_hp >= 0 && v_hp < low)format(string,128," %s (%d) ~w~(%.0f/%d) ~r~%.0f%%  %s",CarList[v_m-400],v_m,v_hp,v_Health[v_m-400],percent,locked);//red - low hp
		else if(v_hp > low && v_hp < med)format(string,128," %s (%d) ~w~(%.0f/%d) ~y~%.0f%%  %s",CarList[v_m-400],v_m,v_hp,v_Health[v_m-400],percent,locked);//yellow - moderate HP
		else format(string,128," %s (%d) ~w~(%.0f/%d) ~g~%.0f%%  %s",CarList[v_m-400],v_m,v_hp,v_Health[v_m-400],percent,locked);//green - high HP
		foreach(Player,p)
		{
			if(IsPlayerInVehicle(p,vehicleid))
	    	{
	        	if(GetPlayerState(p) == PLAYER_STATE_DRIVER)
	        	{
	            	pGuns[0] = DisplayCurrentWeapons(p);
	            	color[0] = TeamActiveColors[gTeam[p]] | 0x000000FF;
	        	}
	        	else
	        	{
	        		for(i = 1; i < 4; i++)
	        		{
	        		  	if(used[i] == false)
	        			{
	        		     	pGuns[i] = DisplayCurrentWeapons(p);
	            			color[i] = TeamActiveColors[gTeam[p]] | 0x000000FF;
	            			used[i] = true;
	            			break;
						}
					}
				}
			}
	  	}
		foreach(Player,p)
		{
			if(PlayerVehicleID[p] == vehicleid)
			{
	        	TextDrawSetString(pText[8][p],string);
				for(i = 0; i < 4; i++)
				{
				    TD_HidepTextForPlayer(p,p,i+9);
     				TextDrawColor(pText[i+9][p],color[i]);
					TextDrawSetString(pText[i+9][p],pGuns[i]);
					TD_HidepTextForPlayer(p,p,i+9);
				}
			}
		}
	}
	return 1;
}

forward UpdateVehicleInfo();
public UpdateVehicleInfo()
{
    /*FunctionLogEx("UpdateVehicleInfo");*/
    if(!Players)return 1;
    new pGuns[4][256],color[4],bool:used[4],v_m,Float:v_hp,Float:percent,string[128],locked[8],Float:low,Float:med,i;
	for(i = 0; i < 4; i++)
	{
	    pGuns[i] = "Unoccupied";
	    color[i] = MainColors[3];
	}
    for(new v; v <= HighestVID; v++)
	{
	    if(v_AmtInside[v] > 0)
	    {
			v_m = GetVehicleModel(v);GetVehicleHealth(v,v_hp);
			percent = (v_hp-249) / float(v_Health[v_m-400]-249) * 100;if(percent < 0.0){percent = 0.0;v_hp = 0.0;}
			if(v_Locked[v] == true)locked = "~r~L";else locked = "~g~~h~U";
			low = float(v_Health[v_m-400]-249) / 1.8;med = float(v_Health[v_m-400]-249) / 1.15;
			if(v_hp >= 0 && v_hp < low)format(string,128," %s (%d) ~w~(%.0f/%d) ~r~%.0f%%  %s",CarList[v_m-400],v_m,v_hp,v_Health[v_m-400],percent,locked);//red - low hp
			else if(v_hp > low && v_hp < med)format(string,128," %s (%d) ~w~(%.0f/%d) ~y~%.0f%%  %s",CarList[v_m-400],v_m,v_hp,v_Health[v_m-400],percent,locked);//yellow - moderate HP
			else format(string,128," %s (%d) ~w~(%.0f/%d) ~g~%.0f%%  %s",CarList[v_m-400],v_m,v_hp,v_Health[v_m-400],percent,locked);//green - high HP
    		foreach(Player,p)
			{
	    		if(IsPlayerInVehicle(p,v))
	    		{
	        		if(GetPlayerState(p) == PLAYER_STATE_DRIVER)
	        		{
	            		pGuns[0] = DisplayCurrentWeapons(p);
	            		color[0] = TeamActiveColors[gTeam[p]] | 0x000000FF;
	        		}
	        		else
	        		{
	        		    for(i = 1; i < 4; i++)
	        		    {
	        		        if(used[i] == false)
	        		        {
	        		        	pGuns[i] = DisplayCurrentWeapons(p);
	            				color[i] = TeamActiveColors[gTeam[p]] | 0x000000FF;
	            				used[i] = true;
	            				break;
							}
						}
					}
				}
	        }
	        foreach(Player,p)
			{
			    if(PlayerVehicleID[p] == v)
			    {
	        		TextDrawSetString(pText[8][p],string);
					for(i = 0; i < 4; i++)
					{
						TextDrawColor(pText[i+9][p],color[i]);
						TextDrawSetString(pText[i+9][p],pGuns[i]);
					}
				}
			}
	    }
	}
	return 1;
}

DisplayInfoWeapons(playerid)
{
    /*FunctionLogEx("DisplayCurrentWeapons");*/
	GetPlayerWeapons(playerid);
	new string[128];
	for(new i = 1; i < MAX_SLOTS; i++)
  	{
     	if(TempGuns[playerid][i][GUN] > 0)
     	{
     	    format(string,128,"%s  %s(%d)",string,WeaponNames[TempGuns[playerid][i][GUN]],TempGuns[playerid][i][AMMO]);
		}
   	}
   	return string;
}

DisplayCurrentWeapons(playerid)
{
    /*FunctionLogEx("DisplayCurrentWeapons");*/
	GetPlayerWeapons(playerid);
	new string[256];
	format(string,256,"%s~w~:",RealName[playerid]);
	for(new i = 1; i < MAX_SLOTS; i++)
  	{
     	if(TempGuns[playerid][i][GUN] > 0)
     	{
     	    format(string,256,"%s %s~b~~h~~h~(%d)~w~",string,WeaponNames[TempGuns[playerid][i][GUN]],TempGuns[playerid][i][AMMO]);
		}
   	}
   	return string;
}

AssignNoNames()
{
	if(NoNameMode == false)return 1;
	//FunctionLog("AssignNoNames");
	new count = 0;
	foreach(Player,i)
    {
        if(gTeam[i] == T_AWAY || gTeam[i] == T_HOME)
        {
            count++;
            SetPlayerName(i,NoNames[count]);
        }
    }
    return 1;
}

forward SetPlayingName(playerid);
public SetPlayingName(playerid)
{
    //FunctionLog("SetPlayingName");
    new newname[STR];
	format(newname,sizeof(newname),"%s%s",PlayingTag,NickName[playerid]);
	SetPlayerName(playerid,newname);
	TempName[playerid] = newname;
	return 1;
}

forward RemovePlayingName(playerid);
public RemovePlayingName(playerid)
{
    //FunctionLog("NickName[RemovePlayingName]");
    if(Current != -1)
    {
		new newname[STR];
		format(newname,sizeof(newname),"%s%s",DeadTag,NickName[playerid]);
		SetPlayerName(playerid,newname);
		TempName[playerid] = newname;
	}
	else
	{
		SetPlayerName(playerid,NickName[playerid]);
		TempName[playerid] = NickName[playerid];
	}
	return 1;
}

CheckDeathReason(killerid,&reason)
{
	if(reason != 51 || IsPlayerInAnyVehicle(killerid))return 1;
	//FunctionLog("CheckDeathReason");
    new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
   	if((WeaponSet[killerid][0][MODE] == 16 || WeaponSet[killerid][1][MODE] == 16 || WeaponSet[killerid][2][MODE] == 16 || WeaponSet[killerid][2][MODE] == 16) && reason == 51 && !IsPlayerInAnyVehicle(killerid))reason = 16;
	else if((WeaponSet[killerid][0][MODE] == 35 || WeaponSet[killerid][1][MODE] == 35 || WeaponSet[killerid][2][MODE] == 35 || WeaponSet[killerid][3][MODE] == 35) && reason == 51 && !IsPlayerInAnyVehicle(killerid))reason = 35;
	else if((WeaponSet[killerid][0][MODE] == 36 || WeaponSet[killerid][1][MODE] == 36 || WeaponSet[killerid][2][MODE] == 36 || WeaponSet[killerid][3][MODE] == 36) && reason == 51 && !IsPlayerInAnyVehicle(killerid))reason = 36;
	else
	{
	    GetPlayerWeapons(killerid);
		if(TempGuns[killerid][8][GUN] == 16 && (TempGuns[killerid][7][GUN] == 35 || TempGuns[killerid][7][GUN] == 36))
		{
		    if(GetPlayerWeapon(killerid) == 16)reason = 16;
		    else if(GetPlayerWeapon(killerid) == 35)reason = 35;
		    else if(GetPlayerWeapon(killerid) == 36)reason = 36;
		}
		else if(TempGuns[killerid][8][GUN] == 16)reason = 16;
		else if(TempGuns[killerid][7][GUN] == 35)reason = 35;
		else if(TempGuns[killerid][7][GUN] == 36)reason = 36;
	}
	//if(LastWeaponUsed[killerid] == 16 || LastWeaponUsed[killerid] == 35 || LastWeaponUsed[killerid] == 36)reason = LastWeaponUsed[killerid];
	return 1;
}

forward RemovePlayerFromRound(tmpplayer);
public RemovePlayerFromRound(tmpplayer)
{
    //FunctionLog("RemovePlayerFromRound");
    //TeamCurrentPlayers[gTeam[tmpplayer]]--;
    RemovePlayerFromVehicle(tmpplayer);
    GetPlayerPos(tmpplayer,PlayerPosition[tmpplayer][0],PlayerPosition[tmpplayer][1],PlayerPosition[tmpplayer][2]);
	SetPlayerPos(tmpplayer,PlayerPosition[tmpplayer][0],PlayerPosition[tmpplayer][1],PlayerPosition[tmpplayer][2]+2);
	Playing[tmpplayer] = false;
	RemovePlayingName(tmpplayer);
	ResetPlayerHealth(tmpplayer);
	ResetPlayerArmor(tmpplayer);
	TogglePlayerControllable(tmpplayer,1);
	SetPlayerColorEx(tmpplayer,TeamInactiveColors[gTeam[tmpplayer]]);
	SetPlayerNewWorld(tmpplayer);
	ResetPlayerWeaponSet(tmpplayer);
	FindPlayerSpawn(tmpplayer,1);
	SpawnAtPlayerPosition[tmpplayer] = 0;
	SpawnPlayer(tmpplayer);
	SetCameraBehindPlayer(tmpplayer);
	TD_HidepTextForPlayer(tmpplayer,tmpplayer,1);
	TD_HidepTextForPlayer(tmpplayer,tmpplayer,13);
	TD_HideMainTextForPlayer(tmpplayer,3);
	TD_HidePanoForPlayer(tmpplayer);
	UpdateRoundII();
	return 1;
}

forward ReleaseC(playerid);
public ReleaseC(playerid)
{
	cBugDetect[playerid] = false;
	return 1;
}

forward SpawnPlayerFix(playerid);
public SpawnPlayerFix(playerid)
{
	SpawnPlayer(playerid);
	return 1;
}

forward AutoLockVehicle(vehicleid);
public AutoLockVehicle(vehicleid)
{
    if(LockMode == false)return 1;
    //FunctionLog("AutoLockVehicle");
    v_Locked[vehicleid] = true;
    foreach(Player,i)
	{
	    if(Playing[i] == true)
	    {
	    	if(TeamStatus[gTeam[i]] == DEFENDING)
	    	{
	    	    SetVehicleParamsForPlayer(vehicleid,i,false,true);
	    	}
		}
	}
	return 1;
}

UnlockVehicle(vehicleid)
{
    if(LockMode == false)return 1;
    //FunctionLog("AutoUnlockVehicle");
    v_Locked[vehicleid] = false;
    foreach(Player,i)
	{
	    if(Playing[i] == true)
	    {
			SetVehicleParamsForPlayer(vehicleid,i,false,false);
		}
	}
	return 1;
}

UpdateNewPlayerLocks(playerid)
{
	if(LockMode == false)return 1;
	//FunctionLog("UpdateNewPlayerLocks");
    for(new i; i <= HighestVID; i++)
	{
	    if(v_Exists[i] == true)
	    {
	    	if(v_Locked[i] == true)
	    	{
	    	    SetVehicleParamsForPlayer(i,playerid,false,true);
	    	}
		}
	}
	return 1;
}

UnlockAllVehicles()
{
	//FunctionLog("UnlockAllVehicles");
    for(new i; i <= HighestVID; i++)
	{
	    if(v_InRound[i] == true)
	    {
	        v_Locked[i] = false;
	        foreach(Player,x)
			{
				SetVehicleParamsForPlayer(i,x,false,true);
			}
	    }
	}
	return 1;
}

DropWeapons(playerid)//stolen from mabako
{
	//FunctionLog("DropWeapons");
	if(Pickups != ModeType && Pickups != 3)return 1;
	new Float: px, Float: py, Float: pz;
	GetPlayerPos(playerid,px,py,pz);

	new P_SLOTS[MAX_SLOTS + 1][2];
	new used_MAX_SLOTS;

	for(new i = 2; i < MAX_SLOTS-3; i++)
	{
	    GetPlayerWeaponData(playerid,i,P_SLOTS[i][GUN],P_SLOTS[i][AMMO]);
		if(P_SLOTS[i][AMMO] > 0 && P_SLOTS[i][GUN] < sizeof(weapons) && weapons[P_SLOTS[i][GUN]] != -1)
		{
			used_MAX_SLOTS++;
		}
		else
		{
 			P_SLOTS[i][GUN] = 0;
 			P_SLOTS[i][AMMO] = 0;
		}
	}
    for(new i = 1; i < MAX_SLOTS; i++)
	{
	    if(i > 1 && i < 10)continue;
	    else
		{
			GetPlayerWeaponData(playerid,i,P_SLOTS[i][GUN],P_SLOTS[i][AMMO]);
			if(P_SLOTS[i][AMMO] > 1)P_SLOTS[i][AMMO] = 1;
			if(i == 0 && P_SLOTS[i][GUN] == 0) P_SLOTS[i][AMMO] = 0; // no fist...
			if(P_SLOTS[i][AMMO] > 0 && P_SLOTS[i][GUN] < sizeof(weapons) && weapons[P_SLOTS[i][GUN]] != -1)
			{
				used_MAX_SLOTS++;
			}
			else
			{
		    	P_SLOTS[i][GUN] = 0;
		    	P_SLOTS[i][AMMO] = 0;
			}
		}
	}
	
	new used_MAX_SLOTS2 = used_MAX_SLOTS;
	for(new i = 1; i < MAX_SLOTS; i++)
	{
	    if(P_SLOTS[i][AMMO] > 0)
	    {
			new Float:angle = 360.0 - float(used_MAX_SLOTS--) * (360.0 / float(used_MAX_SLOTS2));
			new p = CreatePickup(weapons[P_SLOTS[i][GUN]],1,px + floatsin(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0),py + floatcos(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0),pz);
			pickups[p][p_x] = px + floatsin(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0);
			pickups[p][p_y] = py + floatcos(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0);
			pickups[p][p_z] = pz;
			if(p == INVALID_PICKUP)
			{
			    new lowest_time;
				new _id;
				for(new j = 0; j < MAX_SCRIPT_PICKUPS; j++)
				{
					if(pickups[j][p_creation_time] < lowest_time)
					{
					    lowest_time = pickups[j][p_creation_time];
					    _id = j;
					}
				}

				DestroyPickupEx(_id);
				KillTimer(pickups[_id][p_timer]);

				p = CreatePickup(weapons[P_SLOTS[i][GUN]],1,px + floatsin(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0),py + floatcos(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0),pz);
                pickups[p][p_x] = px + floatsin(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0);
				pickups[p][p_y] = py + floatcos(angle,degrees) * (used_MAX_SLOTS2/2 + 1.0);
				pickups[p][p_z] = pz;
			}
			pickups[p][p_creation_time] = Time();
			pickups[p][p_weapon] = P_SLOTS[i][GUN];
			pickups[p][p_ammo] = P_SLOTS[i][AMMO];
			#if MAX_DROP_AMOUNT != -1
		    if(pickups[p][p_ammo] > MAX_DROP_AMOUNT)
		    {
		        pickups[p][p_ammo] = MAX_DROP_AMOUNT;
		    }
		    #endif
		    pickups[p][p_timer] = SetTimerEx("DestroyPickupEx", DropLifeTime * 1000, 0, "i", p);
		}
	}
	return 1;
}

forward DestroyPickupEx(p);
public DestroyPickupEx(p)
{
	//FunctionLog("DestroyPickup");
	DestroyPickup(p);
	pickups[p][p_weapon] = 0;
	pickups[p][p_ammo] = 0;
	pickups[p][p_creation_time] = 0;
	KillTimer(pickups[p][p_timer]);
	return 1;
}

public OnPlayerPickUpPickup(playerid,pickupid)
{
    //FunctionLog("OnPlayerPickUpPickup");
    if(pickups[pickupid][p_creation_time] != 0)
	{
		new string[128];
		format(string,128,"You can pickup this weapon by either pressing 'TAB' or 'CROUCH' - %s(%d)",WeaponNames[pickups[pickupid][p_weapon]],pickups[pickupid][p_ammo]);
		SendClientMessage(playerid,MainColors[0],string);
		PlayerPickup[playerid] = pickupid;
		SetTimerEx("ResetPlayerPickup",5000,0,"ii",playerid,pickupid);
	}
	return 1;
}

DestroyAllPickups()
{
    //FunctionLog("DestroyAllPickups");
    for(new i = 0; i < MAX_SCRIPT_PICKUPS; i++)
	{
	    DestroyPickupEx(i);
	}
	return 1;
}

forward ResetPlayerPickup(playerid,pickupid);
public ResetPlayerPickup(playerid,pickupid)
{
    //FunctionLog("ResetPlayerPickup");
	if(PlayerPickup[playerid] == pickupid)
	{
		PlayerPickup[playerid] = -1;
	}
	return 1;
}

enum ObjectVariables{Object}
new ObjectInfo[250][ObjectVariables];

ReloadObjects()//by incognito with minor edits
{
    //FunctionLog("ReloadObjects");
    new MODE[6];MODE = "base";if(ModeType == TDM || ModeType == ARENA){MODE = "arena";}
	new file[64];format(file,sizeof(file),"/attackdefend/%d/objects/%s.ini",GameMap,MODE);
    if(!fexist(file))return 1;
	for(new o; o < ObjectCount; o++) DestroyObject(ObjectInfo[o][Object]);
	ObjectCount = 0;
	new bool:ReadingInstructions, SplitVariables[7][32], StringInput[16], StringOutput[128];
	new File:ObjectsFile = fopen(file, io_read);
	format(StringInput, sizeof(StringInput), "%s%i",MODE,Current);
	while(fread(ObjectsFile, StringOutput))
	{
		if(strfind(StringOutput, StringInput, true) != - 1)
		{
		    if (!ReadingInstructions)
		    {
		        format(StringInput, sizeof(StringInput),MODE);
				ReadingInstructions = true;
				continue;
			}
			break;
		}
		if(ReadingInstructions && ObjectCount <= sizeof(ObjectInfo) && strlen(StringOutput) > 16)
		{
			sscanf(StringOutput, "sssssss", SplitVariables[0], SplitVariables[1], SplitVariables[2], SplitVariables[3], SplitVariables[4], SplitVariables[5], SplitVariables[6]);
			ObjectInfo[ObjectCount][Object] = CreateObject(strval(SplitVariables[0]), floatstr(SplitVariables[1]), floatstr(SplitVariables[2]), floatstr(SplitVariables[3]), floatstr(SplitVariables[4]), floatstr(SplitVariables[5]), floatstr(SplitVariables[6]));
            ObjectCount++;
			continue;
		}
	}
	fclose(ObjectsFile);
	return 1;
}

ReloadObjectsEx(cur,type[])
{
    //FunctionLog("ReloadObjectsEx");
	new file[64];format(file,sizeof(file),"/attackdefend/%d/objects/%s.ini",GameMap,type);
    if(!fexist(file))return 1;
	for(new o; o < ObjectCount; o++) DestroyObject(ObjectInfo[o][Object]);
	ObjectCount = 0;
	new bool:ReadingInstructions, SplitVariables[7][32], StringInput[16], StringOutput[128];
	new File:ObjectsFile = fopen(file, io_read);
	format(StringInput, sizeof(StringInput), "%s%i",type,cur);
	while(fread(ObjectsFile, StringOutput))
	{
		if(strfind(StringOutput, StringInput, true) != - 1)
		{
		    if(!ReadingInstructions)
		    {
		        format(StringInput, sizeof(StringInput),type);
				ReadingInstructions = true;
				continue;
			}
			break;
		}
		if(ReadingInstructions && ObjectCount <= sizeof(ObjectInfo) && strlen(StringOutput) > 16)
		{
			sscanf(StringOutput, "sssssss", SplitVariables[0], SplitVariables[1], SplitVariables[2], SplitVariables[3], SplitVariables[4], SplitVariables[5], SplitVariables[6]);
			ObjectInfo[ObjectCount][Object] = CreateObject(strval(SplitVariables[0]), floatstr(SplitVariables[1]), floatstr(SplitVariables[2]), floatstr(SplitVariables[3]), floatstr(SplitVariables[4]), floatstr(SplitVariables[5]), floatstr(SplitVariables[6]));
            ObjectCount++;
			continue;
		}
	}
	fclose(ObjectsFile);
	return 1;
}

DestroyObjects()
{
    //FunctionLog("DestroyObjects");
    for(new i; i < ObjectCount; i++)
	{
		DestroyObject(ObjectInfo[i][Object]);
	}
	return 1;
}

forward LifeUpdater();
public LifeUpdater()
{
    /*FunctionLogEx("LifeUpdater");*/
	foreach(Player,i)
	{
	    if(LifeUpdateVar[i] > 0)LifeUpdateVar[i]--;
	    if(LifeUpdateVar[i] == 0)
		{
			TextDrawSetString(pText[14][i]," ");
			HitCounter[i] = 0;
		}
	}
	return 1;
}

forward RemoveIdlePlayer(playerid);
public RemoveIdlePlayer(playerid)
{
    //FunctionLog("RemoveIdlePlayer");
	if(gState[playerid] == e_STATE_IDLE && Current != -1)
	{
	    RemovePlayerFromRound(playerid);
	    new string[128];format(string,128,"*** \"%s\" has been removed from the round for pausing",NickName[playerid]);
	    SendClientMessageToAll(MainColors[0],string);
	}
	return 1;
}

forward Sync(playerid,Float:pZ);
public Sync(playerid,Float:pZ)
{
    //FunctionLog("Sync");
    Syncing[playerid] = false;
    if(gPlayerSpawned[playerid] == false || gSelectingClass[playerid] == true)return 1;
    new Float:Z;GetPlayerPos(playerid,Z,Z,Z);
    if(Z < pZ-4)
	{
	    NoKeys[playerid] = false;
		return SendClientMessage(playerid,MainColors[2],"Error: Sync cannot be used to prevent impact");
	}
	else if(ChangedWeapon[playerid] == true)return SendClientMessage(playerid,MainColors[2],"Error: You cannot change weapons!");
	LastWeapon[playerid] = GetPlayerWeapon(playerid);
	GetPlayerWeapons(playerid);
	ResetPlayerWeapons(playerid);
	PlayerPlaySound(playerid,complete,0.0,0.0,0.0);
	CurrentInt[playerid] = GetPlayerInterior(playerid);
	RespawnPlayerAtPos(playerid,1);
	SetTimerEx("AllowKeys",KeyTime*1000,0,"i",playerid);
	return 1;
}

forward IsPlayerFalling(playerid,Float:Z);
public IsPlayerFalling(playerid,Float:Z)
{
    //FunctionLog("IsPlayerFalling");
	new Float:nZ,Float:Y,Float:X;
	GetPlayerPos(playerid,X,Y,nZ);
	if(nZ < Z)return 1;
	
 	SetPlayerPos(playerid,X,Y,Z+0.6);
	SetPlayerFacingAngle(playerid,random(360));
	SetCameraBehindPlayerEx(playerid);
	GivePlayerWeapon(playerid,1,1);
	PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
	return 1;
}

forward HidenShowArenaTexts(playerid);
public HidenShowArenaTexts(playerid)
{
    //FunctionLog("HidenShowArenaTexts");
    for(new i; i < ACTIVE_TEAMS; i++)
	{
	    if(TeamUsed[i] == true)
	    {
	        TextDrawHideForPlayer(playerid,ArenaTxt[i]);
	        TextDrawShowForPlayer(playerid,ArenaTxt[i]);
	    }
	}
	return 1;
}

forward UnpauseRound();
public UnpauseRound()
{
    //FunctionLog("UnpauseRound");
	if(GamePaused == true)
	{
    	GamePaused = false;
    	SendClientMessageToAll(MainColors[0],"The round has been unpaused.");
    	foreach(Player,i)
		{
		    if(Playing[i] == true || gSpectating[i] == true || gTeam[i] == T_SUB || gTeam[i] == T_NON)
		    {
				TogglePlayerControllable(i,1);
				GameTextForPlayer(i,"~g~Unpaused",2000,3);
			}
		}
		UpdateRoundII();
	}
}

SetPlayerNewWeather(playerid,weatherid)
{
    //FunctionLog("SetPlayerNewWeather");
	SetPlayerWeather(playerid,weatherid);
	pWeather[playerid] = weatherid;
	foreach(Player,i)
	{
	    if(gSpectateID[i] == playerid)SetPlayerWeather(i,weatherid);
	}
}

ResetPlayerWeatherAndTime(playerid)
{
	SetPlayerWeather(playerid,pWeather[playerid]);
	SetPlayerTime(playerid,pTime[playerid][0],0);
}

SetPlayerNewTime(playerid,hour,minute)
{
    //FunctionLog("SetPlayerNewTime");
	SetPlayerTime(playerid,hour,minute);
	foreach(Player,i)
	{
	    if(gSpectateID[i] == playerid)SetPlayerTime(i,hour,minute);
	}
}

ShowPvPRoundStats(playerid,p1[],p2[])
{
    //FunctionLog("ShowPvPRoundStats");
	new file[64],string[128],pName[32],Float:Wins,Float:Losses,Float:ratio;
	format(file,64,"/attackdefend/%d/players/AAD_%s.ini",GameMap,udb_encode(p1));

	format(pName,32,"WR_%s",p2);Wins = dini_Int(file,pName);
	format(pName,32,"LR_%s",p2);Losses = dini_Int(file,pName);
	ratio = Wins / Losses;
	format(string,128,"***  [IN ROUND]  %s  killed  %s %.0f times  //  %s  killed  %s %.0f times  //  Ratio: %.2f",p1,p2,Wins,p1,p2,Losses,ratio);
	SendClientMessage(playerid,MainColors[3],string);
	return 1;
}

SetPlayerRandomSelectionScreen(playerid)
{
    //FunctionLog("SetPlayerRandomSelectionScreen");
    if(GameMap == SA)
 	{
	 	cSelect[playerid] = random(sizeof(sScreenSA));
	 	Vert[playerid] = sScreenSA[cSelect[playerid]][s_cz];
	 	VertLookAt[playerid] = sScreenSA[cSelect[playerid]][s_z];
	 	Horiz[playerid][0] = sScreenSA[cSelect[playerid]][s_cx];
	 	Horiz[playerid][1] = sScreenSA[cSelect[playerid]][s_cy];
 	}
	else
	{
		cSelect[playerid] = random(sizeof(sScreenGTAU));
		Vert[playerid] = sScreenGTAU[cSelect[playerid]][s_cz];
		VertLookAt[playerid] = sScreenGTAU[cSelect[playerid]][s_z];
		Horiz[playerid][0] = sScreenGTAU[cSelect[playerid]][s_cx];
	 	Horiz[playerid][1] = sScreenGTAU[cSelect[playerid]][s_cy];
	}
}

forward AddPlayerToRound(tmpplayer);
public AddPlayerToRound(tmpplayer)
{
    //FunctionLog("AddPlayerToRound");
    //TextDrawHideForPlayer(tmpplayer,MoneyBox);
	//TextDrawHideForPlayer(tmpplayer,pText[6][tmpplayer]);
    SetPlayerName(tmpplayer,NickName[tmpplayer]);
	GetPlayerPos(tmpplayer,PlayerPosition[tmpplayer][0],PlayerPosition[tmpplayer][1],PlayerPosition[tmpplayer][2]);
	SetPlayerPos(tmpplayer,PlayerPosition[tmpplayer][0],PlayerPosition[tmpplayer][1],PlayerPosition[tmpplayer][2]+2);
	ResetPlayerWeaponSet(tmpplayer);
	DuelSpectating[tmpplayer] = -1;
	if(HasPlayed[tmpplayer] == false)TeamStartingPlayers[gTeam[tmpplayer]]++;
	//TeamCurrentPlayers[gTeam[tmpplayer]]++;
	if(ModeType == BASE)
	{
		if(gSpectating[tmpplayer] == true)Spectate_Stop(tmpplayer);
		SelectingWeaps[tmpplayer] = true;
		ViewingResults[tmpplayer] = true;
		Playing[tmpplayer] = true;
		IsDueling[tmpplayer] = false;
		NoCmds[tmpplayer] = false;
		SetPlayerCheckpoint(tmpplayer,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],CPsize);
		SetPlayerInterior(tmpplayer,Interior[Current][BASE]);
		ResetPlayerWeapons(tmpplayer);
		DuelInvitation[tmpplayer] = -1;
		ResetPlayerHealth(tmpplayer);
		TogglePlayerControllable(tmpplayer,0);
		UpdateRoundII();
		SendClientMessage(tmpplayer,MainColors[3],"You have 15 seconds to select your weapons");
		SendClientMessage(tmpplayer,MainColors[3],"If you want to skip the wait type '/ready'");
		GangZoneShowForPlayer(tmpplayer,zone,TeamGZColors[ZoneCols[0]]);
		SetTimerEx("AddPlayer",15000,0,"i",tmpplayer);
		if(TeamStatus[gTeam[tmpplayer]] == ATTACKING)
		{
			if(Interior[Current][BASE] != 0)SetSpawnInfo(tmpplayer,tmpplayer,FindPlayerSkin(tmpplayer),TeamBaseSpawns[Current][0][ATTACKING]-2+random(2),TeamBaseSpawns[Current][1][ATTACKING]-2+random(2),TeamBaseSpawns[Current][2][ATTACKING]+0.2,0.0,0,0,0,0,0,0);
			else SetSpawnInfo(tmpplayer,tmpplayer,FindPlayerSkin(tmpplayer),TeamBaseSpawns[Current][0][ATTACKING]-5+random(5),TeamBaseSpawns[Current][1][ATTACKING]-5+random(5),TeamBaseSpawns[Current][2][ATTACKING]+1,0.0,0,0,0,0,0,0);
			SpawnAtPlayerPosition[tmpplayer] = 2;
			SpawnPlayer(tmpplayer);
			SetPlayerCameraLookAt(tmpplayer,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
			SetPlayerCameraPos(tmpplayer,HomeCP[Current][0]+50,HomeCP[Current][1]+50,HomeCP[Current][2]+80);
			SetPlayerMapIcon(tmpplayer,0,TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],31,0xFFFFFFFF);
			SetPlayerMapIcon(tmpplayer,1,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],RandIcon[random(7)],0xFFFFFFFF);
			SetPlayerRaceCheckpoint(tmpplayer,1,TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],TeamBaseSpawns[Current][0][ATTACKING],TeamBaseSpawns[Current][1][ATTACKING],TeamBaseSpawns[Current][2][ATTACKING],30.0);
			WeaponSelection(tmpplayer);
			SendClientMessage(tmpplayer,MainColors[3],"*** HINT: Use /CARLIST to view cars and /CAR [CAR NAME] to spawn a vehicle.");
			SendClientMessage(tmpplayer,MainColors[3],"*** HINT: To re-enter weapon selection type /GUNMENU");
			SendClientMessage(tmpplayer,MainColors[3],"*** HINT: To TALK in TEAM chat use '!' before your message.");
		}
		else
		{
			if(Interior[Current][BASE] != 0)SetSpawnInfo(tmpplayer,tmpplayer,FindPlayerSkin(tmpplayer),TeamBaseSpawns[Current][0][DEFENDING]-2+random(2),TeamBaseSpawns[Current][1][DEFENDING]-2+random(2),TeamBaseSpawns[Current][2][DEFENDING]+0.2,0.0,0,0,0,0,0,0);
			else SetSpawnInfo(tmpplayer,tmpplayer,FindPlayerSkin(tmpplayer),TeamBaseSpawns[Current][0][DEFENDING]-5+random(5),TeamBaseSpawns[Current][1][DEFENDING]-5+random(5),TeamBaseSpawns[Current][2][DEFENDING]+1,0.0,0,0,0,0,0,0);
			SpawnAtPlayerPosition[tmpplayer] = 2;
			SpawnPlayer(tmpplayer);
			SetPlayerCameraLookAt(tmpplayer,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2]);
			SetPlayerCameraPos(tmpplayer,HomeCP[Current][0]+50,HomeCP[Current][1]+50,HomeCP[Current][2]+80);
			WeaponSelection(tmpplayer);
			SendClientMessage(tmpplayer,MainColors[3],"*** HINT: To re-enter weapon selection type /GUNMENU");
		}
	}
	else if(ModeType == ARENA || ModeType == TDM)
	{
		GangZoneHideForPlayer(tmpplayer,zone);
		GangZoneShowForPlayer(tmpplayer,zone,TeamGZColors[T_AWAY]);
		GangZoneFlashForPlayer(tmpplayer,zone,TeamGZColors[T_HOME]);
		PlayerPlaySound(tmpplayer,complete,0.0,0.0,0.0);
		SetPlayerColorEx(tmpplayer,TeamActiveColors[gTeam[tmpplayer]]);
		Playing[tmpplayer] = true;
		SpawnAtPlayerPosition[tmpplayer] = 1;
		SetSpawnInfo(tmpplayer,tmpplayer,FindPlayerSkin(tmpplayer),TeamArenaSpawns[Current][0][gTeam[tmpplayer]],TeamArenaSpawns[Current][1][gTeam[tmpplayer]],TeamArenaSpawns[Current][2][gTeam[tmpplayer]],0.0,0,0,0,0,0,0);
		SpawnPlayer(tmpplayer);
		UpdateRoundII();
		SetPlayerInterior(tmpplayer,Interior[Current][ARENA]);
		SendClientMessage(tmpplayer,MainColors[3],"You have 15 seconds to select your weapons");
		SendClientMessage(tmpplayer,MainColors[3],"If you want to skip the wait type '/ready'");
		TogglePlayerControllable(tmpplayer,0);
		SelectingWeaps[tmpplayer] = true;
		ViewingResults[tmpplayer] = true;
		WeaponSelection(tmpplayer);
		SetTimerEx("AddPlayer",15000,0,"i",tmpplayer);
	}
	UpdatePlayerActiveSkills(tmpplayer);
	SetPlayerWeather(tmpplayer,rWeather);
	SetPlayerTime(tmpplayer,rTime,0);
	SetPlayerVirtualWorld(tmpplayer,0);
	SetPlayingName(tmpplayer);
	UpdateRoundII();
	return 1;
}

forward ReAddPlayer(playerid);
public ReAddPlayer(playerid)
{
    //FunctionLog("ReAddPlayer");
	ReAdding[playerid] = false;
	TD_HidePanoForPlayer(playerid);
	TogglePlayerControllable(playerid,1);
	SpawnAtPlayerPosition[playerid] = 0;
	FindPlayerSpawn(playerid,1);
	new file[64],string[100],ammo[100],xyz,zyx,i;
	new MODE = BASE;if(ModeType == TDM || ModeType == ARENA){MODE = ARENA;}
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	if(dini_Int(file,"RoundCode") == RoundCode && dini_Int(file,"Playing") == 1 && Current != -1)
	{
		HideAllTextDraws(playerid);
		SetTeam(playerid,dini_Int(file,"Team"));
		SetPlayerLife(playerid,dini_Float(file,"Health"),dini_Float(file,"Armor"));

		string = dini_Get(file,"Weapons");
		ammo = dini_Get(file,"Ammo");

	  	for(i = 0; i < MAX_SLOTS; i++)
		{
			ReAddWeps[playerid][i][GUN] = strval(strtok(string,xyz,','));
			ReAddWeps[playerid][i][AMMO] = strval(strtok(ammo,zyx,','));
		}
			
		dini_Set(file,"Weapons","0,0,0,0,0,0,0,0,0,0,0,0");
		dini_Set(file,"Ammo","0,0,0,0,0,0,0,0,0,0,0,0");

		string = dini_Get(file,"Pos");xyz = 0;
		for(i = 0; i < 4; i++){ReAddPos[playerid][i] = floatstr(strtok(string,xyz,','));}

		string = dini_Get(file,"wSets");xyz = 0;
		for(i = 0; i < 4; i++){WeaponSet[playerid][i][MODE] = strval(strtok(string,xyz,','));}
			
		SetSpawnInfo(playerid,playerid,FindPlayerSkin(playerid),ReAddPos[playerid][0],ReAddPos[playerid][1],ReAddPos[playerid][2],ReAddPos[playerid][3],0,0,0,0,0,0);
		if(TeamSkin[gTeam[playerid]] != -1)SetPlayerSkin(playerid,TeamSkin[gTeam[playerid]]);
		if(ModeType != BASE)
		{
			GangZoneShowForPlayer(playerid,zone,TeamGZColors[T_AWAY]);
	 		GangZoneFlashForPlayer(playerid,zone,TeamGZColors[T_HOME]);
	    	SetPlayerWorldBounds(playerid,ArenaZones[Current][0],ArenaZones[Current][2],ArenaZones[Current][1],ArenaZones[Current][3]);
		}
		//TeamCurrentPlayers[gTeam[playerid]]++;
		SpawnAtPlayerPosition[playerid] = 3;
		SetTimerEx("GivePlayerReAddWeapons",2000,0,"i",playerid);
		SetPlayerCheckpoint(playerid,HomeCP[Current][0],HomeCP[Current][1],HomeCP[Current][2],CPsize);
		SetPlayerInterior(playerid,Interior[Current][BASE]);
		SetPlayerColorEx(playerid,TeamActiveColors[gTeam[playerid]]);
		Playing[playerid] = true;
		SetPlayingName(playerid);
		UpdateRoundII();
		HasPlayed[playerid] = true;
		Team_FriendlyFix();
		SpawnPlayer(playerid);
		format(string,sizeof(string),"*** \"%s\" has been automatically re-added to the round because of a timeout.",RealName[playerid]);
		SendClientMessageToAll(MainColors[0],string);
		dini_IntSet(file,"RoundCode",0);
		UnpauseRound();
		SetPlayerWeather(playerid,rWeather);
		SetPlayerTime(playerid,rTime,0);
		UpdatePlayerActiveSkills(playerid);
	}
	return 1;
}

forward FixRadioStart(playerid);
public FixRadioStart(playerid)
{
    PlayerPlaySound(playerid,1068,0.0,0.0,0.0);
    SetTimerEx("FixRadioEnd",50,0,"i",playerid);
}

forward FixRadioEnd(playerid);
public FixRadioEnd(playerid)
{
    PlayerPlaySound(playerid,1069,0.0,0.0,0.0);
}

forward EliminateKiller(killerid);
public EliminateKiller(killerid)
{
    SetPlayerHealthEx(killerid,0.0);
}

ShowPlayerUAV(playerid,Float:X,Float:Y,Float:Z)
{
    /*FunctionLogEx("ShowPlayerUAV");*/
    new Float:p1[3];GetPlayerPos(playerid,p1[0],p1[1],p1[2]);
    new Float:p2[3];
	if(EnemyUAV == true)
	{
    	foreach(Player,i)
		{
			if(Playing[i] == true)
			{
		    	GetPlayerPos(i,p2[0],p2[1],p2[2]);
				if(i != playerid && gTeam[i] != gTeam[playerid] && InRange(p2[0],p2[1],p2[2],p1[0],p1[1],p1[2],50.0))
				{
				    SetPlayerMapIcon(i,playerid+2,X,Y,Z,56,0xFFFFFFFF);
				}
			}
		}
		UAVtime[playerid] = 3;
 		SetTimerEx("UpdatePlayerUAV",1000,0,"i",playerid);
	}
}

forward UpdatePlayerUAV(playerid);
public UpdatePlayerUAV(playerid)
{
    /*FunctionLogEx("UpdatePlayerUAV");*/
	UAVtime[playerid]--;
	if(UAVtime[playerid] <= 0)HidePlayerUAV(playerid);
	else SetTimerEx("UpdatePlayerUAV",1000,0,"i",playerid);
}

forward HidePlayerUAV(playerid);
public HidePlayerUAV(playerid)
{
    //FunctionLog("HidePlayerUAV");
    foreach(Player,i)
	{
		if(i != playerid)
		{
            RemovePlayerMapIcon(i,playerid+2);
		}
	}
	return 1;
}

forward SetCameraBehindPlayerEx(playerid);
public SetCameraBehindPlayerEx(playerid)
{
    /*FunctionLogEx("SetCameraBehindPlayerEx");*/
	SetCameraBehindPlayer(playerid);
    foreach(Player,x)
	{
		if(gSpectateID[x] == playerid)
		{
			SetTimerEx("Spectate_ReSpecPlayer",400,0,"ii",x,playerid);
		}
	}
	return 1;
}

//------------------------------------------------------------------------------
//Administration Functions

forward EndGracePeriod(playerid);
public EndGracePeriod(playerid)
{
    //FunctionLog("EndGracePeriod");
	GracePeriod[playerid] = false;
}

forward PingUpdate();
public PingUpdate()
{
    /*FunctionLogEx("PingUpdate");*/
	if(Players == 0)return 1;
	new Float:tmpping;
    foreach(Player,i)
	{
	    if(GracePeriod[i] == false)
	    {
	    	PingChecks[i]++;
	    	TotPing[i] += GetPlayerPing(i);
	    	if(PingChecks[i] >= 30)
	    	{
	    	    tmpping = float(TotPing[i]) / float(PingChecks[i]);
	    	    if(tmpping > MaxPing)
	    	    {
					new string[128];
					format(string,sizeof(string),"*** %s has been kicked for exceeding the ping limit by %.2f   (Average: %.2f   Max: %d)",RealName[i],tmpping - float(MaxPing),tmpping,MaxPing);
					SendClientMessageToAll(MainColors[0],string);
					Kick(i);
	    	    }
				PingChecks[i] = 0;
				TotPing[i] = 0;
	    	}
		}
	}
	return 1;
}

forward YOUNOS();
public YOUNOS()
{
    /*FunctionLogEx("YOUNOS");*/
	if(Players == 0)return 1;
	new model,veid;
	foreach(Player,i)
	{
	    if(unos[i] == true && GetPlayerState(i) == PLAYER_STATE_DRIVER)
	    {
	        veid = GetPlayerVehicleID(i);
			model = GetVehicleModel(veid);
	        if(IsNosCompatible(model) == 1)
			{
				AddVehicleComponent(veid,1010);
			}
	    }
	}
	return 1;
}

FindIDFromName(name[])
{
    /*FunctionLogEx("FindIDFromName");*/
    foreach(Player,i)
	{
		if(strfind(RealName[i],name,true) != -1)return i;
		else if(strfind(RealName[i],name,true) != -1)return i;
	}
	return -1;
}

ReturnPlayerID(PlayerName[],value)
{
    /*FunctionLogEx("ReturnPlayerID");*/
	if(IsPlayerConnected(value))return value;
	foreach(Player,i)
	{
		if(strfind(RealName[i],PlayerName,true) != -1)return i;
		else if(strfind(NickName[i],PlayerName,true) != -1)return i;
	}
	return value;
}

forward LoginCheck(playerid);
public LoginCheck(playerid)
{
    //FunctionLog("LoginCheck");
	if(Variables[playerid][LoggedIn] == false)
	{
	    new string[64];
	    format(string,sizeof(string),"%s failed to login. (kicked)",RealName[playerid]);
	    SendClientMessageToAll(Colors[2],string);
	    Kick(playerid);
	}
	return 1;
}

SendMessageToAdmins(text[])
{
    //FunctionLog("SendMessageToAdmins");
	foreach(Player,i)
	{
		if(Variables[i][Level] > 0)
		{
			SendClientMessage(i,Colors[4],text);
		}
	}
	return 1;
}

SendCommandMessageToAdmins(playerid,command[])
{
    //FunctionLog("SendCommandMessageToAdmins");
	if(DisplayCommandMessage == false || Variables[playerid][Level] > 11)return 1;
	new string[128];format(string,128,"Admin Chat: %s has used the command /%s.",RealName[playerid],command);return SendMessageToAdmins(string);
}

IsCmdLvl(playerid,level)
{
    //FunctionLog("IsCmdLvl");
	if(Variables[playerid][Level] >= level && Variables[playerid][LoggedIn] == true)return 1;
	return 0;
}

SendLevelErrorMessage(playerid)
{
    //FunctionLog("SendLevelErrorMessage");
	return SendClientMessage(playerid,Colors[2],"You are not authorized to use this command.");
 }

//end of admin stuff
//------------------------------------------------------------------------------

SendPlayerMessage2All(playerid,const string[])
{
	foreach(Player,i)
	{
	    if(Ignored[i][playerid] == false)
	    {
			SendPlayerMessageToPlayer(i,playerid,string);
	    }
	}
}

forward SetPlayerColorEx(playerid,color);
public SetPlayerColorEx(playerid,color)
{
    //FunctionLog("SetPlayerColorEx");
    SetPlayerColor(playerid,color);
    CurrentColor[playerid] = color;
    return 1;
}

strtok_(const string[], &index)
{
	new length = strlen(string);
	while((index < length) && (string[index] <= ' '))
	{
		index++;
	}
	new offset = index,result[20];
	while((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

AddWheelsToVehicle(playerid,vehicleid,wheelid)
{
	if(wheelid == 0)AddVehicleComponent(vehicleid,RandWheels[random(17)]);
	else if(wheelid == 18 && Wheels[playerid] != 18)RemoveVehicleComponent(vehicleid,Wheel_Info[wheelid][w_id]);
	else if(wheelid < 18 && wheelid > 0)AddVehicleComponent(vehicleid,Wheel_Info[wheelid][w_id]);
	return 1;
}

forward OnPlayerChangedWheels(playerid,wheelid);
public OnPlayerChangedWheels(playerid,wheelid)
{
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && IsNosCompatible(GetPlayerVehicleID(playerid)) == 1)
	{
		AddWheelsToVehicle(playerid,GetPlayerVehicleID(playerid),wheelid);
	}
	Wheels[playerid] = wheelid;
	new string[128];
	format(string,sizeof(string),"*** You have changed your wheels to: \"%s\" (ID: %d)",Wheel_Info[wheelid][w_name],Wheel_Info[wheelid][w_id]);
	SendClientMessage(playerid,MainColors[3],string);
	return 1;
}

forward OnPlayerSpawnedVehicle(playerid,vehicleid);
public OnPlayerSpawnedVehicle(playerid,vehicleid)
{
    new blah = NewVehicle[playerid];
	NewVehicle[playerid] = vehicleid;
	v_Exists[vehicleid] = true;
	v_Destroy[vehicleid] = true;
	if(Vehicles > HighestVID)HighestVID = Vehicles;
	if(blah != -1 && v_Exists[blah] == true && blah != vehicleid)
	{
		if(IsVehicleTrailer(GetVehicleModel(blah)) == 1)
		{
   			for(new i; i < HighestVID; i++)
   			{
       			if(v_Exists[i] == true)
      		 	{
           			if(GetVehicleTrailer(i) == blah)return 1;
       			}
   			}
		}
		else
		{
  			foreach(Player,i)
  			{
  	    		if(IsPlayerInVehicle(i,blah))return 1;
  			}
		}
		DestroyVehicleEx(blah);
	}
	return 1;
}

Float:GetDistanceBetweenPlayers(playerid, playerid2) //By Slick (Edited by Smugller thx for Y_Less )
{
	new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
	new Float:dis;
	GetPlayerPos(playerid,x1,y1,z1);
	GetPlayerPos(playerid2,x2,y2,z2);
	dis = floatsqroot((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1));
	return dis;
}

forward Chase_Update(chaser,chased);
public Chase_Update(chaser,chased)
{
	new Float:Dist,string[128],Float:avg;
	Dist = GetDistanceBetweenPlayers(chaser,chased);
	if(Dist > Chase_MaxDist[chaser])Chase_MaxDist[chaser] = Dist;
	if(Dist < Chase_MinDist[chaser])Chase_MinDist[chaser] = Dist;
	Chase_Checks[chaser]++;
	Chase_TotalDist[chaser] += Dist;
	avg = Chase_TotalDist[chaser] / float(Chase_Checks[chaser]);
	Chase_TotalTime[chaser]-=0.200;
	format(string,sizeof(string),"Chasing %s:~n~~n~~w~Time: ~g~%.1f~n~~w~Dist: ~g~%.2f~n~~w~Avg: ~y~%.2f",NickName[chased],Chase_TotalTime[chaser],Dist,avg);
	TextDrawSetString(pText[7][chaser],string);
	if(Dist > 200.0)Chase_Finish(chaser,chased,chased);
	else if(Chase_TotalTime[chaser] > 0.0)SetTimerEx("Chase_Update",200,0,"ii",chaser,chased);
	else Chase_Finish(chaser,chased,chaser);
	return 1;
}

Chase_Start(chaser,chased,seconds)
{
	Chase_Checks[chaser] = 0;
	Chase_TotalDist[chaser] = 0.0;
	Chase_ChaseID[chaser] = chased;
	Chase_MinDist[chaser] = 20000.0;
	Chase_MaxDist[chaser] = 0;
	Chase_TotalTime[chaser] = seconds;
	Chase_AmtChasing[chased]++;
	TextDrawSetString(pText[7][chaser]," ");
	TD_ShowpTextForPlayer(chaser,chaser,7);

	SetTimerEx("Chase_Update",500,0,"ii",chaser,chased);
	//SetTimerEx("Chase_Finish",1000 * seconds,0,"ii",chaser,chased);
	
	new string[128];
	format(string,sizeof(string),"*** \"%s\" has started to chase you! (duration: %d seconds)",NickName[chaser],seconds);
	SendClientMessage(chased,MainColors[3],string);
	format(string,sizeof(string),"*** You have started a chase with \"%s\"! (duration: %d seconds)",NickName[chased],seconds);
	SendClientMessage(chaser,MainColors[3],string);
	Chase_WhoIsChasingMe(chased);
	TD_ShowpTextForPlayer(chased,chased,7);
	
	if(IsPlayerInAnyVehicle(chased))SetVehicleParamsForPlayer(GetPlayerVehicleID(chased),chaser,true,false);
	new Float:X,Float:Y,Float:Z,Float:angle;
	GetPlayerPos(chased,X,Y,Z);
	angle = GetPosInFrontOfPlayer(chased,X,Y, -5.0);
	if(IsPlayerInAnyVehicle(chaser))
	{
		SetVehiclePos(GetPlayerVehicleID(chaser),X,Y,Z);
		SetVehicleZAngle(GetPlayerVehicleID(chaser),angle);
	}
	else
	{
		SetPlayerPos(chaser,X,Y,Z);
		SetPlayerFacingAngle(chaser,angle);
	}
	return 1;
}

forward Chase_Finish(chaser,chased,winner);
public Chase_Finish(chaser,chased,winner)
{
	if(Chase_ChaseID[chaser] == chased)
	{
		//KillTimer(Chase_Timer[chaser]);
		if(IsPlayerInAnyVehicle(chased))SetVehicleParamsForPlayer(GetPlayerVehicleID(chased),chaser,false,false);
		new string[128],Float:avg;
  		avg = Chase_TotalDist[chaser] / float(Chase_Checks[chaser]);
		if(winner == chaser)
		{
		    format(string,sizeof(string),"*** You have won the chase against \"%s\"! (Avg: %.2f,  Max: %.2f,  Min: %.2f)",NickName[chased],avg,Chase_MaxDist[chaser],Chase_MinDist[chaser]);
			SendClientMessage(chaser,MainColors[3],string);
			format(string,sizeof(string),"*** You have lost the chase against \"%s\"! (Avg: %.2f,  Max: %.2f,  Min: %.2f) (Time Up)",NickName[chaser],avg,Chase_MaxDist[chaser],Chase_MinDist[chaser]);
			SendClientMessage(chased,MainColors[3],string);
		}
		else if(winner == chased)
		{
		    format(string,sizeof(string),"*** You have lost the chase against \"%s\"! (Avg: %.2f,  Max: %.2f,  Min: %.2f) (Too Far Away)",NickName[chased],avg,Chase_MaxDist[chaser],Chase_MinDist[chaser]);
			SendClientMessage(chaser,MainColors[3],string);
			format(string,sizeof(string),"*** You have won the chase against \"%s\"! (Avg: %.2f,  Max: %.2f,  Min: %.2f)",NickName[chaser],avg,Chase_MaxDist[chaser],Chase_MinDist[chaser]);
			SendClientMessage(chased,MainColors[3],string);
		}
		else
		{
			format(string,sizeof(string),"*** Your chase with \"%s\" has ended! (Avg: %.2f,  Max: %.2f,  Min: %.2f)",NickName[chased],avg,Chase_MaxDist[chaser],Chase_MinDist[chaser]);
			SendClientMessage(chaser,MainColors[3],string);
			format(string,sizeof(string),"*** \"%s\" has ended his chase with you! (Avg: %.2f,  Max: %.2f,  Min: %.2f)",NickName[chaser],avg,Chase_MaxDist[chaser],Chase_MinDist[chaser]);
			SendClientMessage(chased,MainColors[3],string);
		}
		TD_HidepTextForPlayer(chaser,chaser,7);
		Chase_ChaseID[chaser] = -1;
		Chase_AmtChasing[chased]--;
		Chase_WhoIsChasingMe(chased);
	}
	return 1;
}

Chase_WhoIsChasingMe(playerid)
{
	if(Chase_AmtChasing[playerid] > 0)
	{
		new string[256];
		format(string,sizeof(string),"Chasing You (%d):~w~",Chase_AmtChasing[playerid]);
		foreach(Player,x)
		{
		    if(Chase_ChaseID[x] == playerid)
		    {
		        format(string,sizeof(string),"%s~n~%s (%d)",string,NickName[x],x);
		    }
		}
		TextDrawSetString(pText[7][playerid],string);
	}
	else
	{
	    TD_HidepTextForPlayer(playerid,playerid,7);
	}
	return 1;
}

Misc_RemovePlayerTags(name[STR])
{
	new count,end,pos,sName[STR],start;
	sName = name;
	if(sName[0] == '_')
	{
	    while(sName[pos])
		{
			if(sName[pos] == '_' && !count)
			{
				count++;
				start = pos;
			}
			else if(sName[pos] == '_' && count > 0)
			{
				pos++;
				end = pos;
				break;
			}
			pos++;
		}
	}
	else if(sName[0] == '[')
	{
		while(sName[pos])
		{
			if(sName[pos] == '[' && !count)
			{
				count++;
				start = pos;
			}
			else if(sName[pos] == ']' && count > 0)
			{
				pos++;
				end = pos;
				break;
			}
			pos++;
		}
	}
	if((end - start) < strlen(sName))strdel(sName,start,end);
	return sName;
}

UpdateRoundStrings(teamid)
{
    TeamLifeTotal[teamid] = 0.0;
	TeamCurrentPlayers[teamid] = 0;
	new Float:ARM,Float:HEA;
	foreach(Player,i)
	{
		if(Playing[i] == true && gTeam[i] == teamid)
		{
		    TeamCurrentPlayers[teamid]++;
			GetPlayerHealth(i,HEA);
			GetPlayerArmour(i,ARM);
			TeamLifeTotal[teamid] += (ARM+HEA);
		}
	}
	if(TeamLifeTotal[teamid] > TeamCurrentPlayers[teamid] * (rHealth+rArmor))TeamLifeTotal[teamid] = TeamCurrentPlayers[teamid] * (rHealth + rArmor);
	if(TeamsBeingUsed == 2)
	{
		new string[75];
    	format(string,sizeof(string),"%s ~w~- ~b~~h~~h~Alive: ~w~%d~b~~h~~h~/~w~%d  ~b~~h~~h~Life: ~w~%.0f",TeamName[teamid],TeamCurrentPlayers[teamid],TeamStartingPlayers[teamid],TeamLifeTotal[teamid]);
		TextDrawSetString(MainText[teamid+10],string);
	}
	else
	{
	    new string[55];
    	format(string,sizeof(string),"%s ~w~- ~b~~h~~h~Alive: ~w~%d~b~~h~~h~/~w~%d",TeamName[teamid],TeamCurrentPlayers[teamid],TeamStartingPlayers[teamid]);
		TextDrawSetString(ArenaTxt[teamid],string);
	}
	return 1;
}

CheckTeamActivePlayers()
{
    if(TeamCurrentPlayers[T_HOME] > 0 && TeamCurrentPlayers[T_AWAY] < 1)
	{
	    Winner = T_HOME;
	    TeamRoundsWon[T_HOME]++;
	    SetTimer("DisplayWinners",5,0);
	}
	else if(TeamCurrentPlayers[T_HOME] < 1 && TeamCurrentPlayers[T_AWAY] > 0)
	{
	    Winner = T_AWAY;
	    TeamRoundsWon[T_AWAY]++;
	    SetTimer("DisplayWinners",5,0);
	}
    else if(TeamCurrentPlayers[T_HOME] < 1 && TeamCurrentPlayers[T_AWAY] < 1)
    {
		Winner = T_NON;
		SetTimer("DisplayWinners",5,0);
    }
    return 1;
}

charrep(str[STR], chr, nchr)
{
	for(new i; i < strlen(str); i++)
	{
		if(str[i] == chr)str[i] = nchr;
	}
	return str;
}

SetKillMessageTD(playerid,killerid,dword[16])
{
	new string[50];
	if(KillMsgShowing[playerid] == true)KillTimer(KillMsgTimer[playerid]);
	format(string,sizeof(string),"%s %s you!",NickName[killerid],dword);
	TextDrawSetString(pText[5][playerid],string);
	TextDrawColor(pText[5][playerid], CurrentColor[playerid] | 255);
	TextDrawShowForPlayer(playerid,pText[5][playerid]);
	KillMsgShowing[playerid] = true;
	KillMsgTimer[playerid] = SetTimerEx("HideKillMessageTD",4500,0,"i",playerid);

	if(KillMsgShowing[killerid] == true)KillTimer(KillMsgTimer[killerid]);
	format(string,sizeof(string),"You %s %s!",dword,NickName[playerid]);
	TextDrawSetString(pText[5][killerid],string);
	TextDrawColor(pText[5][killerid], CurrentColor[killerid] | 255);
	TextDrawShowForPlayer(killerid,pText[5][killerid]);
	KillMsgShowing[killerid] = true;
	KillMsgTimer[killerid] = SetTimerEx("HideKillMessageTD",4500,0,"i",killerid);
	return 1;
}

forward HideKillMessageTD(playerid,killerid);
public HideKillMessageTD(playerid,killerid)
{
	TextDrawHideForPlayer(playerid,pText[5][playerid]);
	KillMsgShowing[playerid] = false;
	TextDrawHideForPlayer(killerid,pText[5][killerid]);
	KillMsgShowing[killerid] = false;
}

forward CheckPlayerName(playerid);
public CheckPlayerName(playerid)
{
    if(strfind(RealName[playerid],DeadTag,true) != -1 || strfind(RealName[playerid],PlayingTag,true) != -1)
    {
		for(new i; i < 9; i++)
		{
			SendClientMessage(playerid,0xFFFFFFFF," ");
		}
		new string[128];
		format(string,sizeof(string),"Error: Your name may not contain \"%s\" or \"%s\". Please change it and reconnect.",PlayingTag,DeadTag);
        SendClientMessage(playerid,MainColors[2],string);
        Kick(playerid);
    }
	return 1;
}

ResetPlayerArmor(playerid)
{
	if(Playing[playerid] == true)SetPlayerArmorEx(playerid,rArmor);
	else SetPlayerArmorEx(playerid,gArmor);
}

ResetPlayerHealth(playerid)
{
	if(Playing[playerid] == true)SetPlayerHealthEx(playerid,rHealth);
	else SetPlayerHealthEx(playerid,gHealth);
}

SetPlayerLife(playerid,Float:h,Float:a)
{
    if(ShowDMG[playerid] == true && h > 0)SettingHP[playerid] = true;
    SetPlayerHealth(playerid,h);
    SetPlayerArmour(playerid,a);
    if(Playing[playerid] == true)UpdateRoundStrings(gTeam[playerid]);
    new string[140];
    if(AmtSpectating[playerid] > 0)
	{
	    if(Playing[playerid] == true)
	    {
			new Float:ratio,Float:killz,Float:deathz;killz = TempKills[playerid];deathz = TempDeaths[playerid];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~w~Kills: ~b~%d  ~w~Deaths: ~b~%d  ~w~Ratio: ~b~%.02f ~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,TempKills[playerid],TempDeaths[playerid],ratio,h,a);
			TextDrawSetString(pText[1][playerid],string);
		}
		else
		{
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,h,a);
			TextDrawSetString(pText[1][playerid],string);
		}
	}
	//format(string,sizeof(string),"HP:    %.0f~n~Team: %s",h + a, TeamName[gTeam[playerid]]);
	//TextDrawSetString(pText[6][playerid],string);
    return 1;
}

SetPlayerHealthEx(playerid,Float:amount)
{
    if(ShowDMG[playerid] == true && amount > 0)SettingHP[playerid] = true;
    SetPlayerHealth(playerid,amount);
    if(Playing[playerid] == true)UpdateRoundStrings(gTeam[playerid]);
    new string[140];
    new Float:a;GetPlayerArmour(playerid,a);gPlayerArmor[playerid] = a;
    if(AmtSpectating[playerid] > 0)
	{
	    if(Playing[playerid] == true)
	    {
			new Float:ratio,Float:killz,Float:deathz;killz = TempKills[playerid];deathz = TempDeaths[playerid];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~w~Kills: ~b~%d  ~w~Deaths: ~b~%d  ~w~Ratio: ~b~%.02f ~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,TempKills[playerid],TempDeaths[playerid],ratio,amount,a);
			TextDrawSetString(pText[1][playerid],string);
		}
		else
		{
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,amount,a);
			TextDrawSetString(pText[1][playerid],string);
		}
	}
	//format(string,sizeof(string),"HP:    %.0f~n~Team: %s",amount + a, TeamName[gTeam[playerid]]);
	//TextDrawSetString(pText[6][playerid],string);
    return 1;
}

SetPlayerArmorEx(playerid,Float:amount)
{
    if(ShowDMG[playerid] == true && amount > 0)SettingHP[playerid] = true;
    SetPlayerArmour(playerid,amount);
    if(Playing[playerid] == true)UpdateRoundStrings(gTeam[playerid]);
    new string[140];
    new Float:h;GetPlayerHealth(playerid,h);gPlayerHealth[playerid] = h;
    if(AmtSpectating[playerid] > 0)
	{
	    if(Playing[playerid] == true)
	    {
			new Float:ratio,Float:killz,Float:deathz;killz = TempKills[playerid];deathz = TempDeaths[playerid];if(deathz == 0)ratio = killz;else ratio = killz / deathz;
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~w~Kills: ~b~%d  ~w~Deaths: ~b~%d  ~w~Ratio: ~b~%.02f ~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,TempKills[playerid],TempDeaths[playerid],ratio,h,amount);
			TextDrawSetString(pText[1][playerid],string);
		}
		else
		{
			format(string,sizeof(string),"%s ~b~(~w~ID %d~b~) ~n~~n~~r~Health: ~w~%.0f ~w~Armor: %.0f",RealName[playerid],playerid,h,amount);
			TextDrawSetString(pText[1][playerid],string);
		}
	}
	//format(string,sizeof(string),"HP:    %.0f~n~Team: %s",h + amount, TeamName[gTeam[playerid]]);
	//TextDrawSetString(pText[6][playerid],string);
    return 1;
}

forward ShowDamage(playerid);public ShowDamage(playerid) ShowDMG[playerid] = true;

SetSpectatorWeatherAndTime(spectator,specid)
{
	if(Playing[specid] == true)
	{
    	SetPlayerWeather(spectator,rWeather);
    	SetPlayerTime(spectator,gTime,0);
	}
	else
	{
	    SetPlayerWeather(spectator,pWeather[specid]);
    	SetPlayerTime(spectator,pTime[specid][0],pTime[specid][1]);
	}
}

/*UpdateAllWeaponSkills()
{
	if(Current == -1)return 1;
	foreach(Player,i)
	{
	    if(Playing[i] == true)
	    {
			UpdatePlayerActiveSkills(i);
		}
	}
	return 1;
}*/

UpdatePlayerActiveSkills(playerid)
{
	for(new i; i < 11; i++)
	{
	    SetPlayerSkillLevel(playerid,i,WeaponSkills[i][s_Level]);
	}
	return 1;
}

UpdatePlayerInactiveSkills(playerid)
{
	for(new i; i < 11; i++)
	{
	    SetPlayerSkillLevel(playerid,i,wSkill[playerid][i]);
	}
	return 1;
}

SavePlayerWeaponSkills(playerid)
{
	new string[STR],file[60];
	format(file,sizeof(file),"/attackdefend/%d/players/AAD_%s.ini",GameMap,udbName[playerid]);
	format(string,sizeof(string),"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",wSkill[playerid][0],wSkill[playerid][1],wSkill[playerid][2],wSkill[playerid][3],wSkill[playerid][4],wSkill[playerid][5],wSkill[playerid][6],wSkill[playerid][7],wSkill[playerid][8],wSkill[playerid][9],wSkill[playerid][10]);
	dini_Set(file,"wSkill",string);
	return 1;
}

SaveWeaponSkills()
{
    new file[64];format(file,128,"/attackdefend/%d/config/gameconfig.ini",GameMap);
	new string[STR];
	for(new i; i < 11; i++)
	{
		if(i < 10)format(string,sizeof(string),"%s%d,",string,WeaponSkills[i][s_Level]);
		else format(string,sizeof(string),"%s%d",string,WeaponSkills[i][s_Level]);
	}
	dini_Set(file,"wSkill",string);
	return 1;
}
stock CreatePlayerInfo(playerid)
{
	// first text-draw.
	InfoTextDraw[playerid][0] = TextDrawCreate(511.000000,102.000000, "Information textdraw 1");
	TextDrawTextSize(InfoTextDraw[playerid][0], 850.0, 0.0);
	TextDrawAlignment(InfoTextDraw[playerid][0], 0);
	TextDrawBackgroundColor(InfoTextDraw[playerid][0], 0x000000ff);
	TextDrawFont(InfoTextDraw[playerid][0], 0);
	TextDrawLetterSize(InfoTextDraw[playerid][0], 0.399999,1.500000);
	TextDrawColor(InfoTextDraw[playerid][0], 0xffffffff);
	TextDrawSetShadow(InfoTextDraw[playerid][0], 1);
	TextDrawSetOutline(InfoTextDraw[playerid][0],1);
	TextDrawSetProportional(InfoTextDraw[playerid][0],1);
	// second text-draw.
	InfoTextDraw[playerid][1] = TextDrawCreate(511.000000,102.000000, "Information textdraw 2");
	TextDrawTextSize(InfoTextDraw[playerid][1], 850.0, 0.0);
	TextDrawAlignment(InfoTextDraw[playerid][1], 0);
	TextDrawBackgroundColor(InfoTextDraw[playerid][1], 0x000000ff);
	TextDrawFont(InfoTextDraw[playerid][1], 0);
	TextDrawLetterSize(InfoTextDraw[playerid][1], 0.399999,1.500000);
	TextDrawColor(InfoTextDraw[playerid][1], 0xffffffff);
	TextDrawSetShadow(InfoTextDraw[playerid][1], 1);
	TextDrawSetOutline(InfoTextDraw[playerid][1],1);
	TextDrawSetProportional(InfoTextDraw[playerid][1],1);
	isInfoTDCreated1[playerid] = true;
	return true;
}
stock DestroyPlayerInfo(playerid)
{
	if(isInfoTDCreated1[playerid] == true)
	{
		TextDrawDestroy(InfoTextDraw[playerid][0]);
		TextDrawDestroy(InfoTextDraw[playerid][1]);
    	isInfoTDCreated1[playerid] = false;
	}
	return true;
}

stock ShowPlayerInfo(playerid)
{
	TextDrawShowForPlayer(playerid, InfoTextDraw[playerid][0]);
	TextDrawShowForPlayer(playerid, InfoTextDraw[playerid][1]);
	return true;
}

stock HidePlayerInfo(playerid)
{
	TextDrawHideForPlayer(playerid, InfoTextDraw[playerid][0]);
	TextDrawHideForPlayer(playerid, InfoTextDraw[playerid][1]);
	return true;
}

stock UpdatePlayerInfo(id, playerid, content[])
{
	if(isInfoTDCreated1[playerid] == true)
	{
	    if(id == 0 || id == 1)
	    {
			TextDrawSetString(InfoTextDraw[playerid][id], content);
			TextDrawShowForPlayer(playerid, InfoTextDraw[playerid][id]);
		}
		return false;
	}
	return true;
}
