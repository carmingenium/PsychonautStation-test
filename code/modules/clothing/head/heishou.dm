//Mao Autodrobe
/obj/item/clothing/head/costume/mao_hat
	name = "Heishou Pack Mao Branch Hat"
	desc = "Its yellow afterimages might as well be the last thing you see."
	icon = 'icons/psychonaut/obj/clothing/head/heishou_hats/mao_hat.dmi'
	worn_icon = 'icons/psychonaut/mob/clothing/head/heishou_hats/mao_hat.dmi'
	icon_state = "mao_hat"
	flags_inv = HIDEHAIR

//Si Chaplain
/obj/item/clothing/head/si_hat
	name = "Heishou Pack Si Branch Hat"
	desc = "Toxic aura emanating from it makes you wanna look away..."
	icon = 'icons/psychonaut/obj/clothing/head/heishou_hats/si_hat.dmi'
	worn_icon = 'icons/psychonaut/mob/clothing/head/heishou_hats/si_hat.dmi'
	icon_state = "si_hat"
	flags_inv = HIDEHAIR

//You Security
/obj/item/clothing/head/you_hat
	name = "Heishou Pack You Branch Hat"
	desc = "The red crest brings chaos with it."
	icon = 'icons/psychonaut/obj/clothing/head/heishou_hats/you_hat.dmi'
	worn_icon = 'icons/psychonaut/mob/clothing/head/heishou_hats/you_hat.dmi'
	icon_state = "you_hat"
	flags_inv = HIDEHAIR
	/datum/armor/you_hat
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50
	wound = 10

//Wu Mining
/obj/item/clothing/head/wu_hat
	name = "Heishou Pack Wu Branch Hat"
	desc = "Obsidian black hat casts a trembling shadow."
	icon = 'icons/psychonaut/obj/clothing/head/heishou_hats/wu_hat.dmi'
	worn_icon = 'icons/psychonaut/mob/clothing/head/heishou_hats/wu_hat.dmi'
	icon_state = "wu_hat"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flags_inv = HIDEHAIR
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL
	/datum/armor/wu_hat
	melee = 30
	bullet = 30
	laser = 10
	energy = 20
	bomb = 50
	bio = 60
	fire = 100
	acid = 100
	wound = 10
