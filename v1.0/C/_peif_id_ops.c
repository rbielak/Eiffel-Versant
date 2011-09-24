/* Operations on the special transient attribute of evry pobject */
#include <osc.h>
#include <oscerr.h>
#include <omapi.h>

#include <stdio.h>

#define PEIF_ID_OFFSET 8

void c_set_was_modified(o_u1b *obj_ptr)
{
	int v = *(o_4b *)(obj_ptr + PEIF_ID_OFFSET);
	/* Set the high order bit on */
	*(o_4b *)(obj_ptr + PEIF_ID_OFFSET) = v | 0x80000000;
}

o_u1b c_was_modified (o_u1b *obj_ptr) 
{
	if (*(o_4b *)(obj_ptr + PEIF_ID_OFFSET) & 0x80000000)
		return (1);
	/* Was modified is false */
	return (0);
}

void c_set_peif_id_and_clear_wm (o_u1b *obj_ptr, int eif_id) 
{
	*(o_4b *)(obj_ptr + PEIF_ID_OFFSET) = eif_id;
}

int c_get_peif_id (o_u1b *obj_ptr) 
{
	int v = *(o_4b *)(obj_ptr + PEIF_ID_OFFSET);
	/* Zero out the was_modified bit */
	return (v & 0x7FFFFFFF);
}
