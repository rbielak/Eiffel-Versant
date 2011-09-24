#include "eif_eiffel.h"
#include	<osc.h>
#include	<oscerr.h>
#include	<omapi.h>
#include <stdio.h>

/* #define versant_debug 0 */

extern o_4b get_db_int_attr (o_object obj, char *attr_name);
extern o_float get_db_real_attr (o_object obj, char *attr_name);
extern void set_eif_int_attr (int offset, EIF_OBJ object, int value);
extern void set_eif_double_attr (int offset, EIF_OBJ object, double value);

void c_int_retr (o_object pobject, char *attr_name, int offset, EIF_OBJ eobject)
{
  int value = 0;
#ifdef versant_debug
  printf ("versant.c_get_byte_attr \n");
#endif

  value = get_db_int_attr (pobject, attr_name);
  if (o_errno == O_OK) 
	{
		set_eif_int_attr (offset, eobject, value);
	}
}

void c_int_o_retr (o_object pobject, int db_offset, int offset, EIF_OBJ eobject)
{
  int value = 0;
#ifdef versant_debug
  printf ("versant.c_int_o_retr \n");
#endif

  value = get_db_int_o_attr (pobject, db_offset);
  if (o_errno == O_OK) 
	{
		set_eif_int_attr (offset, eobject, value);
	}
}

void c_int_o_retr_ptr (o_u1b *obj_ptr, int db_offset, int offset, EIF_OBJ eobject)
{
	int value = 0;
 
	value = * (int *)(obj_ptr + db_offset);
	set_eif_int_attr (offset, eobject, value);
}

void c_ptr_o_retr_ptr (o_u1b *obj_ptr, int db_offset, int offset, EIF_OBJ eobject)
{
	o_vstr vstr, value;
	o_vstr *ptr;
 
	vstr = * (o_vstr *) (obj_ptr + db_offset);
	o_copyvstr (&value, &vstr);

	ptr = (o_vstr *)nth_address (offset, eif_access(eobject));

	if (*ptr)
		o_deletevstr (ptr);

	*(o_vstr *)ptr = value;
}

void c_bool_o_retr (o_object pobject, int db_offset, int offset, EIF_OBJ eobject)
{
  char value = 0;
  value = get_db_bool_o_attr (pobject, db_offset);
  if (o_errno == O_OK) 
	 {
		set_eif_bool_attr (offset, eobject, value);
	 }
}

void c_bool_o_retr_ptr (o_u1b *obj_ptr, int db_offset, int offset, EIF_OBJ eobject)
{
	char value = 0;
 
	value = * (char *)(obj_ptr + db_offset);
	set_eif_bool_attr (offset, eobject, value);
}

void c_char_o_retr (o_object pobject, int db_offset, int offset, EIF_OBJ eobject)
{
  char value = 0;
  value = get_db_char_o_attr (pobject, db_offset);
  if (o_errno == O_OK) 
	 {
		set_eif_bool_attr (offset, eobject, value);
	 }
}

void c_char_o_retr_ptr (o_u1b *obj_ptr, int db_offset, int offset, EIF_OBJ eobject)
{
	char value = 0;
 
	value = * (char *)(obj_ptr + db_offset);
	set_eif_bool_attr (offset, eobject, value);
}

void c_double_retr (o_object pobject, char *attr_name, int offset, EIF_OBJ eobject)
{
  o_double value = 0.0;
  get_db_double_attr (pobject, attr_name, &value);
  if (o_errno == O_OK) 
	 {
		set_eif_double_attr (offset, eobject, value);
	 }
}

void c_double_o_retr (o_object pobject, int db_offset, int offset, EIF_OBJ eobject)
{
  o_double value = 0.0;
  get_db_double_o_attr (pobject, db_offset, &value);
  if (o_errno == O_OK) 
	 {
		set_eif_double_attr (offset, eobject, value);
	 }
}

void c_double_o_retr_ptr (o_u1b *obj_ptr, int db_offset, int offset, EIF_OBJ eobject)
{
	o_double value = 0.0;
 
	value = * (double *) (obj_ptr + db_offset);
	set_eif_double_attr (offset, eobject, value);
}

EIF_OBJ get_db_string_attr (o_object obj, char *attr_name)
{
  o_err err;
  o_bufdesc desc;
  o_vstr vstr;
  EIF_OBJ result = 0;
#ifdef versant_debug
  printf ("versant.get_db_string_attr \n");
#endif

  desc.length = sizeof(vstr);
  desc.data = (o_u1b *)&vstr;
  err = o_getattr (obj, attr_name, &desc);
  if (err == O_OK) 
	 {
		if (vstr != NULL) {
	  result = RTMS ((char *)vstr);
	  o_deletevstr (&vstr); 
	}
		else
	result = NULL;
	 }
  return (result);
}


EIF_OBJ get_db_string_o_attr (o_object obj, int db_offset)
{
  o_err err;
  o_bufdesc desc;
  o_vstr vstr;
  EIF_OBJ result = 0;

#ifdef versant_debug
  printf ("versant.get_db_string_o_attr \n");
#endif

  desc.length = sizeof(vstr);
  desc.data = (o_u1b *)&vstr;
  err = o_getattroffset (obj, db_offset, &desc);
  if (err == O_OK)
		if (vstr != NULL) 
	{
	  result = RTMS ((char *)vstr);
	  o_deletevstr (&vstr); 
	}
  return (result);
}

/* Retrieve class name of an object and return it as an Eiffel string */
EIF_OBJ c_get_class_name (o_object object)
{
  char *cname;
  EIF_OBJ result = 0;
  o_vstr vstr;
  o_err err;
  int i;
#ifdef versant_debug
  printf ("versant.c_get_class_name oid =%d\n", object);
#endif

  err = o_classnameof (object, &vstr);

	if (err == O_OK) 
	{
		cname = (char *)vstr;
		for (i=0;i<strlen(cname);i++)
			cname[i] = toupper (cname[i]);
		result = RTMS (cname);
	}

	o_deletevstr (&vstr);
	return (result);
}

/* Initialize an attribute desctiptor */

o_attrdesc *c_build_attr_desc (EIF_OBJ object,
								o_attrname name,
								o_clsname  type_name,
								int rep)
{

  o_attrdesc *atd;
#ifdef versant_debug
  printf ("versant.c_build_attr_desc \n");
#endif

  /*  printf ("In c_build_attr-desc \n"); */
  atd = (o_attrdesc *)eif_access (object);
  /*  printf ("Atd=%d *atd=%d \n", atd, *atd); */

  return (atd);
}


/* Boolean, indicating that the db session is active */
char eif_vers_session_active;

void c_set_session_active (char active)
{
  eif_vers_session_active = active;
}

char c_is_session_active ()
{
	return eif_vers_session_active;
}

/* Get a string representation of the object's LOID */
EIF_OBJ c_get_loid (o_object oid)
{
  o_uid loid;
  o_err err;
  char str_loid[30];
  EIF_OBJ result;

  result = NULL;
  err = o_getloid (oid, &loid);
  if (err == O_OK)
	 {
		/* Create a string from the loid */
		sprintf(str_loid, "%d.%d.%d", loid.uid.dbID, loid.uid.objID1, loid.uid.objID2);
		result = RTMS  (str_loid);
	 }
  return (result);
}

char *c_get_reusable_loid (o_object oid)
{
  o_uid loid;
  o_err err;
  static char str_loid[30];
 
  str_loid [0] = '\0';
  err = o_getloid (oid, &loid);
  if (err == O_OK)
	{
		/* Create a string from the loid */
		sprintf(str_loid, "%d.%d.%d", loid.uid.dbID, loid.uid.objID1, loid.uid.objID2);
  }
  return (str_loid);
}
