if UnitClassBase( 'player' ) ~= 'WARRIOR' then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local IsCurrentSpell = _G.IsCurrentSpell

local spec = Hekili:NewSpecialization( 1 )


local function rage_amount( isOffhand )
    local d
    if isOffhand then d = select( 3, UnitDamage( "player" ) ) * 0.7
    else d = UnitDamage( "player" ) * 0.7 end

    local c = ( state.level > 70 and 1.4139 or 1 ) * ( 0.0091107836 * ( state.level ^ 2 ) + 3.225598133 * state.level + 4.2652911 )
    local f = isOffhand and 1.75 or 3.5
    local s = ifOffhand and ( select( 2, UnitAttackSpeed( "player" ) ) or 2.5 ) or UnitAttackSpeed( "player" )

    return min( ( 15 * d ) / ( 4 * c ) + ( f * s * 0.5 ), 15 * d / c ) * ( state.talent.endless_rage.enabled and 1.25 or 1 ) * ( state.buff.defensive_stance.up and 0.95 or 1 )
end

-- TODO:  Anger Management (talent):  1 rage per 3s in combat.
spec:RegisterResource( Enum.PowerType.Rage, {
    bloodrage = {
        aura = "bloodrage",

        last = function ()
            local app = state.buff.bloodrage.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 1
    },

    second_wind = {
        aura = "second_wind",

        last = function ()
            local app = state.buff.second_wind.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 2,
        value = function() return talent.second_wind.rank * 2 end,
    },

    mainhand = {
        swing = "mainhand",

        last = function ()
            local swing = state.combat == 0 and state.now or state.swings.mainhand
            local t = state.query_time

            return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
        end,

        interval = "mainhand_speed",

        stop = function () return state.swings.mainhand == 0 end,
        value = function( now )
            return rage_amount() or 0
        end,
    },

    offhand = {
        swing = "offhand",

        last = function ()
            local swing = state.combat == 0 and state.now or state.swings.offhand
            local t = state.query_time

            return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
        end,

        interval = "offhand_speed",

        stop = function () return state.swings.offhand == 0 end,
        value = function( now )
            return rage_amount( true ) or 0
        end,
    },
} )

-- Talents
spec:RegisterTalents( {
    anger_management                = {   137, 1, 12296 },
    anticipation                    = {   138, 5, 12297, 12750, 12751, 12752, 12753 },
    armored_to_the_teeth            = {  2250, 3, 61216, 61221, 61222 },
    bladestorm                      = {  1863, 1, 46924 },
    blood_craze                     = {   661, 3, 16487, 16489, 16492 },
    blood_frenzy                    = {  1664, 2, 29836, 29859 },
    bloodsurge                      = {  1866, 3, 46913, 46914, 46915 },
    bloodthirst                     = {   167, 1, 23881 },
    booming_voice                   = {   158, 2, 12321, 12835 },
    commanding_presence             = {   154, 5, 12318, 12857, 12858, 12860, 12861 },
    concussion_blow                 = {   152, 1, 12809 },
    critical_block                  = {  1893, 3, 47294, 47295, 47296 },
    cruelty                         = {   157, 5, 12320, 12852, 12853, 12855, 12856 },
    damage_shield                   = {  2246, 2, 58872, 58874 },
    death_wish                      = {   165, 1, 12292 },
    deep_wounds                     = {   121, 3, 12834, 12849, 12867 },
    deflection                      = {   130, 5, 16462, 16463, 16464, 16465, 16466 },
    devastate                       = {  1666, 1, 20243 },
    dual_wield_specialization       = {  1581, 5, 23584, 23585, 23586, 23587, 23588 },
    endless_rage                    = {  1661, 1, 29623 },
    enrage                          = {   155, 5, 12317, 13045, 13046, 13047, 13048 },
    flurry                          = {   156, 5, 12319, 12971, 12972, 12973, 12974 },
    focused_rage                    = {  1660, 3, 29787, 29790, 29792 },
    furious_attacks                 = {  1865, 2, 46910, 46911 },
    gag_order                       = {   149, 2, 12311, 12958 },
    heroic_fury                     = {  1868, 1, 60970 },
    impale                          = {   662, 2, 16493, 16494 },
    improved_berserker_rage         = {  1541, 2, 20500, 20501 },
    improved_berserker_stance       = {  1658, 5, 29759, 29760, 29761, 29762, 29763 },
    improved_bloodrage              = {   142, 2, 12301, 12818 },
    improved_charge                 = {   126, 2, 12285, 12697 },
    improved_cleave                 = {   166, 3, 12329, 12950, 20496 },
    improved_defensive_stance       = {  1652, 2, 29593, 29594 },
    improved_demoralizing_shout     = {   161, 5, 12324, 12876, 12877, 12878, 12879 },
    improved_disarm                 = {   151, 2, 12313, 12804 },
    improved_disciplines            = {   150, 2, 12312, 12803 },
    improved_execute                = {  1542, 2, 20502, 20503 },
    improved_hamstring              = {   129, 3, 12289, 12668, 23695 },
    improved_heroic_strike          = {   124, 3, 12282, 12663, 12664 },
    improved_intercept              = {  1543, 2, 29888, 29889 },
    improved_mortal_strike          = {  1824, 3, 35446, 35448, 35449 },
    improved_overpower              = {   131, 2, 12290, 12963 },
    improved_rend                   = {   127, 2, 12286, 12658 },
    improved_revenge                = {   147, 2, 12797, 12799 },
    improved_slam                   = {  2233, 2, 12862, 12330 },
    improved_spell_reflection       = {  2247, 2, 59088, 59089 },
    improved_thunder_clap           = {   141, 3, 12287, 12665, 12666 },
    improved_whirlwind              = {  1655, 2, 29721, 29776 },
    incite                          = {   144, 3, 50685, 50686, 50687 },
    intensify_rage                  = {  1864, 3, 46908, 46909, 56924 },
    iron_will                       = {   641, 3, 12300, 12959, 12960 },
    juggernaut                      = {  2283, 1, 64976 },
    last_stand                      = {   153, 1, 12975 },
    mace_specialization             = {   125, 5, 12284, 12701, 12702, 12703, 12704 },
    mortal_strike                   = {   135, 1, 12294 },
    onehanded_weapon_specialization = {   702, 5, 16538, 16539, 16540, 16541, 16542 },
    piercing_howl                   = {   160, 1, 12323 },
    poleaxe_specialization          = {   132, 5, 12700, 12781, 12783, 12784, 12785 },
    precision                       = {  1657, 3, 29590, 29591, 29592 },
    puncture                        = {   146, 3, 12308, 12810, 12811 },
    rampage                         = {  1659, 1, 29801 },
    safeguard                       = {  1870, 2, 46945, 46949 },
    second_wind                     = {  1663, 2, 29834, 29838 },
    shield_mastery                  = {  1654, 2, 29598, 29599 },
    shield_specialization           = {  1601, 5, 12298, 12724, 12725, 12726, 12727 },
    shockwave                       = {  1872, 1, 46968 },
    strength_of_arms                = {  1862, 2, 46865, 46866 },
    sudden_death                    = {  1662, 3, 29723, 29725, 29724 },
    sweeping_strikes                = {   133, 1, 12328 },
    sword_and_board                 = {  1871, 3, 46951, 46952, 46953 },
    sword_specialization            = {   123, 5, 12281, 12812, 12813, 12814, 12815 },
    tactical_mastery                = {   128, 3, 12295, 12676, 12677 },
    taste_for_blood                 = {  2232, 3, 56636, 56637, 56638 },
    titans_grip                     = {  1867, 1, 46917 },
    toughness                       = {   140, 5, 12299, 12761, 12762, 12763, 12764 },
    trauma                          = {  1859, 2, 46854, 46855 },
    twohanded_weapon_specialization = {   136, 3, 12163, 12711, 12712 },
    unbridled_wrath                 = {   159, 5, 12322, 12999, 13000, 13001, 13002 },
    unending_fury                   = {  2234, 5, 56927, 56929, 56930, 56931, 56932 },
    unrelenting_assault             = {  1860, 2, 46859, 46860 },
    vigilance                       = {   148, 1, 50720 },
    vitality                        = {  1653, 3, 29140, 29143, 29144 },
    warbringer                      = {  2236, 1, 57499 },
    weapon_mastery                  = {   134, 2, 20504, 20505 },
    wrecking_crew                   = {  2231, 5, 46867, 56611, 56612, 56613, 56614 },
} )


-- Auras
spec:RegisterAuras( {
    my_battle_shout = {
        duration = function() return 120 * ( 1 + talent.booming_voice.rank * 0.25 ) end,
        max_stack = 1,
        generate = function( t )
            for i, id in ipairs( class.auras.battle_shout.copy ) do
                local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "player", id, "PLAYER" )

                if name then
                    t.name = name
                    t.count = 1
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = caster
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    battle_stance = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=2457)
        id = 2457,
        duration = 3600,
        max_stack = 1,
    },
    -- Immune to Fear, Sap and Incapacitate effects.  Generating extra rage when taking damage.
    berserker_rage = {
        id = 18499,
        duration = 10,
        max_stack = 1,
    },
    berserker_stance = { -- TODO: Check Aura (https://wowhead.com/wotlk/spell=2458)
        id = 2458,
        duration = 3600,
        max_stack = 1,
    },
    -- You cannot be stopped and perform a Whirlwind every $t1 sec.  No other abilities can be used.
    bladestorm = {
        id = 46924,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
    },
    -- Regenerates $o1% of your total Health over $d.
    blood_craze = {
        id = 16491,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
        copy = { 16491, 16490, 16488 },
    },
    -- Increases physical damage taken by $s1%.
    blood_frenzy = {
        id = 30070,
        duration = 3600,
        max_stack = 1,
        copy = { 30069, 30070 },
    },
    -- Generating $/10;s1 Rage per second.
    bloodrage = {
        id = 29131,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Taunted.
    challenging_shout = {
        id = 1161,
        duration = 6,
        max_stack = 1,
    },
    -- Stunned.
    charge_stun = {
        id = 7922,
        duration = 1.5,
        max_stack = 1,
    },
    cleave = {
        duration = function () return swings.mainhand_speed end,
        max_stack = 1,
    },
    my_commanding_shout = {
        duration = function() return 120 * ( 1 + talent.booming_voice.rank * 0.25 ) end,
        max_stack = 1,
        generate = function( t )
            for i, id in ipairs( class.auras.commanding_shout.copy ) do
                local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "player", id, "PLAYER" )

                if name then
                    t.name = name
                    t.count = 1
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = caster
                    return
                end
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Stunned.
    concussion_blow = {
        id = 12809,
        duration = 5,
        max_stack = 1,
    },
    -- Dazed.
    dazed = {
        id = 29703,
        duration = 6,
        max_stack = 1,
    },
    -- Increases physical damage by $s1%.  Increases all damage taken by $s3%.
    death_wish = {
        id = 12292,
        duration = 30,
        max_stack = 1,
    },
    defensive_stance = {
        id = 71,
        duration = 3600,
        max_stack = 1,
    },
    -- Reduces melee attack power by $s1.
    demoralizing_shout = {
        id = 1160,
        duration = function() return 30 * ( 1 + talent.booming_voice.rank * 0.25 ) end,
        max_stack = 1,
        no_ticks = true,
        copy = { 1160, 6190, 11554, 11555, 11556, 25202, 25203, 27579, 47437 },
    },
    deep_wound = {
        id = 43104,
        duration = 12,
        max_stack = 1,
    },
    -- Disarmed!
    disarm = {
        id = 676,
        duration = function() return 10 + talent.improved_disarm.rank end,
        max_stack = 1,
    },
    -- Physical damage increased by $s1%.
    enrage = {
        id = 57522,
        duration = 12,
        max_stack = 1,
        copy = { 12880, 14201, 14202, 14203, 14204, 57514, 57516, 57518, 57519, 57520, 57521, 57522 },
    },
    -- Regenerates $s1% of your total health every $t1 sec.
    enraged_regeneration = {
        id = 55694,
        duration = 10,
        tick_time = 1,
        max_stack = 1,
    },
    -- Attack speed increased by $s1%.
    flurry = {
        id = 12970,
        duration = 15,
        max_stack = 1,
        copy = { 12966, 12967, 12968, 12969, 12970, 16257, 16277, 16278, 16279, 16280 },
    },
    -- All healing reduced by $s1%.
    furious_attacks = {
        id = 56112,
        duration = 10,
        max_stack = 2,
    },
    -- Glyph.
    glyph_of_revenge = {
        id = 58363,
        duration = 10,
        max_stack = 1,
    },
    -- Movement slowed by $s1%.
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1,
    },
    heroic_strike = {
        duration = function () return swings.mainhand_speed end,
        max_stack = 1,
    },
    -- Immobilized.
    improved_hamstring = {
        id = 23694,
        duration = 5,
        max_stack = 1,
        copy = { 12668, 12289 },
    },
    -- Stunned.
    intercept_stun = {
        id = 25274,
        duration = 3,
        max_stack = 1,
        copy = { 20253, 20614, 20615, 25273, 25274, 30153, 30195, 30197, 47995, 58747, 67573 },
    },
    -- The next melee or ranged attack made against you will be made against the intervening warrior instead.
    intervene = {
        id = 3411,
        duration = 10,
        max_stack = 1,
    },
    -- Cowering in fear.
    intimidating_shout = {
        id = 20511,
        duration = 8,
        max_stack = 1,
        copy = { 20511, 5246 },
    },
    -- Your next Slam or Mortal Strike has an additional $65156s1% chance to critically hit.
    juggernaut = {
        id = 65156,
        duration = 10,
        max_stack = 1,
    },
    -- Taunted.
    mocking_blow = {
        id = 694,
        duration = 6,
        max_stack = 1,
        copy = { 694, 7400, 7402, 20559, 20560, 25266 },
    },
    -- Healing effects reduced by $s1%.
    mortal_strike = {
        id = 12294,
        duration = 10,
        max_stack = 1,
        copy = { 12294, 21551, 21552, 21553, 25248, 27580, 30330, 47485, 47486, 65926, 71552 },
    },
    -- Allows the use of Overpower.
    overpower_ready = {
        id = 68051,
        duration = 6,
        max_stack = 1,
    },
    -- Dazed.
    piercing_howl = {
        id = 12323,
        duration = 6,
        max_stack = 1,
    },
    -- Special ability attacks have an additional $s1% chance to critically hit but all damage taken is increased by $s2%.
    recklessness = {
        id = 1719,
        duration = function() return 15 end,
        max_stack = 1,
    },
    -- Bleeding for $s1 plus a percentage of weapon damage every $t1 seconds.  If used while the victim is above $s2% health, Rend does $s3% more damage.
    rend = {
        id = 47465,
        duration = function() return glyph.rending.enabled and 21 or 27 end,
        max_stack = 1,
        copy = { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208, 46845, 47465 },
    },
    -- Counterattacking all melee attacks.
    retaliation = {
        id = 20230,
        duration = function() return 15 end,
        max_stack = 1,
    },
    revenge_stun = {
        id = 12798,
        duration = 3,
        max_stack = 1,
    },
    revenge_usable = {
        duration = 5,
        max_stack = 1,
    },
    -- All damage taken reduced by $s1%.
    safeguard = {
        id = 46947,
        duration = 6,
        max_stack = 1,
        copy = { 46946, 46947 },
    },
    second_wind = {
        id = 29842,
        duration = 3600,
        max_stack = 1,
    },
    -- Armor reduced by $s2%.
    shattering_throw = {
        id = 64382,
        duration = 10,
        max_stack = 1,
    },
    shield_bash_silenced = {
        id = 18498,
        duration = 3,
        max_stack = 1,
    },
    -- Block chance and block value increased by $s1%.
    shield_block = {
        id = 2565,
        duration = function() return talent.improved_shield_block.enabled and 6 or 5 end,
        max_stack = 1,
    },
    -- All damage taken reduced by $s1%.
    shield_wall = {
        id = 871,
        duration = function() return 10 + ( talent.improved_shield_wall.rank == 2 and 5 or talent.improved_shield_wall.rank == 1 and 2 or 0 ) end,
        max_stack = 1,
    },
    -- Stunned.
    shockwave = {
        id = 46968,
        duration = 4,
        max_stack = 1,
    },
    -- Silenced.
    silenced_gag_order = {
        id = 18498,
        duration = 3,
        max_stack = 1,
    },
    -- Your next Slam is instant.
    slam = {
        id = 46916,
        duration = 5,
        max_stack = 1,
        copy = "bloodsurge"
    },
    -- Reflects the next spell cast on you.
    spell_reflection = {
        id = 23920,
        duration = 5,
        max_stack = 1,
    },
    -- You may use Execute regardless of target's health.
    sudden_death = {
        id = 52437,
        duration = 10,
        max_stack = 1,
    },
    -- Your next $n melee attacks strike an additional nearby opponent.
    sweeping_strikes = {
        id = 12328,
        duration = 30,
        max_stack = 5,
    },
    -- Shield Slam rage cost reduced by $s1%.
    sword_and_board = {
        id = 50227,
        duration = 5,
        max_stack = 1,
    },
    -- Allows the use of Overpower.
    taste_for_blood = {
        id = 60503,
        duration = 9,
        max_stack = 1,
    },
    -- Taunted.
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1,
    },
    -- Attack speed reduced by $s2%.
    thunder_clap = {
        id = 47502,
        duration = 30,
        max_stack = 1,
        copy = { 6343, 8198, 8204, 8205, 11580, 11581, 13532, 25264, 47501, 47502 },
    },
    -- Bleed effects cause an additional $s1% damage.
    trauma = {
        id = 46857,
        duration = 60,
        max_stack = 1,
        copy = { 46856, 46857 },
    },
    -- Damage taken reduced by $s1% and $s3% of all threat transferred to warrior.
    vigilance = {
        id = 50720,
        duration = 1800,
        max_stack = 1,
    },

    -- Aliases / polybuffs.
    stance = {
        alias = { "battle_stance", "defensive_stance", "berserker_stance" },
        aliasMode = "first",
        aliasType = "buff",
    },
    shout = {
        alias = { "my_battle_shout", "my_commanding_shout" },
        aliasMode = "first",
        aliasType = "buff"
    }
} )


-- Glyphs
spec:RegisterGlyphs( {
    [12297] = "anticipation",
    [12320] = "cruelty",
    [58365] = "barbaric_insults",
    [58095] = "battle",
    [63324] = "bladestorm",
    [58375] = "blocking",
    [58096] = "bloodrage",
    [58369] = "bloodthirst",
    [58097] = "charge",
    [58366] = "cleaving",
    [68164] = "command",
    [58388] = "devastate",
    [58104] = "enduring_victory",
    [63327] = "enraged_regeneration",
    [58367] = "execution",
    [58372] = "hamstring",
    [58357] = "heroic_strike",
    [58377] = "intervene",
    [58376] = "last_stand",
    [58099] = "mocking_blow",
    [58368] = "mortal_strike",
    [58386] = "overpower",
    [58355] = "rapid_charge",
    [58385] = "rending",
    [58356] = "resonating_power",
    [58364] = "revenge",
    [63329] = "shield_wall",
    [63325] = "shockwave",
    [63328] = "spell_reflection",
    [58387] = "sunder_armor",
    [58384] = "sweeping_strikes",
    [58353] = "taunt",
    [58098] = "thunder_clap",
    [58382] = "victory_rush",
    [63326] = "vigilance",
    [58370] = "whirlwind",
} )


local enemy_revenge_trigger = 0
local enemy_dodged = 0

local misses = {
    DODGE = true,
    PARRY = true,
    BLOCK = true
}

spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, missType, _, _, _, _, _, critical = CombatLogGetCurrentEventInfo()

    if sourceGUID == state.GUID and subtype:match( "_MISSED$" ) and ( missType == "DODGE" or state.glyph.overpower.enabled and missType == "PARRY" ) then
        enemy_dodged = GetTime()
    elseif destGUID == state.GUID and subtype:match( "_MISSED$" ) and misses[ missType ] then
        enemy_revenge_trigger = GetTime()
    end
end )


spec:RegisterStateFunction( "swap_stance", function( stance )
    removeBuff( "battle_stance" )
    removeBuff( "defensive_stance" )
    removeBuff( "berserker_stance" )

    local swap = rage.current - ( ( IsSpellKnown( 12678 ) and 10 or 0 ) + 5 * talent.tactical_mastery.rank )
    if swap > 0 then
        spend( swap, "rage" )
    end

    if stance then applyBuff( stance )
    else applyBuff( "stance" ) end
end )


local finish_heroic_strike = setfenv( function()
    spend( 15, "rage" )
end, state )

spec:RegisterStateFunction( "start_heroic_strike", function()
    applyBuff( "heroic_strike", swings.time_to_next_mainhand )
    state:QueueAuraExpiration( "heroic_strike", finish_heroic_strike, buff.heroic_strike.expires )
end )


local finish_cleave = setfenv( function()
    spend( 20, "rage" )
end, state )

spec:RegisterStateFunction( "start_cleave", function()
    applyBuff( "cleave", swings.time_to_next_mainhand )
    state:QueueAuraExpiration( "cleave", finish_cleave, buff.cleave.expires )
end )


spec:RegisterHook( "reset_precast", function()
    local form = GetShapeshiftForm()

    if form == 1 then applyBuff( "battle_stance" )
    elseif form == 2 then applyBuff( "defensive_stance" )
    elseif form == 3 then applyBuff( "berserker_stance" )
    else removeBuff( "stance" ) end

    if IsCurrentSpell( class.abilities.heroic_strike.id ) then
        start_heroic_strike()
        Hekili:Debug( "Starting Heroic Strike, next swing in %.2f...", buff.heroic_strike.remains )
    end

    if IsCurrentSpell( class.abilities.cleave.id ) then
        start_cleave()
        Hekili:Debug( "Starting Cleave, next swing in %.2f...", buff.cleave.remains )
    end

    if IsUsableSpell( class.abilities.overpower.id ) and enemy_dodged > 0 and now - enemy_dodged < 6 then applyBuff( "overpower_ready", enemy_dodged + 5 - now ) end
    if IsUsableSpell( class.abilities.revenge.id ) and enemy_revenge_trigger > 0 and now - enemy_revenge_trigger < 5 then applyBuff( "revenge_usable", enemy_revenge_trigger + 5 - now ) end
end )


-- Abilities
spec:RegisterAbilities( {
    -- The warrior shouts, increasing attack power of all raid and party members within 30 yards by 550.  Lasts 2 min.
    battle_shout = {
        id = 47436,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = false,
        texture = 132333,

        essential = true,

        handler = function( rank )
            if buff.my_commanding_shout.up then
                removeBuff( "commanding_shout" )
                removeBuff( "my_commanding_shout" )
                removeBuff( "shout" )
            end
            applyBuff( "battle_shout" )
            applyBuff( "my_battle_shout" )
            applyBuff( "shout" )
        end,

        copy = 6673
    },


    -- A balanced combat stance that increases the armor penetration of all of your attacks by 10%.
    battle_stance = {
        id = 2457,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132349,

        nobuff = "battle_stance",

        handler = function()
            swap_stance( "battle_stance" )
        end
    },


    -- The warrior enters a berserker rage, removing and granting immunity to Fear, Sap and Incapacitate effects and generating extra rage when taking damage.  Lasts 10 sec.
    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = function() return 30 * ( 1 - 0.11 * talent.intensify_rage.rank ) end,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 136009,

        buff = "berserker_stance",

        handler = function()
            applyBuff( "berserker_rage" )
            if talent.improved_berserker_rage.enabled then
                gain( 10 * talent.improved_berserker_rage.rank, "rage" )
            end
        end
    },


    -- An aggressive stance.  Critical hit chance is increased by 3% and all damage taken is increased by 5%.
    berserker_stance = {
        id = 2458,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132275,

        nobuff = "berserker_stance",

        handler = function()
            swap_stance( "berserker_stance" )
        end
    },


    -- Instantly Whirlwind up to 4 nearby targets and for the next 6 sec you will perform a whirlwind attack every 1 sec.  While under the effects of Bladestorm, you can move but cannot perform any other abilities but you do not feel pity or remorse or fear and you cannot be stopped unless killed.
    bladestorm = {
        id = 46924,
        cast = 0,
        cooldown = function() return glyph.bladestorm.enabled and 75 or 90 end,
        gcd = "spell",

        spend = 25,
        spendType = "rage",

        talent = "bladestorm",
        startsCombat = true,
        texture = 236303,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "bladestorm" )
            setCooldown( "global_cooldown", 6 )
        end,
    },


    -- Generates 20 rage at the cost of health, and then generates an additional 10 rage over 10 sec.
    bloodrage = {
        id = 2687,
        cast = 0,
        cooldown = function() return 60 * ( 1 - 0.11 * talent.intensify_rage.rank ) end,
        gcd = "off",

        spend = function() return glyph.bloodrage.enabled and 0 or 1299 end,
        spendType = "health",

        startsCombat = false,
        texture = 132277,

        toggle = "cooldowns",

        handler = function()
            gain( 20 * ( 1 + 0.25 * talent.improved_bloodrage.rank ), "rage" )
            applyBuff( "bloodrage" )
        end
    },


    -- Instantly attack the target causing 1092 damage.  In addition, the next 3 successful melee attacks will restore 1% of max health.  This effect lasts 8 sec.  Damage is based on your attack power.
    bloodthirst = {
        id = 23881,
        cast = 0,
        cooldown = 4,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        talent = "bloodthirst",
        startsCombat = true,
        texture = 136012,

        handler = function( rank )
            applyBufF( "bloodthirst", nil, 5 )
            -- TODO: if glyph.bloodthirst.enabled then [double health gain] end
        end,
    },


    -- Forces all enemies within 10 yards to focus attacks on you for 6 sec.
    challenging_shout = {
        id = 1161,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = function() return 5 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132091,

        toggle = "defensives",

        handler = function()
            applyDebuff( "target", "challenging_shout" )
        end
    },


    -- Charge an enemy, generate 15 rage, and stun it for 1.50 sec.  Cannot be used in combat.
    charge = {
        id = 11578,
        cast = 0,
        cooldown = function() return 15 * ( glyph.rapid_charge.enabled and 0.93 or 1 ) end,
        gcd = "off",

        spend = function() return -15 - 5 * talent.improved_charge.rank + ( talent.juggernaut.enabled and 5 or 0 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 132337,

        buff = function ()
            if talent.warbringer.enabled then return end
            return "battle_stance"
        end,
        usable = function()
            if talent.juggernaut.enabled then return target.minR > 7, "target must be outside your deadzone" end
            return not combat and target.minR > 7, "cannot be in combat; target must be outside your deadzone"
        end,

        handler = function( rank )
            setDistance( 7 )
            if not target.is_boss then applyDebuff( "target", "charge_stun" ) end
            applyBuff( "juggernaut" )
        end,
    },

    -- On next attack...
    cleave = {
        id = 47520,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        spend = function() return 20 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132338,

        nobuff = "cleave",

        handler = function( rank )
            gain( 20 - talent.focused_rage.rank, "rage" )
            start_cleave()
        end,

        copy = { 845, 7369, 11608, 11609, 20569, 25231 }
    },


    -- Increases maximum health of all party and raid members within 30 yards by 2255.  Lasts 2 min.
    commanding_shout = {
        id = 47440,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = false,
        texture = 132351,

        essential = true,

        handler = function()
            if buff.my_commanding_shout.up then
                removeBuff( "battle_shout" )
                removeBuff( "my_battle_shout" )
                removeBuff( "shout" )
            end
            applyBuff( "commanding_shout" )
            applyBuff( "my_commanding_shout" )
            applyBuff( "shout" )
        end
    },


    -- Stuns the opponent for 5 sec and deals 830 damage (based on attack power).
    concussion_blow = {
        id = 12809,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = function() return 15 - talent.focused_rage.rank end,
        spendType = "rage",

        talent = "concussion_blow",
        startsCombat = true,
        texture = 132325,

        handler = function()
            applyDebuff( "target", "concussion_blow" )
        end
    },


    -- When activated you become enraged, increasing your physical damage by 20% but increasing all damage taken by 5%.  Lasts 30 sec.
    death_wish = {
        id = 12292,
        cast = 0,
        cooldown = function() return 180 * ( 1 - 0.11 * talent.intensify_rage.rank ) end,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "death_wish",
        startsCombat = true,
        texture = 136146,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "death_wish" )
            applyBuff( "enrage" )
        end,
    },


    -- A defensive combat stance.  Decreases damage taken by 10% and damage caused by 5%.  Increases threat generated.
    defensive_stance = {
        id = 71,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132341,

        nobuff = "defensive_stance",

        handler = function()
            swap_stance( "defensive_stance" )
        end
    },


    -- Reduces the melee attack power of all enemies within 10 yards by 411 for 30 sec.
    demoralizing_shout = {
        id = 47437,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 132366,

        handler = function( rank )
            applyDebuff( "target", "demoralizing_shout" )
            active_dot.demoralizing_shout = active_enemies
        end,
    },


    -- Sunder the target's armor causing the Sunder Armor effect.  In addition, causes 120% of weapon damage plus 58 for each application of Sunder Armor on the target.  The Sunder Armor effect can stack up to 5 times.
    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 15 - talent.focused_rage.rank - talent.puncture.rank end,
        spendType = "rage",

        talent = "devastate",
        startsCombat = true,
        texture = 135291,

        handler = function( rank )
            applyDebuff( "target", "sunder_armor", nil, min( 5, debuff.sunder_armor.stack + ( glyph.devastate.enabled and 2 or 1 ) ) )
        end,
    },


    -- Disarm the enemy's main hand and ranged weapons for 10 sec.
    disarm = {
        id = 676,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.improved_disarm.rank end,
        gcd = "spell",

        spend = 15,
        spendType = "rage",

        startsCombat = true,
        texture = 132343,

        toggle = "cooldowns",

        buff = "defensive_stance",

        handler = function ()
            applyDebuff( "target", "disarm" )
        end,
    },


    -- You regenerate 30% of your total health over 10 sec.  This ability requires an Enrage effect, consumes all Enrage effects and prevents any from affecting you for the full duration.
    enraged_regeneration = {
        id = 55694,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 15,
        spendType = "rage",

        startsCombat = false,
        texture = 132345,

        toggle = "cooldowns",
        buff = "enrage",

        handler = function ()
            removeBuff( "enrage" )
            applyBuff( "enraged_regeneration" )
        end,
    },


    -- Attempt to finish off a wounded foe, causing 1892 damage and converting each extra point of rage into 38 additional damage (up to a maximum cost of 30 rage).  Only usable on enemies that have less than 20% health.
    execute = {
        id = 47471,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function()
            return ( talent.improved_execute.rank == 2 and 10 or talent.improved_execute.rank == 1 and 13 or 15 ) - talent.focused_rage.rank
        end,
        spendType = "rage",

        startsCombat = true,
        texture = 135358,

        usable = function() return buff.sudden_death.up or target.health.pct < 20, "requires sudden_death or target health under 20 percent" end,

        handler = function( rank )
            removeBuff( "sudden_death" )
            spend( min( 30 - action.execute.spend, rage.current ), "rage" )
            if rage.current < ( 3.33 * talent.sudden_death.rank ) then
                gain( 3.33 * talent.sudden_death.rank - rage.current, "rage" )
            end
        end,
    },


    -- Maims the enemy, reducing movement speed by 50% for 15 sec.
    hamstring = {
        id = 1715,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132316,

        nobuff = "defensive_stance",

        handler = function( rank )
            applyDebuff( "target", "hamstring" )
        end,
    },


    -- Removes any Immobilization effects and refreshes the cooldown of your Intercept ability.
    heroic_fury = {
        id = 60970,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        talent = "heroic_fury",
        startsCombat = false,
        texture = 236171,

        handler = function ()
            setCooldown( "intercept", 0 )
        end,
    },


    -- On next attack...
    heroic_strike = {
        id = 47450,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        spend = function()
            if buff.glyph_of_revenge.up then return 0 end
            return 15 - talent.focused_rage.rank - talent.improved_heroic_strike.rank
        end,
        spendType = "rage",

        startsCombat = true,
        texture = 132282,

        nobuff = "heroic_strike",

        handler = function( rank )
            gain( 15 - talent.focused_rage.rank - talent.improved_heroic_strike.rank, "rage" )
            start_heroic_strike()
        end,

        copy = { 78, 284, 285, 1608, 11564, 11565, 11566, 11567, 25286, 29707, 30324 }
    },


    -- Throws your weapon at the enemy causing 1104 damage (based on attack power).  This ability causes high threat.
    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 132453,

        toggle = "cooldowns",

        handler = function ()
            if talent.gag_order.rank == 2 then
                applyDebuff( "target", "silenced_gag_order" )
                interrupt()
            end
        end,
    },


    -- Charge an enemy, causing 262 damage (based on attack power) and stunning it for 3 sec.
    intercept = {
        id = 20252,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.improved_intercept.rank end,
        gcd = "off",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132307,

        buff = function ()
            if talent.warbringer.enabled then return end
            return "berserker_stance"
        end,

        handler = function( rank )
            setDistance( 7 )
            applyDebuff( "target", "intercept_stun" )
        end,
    },


    -- Run at high speed towards a party member, intercepting the next melee or ranged attack made against them as well as reducing their total threat by 10%.
    intervene = {
        id = 3411,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 10,
        spendType = "rage",

        startsCombat = false,
        texture = 132365,

        buff = function ()
            if talent.warbringer.enabled then return end
            return "defensive_stance"
        end,

        handler = function()
            applyBuff( "intervene" )
        end
    },


    -- The warrior shouts, causing up to 5 enemies within 8 yards to cower in fear.  The targeted enemy will be unable to move while cowering.  Lasts 8 sec.
    intimidating_shout = {
        id = 5246,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = function() return 25 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132154,

        toggle = "cooldowns",

        handler = function()
            applyDebuff( "target", "intimidating_shout" )
        end
    },


    -- When activated, this ability temporarily grants you 30% of your maximum health for 20 sec.  After the effect expires, the health is lost.
    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = function() return glyph.last_stand.enabled and 120 or 180 end,
        gcd = "off",

        talent = "last_stand",
        startsCombat = false,
        texture = 135871,

        toggle = "defensives",

        handler = function()
            applyBuff( "last_stand" )
            health.max = health.max * 1.2
            gain( health.current * 0.2, "health" )
        end
    },


    -- A mocking attack that causes a moderate amount of threat and forces the target to focus attacks on you for 6 sec.  If the target is tauntable, also deals weapon damage.
    mocking_blow = {
        id = 694,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132350,

        toggle = "cooldowns",

        buff = "battle_stance",

        handler = function( rank )
            applyDebuff( "target", "mocking_blow" )
        end,
    },


    -- A vicious strike that deals weapon damage plus 85 and wounds the target, reducing the effectiveness of any healing by 50% for 10 sec.
    mortal_strike = {
        id = 12294,
        cast = 0,
        cooldown = function() return 6 - 0.2 * talent.improved_mortal_strike.rank end,
        gcd = "spell",

        spend = function() return 30 - talent.focused_rage.rank end,
        spendType = "rage",

        talent = "mortal_strike",
        startsCombat = true,
        texture = 132355,

        handler = function( rank )
            removeBuff( "juggernaut" )
            applyDebuff( "target", "mortal_strike" )
        end,
    },


    -- Instantly overpower the enemy, causing weapon damage.  Only useable after the target dodges.  The Overpower cannot be blocked, dodged or parried.
    overpower = {
        id = 7384,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = function() return 5 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132223,

        buff = "battle_stance",

        usable = function() return buff.taste_for_blood.up or buff.overpower_ready.up, "only usable after dodging or with taste_for_blood" end,

        handler = function( rank )
            removeBuff( "taste_for_blood" )
            removeBuff( "overpower_ready" )
        end,
    },


    -- Causes all enemies within 10 yards to be Dazed, reducing movement speed by 50% for 6 sec.
    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "piercing_howl",
        startsCombat = true,
        texture = 136147,

        handler = function()
            applyDebuff( "target", "piercing_howl" )
        end
    },


    -- Pummel the target, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec.
    pummel = {
        id = 6552,
        cast = 0,
        cooldown = 10,
        gcd = "off",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 132938,

        buff = "berserker_stance",
        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function( rank )
            interrupt()
        end,
    },


    -- Your next 3 special ability attacks have an additional 100% to critically hit but all damage taken is increased by 20%.  Lasts 12 sec.
    recklessness = {
        id = 1719,
        cast = 0,
        cooldown = function() return 300 * ( 1 - 0.11 * talent.intensify_rage.rank ) - 30 * talent.improved_disciplines.rank end,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132109,

        toggle = "cooldowns",

        buff = "berserker_stance",

        handler = function ()
            applyBuff( "recklessness" )
        end,
    },


    -- Wounds the target causing them to bleed for 380 damage plus an additional 780 (based on weapon damage) over 15 sec.  If used while your target is above 75% health, Rend does 35% more damage.
    rend = {
        id = 47465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132155,

        nobuff = "berserker_stance",

        handler = function( rank )
            applyDebuff( "target", "rend" )
        end,
    },


    -- Instantly counterattack any enemy that strikes you in melee for 12 sec.  Melee attacks made from behind cannot be counterattacked.  A maximum of 20 attacks will cause retaliation.
    retaliation = {
        id = 20230,
        cast = 0,
        cooldown = function() return 300 - 30 * talent.improved_disciplines.rank end,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132336,

        toggle = "cooldowns",

        buff = "battle_stance",

        handler = function()
            applyBuff( "retaliation" )
        end
    },


    -- Instantly counterattack an enemy for 2313 to 2675 damage.   Revenge is only usable after the warrior blocks, dodges or parries an attack.
    revenge = {
        id = 57823,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = function() return 5 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132353,

        buff = function()
            if buff.revenge_usable.up then return "defensive_stance" end
            return "revenge_usable"
        end,

        handler = function( rank )
            removeBuff( "revenge_usable" )
            if glyph.revenge.enabled then applyBuff( "glyph_of_revenge" ) end
        end,
    },


    -- Throws your weapon at the enemy causing 1104 damage (based on attack power), reducing the armor on the target by 20% for 10 sec or removing any invulnerabilities.
    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 300,
        gcd = "spell",

        spend = function() return 25 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 311430,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "shattering_throw" )
        end,
    },


    -- Bash the target with your shield dazing them and interrupting spellcasting, which prevents any spell in that school from being cast for 6 sec.
    shield_bash = {
        id = 72,
        cast = 0,
        cooldown = 12,
        gcd = "off",

        spend = function() return 10 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132357,

        toggle = "interrupts",

        buff = "defensive_stance",
        usable = function() return equipped.shield end,
        readyTime = state.timeToInterrupt,
        debuff = "casting",

        handler = function( rank )
            interrupt()
            if talent.gag_order.rank == 2 then
                applyDebuff( "target", "silenced_gag_order" )
                interrupt()
            end
        end,
    },


    -- Increases your chance to block and block value by 100% for 10 sec.
    shield_block = {
        id = 2565,
        cast = 0,
        cooldown = function() return 60 - 10 * talent.shield_block.rank end,
        gcd = "off",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132110,

        buff = "defensive_stance",

        handler = function()
            applyBuff( "shield_block" )
        end
    },


    -- Slam the target with your shield, causing 990 to 1040 damage, modified by your shield block value, and dispels 1 magic effect on the target.  Also causes a high amount of threat.
    shield_slam = {
        id = 47488,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function()
            if buff.sword_and_board.up then return 0 end
            return 20 - talent.focused_rage.rank
        end,
        spendType = "rage",

        startsCombat = true,
        texture = 134951,

        equipped = "shield",

        handler = function( rank )
            removeBuff( "player", "sword_and_board" )
            removeBuff( "target", "dispellable_magic" )
        end,
    },


    -- Reduces all damage taken by 60% for 12 sec.
    shield_wall = {
        id = 871,
        cast = 0,
        cooldown = function() return ( glyph.shield_wall.enabled and 180 or 300 ) - 30 * talent.improved_disciplines.rank end,
        gcd = "off",

        spend = 0,
        spendType = "rage",

        startsCombat = false,
        texture = 132362,

        toggle = "defensives",

        buff = "defensive_stance",

        handler = function()
            applyBuff( "shield_wall" )
        end
    },


    -- Sends a wave of force in front of the warrior, causing 1638 damage (based on attack power) and stunning all enemy targets within 10 yards in a frontal cone for 4 sec.
    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = function() return glyph.shockwave.enabled and 17 or 20 end,
        gcd = "spell",

        spend = 15,
        spendType = "rage",

        talent = "shockwave",
        startsCombat = true,
        texture = 236312,

        debuff = function()
            if not target.is_boss then return "casting" end
        end,

        timeToReady = function()
            if not target.is_boss then return state.timeToInterrupt() end
        end,

        handler = function ()
            applyDebuff( "target", "shockwave" )
            if not target.is_boss then interrupt() end
        end,
    },


    -- Slams the opponent, causing weapon damage plus 250.
    slam = {
        id = 47475,
        cast = function()
            if buff.bloodsurge.up then return 0 end
            return 1.5 - 0.5 * talent.improved_slam.rank
        end,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 15 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
            removeBuff( "bloodsurge" )
            removeBuff( "juggernaut" )
        end,
    },


    -- Raise your shield, reflecting the next spell cast on you.  Lasts 5 sec.
    spell_reflection = {
        id = 23920,
        cast = 0,
        cooldown = function() return glyph.spell_reflection.enabled and 9 or 10 end,
        gcd = "off",

        spend = 15,
        spendType = "rage",

        startsCombat = false,
        texture = 132361,

        toggle = "interrupts",
        debuff = "casting",

        handler = function()
            applyBuff( "spell_reflection" )
            applyDebuff( "target", "spell_reflection" )
        end
    },


    -- Sunders the target's armor, reducing it by 4% per Sunder Armor and causes a high amount of threat.  Threat increased by attack power.  Can be applied up to 5 times.  Lasts 30 sec.
    sunder_armor = {
        id = 7386,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function() return 15 - talent.focused_rage.rank - talent.puncture.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132363,

        handler = function( rank )
            applyDebuff( "target", "sunder_armor", nil, min( 5, debuff.sunder_armor.stack + 1 ) )
        end,
    },


    -- Your next 5 melee attacks strike an additional nearby opponent.
    sweeping_strikes = {
        id = 12328,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = function() return glyph.sweeping_strikes.enabled and 0 or 30 end,
        spendType = "rage",

        talent = "sweeping_strikes",
        startsCombat = false,
        texture = 132306,

        nobuff = "defensive_stance",

        handler = function()
            applyBuff( "sweeping_strikes", nil, 10 )
        end
    },


    -- Taunts the target to attack you, but has no effect if the target is already attacking you.
    taunt = {
        id = 355,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136080,

        buff = "defensive_stance",

        handler = function()
            applyDebuff( "target", "taunt" )
        end
    },


    -- Blasts nearby enemies increasing the time between their attacks by 10% for 30 sec and doing 300 damage to them.  Damage increased by attack power.  This ability causes additional threat.
    thunder_clap = {
        id = 47502,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = function() return 20 - ( glyph.resonating_power.enabled and 5 or 0 ) - talent.focused_rage.rank - ( talent.improved_thunder_clap.rank == 3 and 4 or talent.improved_thunder_clap.rank == 2 and 2 or talent.improved_thunder_clap.rank == 1 and 1 or 0 ) end,
        spendType = "rage",

        startsCombat = true,
        texture = 136105,

        nobuff = "berserker_stance",

        handler = function( rank )
            applyDebuff( "target", "thunder_clap" )
            active_dot.thunder_clap = min( active_enemies, 4 + active_dot.thunder_clap )
        end,
    },


    -- Instantly attack the target causing 983 damage.  Can only be used within 20 sec after you kill an enemy that yields experience or honor.  Damage is based on your attack power.
    victory_rush = {
        id = 34428,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 132342,

        nobuff = "defensive_stance",

        handler = function()
            removeBuff( "victory_rush" )
        end
    },


    -- Focus your protective gaze on a group or raid target, reducing their damage taken by 3% and transfers -10% of the threat they cause to you.  In addition, each time they are hit by an attack your Taunt cooldown is refreshed.  Lasts 30 min.  This effect can only be on one target at a time.
    vigilance = {
        id = 50720,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "vigilance",
        startsCombat = false,
        texture = 236318,

        usable = function() return active_dot.vigilance == 0, "can only have 1 active" end,

        handler = function ()
            active_dot.vigilance = 1
        end,
    },


    -- In a whirlwind of steel you attack up to 4 enemies within 8 yards, causing weapon damage from both melee weapons to each enemy.
    whirlwind = {
        id = 1680,
        cast = 0,
        cooldown = function() return 10 - talent.improved_whirlwind.rank - ( glyph.of_whirlwind.enabled and 2 or 0 ) end,
        gcd = "spell",

        spend = function() return 25 - talent.focused_rage.rank end,
        spendType = "rage",

        startsCombat = true,
        texture = 132369,

        buff = "berserker_stance",

        handler = function()
        end
    },
} )



spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    gcd = 6673,

    nameplates = true,
    nameplateRange = 8,

    damage = false,
    damageExpiration = 6,

    package = "Arms (IV)",

    package1 = "Arms (IV)",
    package2 = "Fury (IV)",
    package3 = "Protection Warrior (IV)"
} )


spec:RegisterPack( "Arms (IV)", 20220925, [[Hekili:1AvZUnUnq4NLflq6g0yfj760KfjgOT7LKdja1bBVjrAPXrersuGKYUgiGp7DgjBjkzlVTh6H4yto)(nZ8nmmi81WLjCde(8u)Pt9VB6CVGBNnlyE4sZUsiCzjp(D(B4xk454N)MkxBzF5XVFjD1UmjpHmHwwPIXRtnMs9xV(6TB36jI3nzdik0EXY8R3knzVpjoJR1I4R5OzMSLRucPAssPEs5gyIsA4gHSysSuMLi3wONWxjYegbOdxUQsKzESiC1Xb8nZN7FdgeLqC4ZbyuissGgjbDC4Yxtfyqxsoty2zz0VwX1qILjxV2YmPGL9ymEZ3P41YERsKaEHlZeAJMYpUeW)9CnCXJPGeD3wakffVfPnkX7uicf8vzqs4VhAWWJKT7KLXOVbLG3yGnqeua5yMzzlSSzDM1KwvKaQieQkBsaLOS5QxF5BV8vl7BaAOCrbqrUc0PiAzzRLkl71)WY2O9SSx2aQs5wq5rXYm34wE4Qbb8V4ku)OONCZ)rjwI04PGIK6mZ3YUWYour9CTlkuohX7oVUkJJjSrQYjhDZOosHDK1w)w)oLJZa(gav0qW2AEvM5OAwzvEoKDQkvBvTeYYIuW6my)j9KThsgNYv0OXXW4OrThgzIyHPo6N67M6szcjX5H4vvRx7vlBwL24vvwdVjq956uUHKd7jXgd5wpcYDsTbxFEm(ty3Li(Du6olqvvsRFDGwTachXUMFerZo)GU(GMjSOgQfAgdT9TJgrFPlrBAIqwePYtBqkkl7ElBUL9XhNwO9TAhe7YAyZqLpJNrKdrgzuIOPPIi)AXmhJmY0OS4NWY5YAbrUfKprlZbjnEczA8Zuo6xQKhtJEqYviTZEj5w2FkFR6ecvp3E3)M52aFxPQ0qecy5dPJccgfxBho7g)q8INSRpCoS5QQ0TXi(9mqRlW)Q9wVzkNX6bbvVXj4VH4kZW5PGE8s6m(rgz8PLwEIBCM0sbLueVN1UHUOeJFz(kEhHX4dFy7wrmmy0cv1Kbrn3DE2)Mj49YNkRmJyk6QwgNXTu(UOZymmRY5fj1BP2BW6egBL0KaTlrdxIBJlq5W(MhZlLkdTDCg2HwBjlREvON9jcSKRfzyz6ZF2YAEpWF1SjNEyq7w0lTprcqoyI)DtMo3(K9PgRP9Ab8F(HR7HDxjw)Wqy(8QrPvRwhbfNw3HWsR(NcnDIBu1MniUNmCJH7DnBiCpPLNN8P7gHft97z1bJBDPOd5)fNJ431AeXnzHpTNsVxmoG0(kIo(bKnMuOpR9IaSOIVY4)xMVEWGd)lfpFz0na3p)JpodZ)9ZV8IJ57xem31BTuSUh2YO2hq7i8O4Auo0UG6y(Z(9fh0Z909uI9qeKb0939OZo0uT4gF3XnSysAo4bR9QL)NEt5ql7(QUt01mBO8hJZNWqdVRdHCCXH3AUW)IZ(gZHgR5XITWv97iRmP0s(okSAUYW)j]] )

spec:RegisterPack( "Fury (IV)", 20220925, [[Hekili:fAvxVTkoq0FmxPQwTlKV2092v9Mh2hUsTp0xO6UVb4yMuSIbJShs2iv5F77yObmKqwv1KGNzoZ5yp(iIxe)ECugdH43woF5Y5pTCD4IVVA18hJJWtvqCufJVN9b9Jswb95pR1NSP3)YVEWf6KuXYCqyu1AofohXkZFnB2XJhdf8tbharPjKRkMDuHY9bCjZye8z7iycoY0AHshKvzcQoabAfYqHQmGRuYm1XstaBRqkqbyIJ2wlK4lLXBhtyQ7vap(Tfu7fzzqBkGHhh9EUWytRCDrGeVDpTLzGmBQQ0MI5Gn9fof4xoEAt)OwKbHKY0QDcjPNV9nBARK)NwY60ExbpyF1LGJibZFky5A7R2xzCNgmHvAG09wg(B)y2wqBa9EqNyqwjh(DXUFSTE3UW2hdDIDIkzikHetUQg7QYFXBul9JcwzMO8Jr1xCk5kq0bcvAvDrbi9xH2JLYenStcnR5htuIaD8xH(lUvQuzAA0X1w33HzWobxGBwoFaW5evaTJLyUwDSxLoaK1gmSU6UmOD)AuYdvpHwgWW8KJctU)Q5Gwj4jUPoh8NNVc7iEOgkyUraVIODY9sWykP)7ivp(eR(8ZPOvDLps1girGqXa4n1Lz0abtxO0o4V)mwER7Mp47FEDFJ8d(fNFE9d3Hm9hagIIcibvjzcyZI1(DJZOtV2htKctZSG7Xdqcucf0nSnlU40dZfAZGdvJKvm8aYutD2Dc1TPEKQsEuuMDMG9H8q9A74FDmzqTyF3yZMhhmUa)lWRrW)MgtbuGU2ooaM3UPrEpvxr2RgNpxcSd(Tpo6aD)LYW3ZHmVkPZBYy6LIkLgDEkRSPTqztD7XMq7RXrSAmxPP06SnIJAI68nPosF9wJnCBPeYNfsCeuY2kHS4)ogPE7sQFLio5PrZCS2k7vKnDdrLE881VdNvtIJtVnv7085YB3oOcrNR6owTeVGYT2fxJVNZyS9XOCx5NB3TYrj9h3K4NTxAeWspb0ze5Wy9KyCHNJn9oB6T8D8u3OWUo9OVK6TngPP)Cs(mTjvpSE(AoW((Tf3aVlB6NFoT8QR6BIVpORlp5lSoRTr6AX8j5Y99T9cRoB6Z201d52vS8oN2dnNrxA(1mdSyT3bKhin0BXi61nTpYN8)5A2IgWgmP75XnEpz6BEx6N2OSP9uhg(k(QEAN8SBA)TV)CXf)bUXnaS2xNFzepuJO7DN(6nq6CjMwXEV(J3g4Oxw62EFx)fI8qZl0TD)M8vJ8Mog9gvX9)f)Fp]] )

spec:RegisterPack( "Protection Warrior (IV)", 20220925, [[Hekili:vwvxVnQoq0Fm9LTAlKV20D7vQ5H9T2hQwjw19ndoMjfRyWiBtqrQIF73zGCjgsixTQsTn2N5mNz8mNWwW(nlkL7a2BlNVC58NwUoCXpwTC9swK7yjWIk5I98pW)PGNJ)(xgTdeoPUOj5pCJrQnnjF5L3VNqEuP5PeJwDLrGOZCUs7)mBwDDDOuCm4ailSHcD(SATtTpqO4wRumRSN1G6osdC8I9bLhGa8kE7ncTwLQRlSb8TsL0jbllABLu5EPGT96LXculLGG9g(pzY0uOdjyfSOFNjTnjLu2KUJnj0N2YTqAtcvDUmOj5fbEX7KQBs(OsMcHSiL06SuvY1a(N3A7H8w1JnTSQIuWeJvwjlck4Bvqk7NmhQmFC2mTyFn)amc0kFqg4au8XyiFJGC(KibkFWi5iE8HQjzttYJZptIqbuAC4pyHVJxPCxO6YQ8CqDt9wckvSb2PGtNmTSfzCZ1v9)HyRsRtn8laT2huLfIXkl3oc0Jtw)0mJS4d)USeuPXy6e7Pq)(KHUTA3UqF4HvLxWJvXZjA(XK0qbCaIHcihhpBFlw41y4ypS7dX0uu3SuC3MfnnHC)0))aWI5dNKoRTr4wmPoT4ovi35WL74sDnyAL6Q1ZN3K85Nnj3Uoop8szzWCskCGtKFHMx93n1MbgTueBDg5(tdVLgaDo2Ypp(EJxsCuqaHKDHV22bfwQU6UUFiFAEWS5ui(mDLBeB(x1Vcmnt5hJVbzyHLZlsXH3EcBR5dGXsa6T1yrObzbId3kEjVuBCKF1QUxmY2Q1DkS5vK7kxM2GW69WOEOENuHpo3DxtYeE59WVV5vcgL6G5pfSCDZRnV2LhBy)RXxFE24g7dYDpp(z46r63s6J6I(01JDCpRp(R1Q9KogANFN)jJ938VRZpZ)KE)l)d79RgWRNLcjWtwuxbcTaFUXn0jAGAgzI8azF8m6EqbpCVDZc)apzMmrQhE8P9BIYlSk2q2eF(5TsvVlG)HdwPjMPg4MhN7pvHLbI0)lrhFxV2gFX4Y70XDF9Nx6AxSy)l]] )

