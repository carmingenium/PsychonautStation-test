
#define CLOCK_INACTIVE_FLAGS SNUG_FIT|STACKABLE_HELMET_EXEMPT|STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT
#define CLOCK_ACTIVE_FLAGS

/obj/item/clothing/head/helmet/tambur
	name = "clock"
	desc = "This piece of headgear harnesses the energies of a hallucinatory anomaly to create a safe audiovisual replica of -all- external stimuli directly into the cerebral cortex, \
		granting the user effective immunity to both psychic threats, and anything that would affect their perception - be it ear, eye, or even brain damage. \
		It can also violently discharge said energy, inducing hallucinations in others."
	icon_state = null
	worn_icon_state = null
	base_icon_state = null
	force = 10
	dog_fashion = null
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 8 SECONDS
	clothing_flags = CLOCK_ACTIVE_FLAGS
	flags_cover = HEADCOVERSEYES|EARS_COVERED
	flags_inv = HIDEHAIR|HIDEFACE
	flash_protect = FLASH_PROTECTION_WELDER_SENSITIVE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'
	armor_type = /datum/armor/head_helmet_clock


	var/core_installed = FALSE
	var/list/active_components = list()
	var/list/additional_clothing_traits = list(
		/* eye/ear protection */
		TRAIT_NOFLASH,
		TRAIT_TRUE_NIGHT_VISION,
	)

// weaker overall but better against energy
/datum/armor/head_helmet_clock
	melee = 30
	bullet = 15
	laser = 45
	energy = 60
	bomb = 15
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/head/helmet/tambur/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)
	update_anomaly_state()

/obj/item/clothing/head/helmet/tambur/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_HEAD)

/obj/item/clothing/head/helmet/tambur/dropped(mob/living/user, silent)



/obj/item/clothing/head/helmet/tambur/proc/update_anomaly_state()


	if(!core_installed)
		clothing_flags = CLOCK_INACTIVE_FLAGS
		detach_clothing_traits(additional_clothing_traits)
		QDEL_LIST(active_components)
		RemoveElement(/datum/element/wearable_client_colour, /datum/client_colour/perceptomatrix, ITEM_SLOT_HEAD, HELMET_TRAIT, forced = TRUE)
		return

	clothing_flags = CLOCK_ACTIVE_FLAGS
	attach_clothing_traits(additional_clothing_traits)




/obj/item/clothing/head/helmet/tambur/Destroy(force)
	QDEL_LIST(active_components)
	return ..()

/obj/item/clothing/head/helmet/tambur/examine(mob/user)
	. = ..()
	if (!core_installed)
		. += span_warning("It requires a bioscrambler anomaly core in order to function.")

/obj/item/clothing/head/helmet/tambur/update_icon_state()
	icon_state = base_icon_state + (core_installed ? "" : "_inactive")
	worn_icon_state = base_icon_state + (core_installed ? "" : "_inactive")
	return ..()

/obj/item/clothing/head/helmet/tambur/item_interaction(mob/user, obj/item/weapon, params)
	if (!istype(weapon, /obj/item/assembly/signaler/anomaly/bioscrambler))
		return NONE
	balloon_alert(user, "inserting...")
	if (!do_after(user, delay = 3 SECONDS, target = src))
		return ITEM_INTERACT_BLOCKING
	qdel(weapon)
	core_installed = TRUE
	update_anomaly_state()
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/crate/crate_open.ogg', 50, FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/head/helmet/tambur/functioning
	core_installed = TRUE

/
#undef CLOCK_INACTIVE_FLAGS
#undef CLOCK_ACTIVE_FLAGS
