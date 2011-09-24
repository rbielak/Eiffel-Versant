#ifdef WINISS

#include "eiffel.h"

#else

#include "eif_eiffel.h"
#include "malloc.h"
#include "eif_garcol.h"
#include "eif_struct.h"
#include "eif_out.h"
#include "eif_macros.h"
#include "eif_plug.h"

#endif

/* #define CDEBUG 1 */

set_nth (uint32 i, char *dest, char *src)
{
	char **o_ref, *tmp;
	tmp = dest + i;
	o_ref = (char **)tmp;
	*o_ref = src;
	RTAR(src,dest);
}

char *nth_address (uint32 i, char *object)
{
  return (object + i);
}

EIF_BOOLEAN extract_boolean (uint32 offset, char* src)
{
	return *(EIF_BOOLEAN *)(src + offset);
}

int extract_integer (uint32 offset, char* src)
{
	return *(int *)(src + offset);
}

char extract_character (uint32 offset, char* src)
{
	return *(char *)(src + offset);
}

double extract_double (uint32 offset, char* src)
{
	return *(double *)(src + offset);
}

EIF_OBJ extract_string (uint32 offset, char* src)
{
	return *(EIF_OBJ *)(src + offset);
}

char *extract_pointer (uint32 offset, char* src)
{
	return *(char **)(src + offset);
}

EIF_OBJ extract_reference (uint32 offset, char* src)
{
	return *(EIF_OBJ *)(src + offset);
}

void set_eif_int_attr (int offset, EIF_OBJ object, int value)
{
#ifdef WINISS
  *(int *)((char *) (((char *) eif_access(object)) + offset)) = value;
#else
  *(int *)((char *) (eif_access(object) + offset)) = value;
#endif
}

void set_eif_bool_attr (int offset, EIF_OBJ object, EIF_BOOLEAN value)
{
#ifdef WINISS
  *(EIF_BOOLEAN *)((char *) (((char *) eif_access(object)) + offset)) = value;
#else
  *(EIF_BOOLEAN *)((char *) (eif_access(object) + offset)) = value;
#endif
}

void set_eif_double_attr (int offset, EIF_OBJ object, double value)
{
#ifdef WINISS
  *(double *)((char *) (((char *) eif_access(object)) + offset)) = value;
#else
  *(double *)((char *) (eif_access(object) + offset)) = value;
#endif

}


#ifdef ISS

int c_eif_id (char *cl_name)
{
	EIF_TYPE_ID tid;
	char *start_generic = NULL;
	char *end_generic = NULL;
	int nb_generics;
	int generics_id [50];
	char base_name[50];
	char generic_name[50];

	start_generic = strchr (cl_name, '[');
	if (!start_generic)
		tid = eif_type_id (cl_name);
	else {
		int nb = 0;
		strncpy (base_name, cl_name, start_generic - cl_name);
		base_name[start_generic - cl_name] = '\0';
		end_generic = start_generic+1;
		for (nb_generics = 0; (']' != *end_generic); nb_generics++) {
			for (end_generic = start_generic+1;
					((']' != *end_generic) && (',' != *end_generic)) || (nb != 0);
					end_generic++) {
				if ('[' == *end_generic) nb++;
				if (']' == *end_generic) nb--;
			}
			strncpy (generic_name, start_generic + 1, end_generic - start_generic - 1);
			generic_name[end_generic - start_generic - 1] = '\0';
			generics_id [nb_generics] = c_eif_id (generic_name);
			start_generic = end_generic;
		}
		tid = eif_generic_id (base_name, generics_id [0], generics_id [1],
					generics_id [2], generics_id [3], generics_id [4]);
	}
	if (tid == EIF_NO_TYPE)
		printf ("_eiffel.c: **ERROR: type not in system: %s \n", cl_name);
	return (tid);
}

char *c_eifcreate (int cid)
{
#ifdef WORKBENCH
   System (cid).cn_deferred = 0;
#endif
   return emalloc ((uint32) cid & SK_DTYPE);
}

#endif

#ifdef ISE
/* Changed for ISE 4.3 */
int c_eif_id (char *cl_name)
{
  EIF_TYPE_ID tid;
  
  tid = eif_type_id (cl_name);
  if (tid == EIF_NO_TYPE) {
	printf ("**ERROR: type not in system: %s \n", cl_name);
	eif_panic ("e_eif_id: type not in system");
  }
  return (tid);
}

EIF_OBJ c_eifcreate (int cid)
{
  return (eif_wean (eif_create (cid)));
}

#endif
