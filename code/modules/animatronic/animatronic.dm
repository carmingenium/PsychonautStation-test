
/////////////////////////
////// Animatronic //////
/////////////////////////


/obj/item/animatronic_part
	name = "animatronic part"
	icon = 'icons/mob/rideables/mech_construct.dmi'
	icon_state = "blank"
	w_class = WEIGHT_CLASS_GIGANTIC
	obj_flags = CONDUCTS_ELECTRICITY
	var/part_slot = ""

/obj/item/animatronic_part/proc/try_attach_part(mob/user, obj/machinery/animatronic/A, attach_right = FALSE)
	if(!user.transferItemToLoc(src, A))
		to_chat(user, span_warning("The [src] is stuck to your hand, you cannot put it in the [A]!"))
		return ITEM_INTERACT_BLOCKING
	A.AddPart(src)
	user.visible_message(span_notice("[user] attaches [src] to [A]."), span_notice("You attach [src] to [A]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/animatronic_part/base
	name = "Animatronic Base"
	icon = 'icons/psychonaut/obj/animatronic/animatronic_parts.dmi'
	icon_state = "base"
	part_slot = "base"

	attackby(obj/item/used, mob/user, list/modifiers, list/attack_modifiers)
		if(!istype(used, /obj/item/animatronic_part))
			return ..()


		if(locate(/obj/machinery/animatronic) in src)
			// If it's already inside, forward to the normal attach flow
			return src.try_attach_part(user, locate(/obj/machinery/animatronic))

		var/turf/T = get_turf(src)
		if(!isturf(T))
			return ..()


		var/obj/machinery/animatronic/A = new /obj/machinery/animatronic(get_turf(src))
		if(!A)
			return ..()


		if(!user.transferItemToLoc(src, A))
			src.forceMove(A)
		A.AddPart(src)


		if(used != src)
			if(!user.transferItemToLoc(used, A))
				used.forceMove(A)
			A.AddPart(used)

		user.visible_message(span_notice("[user] attaches [used] to a newly assembled animatronic."), span_notice("You attach [used] and form an animatronic."))
		return TRUE

/obj/item/animatronic_part/head
	name = "Animatronic Skull"
	icon ='icons/psychonaut/obj/animatronic/animatronic_parts.dmi'
	icon_state = "head"
	part_slot = "head"

/obj/item/animatronic_part/arms
	name = "Animatronic Arms"
	icon ='icons/psychonaut/obj/animatronic/animatronic_parts.dmi'
	icon_state = "arms"
	part_slot = "arms"

/obj/item/animatronic_part/legs
	name = "Animatronic Legs"
	icon ='icons/psychonaut/obj/animatronic/animatronic_parts.dmi'
	icon_state = "legs"
	part_slot = "legs"

/obj/item/animatronic_part/chest
	name = "Animatronic Chest"
	icon ='icons/psychonaut/obj/animatronic/animatronic_parts.dmi'
	icon_state = "chest"
	part_slot = "chest"


// --- Suits ---

/obj/item/animatronic_suit
	name = "animatronic suit"
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_SMALL
	var/can_wear_by_human = TRUE
	var/can_attach_to_skeleton = TRUE
	var/suit_slot = ""




/obj/item/animatronic_suit/interact(mob/user)

	var/slot = 0
	switch(suit_slot)
		if("head")
			slot = ITEM_SLOT_HEAD
		if("chest")
			slot = ITEM_SLOT_OCLOTHING
		if("arms")
			slot = ITEM_SLOT_GLOVES
		if("legs")
			slot = ITEM_SLOT_FEET
		else
			slot = 0

	if(!slot)
		return ..()


	if(user.equip_to_slot_if_possible(src, slot))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING


/obj/item/animatronic_suit/proc/try_attach_to_skeleton(mob/user, obj/machinery/animatronic/A)
	if(!user.transferItemToLoc(src, A))
		to_chat(user, span_warning("The [src] is stuck to your hand, you cannot put it in the [A]!"))
		return ITEM_INTERACT_BLOCKING
	A.AddSuit(src)
	user.visible_message(span_notice("[user] attaches [src] to [A]."), span_notice("You attach [src] to [A]."))
	return ITEM_INTERACT_SUCCESS


/obj/item/animatronic_suit/cat/head
	name = "Cat animatronic  Suit Head"
	icon ='icons/psychonaut/obj/animatronic/animatronic_suit.dmi'
	suit_slot = "head"
	icon_state = "head_suit"
	// wearable on humans
	worn_icon = 'icons/psychonaut/mob/animatronic/animatronic_suit.dmi'
	worn_icon_state = "head_suit"
	slot_flags = ITEM_SLOT_HEAD


/obj/item/animatronic_suit/cat/chest
	name = "Cat Animatronic Suit Chest"
	icon ='icons/psychonaut/obj/animatronic/animatronic_suit.dmi'
	suit_slot = "chest"
	icon_state = "chest_suit"
	worn_icon = 'icons/psychonaut/mob/animatronic/animatronic_suit.dmi'
	slot_flags = ITEM_SLOT_OCLOTHING
	worn_icon_state = "chest_suit"

/obj/item/animatronic_suit/cat/arms
	name = "Cat Animatronic Suit Arms"
	icon ='icons/psychonaut/obj/animatronic/animatronic_suit.dmi'
	suit_slot = "arms"
	icon_state = "arms_suit"
	worn_icon = 'icons/psychonaut/mob/animatronic/animatronic_suit.dmi'
	slot_flags = ITEM_SLOT_GLOVES
	worn_icon_state = "arms_suit"

/obj/item/animatronic_suit/cat/legs
	name = "Cat Animatronic Suit Legs"
	icon ='icons/psychonaut/obj/animatronic/animatronic_suit.dmi'
	suit_slot = "legs"
	icon_state = "legs_suit"
	worn_icon = 'icons/psychonaut/mob/animatronic/animatronic_suit.dmi'
	slot_flags = ITEM_SLOT_FEET
	worn_icon_state = "legs_suit"


#define ANIMATION_STEP_TIME (1 SECONDS)

/obj/machinery/animatronic
	name = "animatronic skeleton"
	icon = 'icons/mob/rideables/mech_construct.dmi'
	icon_state = "blank"
	anchored = FALSE
	density = TRUE
	var/list/attached_parts = list()
	var/list/attached_suits = list()
	var/active = FALSE
	var/complete_suit = FALSE
	var/dance_timerid = null
	var/dance_index = 0
	var/list/dance_frames = list("a1", "a2", "a3", "a4")

	proc/AddPart(obj/item/animatronic_part/P)
		attached_parts += P
		if(P.icon_state)
			var/image/overlay = image(icon='icons/psychonaut/obj/animatronic/animatronic_parts.dmi', icon_state=P.icon_state+"+o")
			src.add_overlay(overlay)
		CheckPartsComplete()

	proc/RemovePart(obj/item/animatronic_part/P)
		attached_parts -= P
		if(P.icon_state)
			var/image/overlay = image(icon='icons/psychonaut/obj/animatronic/animatronic_parts.dmi', icon_state=P.icon_state+"+o")
			src.cut_overlay(overlay)
		complete_suit = FALSE
		name = "animatronic skeleton"
		icon_state = "blank"
		CheckPartsComplete()

	proc/AddSuit(obj/item/animatronic_suit/S)
		attached_suits += S
		if(S.icon_state)
			var/image/overlay = image(icon='icons/psychonaut/obj/animatronic/animatronic_suit.dmi', icon_state=S.icon_state+"+o")
			src.add_overlay(overlay)
		CheckSuitsComplete()

	proc/RemoveSuit(obj/item/animatronic_suit/S)
		attached_suits -= S
		if(S.icon_state)
			var/image/overlay = image(icon='icons/psychonaut/obj/animatronic/animatronic_suit.dmi', icon_state=S.icon_state+"+o")
			src.cut_overlay(overlay)
		complete_suit = FALSE
		name = "endoskeleton"
		icon_state = "endoskeleton"
		CheckSuitsComplete()

	proc/CheckPartsComplete()
		var/list/required = list("base","head","chest","arms","legs")
		for(var/slot in required)
			var/found = 0
			for(var/obj/item/animatronic_part/part in attached_parts)
				if(part.part_slot == slot)
					found = 1
					break
			if(!found)
				return
		name = "endoskeleton"
		icon_state = "endoskeleton"
		visible_message(span_notice("Animatronic skeleton is fully assembled! You can now dress it with a suit."))

	proc/CheckSuitsComplete()
		var/list/required_slots = list("head","chest","arms","legs")
		for(var/slot in required_slots)
			var/f = 0
			for(var/obj/item/animatronic_suit/s in attached_suits)
				if(s.suit_slot == slot)
					f = 1
					break
			if(!f)
				complete_suit = FALSE
				return
		complete_suit = TRUE
		name = "animatronic"
		icon_state = "animatronic"
		visible_message(span_notice("Animatronic suit is fully assembled! The animatronic is ready for activation."))

	proc/on_activation(mob/user)
		if(!complete_suit)
			to_chat(user, span_notice("This animatronic is not fully dressed yet."))
			return
		if(!anchored)
			to_chat(user, span_notice("You must secure the animatronic with a wrench before activating it."))
			return
		StartDance(user)

	proc/StartDance(mob/user)
		if(active)
		to_chat(user, span_notice("It is already active."))
			return
		if(!anchored)
		to_chat(user, span_notice("The animatronic must be secured with a wrench before it can be activated."))
			return
		active = TRUE
		visible_message(span_notice("[user] activates the animatronic. It powers on and begins to move..."))
		dance_index = 0
		if(dance_timerid)
			deltimer(dance_timerid)
			dance_timerid = null
		dance_timerid = addtimer(CALLBACK(src, PROC_REF(DanceStep)), ANIMATION_STEP_TIME, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)

	proc/StopDance()
		if(!active)
			return
		active = FALSE
		if(dance_timerid)
			deltimer(dance_timerid)
			dance_timerid = null
		dance_index = 0
		src.icon_state = "blank"

	proc/DanceStep()
		if(!active)
			return
		if(!anchored)
			StopDance()
			return
		if(!length(dance_frames))
			return
		dance_index = (dance_index % length(dance_frames)) + 1
		var/new_state = dance_frames[dance_index]
		if(new_state)
			src.icon_state = new_state
		if(dance_timerid)
			deltimer(dance_timerid)
		dance_timerid = addtimer(CALLBACK(src, PROC_REF(DanceStep)), ANIMATION_STEP_TIME, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)

/// Override item_interaction to handle animatronic part and suit attachment
/obj/machinery/animatronic/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/animatronic_part))
		var/obj/item/animatronic_part/part = tool
		return part.try_attach_part(user, src)
	if(istype(tool, /obj/item/animatronic_suit))
		var/obj/item/animatronic_suit/suit = tool
		return suit.try_attach_to_skeleton(user, src)
	return ..()

/// Override add_context to show wrench options
/obj/machinery/animatronic/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
		return CONTEXTUAL_SCREENTIP_SET
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/animatronic/attackby(obj/item/used, mob/user, list/modifiers, list/attack_modifiers)
	if(used.tool_behaviour == TOOL_WRENCH)
		if(modifiers["shift"])
			used.play_tool_sound(src, 50)
			switch(dir)
				if(NORTH)
					dir = EAST
				if(EAST)
					dir = SOUTH
				if(SOUTH)
					dir = WEST
				if(WEST)
					dir = NORTH
				else
					dir = NORTH
			to_chat(user, span_notice("You adjust the animatronic to face [dir2text(dir)]."))
			return
		// Normal click to toggle anchor
		if(anchored)
			used.play_tool_sound(src, 75)
			to_chat(user, span_notice("You unsecure the animatronic from the floor."))
			set_anchored(FALSE)
			return
		else
			used.play_tool_sound(src, 100)
			to_chat(user, span_notice("You secure the animatronic to the floor."))
			set_anchored(TRUE)
			return
	return ..()
