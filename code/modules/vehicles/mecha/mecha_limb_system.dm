/**
 * Mecha Limb System
 * Handles limb damage tracking, equipment dropping on limb damage,
 * hand-based weapon control UI, and severed limbs HUD display
 */

///Assoc list tracking which limbs are damaged/severed
/obj/vehicle/sealed/mecha/var/list/limb_status = list(
	MECHA_L_ARM = LIMB_INTACT,
	MECHA_R_ARM = LIMB_INTACT,
	MECHA_L_LEG = LIMB_INTACT,
	MECHA_R_LEG = LIMB_INTACT,
	MECHA_TORSO = LIMB_INTACT,
	MECHA_HEAD = LIMB_INTACT,
)

///List tracking currently active hand weapons
/obj/vehicle/sealed/mecha/var/list/hand_active = list(
	MECHA_L_ARM = FALSE,
	MECHA_R_ARM = FALSE,
)

///List of severed limbs screen objects for each occupant
/obj/vehicle/sealed/mecha/var/list/limb_screens = list()

///Associated damage zones to limbs for tracking
/obj/vehicle/sealed/mecha/var/list/zone_to_limb_map = list(
	BODY_ZONE_HEAD = MECHA_HEAD,
	BODY_ZONE_CHEST = MECHA_TORSO,
	BODY_ZONE_L_ARM = MECHA_L_ARM,
	BODY_ZONE_R_ARM = MECHA_R_ARM,
	BODY_ZONE_L_LEG = MECHA_L_LEG,
	BODY_ZONE_R_LEG = MECHA_R_LEG,
	BODY_ZONE_PRECISE_L_HAND = MECHA_L_ARM,
	BODY_ZONE_PRECISE_R_HAND = MECHA_R_ARM,
)

///Proc to handle limb damage and equipment dropping
/obj/vehicle/sealed/mecha/proc/apply_limb_damage(limb, damage_amount)
	if(!limb_status)
		return

	var/current_status = limb_status[limb]

	//Determine if limb should be severed based on damage threshold
	var/damage_threshold = max_integrity / 3
	if(damage_amount >= damage_threshold && current_status == LIMB_INTACT)
		sever_limb(limb)
		return

	//Apply damage status if not already severed
	if(damage_amount > 0 && current_status != LIMB_SEVERED)
		limb_status[limb] = LIMB_DAMAGED
		update_limbs_hud()

///Proc to sever a limb
/obj/vehicle/sealed/mecha/proc/sever_limb(limb)
	if(!limb_status)
		return

	if(limb_status[limb] == LIMB_SEVERED)
		return  // Already severed

	limb_status[limb] = LIMB_SEVERED

	to_chat(occupants, span_danger("[limb] HAS BEEN SEVERED!"))
	playsound(src, 'sound/effects/explosion_distant.ogg', 50)

	//Drop equipment from severed limb
	if(limb == MECHA_L_ARM || limb == MECHA_R_ARM)
		drop_limb_equipment(limb)
		//Disable hand control for this arm
		hand_active[limb] = FALSE

	//Update HUD display
	update_limbs_hud()

///Proc to drop equipment from a damaged/severed limb
/obj/vehicle/sealed/mecha/proc/drop_limb_equipment(limb)
	var/equipment_to_drop = null

	if(limb == MECHA_L_ARM)
		equipment_to_drop = equip_by_category[MECHA_L_ARM]
	else if(limb == MECHA_R_ARM)
		equipment_to_drop = equip_by_category[MECHA_R_ARM]

	if(equipment_to_drop && istype(equipment_to_drop))
		equipment_to_drop.detach(get_turf(src))
		to_chat(occupants, span_warning("Equipment from [limb] has been ejected!"))

///Proc to toggle hand weapon on/off
/obj/vehicle/sealed/mecha/proc/toggle_hand_weapon(limb, mob/user)
	if(!limb_status)
		return

	if(limb_status[limb] == LIMB_SEVERED)
		balloon_alert(user, "[limb] is severed!")
		return

	if(limb_status[limb] == LIMB_DAMAGED)
		balloon_alert(user, "[limb] is damaged, functionality limited!")

	var/equipment = null
	if(limb == MECHA_L_ARM)
		equipment = equip_by_category[MECHA_L_ARM]
	else if(limb == MECHA_R_ARM)
		equipment = equip_by_category[MECHA_R_ARM]

	if(!equipment)
		balloon_alert(user, "No weapon equipped in [limb]!")
		return

	hand_active[limb] = !hand_active[limb]
	balloon_alert(user, "[equipment.name] [hand_active[limb] ? "ACTIVE" : "DEACTIVATED"]!")

	if(hand_active[limb])
		equipment.active = TRUE
		SEND_SOUND(occupants, sound('sound/machines/terminal/terminal_prompt.ogg', volume=50))
	else
		equipment.active = FALSE
		SEND_SOUND(occupants, sound('sound/machines/terminal/terminal_eject.ogg', volume=50))

///Proc to update the severed limbs HUD display
/obj/vehicle/sealed/mecha/proc/update_limbs_hud()
	//Clear old screens
	for(var/mob/occupant in occupants)
		if(!occupant.client)
			continue
		for(var/screen_obj in limb_screens)
			occupant.client.screen -= screen_obj
	limb_screens.Clear()

	//Create new screens for each limb
	var/y_pos = 1
	for(var/limb in limb_status)
		var/status = limb_status[limb]
		var/icon_state = "intact"
		var/color_val = COLOR_GREEN
		var/limb_name = limb

		switch(status)
			if(LIMB_INTACT)
				icon_state = "intact"
				color_val = COLOR_GREEN
			if(LIMB_DAMAGED)
				icon_state = "damaged"
				color_val = COLOR_YELLOW
			if(LIMB_SEVERED)
				icon_state = "severed"
				color_val = COLOR_RED

		var/atom/movable/screen/limb_status_display/display = new
		display.limb_name = limb_name
		display.icon_state = icon_state
		display.screen_loc = "RIGHT+1,NORTH-[y_pos]"
		display.color = color_val

		limb_screens += display

		for(var/mob/occupant in occupants)
			if(occupant.client)
				occupant.client.screen += display

		y_pos += 2

///Screen object for limb status display on HUD
/atom/movable/screen/limb_status_display
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "intact"
	screen_loc = "RIGHT+1,NORTH-1"
	layer = HUD_LAYER
	plane = HUD_PLANE
	var/limb_name = ""

/atom/movable/screen/limb_status_display/Initialize(mapload)
	. = ..()
	// Use a simple colored box to represent limb status
	var/mutable_appearance/limb_display = mutable_appearance('icons/hud/screen_gen.dmi', "other-1")
	appearance = limb_display
