#include	<osc.h>
#include	<oscerr.h>
#include	<omapi.h>
#include	<obmacros.h>

#include <stdio.h>

/* #define versant_debug 0  */

extern char eif_vers_session_active;

int  c_sizeofvstr (o_vstr vstr)
{
#ifdef versant_debug
	printf ("versant.c_sizeofvstr\n");
#endif

	return (o_sizeofvstr(&vstr));
}

void c_dump_vstr (o_vstr vp)
{
	register int i, vsize;
	register o_object *arr;
	
	vsize = o_sizeofvstr (&vp) / 4;
	printf ("-->Dump of vstr %d  size = %d\n", vp, vsize);
	arr = (o_object *)vp;
	/*for (i=0;i < vsize;i++)
	  printf ("%d|", arr[i]);*/
	printf ("----------------\n");
	
}

o_object c_get_entry (o_object *vp, int index)
{
#ifdef versant_debug
	printf ("versant.c_get_entry\n");
#endif
	return ((vp == NULL)?(o_object)NULL:vp[index]);
}

o_double c_get_double_entry (o_double *vp, int index)
{
#ifdef versant_debug
	printf ("versant.c_get_double_entry\n");
	printf ("vstr= %d index= %d return double= %f\n", vp, index, vp[index]);
#endif
	return (vp[index]);
}

o_u1b c_get_bool_entry (o_u1b *vp, int index)
{
	return ((vp == NULL)?(o_u1b)NULL:vp[index]);
}

o_ptr c_get_ptr_entry (o_ptr *vp, int index)
{
	return ((vp == NULL)?(o_ptr)NULL:vp[index]);
}

void set_ith_entry (int *vstr, int item, int index)
{
#ifdef versant_debug
	printf ("versant.set_ith_entry\n");
#endif
	vstr[index] = item;
}

void set_ith_double_entry (o_double *vstr, o_double item, int index)
{
#ifdef versant_debug
	printf ("versant.set_ith_double_entry\n");
#endif
	vstr[index] = item;
}

void set_ith_bool_entry (o_u1b *vstr, o_u1b item, int index)
{
#ifdef versant_debug
	printf ("versant.set_ith_bool_entry\n");
#endif
	vstr[index] = item;
}

void set_ith_ptr_entry (o_ptr *vstr, o_ptr item, int index)
{
#ifdef versant_debug
	printf ("versant.set_ith__ptr_entry\n");
#endif
	vstr[index] = item;
}

o_vstr c_build_sized_vstr_from_vstr (o_vstr vstr, int size, o_vstr source, int position)
{
	return (o_newvstr(&vstr,4 * size,(o_u1b *) source + (4 * position)));
}

o_vstr c_build_sized_vstr (o_vstr vstr, int size)
{
	return (o_newvstr(&vstr,size,(o_u1b *)NULL));
}

o_vstr c_resize_vstr (o_vstr vstr, int size)
{
	return (o_appendvstr(&vstr,size,(o_u1b *)NULL));
}

o_vstr c_build_vstr (o_vstr vstr, o_u1b *data)
{
#ifdef versant_debug
	printf ("versant.c_build_vstr\n");
#endif
	return ((vstr==NULL)?o_newvstr(&vstr,4,(o_u1b *)&data):o_appendvstr(&vstr,4,(o_u1b *)&data));
}

o_vstr c_build_int_vstr (o_vstr vstr, int data)
{
#ifdef versant_debug
	printf ("versant.c_build_int_vstr\n");
#endif
	return ((vstr==NULL)?o_newvstr(&vstr,4,(o_u1b *)&data):o_appendvstr(&vstr,4,(o_u1b *)&data));
}

o_vstr c_build_double_vstr (o_vstr vstr, o_double data)
{
#ifdef versant_debug
	printf ("versant.c_build_double_vstr\n");
	printf ("vstr= %d double= %f\n", vstr, data);
#endif
	return ((vstr==NULL)?o_newvstr(&vstr,sizeof(o_double),(o_u1b *)&data):o_appendvstr(&vstr,sizeof(o_double),(o_u1b *)&data));
}

o_vstr c_build_bool_vstr (o_vstr vstr, o_u1b data)
{
	return ((vstr==NULL)?o_newvstr(&vstr,sizeof(o_u1b),&data):o_appendvstr(&vstr,sizeof(o_u1b),&data));
}

o_vstr c_diffvstrobj (o_vstr v1, o_vstr v2)
{
#ifdef versant_debug
	printf ("versant.c_diffvstrobj\n");
#endif
	return (o_diffvstrobjs (&v1, &v2));
}

o_vstr c_unionvstrobj (o_vstr v1, o_vstr v2)
{
#ifdef versant_debug
	printf ("versant.c_unionvstrobj\n");
#endif
	return (o_unionvstrobjs (&v1, &v2));
}

o_vstr c_intersectvstrobj (o_vstr v1, o_vstr v2)
{
#ifdef versant_debug
	printf ("versant.c_intersectvstrobj\n");
#endif
	return (o_intersectvstrobjs (&v1, &v2));
}

o_vstr c_concatvstr (o_vstr v1, o_vstr v2)
{
#ifdef versant_debug
	printf ("versant.c_concatvstr\n");
#endif
	return (o_concatvstr (&v1, &v2));
}

o_vstr c_copyvstr (o_vstr source)
{
	o_vstr target;
	return (o_copyvstr (&target, &source));
}

void c_deletevstr (o_vstr vstr)
{
#ifdef versant_debug
	printf ("versant.c_deletevstr\n");
#endif
	o_deletevstr (&vstr);
}

void c_dispose_delete_vstr (o_vstr vstr)
{
#ifdef versant_debug
	printf ("c_dispose_delete_vstr. active=%d vstr=%X\n", eif_vers_session_active, vstr);
#endif
	if (eif_vers_session_active && vstr)
		o_deletevstr (&vstr);
}
 
o_vstr c_build_array_vstr (o_vstr vstr, int nb_element, int *data)
{
	o_vstr *vp = &vstr;
	o_vstr result;
#ifdef versant_debug
	printf ("versant.c_build_array_vstr\n");
#endif

	if (*vp==NULL)
	  result = o_newvstr (vp, nb_element * sizeof(int), (o_u1b *) data);
	else
	  result = o_appendvstr (vp, nb_element * sizeof (int), (o_u1b *) data);

#ifdef versant_debug
	c_dump_vstr (result);
#endif
	return (result);
}


o_vstr c_new_filled_vstr (int v_size, char fill_char)
/* Create a new vstr of specified size and fill every byte with the fill character */
{
  o_vstr result;
  char *cp;
  int i;

  result = o_newvstr (&result, v_size, NULL);
  /* Fill with fill value */
  cp = (char *)result;
  for (i = 0; i < v_size; i++)
	cp [i] = fill_char;
  return (result);

}

void c_remove_i_th_int (o_vstr target, int index) 
/* Remove the index-th integer from the Vstr */
{
  int vlen, copy_len;
  int *tp, *sp;

  vlen = o_sizeofvstr (&target);
  tp = (int *)target;
  /* Careful, nasty pointer arithmetic here */
  tp = tp + index;
  sp = tp + 1;
  /* Shift vstr from */
  copy_len = vlen - index * sizeof(int) - sizeof(int);
  if (copy_len > 0)
	memcpy (tp, sp, copy_len);
  /* Fix up the size */
  o_adjustvstr (&target, vlen - sizeof (int));
}
