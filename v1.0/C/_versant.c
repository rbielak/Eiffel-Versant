#include	<osc.h>
#include	<oscerr.h>
#include	<omapi.h>
#include	<obmacros.h>

#include <stdio.h>

/* #define versant_debug 0  */

void str_to_lower (char *src, char *dest)
{
  int sl, i;

  sl = strlen (src);
  for (i=0; i < sl; i++)
    dest[i] = tolower(src[i]);
  dest[sl] = '\0';
}

o_err c_begin_session (char *lx_name, o_dbname dbname, char *sess)
{
  o_err stat;
  stat = o_beginsession (NULL, dbname, sess, NULL);
  return (stat);
}

o_object c_scan_loid (char *loid)
{
  o_object oid;
  if (o_scanloid (loid, &oid) == O_OK)
    return (oid);
  else
    return (NULL);
}

o_err c_commit ()
{
#ifdef versant_debug
  printf ("versant.c_commit \n");
#endif
  return (o_xact (O_COMMIT_AND_RETAIN, NULL));
}

o_err c_checkpoint_commit ()
{
  return (o_xact (O_CHECKPOINT_COMMIT, NULL));
}

o_err c_abort ()
{
  return (o_xact (O_ROLLBACK_AND_RETAIN, NULL));
}

o_err c_partial_commit (o_vstr vstr)
{
  o_vstr avstr;
  return (o_xactwithvstr (O_COMMIT_AND_RETAIN | O_FLUSH_VSTR, NULL, vstr, &avstr));
}

/***** Retrieve values of attributes *****/
o_4b get_db_int_attr (o_object obj, char *attr_name) 
{
  o_err err;
  o_bufdesc desc;
  o_4b value = 0;

  
#ifdef versant_debug
  printf ("versant.c_get_db_int_attr\n");
#endif

  desc.length = sizeof (value);
  desc.data = (o_u1b *)&value;
  err = o_getattr (obj, attr_name, &desc);
  return (value);
}

o_4b get_db_ptr_attr (o_object obj, char *attr_name) 
{
  o_err err;
  o_bufdesc desc;
  o_4b value = 0;
  
#ifdef versant_debug
  printf ("versant.c_get_db_ptr_attr\n");
#endif

  desc.length = sizeof (value);
  desc.data = (o_u1b *)&value;
  err = o_getattr (obj, attr_name, &desc);
  return (value);
}

o_4b get_db_ptr_o_attr (o_object obj, int offset) 
{
  o_err err;
  o_bufdesc desc;
  o_4b value = 0;
  
#ifdef versant_debug
  printf ("versant.c_get_db_ptr_o_attr\n");
  printf ("o_ptr oid=%d off=%d \n", obj, offset);  
#endif



  desc.length = sizeof (value);
  desc.data = (o_u1b *)&value;
  err = o_getattroffset (obj, offset, &desc);
  return (value);
}

o_4b get_db_int_o_attr (o_object obj, int offset)
{
  o_err err;
  o_bufdesc desc;
  o_4b value = 0;

#ifdef versant_debug
  printf ("versant.c_get_db_int_o_attr \n");
  printf ("o_int oid=%d off=%d \n", obj, offset);  
#endif

  desc.length = sizeof (value);
  desc.data = (o_u1b *)&value;
  err = o_getattroffset (obj, offset, &desc);
  return (value);
}

o_u1b get_db_bool_o_attr (o_object obj, int offset)
{
  o_err err;
  o_bufdesc desc;
  o_u1b value = 0;
  
#ifdef versant_debug
  printf ("versant.c_get_bool_entry \n");
#endif


  desc.length = 1;
  desc.data = (o_u1b *)&value;
  err = o_getattroffset (obj, offset, &desc);
  return (value);
}

o_u1b get_db_bool_attr (o_object obj, char *attr_name)
{
  o_err err;
  o_bufdesc desc;
  o_u1b value = 0;
  
#ifdef versant_debug
  printf ("versant.get_db_bool_attr \n");
#endif


  desc.length = 1;
  desc.data = (o_u1b *)&value;
  err = o_getattr (obj, attr_name, &desc);
  return (value);
}

char get_db_char_o_attr (o_object obj, int offset)
{
  o_err err;
  o_bufdesc desc;
  o_u1b value = 0;
  
#ifdef versant_debug
  printf ("versant.c_get_char_o_attr \n");
#endif


  desc.length = 1;
  desc.data = (char *)&value;
  err = o_getattroffset (obj, offset, &desc);
  return (value);
}

char get_db_char_attr (o_object obj, char* attr_name)
{
  o_err err;
  o_bufdesc desc;
  o_u1b value = 0;
  
#ifdef versant_debug
  printf ("versant.c_get_char_attr \n");
#endif

  desc.length = 1;
  desc.data = (char *)&value;
  err = o_getattr (obj, attr_name, &desc);
  return (value);
}

void set_db_int_attr (o_object obj, char *attr_name, int value)
{
  o_err err;
  o_bufdesc desc;

  
#ifdef versant_debug
  printf ("versant.c_set_dbint_attar \n");
#endif

  desc.length = sizeof (value);
  desc.data = (char *)&value;
  err = o_setattr (obj, attr_name, &desc);
}

void set_db_int_o_attr (o_object obj, int offset, int value)
{
  o_err err;
  o_bufdesc desc;

  
#ifdef versant_debug
  printf ("versant.c_set_db_int_o_attr \n");
#endif

  desc.length = sizeof (value);
  desc.data = (char *)&value;
/*  printf ("Jset_db_int_o_attr obj=%d off=%d value=%d \n", obj, offset, value); */
  err = o_setattroffset (obj, offset, &desc);
}

void set_db_bool_o_attr (o_object obj, int offset, o_u1b value)
{
  o_err err;
  o_bufdesc desc;

  
#ifdef versant_debug
  printf ("versant.set_db_bool_o_attr \n");
#endif

  desc.length = 1;
  desc.data = (char *)&value;
  err = o_setattroffset (obj, offset, &desc);
}

void set_db_bool_attr (o_object obj, char *attr_name, o_u1b value)
{
  o_err err;
  o_bufdesc desc;
 
 
#ifdef versant_debug
  printf ("versant.set_db_bool_attr \n");
#endif
 
  desc.length = 1;
  desc.data = (char *)&value;
  err = o_setattr (obj, attr_name, &desc);
}

void set_db_char_o_attr (o_object obj, int offset, char value)
{
  o_err err;
  o_bufdesc desc;
  
#ifdef versant_debug
  printf ("versant.set_db_char_o_attr \n");
#endif

  desc.length = 1;
  desc.data = (char *)&value;
  err = o_setattroffset (obj, offset, &desc);
}

void set_db_double_o_attr (o_object obj, int offset, double *value)
{
  o_err err;
  o_bufdesc desc;
#ifdef versant_debug
  printf ("versant.set_db_double_o_attr \n");
#endif

  desc.length = sizeof (*value);
  desc.data = (char *)value;
  err = o_setattroffset (obj, offset, &desc);
}


void set_db_vstring_attr (o_object obj, char *attr_name, char* value)
{
  o_err err;
  o_bufdesc desc;
  o_vstr vstr;
#ifdef versant_debug
  printf ("versant.set_db_vstringattr \n");
#endif

  /* Make sure to store the null at the end of each string */
  if (o_newvstr (&vstr, strlen(value)+1, value) != 0)
    {
      desc.length = sizeof(vstr);
      desc.data = (char *)&vstr;
      err = o_setattr (obj, attr_name, &desc);
      o_deletevstr (&vstr);
    }
}

void set_db_vstring_o_attr (o_object obj, int offset, char* value)
{
  o_err err;
  o_bufdesc desc;
  o_vstr vstr;
#ifdef versant_debug
  printf ("versant.set_db_vstring_o_attr \n");
#endif

  /* Make sure to store the null at the end of each string */
  if (o_newvstr (&vstr, strlen(value)+1, value) != 0)
    {
      desc.length = sizeof(vstr);
      desc.data = (char *)&vstr;
      err = o_setattroffset (obj, offset, &desc);
      o_deletevstr (&vstr);
    }
}

o_float get_db_real_attr (o_object obj, char *attr_name) 
{
  o_err err;
  o_bufdesc desc;
  o_float value = 0.0;
#ifdef versant_debug
  printf ("versant.get_db_real_o_attr \n");
#endif

  desc.length = sizeof (value);
  desc.data = (o_u1b *)&value;
  err = o_getattr (obj, attr_name, &desc);
  return (value);
}

void get_db_double_attr (o_object obj, char *attr_name, o_double *value) 
{
  o_err err;
  o_bufdesc desc;
#ifdef versant_debug
  printf ("versant.get_db_double_attr \n");
#endif

  desc.length = sizeof (*value);
  desc.data = (o_u1b *)value;
  err = o_getattr (obj, attr_name, &desc);
}

void get_db_double_o_attr (o_object obj, int offset, o_double *value) 
{
  o_err err;
  o_bufdesc desc;
#ifdef versant_debug
  printf ("versant.get_db_double_o_attr \n");
#endif

  desc.length = sizeof (*value);
  desc.data = (o_u1b *)value;
  err = o_getattroffset (obj, offset, &desc);
}

void set_db_double_attr (o_object obj, char *attr_name, double* value)
{
  o_err err;
  o_bufdesc desc;
#ifdef versant_debug
  printf ("versant.set_db_double_attr \n");
#endif

  desc.length = sizeof (*value);
  desc.data = (char *)value;
  err = o_setattr (obj, attr_name, &desc);
}

/** Rotuines for looking at schema objects ***/

o_vstr c_get_db_class_attrs (o_object oid)
{
  o_vstr attr_vstr;
  o_err err;
#ifdef versant_debug
  printf ("versant.c_get_db_class_attrs \n");
#endif

  err = o_extractclass (oid, NULL, NULL, &attr_vstr, NULL);
  
  if (err == O_OK) 
    return (attr_vstr);
  else
    return (NULL);
}

int c_get_attr_offset (o_object oid, char *attr_name)
{
  o_err err;
  int offset;
#ifdef versant_debug
  printf ("versant.c_get_attr_offset\n");
#endif

  err = o_getattroffsetbyname (oid, attr_name, (o_4b *)&offset);
  if (err == O_OK)
    return (offset);
  else
    return (-1);
}

int c_get_error ()
{
  return(o_errno);
}

o_bufdesc *c_make_buff_desc (int ptr, int size)
{
  o_bufdesc *bp;
#ifdef versant_debug
  printf ("versant.c_make_buff_desc \n");
#endif 
  bp = (o_bufdesc *)malloc (sizeof (o_bufdesc));
  bp->length = size;
  bp->data = (o_u1b *)ptr;
/*   printf ("C_make_buff: len=%d datap=%d  data=%d\n", size, ptr, *(char *)ptr); */
  return (bp);
}

void c_free_buff_desc (o_bufdesc *bp)
{
#ifdef versant_debug
  printf ("versant.c_free_buff_desc \n");
#endif

  if (bp != NULL)
    free (bp);
}

void c_build_buff_desc (o_bufdesc *bp, int ptr, int count)
{
  bp->length = count;
  bp->data = (o_u1b *)ptr;
}

o_vstr c_build_pred_block_vstr (o_vstr vp, o_predblock *pb)
{
  if (vp == 0)
    vp = o_newvstr (&vp, sizeof (o_predblock), (o_u1b *)pb);
  else
    vp = o_appendvstr (&vp, sizeof(o_predblock),(o_u1b *)pb);
  return (vp);
}

o_vstr c_build_whole_pred_vstr (o_vstr vp, o_predterm *pt)
{
  o_vstr lv;
  int i, count;
#ifdef versant_debug
  printf ("versant.c_build_whole_pred_vstr \n");
#endif

  if (vp==0) 
    {
      lv = o_newvstr (&lv, sizeof(o_predterm), (o_u1b *)pt);
      vp = lv;
    }
  else
    lv = o_appendvstr (&vp, sizeof(o_predterm),(o_u1b *)pt);
  
  return (lv);
}

o_vstr c_build_pred_vstr (o_vstr vp, o_predterm *pt)
{
  o_vstr lv;
  int i, count;
#ifdef versant_debug
  printf ("versant.c_build_pred_vstr \n");
#endif

  if (vp==0) 
    {
      lv = o_newvstr (&lv, sizeof(&pt), (o_u1b *)&pt);
      vp = lv;
    }
  else
    lv = o_appendvstr (&vp, sizeof(&pt),(o_u1b *)&pt);
  
  return (lv);
}


o_predterm *c_alloc_pred ()
{
  return ((o_predterm *)malloc(sizeof(o_predterm)));
}


void c_fill_pred_struct (o_predterm *pp,
			 o_attrname name,
			 o_bufdesc *bp,
			 o_opertype op,
			 o_typetype keytype) 
{
#ifdef versant_debug
  printf ("versant.c_fill_pred_struct \n");
#endif
  pp->attribute = name;
  pp->oper = op;
  pp->key = *bp;
  pp->keytype = keytype; 
  pp->flags = 0;
}

o_predterm *c_make_pred_struct (o_attrname name,
			      o_bufdesc *bp,
			      o_opertype op)
{
  o_predterm *pp;
#ifdef versant_debug
  printf ("versant.c_make_pred_struct \n");
#endif

  pp = (o_predterm *)malloc (sizeof(o_predterm));
  pp->attribute = name;
  pp->oper = op;
  pp->key = *bp;
/*
  printf ("Predicate address: %d \n", pp);
  printf ("Attr=%s operator=%d \n", pp->attribute, pp->oper);
  printf ("Desc size=%d data=%d *data=%d\n", pp->key.length, pp->key.data, *(int *)pp->key.data);
*/
  return (pp);
}

void c_free_pred_struct (o_predterm *pt)
{
#ifdef versant_debug
  printf ("versant.c_free_pred_struct \n");
#endif

  if (pt != NULL) 
    free (pt);
}

o_predblock *c_make_pred_block (o_conjtype operation, o_vstr more_blocks, o_vstr more_terms)
{
  o_predblock *pb;

  pb = (o_predblock *)malloc (sizeof (o_predblock));
  
  pb->conj = operation;
  pb->more_predblocks = more_blocks;
  pb->leaf_predterms = more_terms;
  pb->flags = 0;
  return (pb);
}

void c_free_pred_block (o_predblock *pb)
{
  /* Get rid of the vstrs */
  if (pb->more_predblocks != NULL)
    o_deletevstr (&pb->more_predblocks);
  if (pb->leaf_predterms != NULL)
    o_deletevstr (&pb->leaf_predterms);  
  /* and free the predicate block */
  free (pb);
}

void c_build_pred_struct (o_predterm *pt, 
			  o_attrname name,
			  o_bufdesc *bp,
			  o_opertype op)
{
  pt->attribute = name;
  pt->oper = op;
  pt->key = *bp;
}

int c_to_address (int ptr) 
{
  return(ptr);
}

void c_load_array (int arr [], o_vstr vp, int count)
{
  o_object *op;
  int i;

  op = (o_object *)vp;

  for (i=0;i<count;i++)
    {
      arr[i] = (int)*op;
      op++;
    };
}

void c_get_string (o_vstr vp, char *s, int cnt)
{
  char *cp;
  cp = (char *)vp;
  strncpy (s, cp, cnt);
  s[cnt] = '\0';
}

void c_split_loid (o_uid *l, int *db, int *hl, int *ll)
{
   *db = 0; *hl = 0; *ll = 0;
   *db = l->uid.dbID;
   *hl = l->uid.objID1;
   *ll = l->uid.objID2;
}

void c_glue_loid (o_uid *l, int db, int hl, int ll)
{
   l->uid.dbID = db;
   l->uid.objID1 = hl;
   l->uid.objID2 = ll;  
}


o_u1b c_get_byte_attr (o_object oid, o_attrname name)
{
  o_bufdesc desc;
  o_u1b byte;
  int stat;
#ifdef versant_debug
  printf ("versant.c_get_byte_attr \n");
#endif

  c_build_buff_desc (&desc, (int)&byte, 1);
  stat = o_getattr (oid, name, &desc);
  if (stat == 0) return (byte);
}

o_err c_set_byte_attr (o_object oid, o_attrname name, o_u1b byte)
{
  o_bufdesc desc;

  c_build_buff_desc (&desc, (int)&byte, 1);
  return ( o_setattr (oid, name, &desc));
}

o_err  c_add_attr (o_clsname class_name, o_dbname dbname,
		char *attr_name, char *attr_type, int rep,
		o_vstr auxp)
{
  o_attrdesc desc;
  char l_attr_type[100];
  char l_class_name[100];

  /* Change type to lower case */
  str_to_lower (class_name, l_class_name);
  str_to_lower (attr_type, l_attr_type);

  desc.name           = attr_name;
  desc.inherit.supcls = NULL;
  desc.inherit.name   = NULL;
  desc.domain         = l_attr_type;
  desc.repfactor      = rep;
  desc.initval        = NULL;
  desc.status         = 0;
  desc.auxinfo        = auxp;
  return (o_newattr (l_class_name, dbname, &desc));
}

o_err c_redefine_attr (o_clsname class_name,
		       o_dbname dbname,
		       char *attr_name,
		       char *attr_type,
		       int rep,
		       o_clsname parent,
		       o_attrname parent_attr)
{
  o_attrdesc desc;

/*  printf ("Class_nasme=%s Attr_name=%s type=%s \n", class_name, attr_name, attr_type);
  printf ("Rep=%d Parent=%s old_name=%s \n", rep, parent, parent_attr);
*/
  desc.name           = attr_name;
  desc.inherit.supcls = parent;
  desc.inherit.name   = parent_attr;
  desc.domain         = attr_type;
  desc.repfactor      = rep;
  desc.initval        = NULL;
  desc.status         = 0;
  desc.auxinfo        = NULL;
  printf ("Calling newattr \n");
  return (o_newattr (class_name, dbname, &desc));
}

o_err c_append_list (o_list list, o_object obj)
{
  o_item item;
  item = o_newitem (list, sizeof (o_object), (o_u1b *)&obj);
  return (o_errno);
}

o_vstr c_db_select (o_clsname class_name,
		 o_dbname db_name,
		 o_bool iflag,
		 o_lockmode lock,
		 o_vstr predicates)
{
  o_predterm *pt;
  o_bufdesc *bp;
  char *cp;
  int count, i, j ;
  o_vstr result;

#ifdef versant_debug
  printf ("Select class_name=%s  dbp=%d  lock=%d\n", class_name, db_name, lock);

  count = o_sizeofvstr (&predicates) / 4;
  for (i=0; i < count; i++)
    {
      pt = (o_predterm *) c_get_entry(predicates,i);
      printf ("Attr=%s Value size=%d Ops=%d\n", pt->attribute, pt->key.length, pt->oper);
      cp = pt->key.data;
      for (j =0; j < pt->key.length; j ++)
	{
	  printf ("%d ", *cp),
	  cp++;
	}
      printf ("\n end of buffer dump \n");
    }
#endif
  result = o_select (class_name, db_name, iflag, lock, predicates);
  return (result);
}


o_vstr c_pathselect (o_clsname class_name, o_dbname db_name, o_predblock *pb,
		     o_object vstr_object, o_attrname attr_name)
{
  o_vstr result = NULL;
  o_predterm *pt;
  o_bufdesc *bp;
  char *cp;
  int count, i, j ;


  if (class_name != NULL)
    /* Class query */
    result = o_pathselect (class_name, db_name, 0, NULL, O_SELECT_DEEP, 
			   NOLOCK, NOLOCK, pb, NULL, NULL);
  else
    /* VSTR query */
    result = o_pathselect (NULL, db_name, 0, NULL, (O_SELECT_DEEP || O_SELECT_WITH_VSTR), 
			   NOLOCK, NOLOCK, pb, vstr_object, attr_name);
#ifdef versant_debug
  printf ("Error after select=%d \n", o_errno);
#endif
  return (result);
}

o_object c_locateclass (o_clsname cls_name, o_dbname db)
{
  int i;
  char l_cls_name[100];
  int sl;

  /* Make sure class name is in lower case */
  str_to_lower (cls_name, l_cls_name);
  return (o_locateclass (l_cls_name, db));
}

o_err c_rename_class (o_clsname old_name, o_dbname db, o_clsname new_name)
{
  char l_old_name[100];
  char l_new_name[100];
  
  str_to_lower (old_name, l_old_name);
  str_to_lower (new_name, l_new_name);
  
  return (o_renameclass (l_old_name, db, l_new_name));
}

o_bool c_isdirty (o_object obj)
{
	return (O_OBJ_IS_DIRTY(obj));
}

o_bool c_ispinned (o_object obj)
{
	return (O_OBJ_IS_PINNED(obj));
}

o_bool c_iscached (o_object obj)
{
	return (O_OBJ_IS_CACHED(obj));
}

o_object c_codfromptr (o_ptr ptr)
{
	return (O_OBJ_TOP_TO_COD(ptr));
}

o_ptr c_ptrfromcod (o_object obj)
{
	return (O_OBJ_COD_TO_TOP(obj));
}

int nbpins (o_object obj)
{
	int pin_flags;
	
	pin_flags = ((o_u4b)((o_ptr**)O_OBJ_COD_TO_TOP(obj))[-1]) & 0xf000;
	return (pin_flags >> 12);
}

void c_subscribe_mods (o_object object, o_dbname dbname)
     /* Register this object for event notification when things change */
{
  o_err err;
  o_vstr objects;
  o_vstr events;
  o_u4b *arr;
  loid req_id;
  o_4b bad_index;

  objects = o_newvstr (&objects, sizeof (object), (o_u1b *)&object);
  events = o_newvstr (&events, 8, NULL);
  arr = (o_u4b*)events;
  arr[0] = O_EV_OBJ_MODIFIED;
  arr[1] = O_EV_OBJ_MODIFIED;

  err = o_defineevent (dbname, objects, events, NULL, 0, EV_EVAL_AT_COMMIT, 0, NULL, 
		       &req_id, &bad_index);
}

void c_unsubscribe_mods ()
{
}

void c_copy_full_object (o_ptr target, o_ptr src, o_object class_id)
{
	o_4b obj_size;

	obj_size = get_db_int_attr (class_id, "memlen");
	memcpy (target, src, obj_size);
}

void c_reset_object (o_ptr target, o_object class_id)
{
	o_4b obj_size;

	obj_size = get_db_int_attr (class_id, "memlen");
	memset (target, 0, obj_size);
}

void c_unmark_deleted (o_object to_unmark)
{
	*(o_u2b*)(to_unmark) &= ~0x80;
}


o_err c_repin_all_objects ()
	 /* Repin all objects mentioned in the COD */
{
  o_coditer iterator;
  o_err result;
  o_object current_object;
  int total, got_pinned, failed_pin;
  o_u1b* obj_ptr;

  result = o_resetcoditer (&iterator, O_COD_ITER_ALL);
  if (result == O_OK) 
	{
	  total = 0;
	  got_pinned = 0;
	  failed_pin = 0;
	  do
		{
		  current_object = o_nextcod (&iterator);
		  if (current_object != NULL) 
			{
			  total++;
			  if (!(O_OBJ_IS_PINNED (current_object) | (O_OBJ_IS_SCHEMA (current_object)))) 
				{
				  /* Pin if not already pinned and not a schema object */
				  obj_ptr = o_locateobj (current_object, NULL);
				  if (o_errno == O_OK)
					if (!(O_OBJ_IS_PINNED (current_object))) 
					  {
						printf ("Error: Object %d not pinned err=%d!!!!\n", current_object, o_errno);
						failed_pin++;
					  }
					else
					  got_pinned++;
				}
			}
		}
	  while (current_object != NULL);
	}
#ifdef versant_debug
  printf ("c_repin_all_objects: total=%d pinned=%d failed=%d \n", total, got_pinned, failed_pin);
#endif
  return (result);
}
