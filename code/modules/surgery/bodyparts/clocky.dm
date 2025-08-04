#define DOAFTER_IMPLANTING_HEAD "implanting"

/obj/item/bodypart/head/clock
	name = "clock"
	desc = "A cutting-edge cyberheart, originally designed for Nanotrasen killsquad usage but later declassified for normal research. Voltaic technology allows the heart to keep the body upright in dire circumstances, alongside redirecting anomalous flux energy to fully shield the user from shocks and electro-magnetic pulses. Requires a refined Flux core as a power source."
	icon_state = "anomalock_heart"
	/*beat_noise = "an astonishing <b>BZZZ</b> of immense electrical power"*/

	var/obj/item/assembly/signaler/anomaly/core
	var/required_anomaly = /obj/item/assembly/signaler/anomaly/bioscrambler
	var/prebuilt = FALSE
	var/core_removable = TRUE

	var/lightning_overlay
	var/lightning_timer

/obj/item/bodypart/head/clock/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/bodypart/head/clock/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	if(!core)
		return
	add_lightning_overlay(30 SECONDS)
	playsound(organ_owner, 'sound/items/eshield_recharge.ogg', 40)
	organ_owner.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	RegisterSignal(organ_owner, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	organ_owner.apply_status_effect(/datum/status_effect/clock_rewind)

/obj/item/bodypart/head/clock/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	if(!core)
		return
	organ_owner.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)
	organ_owner.remove_status_effect(/datum/status_effect/clock_rewind)
	tesla_zap(source = organ_owner, zap_range = 20, power = 2.5e5, cutoff = 1e3)
	qdel(src)

/obj/item/bodypart/head/clock/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	if(target_mob != user || !istype(target_mob) || !core)
		return ..()

	if(DOING_INTERACTION(user, DOAFTER_IMPLANTING_HEAD))
		return
	user.balloon_alert(user, "this will hurt...")
	to_chat(user, span_userdanger("Black cyberveins tear your skin apart, pulling the clock onto your shoulders. This feels unwise.."))
	if(!do_after(user, 5 SECONDS, interaction_key = DOAFTER_IMPLANTING_HEAD))
		return ..()
	playsound(target_mob, 'sound/items/weapons/slice.ogg', 100, TRUE)
	user.temporarilyRemoveItemFromInventory(src, TRUE)
	/* Insert(user) */
	user.apply_damage(100, BRUTE, BODY_ZONE_CHEST)
	user.emote("scream")
	return TRUE

/obj/item/bodypart/head/clock/proc/on_emp_act(severity)
	SIGNAL_HANDLER
	add_lightning_overlay(10 SECONDS)

/obj/item/bodypart/head/clock/proc/add_lightning_overlay(time_to_last = 10 SECONDS)
	if(lightning_overlay)
		lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay)), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE))
		return
	lightning_overlay = mutable_appearance(icon = 'icons/effects/effects.dmi', icon_state = "lightning")
	owner.add_overlay(lightning_overlay)
	lightning_timer = addtimer(CALLBACK(src, PROC_REF(clear_lightning_overlay)), time_to_last, (TIMER_UNIQUE|TIMER_OVERRIDE))

/obj/item/bodypart/head/clock/proc/clear_lightning_overlay()
	owner.cut_overlay(lightning_overlay)
	lightning_overlay = null

/obj/item/bodypart/head/clock/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(core)
		return attack(user, user, modifiers)

/obj/item/bodypart/head/clock/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, required_anomaly))
		return NONE
	if(core)
		balloon_alert(user, "core already in!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	core = tool
	balloon_alert(user, "core installed")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	update_icon_state()
	return ITEM_INTERACT_SUCCESS

/obj/item/bodypart/head/clock/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "no core!")
		return
	if(!core_removable)
		balloon_alert(user, "can't remove core!")
		return
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	balloon_alert(user, "core removed")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	update_icon_state()

/obj/item/bodypart/head/clock/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (core ? "-core" : "")

/obj/item/bodypart/head/clock/prebuilt/Initialize(mapload)
	. = ..()
	core = new /obj/item/assembly/signaler/anomaly/bioscrambler(src)
	update_icon_state()

#undef DOAFTER_IMPLANTING_HEAD
