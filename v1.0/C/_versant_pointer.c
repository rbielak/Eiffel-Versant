#include "eif_eiffel.h"
/*************
#include "eif_config.h"
#include "eif_malloc.h"
#include "eif_garcol.h"
#include "eif_struct.h"
#include "eif_out.h"
#include "eif_macros.h"
#include "eif_plug.h"
*************/

#include <osc.h>
#include <oscerr.h>
#include <omapi.h>

#include <stdio.h>

void set_db_int_o_ptr (o_u1b *obj_ptr, int offset, o_4b value)
{
	*(o_4b *)(obj_ptr + offset) = value;
}

void set_db_ptr_o_ptr (o_u1b *obj_ptr, int offset, o_vstr value)
{
	register o_vstr* loc;
	loc = (o_vstr *)(obj_ptr + offset);
	if (*loc)
		o_deletevstr (loc);
	o_copyvstr (loc, &value);
}

void set_db_bool_o_ptr (o_u1b *obj_ptr, int offset, o_u1b value)
{
	*(o_u1b *)(obj_ptr + offset) = value;
}

void set_db_char_o_ptr (o_u1b *obj_ptr, int offset, char value)
{
	*(char *)(obj_ptr + offset) = value;
}

void set_db_double_o_ptr (o_u1b *obj_ptr, int offset, double value)
{
	*(double *)(obj_ptr + offset) = value;
}

void set_db_string_o_ptr (o_u1b *obj_ptr, int offset, char *value)
{
	o_vstr vstr;
	register o_vstr* loc;
	o_newvstr (&vstr, strlen(value)+1, value);
	loc = (o_vstr *)(obj_ptr + offset);
	if (*loc)
		o_deletevstr (loc);
	*loc = vstr;
}

o_4b get_db_int_o_ptr (o_u1b *obj_ptr, int offset)
{
#ifdef versant_debug
	printf ("versant.c_get_db_int_o_ptr\n");
#endif
	return (*(o_4b *)(obj_ptr + offset));
}
 
o_vstr get_db_ptr_o_ptr (o_u1b *obj_ptr, int offset)
{
	o_vstr vstr;
#ifdef versant_debug
	printf ("versant.get_db_ptr_o_ptr\n");
#endif
 
	o_copyvstr (&vstr, (o_vstr *)(obj_ptr + offset));
	return (vstr);
}

EIF_OBJ get_db_string_o_ptr (o_u1b *obj_ptr, int db_offset)
{
	register EIF_OBJ result = 0;
	register o_vstr vstr;
 
#ifdef versant_debug
	printf ("versant.get_db_string_o_ptr \n");
#endif
 
	vstr = * (o_vstr *) (obj_ptr + db_offset);
	if (vstr)
		result = RTMS ((char *)vstr);

	return (result);
}

o_u1b get_db_bool_o_ptr (o_u1b *obj_ptr, int offset)
{

#ifdef versant_debug
	printf ("versant.get_db_bool_o_ptr\n");
#endif
 
	return (*(o_u1b *)(obj_ptr + offset));
}

char get_db_char_o_ptr (o_u1b *obj_ptr, int offset)
{

#ifdef versant_debug
	printf ("versant.get_db_char_o_ptr\n");
#endif
 
	return (*(char *)(obj_ptr + offset));
}

double get_db_double_o_ptr (o_u1b *obj_ptr, int offset)
{

#ifdef versant_debug
	printf ("versant.get_db_double_o_ptr\n");
#endif
 
	return (*(double *)(obj_ptr + offset));
}

/* Quickly determine if a string a a vstr are different. */
/* Return true if they are, false otherwise.             */
o_u1b c_is_string_different (o_u1b *obj_ptr, int offset, char *sp, int sz) {
  o_vstr vstr;
  int v_sz;
  o_u1b result = 1;

  vstr = *(o_vstr *) (obj_ptr + offset);
  
  if (vstr) {
	if (sp != NULL) {
	  /* Both are not NULL */
	  /* vstr size includes the terminating NULL */
	  v_sz = o_sizeofvstr (&vstr) - 1;
	  if (v_sz == sz) {
		/* Same size, must compare */
		if (strncmp ((char *)vstr, sp, sz) == 0)
		  result = 0; /* Equal, means not different */
	  }
	}
  }
  else {
	/* Both are NULL */
	if (sp == NULL)
	  result = 0;
  }
  return (result);
}

/* Quickly determine if two vstrs are different */
o_u1b c_is_vstr_different (o_u1b *obj_ptr, int offset, o_vstr other) {
  o_vstr vstr;
  int sz;
  o_u1b result = 1;

  vstr = *(o_vstr *) (obj_ptr + offset);

  if (vstr != other) {
	sz = o_sizeofvstr (&other);
	if (sz == o_sizeofvstr (&vstr)) {
	  /* If same size then compare */
	  if (strncmp ((char *)other, (char *)vstr, sz) == 0)
		result = 0; /* Equal means not different */
	}
  }
  else
	/* Pointers are equal */
	result = 0;

  return (result);

}
