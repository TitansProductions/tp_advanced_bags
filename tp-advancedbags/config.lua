Config                                  = {}


-- ###############################################
-- GENERAL
-- ###############################################

Config.Debug                            = true
Config.Locale                           = "en"

-- ###############################################
-- BLACKLISTED ZONES
-- ###############################################

Config.BlackListedZones                 = true
Config.BlackListedZonesDebug            = false

-- If you set this as enabled, you can see the radius of the blacklisted locations. 
-- This is only for testing.
Config.EnableBlackListedZoneRadiusBlips = true


-- It does not matter what name it will be, you can choose whatever name you want but without symbols.
-- POS  : Pos is the location's central spot where you want to be blacklisted.
-- SIZE : Size is the most important, depending on the size (x) and where the central spot is. In other meanings, the (x) is the radius.
Config.Zones = {

	VineWoodHills = {
		Pos   = {x = -418.36, y = 1151.68, z = 326.0},
		Size  = { x = 300.0, y = 4.0, z = 1.0 },
	},

}

-- ###############################################
-- BAG INVENTORY
-- ###############################################

-- ------------------------
-- Items & Accounts Weight
-- ------------------------

-- 0.01 = 1 gram, 
-- 0.1  = 100 gram 
-- 1.0  = 1 kilogram (kg).

Config.Limit               = 100.0
Config.DefaultWeight       = 0.1
Config.DefaultWeaponWeight = 3.5


Config.MoneyWeight         = 0.01
Config.BlackMoneyWeight    = 0.01

Config.localWeight = {
    bread = 0.5,
    water = 0.5,
    bag   = 0.5,
    disc_ammo_rifle = 1.0,
    disc_ammo_pistol = 1.0,
    disc_ammo_smg    = 1.0,
    disc_ammo_shotgun = 1.0,

    WEAPON_SMG = 4.5,
}

-- You can change your custom / replacement weapon names in inventory when displayed.
Config.WeaponLabelNames = {

    ['WEAPON_ADVANCEDRIFLE']  = "AUG",
    ['WEAPON_ASSAULTRIFLE']   = "AK47",
    ['WEAPON_COMPACTRIFLE']   = "AKS-74U",
    ['WEAPON_CARBINERIFLE']   = "M4A1",
    ['WEAPON_SPECIALCARBINE'] = "SCAR",
    ['WEAPON_COMBATPDW']      = "UMP .45",
    ['WEAPON_MICROSMG']       = "UZI",
    ['WEAPON_SMG']            = "MP5",
}