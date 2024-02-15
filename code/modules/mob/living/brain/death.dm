/mob/living/brain/get_death_message(gibbed)
	var/obj/item/organ/internal/brain_interface/container = get_container()
	if(!gibbed && istype(container))
		return "beeps shrilly as \the [container] flatlines!"
	return ..()

/mob/living/brain/death(gibbed)
	var/obj/item/organ/holder = loc
	var/obj/item/organ/internal/brain_interface/container = get_container()
	. = ..()
	if(stat == DEAD && istype(holder))
		holder.die()
	if(istype(container) && !QDELETED(container))
		container.update_icon()

/mob/living/brain/gib()
	var/obj/item/organ/internal/brain_interface/container = get_container()
	var/obj/item/organ/internal/brain/sponge = loc
	. = ..(null, 1)
	if(container && !QDELETED(container))
		qdel(container)
	if(istype(sponge) && !QDELETED(sponge))
		qdel(sponge)
