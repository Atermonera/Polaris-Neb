/mob/living/carbon/human/gib(anim="gibbed-m",do_gibs)
	for(var/obj/item/organ/I in get_internal_organs())
		remove_organ(I)
		if(!QDELETED(I) && isturf(loc))
			I.throw_at(get_edge_target_turf(src, pick(global.alldirs)), rand(1,3), THROWFORCE_GIBS)

	for(var/obj/item/organ/external/E in get_external_organs())
		if(!E.parent_organ)
			continue //Skip root organ
		E.dismember(FALSE, DISMEMBER_METHOD_EDGE, TRUE, ignore_last_organ = TRUE)

	for(var/obj/item/I in get_contained_external_atoms())
		drop_from_inventory(I)
		if(!QDELETED(I))
			I.throw_at(get_edge_target_turf(src, pick(global.alldirs)), rand(1,3), round(THROWFORCE_GIBS/I.w_class))

	var/last_loc = loc
	..(species.gibbed_anim, do_gibs = FALSE)
	if(last_loc)
		gibs(last_loc)

/mob/living/carbon/human/dust()
	if(species)
		..(species.dusted_anim, species.remains_type)
	else
		..()

/mob/living/carbon/human/get_death_message(gibbed)
	if(get_config_value(/decl/config/toggle/health_show_human_death_message))
		return species.get_species_death_message(src) || "seizes up and falls limp..."
	return ..()

/mob/living/carbon/human/death(gibbed)

	if(stat == DEAD) return

	BITSET(hud_updateflag, HEALTH_HUD)
	BITSET(hud_updateflag, STATUS_HUD)
	BITSET(hud_updateflag, LIFE_HUD)

	//Handle species-specific deaths.
	species.handle_death(src)

	animate_tail_stop()

	callHook("death", list(src, gibbed))

	if(SSticker.mode)
		SSticker.mode.check_win()

	. = ..()

	if(!gibbed)
		handle_organs()
		if(species.death_sound)
			playsound(loc, species.death_sound, 80, 1, 1)

	handle_hud_list()

/mob/living/carbon/human/proc/is_husked()
	return (MUTATION_HUSK in mutations)

/mob/living/carbon/human/proc/make_husked()
	if(is_husked())
		return

	SET_FACIAL_HAIR_STYLE(src, /decl/sprite_accessory/facial_hair/shaved, TRUE)
	SET_HAIR_STYLE(src, /decl/sprite_accessory/hair/bald, FALSE)

	mutations.Add(MUTATION_HUSK)
	for(var/obj/item/organ/external/E in get_external_organs())
		E.status |= ORGAN_DISFIGURED
	update_body(1)

/mob/living/carbon/human/physically_destroyed(var/skip_qdel, var/droplimb_type = DISMEMBER_METHOD_BLUNT)
	for(var/obj/item/organ/external/limb in get_external_organs())
		if(!limb.parent_organ) // don't dismember root
			continue
		limb.dismember(TRUE, droplimb_type, TRUE, TRUE)
	dump_contents()
	if(!skip_qdel && !QDELETED(src))
		qdel(src)
