-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VERSANT_EXTERNALS

inherit

	VSTR_EXTERNALS -- This is a temporary fix.

feature {POBJECT, PERSISTENCY_ROOT, PERSISTENT_ROOTS, SELECT_QUERY, DB_GLOBAL_INFO}

	get_db_int_attr (oid : INTEGER; attr_name : POINTER) : INTEGER is
		external "C"
		end;
	
	get_db_ptr_attr (oid : INTEGER; attr_name : POINTER) : POINTER is
		external "C"
		end;

	get_db_ptr_o_attr (oid : INTEGER; offset : INTEGER) : POINTER is
		external "C"
		end;

	get_db_char_attr (oid : INTEGER; attr_name : POINTER) : CHARACTER is
		external "C"
		end;
	
	get_db_char_o_attr (oid : INTEGER; offset : INTEGER) : CHARACTER is
		external "C"
		end;

	get_db_bool_o_attr (oid : INTEGER; offset : INTEGER) : BOOLEAN is
		external "C"
		alias "get_db_char_o_attr"
		end;

	get_db_bool_attr (oid : INTEGER; attr_name : POINTER) : BOOLEAN is
		external "C"
		end;
	
	get_db_int_o_attr (oid : INTEGER; offset : INTEGER) : INTEGER is
		external "C"
		end;

	get_db_double_o_attr (oid : INTEGER; offset : INTEGER; value : POINTER) is
		external "C"
		end;

	get_db_double_attr (oid : INTEGER; attr_name: POINTER ; value : POINTER) is
		external "C"
		end;

	set_db_int_attr (oid : INTEGER; attr_name : POINTER; value : INTEGER) is
		external "C"
		end;

	set_db_bool_attr (oid : INTEGER; attr_name : POINTER; value : BOOLEAN) is
		external "C"
		end;

	set_db_ptr_attr (oid : INTEGER; attr_name : POINTER; value : POINTER) is
		external "C (EIF_INTEGER, EIF_POINTER, EIF_INTEGER)"
		alias "set_db_int_attr"
		end;

	set_db_vstr_attr (oid : INTEGER; attr_name : POINTER; value : POINTER) is
		external "C (EIF_INTEGER, EIF_POINTER, EIF_INTEGER)"
		alias "set_db_int_attr"
		end;

	set_db_int_o_attr (oid : INTEGER; attr_offset : INTEGER; value : INTEGER) is
		external "C"
		end;
	
	set_db_ptr_o_attr (oid : INTEGER; attr_offset : INTEGER; value : POINTER) is
		external "C"
		alias "set_db_int_o_attr"
		end;

	get_db_string_attr (oid : INTEGER; attr_name : POINTER) : STRING is
		external "C"
		end;
	
	get_db_string_o_attr (oid : INTEGER; offset : INTEGER) : STRING is
		external "C"
		end;
	
	set_db_vstring_attr (oid : INTEGER; attr_name : POINTER; value : POINTER) is
		external "C"
		end;
	
	set_db_vstring_o_attr (oid : INTEGER; offset : INTEGER; value : POINTER) is
		external "C"
		end;

	set_db_double_attr (oid : INTEGER; attr_name : POINTER; value : ANY) is
		external "C"
		end;
	
	set_db_double_o_attr (oid : INTEGER; offset : INTEGER; value : ANY) is
		external "C"
		end;

	set_db_bool_o_attr (oid : INTEGER; offset : INTEGER; value : BOOLEAN) is
		external "C"
		end;
	
	set_db_char_o_attr (oid : INTEGER; offset : INTEGER; value : CHARACTER) is
		external "C"
		end;

	c_begin_session (long_tran_name : POINTER; 
			db_name : POINTER; 
			sess_name : POINTER) : INTEGER is
		external "C"
		end;
	
	c_get_attr_offset (oid : INTEGER; attr_name : POINTER) : INTEGER is
		external "C"
		end;
			
	o_endsession (sess_name : POINTER;
				options : POINTER) : INTEGER is
		external  "C"
		end;

	c_commit : INTEGER is
		external  "C"
		end;
	
	c_abort : INTEGER is
		external "C"
		end;
	
	c_get_error : INTEGER is
		external "C"
		end;
	
	c_scan_loid (loid : POINTER) : INTEGER is
		external "C"
		end;
	
	o_migrateobj (oid : INTEGER; from_db, to_db : POINTER) : INTEGER is
		external "C"
		end
	
	o_migrateobjs (oid_vstr : POINTER; from_db, to_db : POINTER; not_moved: POINTER) : INTEGER is
		external "C"
		end
	
	o_unpinobj (oid : INTEGER; modified:INTEGER) : INTEGER is
		external "C"
		end;
	
	o_locateobj (oid : INTEGER; lock__code : INTEGER) : POINTER is
		external "C"
		end;
	
	c_locateclass (class_name : POINTER; db_name : POINTER) : INTEGER is
		external "C"
		end;

	c_get_class_name (oid : INTEGER) : STRING is
		external "C"
		end;

	c_get_db_class_attrs (oid : INTEGER) : POINTER is
		external "C"
		end;
	
	c_to_address (item : POINTER) : POINTER is
		external "C"
		end;
	
	c_build_buff_desc (desc : POINTER; val_ptr : POINTER; size : INTEGER) is
		external "C"
		end;
	
	c_build_pred_struct (struct : POINTER; attr_name : POINTER; val_desc : POINTER; 
				  op : INTEGER; key_type: INTEGER) is
		external "C"
		end;

	c_build_pred_vstr (vstr : POINTER; pred_p : POINTER) : POINTER is
		external "C"
		end;
	
	c_build_whole_pred_vstr (vstr : POINTER; pred_p : POINTER) : POINTER is
		external "C"
		end;

	
	c_build_pred_block_vstr (vstr : POINTER; pred_block_p : POINTER) : POINTER is
		external "C"
		end;

	c_make_buff_desc (vp : POINTER; vs : INTEGER) : POINTER is
		external "C"
		end;
	
	c_free_buff_desc (p : POINTER) is
		external "C"
		end;
	
	c_free_pred_struct (ptr : POINTER) is
		external "C"
		end;

	c_free_pred_block (pb: POINTER) is
		external "C"
		end

	c_make_pred_struct (name : POINTER; desc : POINTER; op : INTEGER) : POINTER is
		external "C"
		end;
	
	c_make_pred_block (op: INTEGER; more_blocks, more_terms : POINTER) : POINTER is
		external "C"
		end

	c_add_attr (cls, db, at_name, tp_name : POINTER; rep : INTEGER; aux_info: POINTER): INTEGER is
		external "C"
		end;
	
	c_redefine_attr (p1, p2, p3, p4 : POINTER; i1 : INTEGER; p5, p6 : POINTER) : INTEGER is
		external "C"
		end;
	
	c_append_list (list_id, obj_id : INTEGER) : INTEGER is
		external "C"
		end;
	
	c_alloc_pred : POINTER is
		external "C"
		end;
	
	c_fill_pred_struct (predp : POINTER; 
				 attr_name : POINTER; 
				 buffp : POINTER; 
				 op : INTEGER;
				 key_type: INTEGER) is
		external "C"
		end;

	o_defineclass (cls_name, db_name : POINTER; attr_vstrp, parent_vstrp : POINTER;
			methods_vstrp : INTEGER) : INTEGER is
		external "C"
		end;

	o_makeobj (class_id : INTEGER; init_values : POINTER; topin : BOOLEAN) : INTEGER is
		external "C"
		end;
	
	o_createobj (class_name : POINTER; init_values : POINTER; topin : BOOLEAN) : INTEGER is
		external "C"
		end;
	
	o_dropattr (class_name : POINTER; db_name : POINTER; attr_name : POINTER) : INTEGER is
		external "C"
		end;
	
	o_dropclass (class_name : POINTER; db_name : POINTER) : INTEGER is
		external "C"
		end;

	o_newlist : INTEGER is
		external "C"
		end;
			
	o_listlength (list_id : INTEGER) : INTEGER is
		external "C"
		end;

	c_db_select (cls_name : POINTER; db_name : POINTER; iflag : BOOLEAN; 
		  lock_code : INTEGER; pred : POINTER) : POINTER is
		external "C"
		end;
	
	c_pathselect (cls_name: POINTER; db_name: POINTER; predicate_block: POINTER;
				vstr_object: INTEGER; vstr_attr_name: POINTER) : POINTER is
		external "C"
		end

	o_setdefaultlock (lock_code : INTEGER) is
		external "C"
		end;
	
	o_shallowrenameattr (cls, db, oldname, newname : POINTER) : INTEGER is
		external "C"
		end;

	o_greadobjs (vstr : POINTER; dbname : POINTER; topin : BOOLEAN; lock_code : INTEGER) : INTEGER is
		external "C"
		end;
	
	o_refreshobj (oid : INTEGER; lock_code : INTEGER; changed : POINTER) is
		external "C"
		end;
	
	o_acquireslock (obj : INTEGER; lock_code : INTEGER) : INTEGER is
		external "C"
		end;
	
	o_downgradelock (obj : INTEGER; lock_code : INTEGER) : INTEGER is
		external "C"
		end;
	
	o_connectdb (db_name : POINTER; lock_mode : INTEGER) : INTEGER is
		external "C"
		end;
	
	o_disconnectdb (db_name : POINTER) : INTEGER is
		external "C"
		end;
	
	o_classobjof (oid : INTEGER) : INTEGER is
		external "C"
		end

	o_releaseobj (oid: INTEGER): INTEGER is
		external "C"
		end

	o_releaseobjs (objs_vstr: POINTER; options: INTEGER): INTEGER is
		external "C"
		end

	o_getclosure (objs_vstr : POINTER; db_name : POINTER; levels : INTEGER; 
				reserved : INTEGER; to_pin : BOOLEAN; lockmode : INTEGER) : POINTER is
		external "C"
		end

	o_deleteobj (object_id: INTEGER): INTEGER is
		external "C"
		end
	
	o_geterrormessage (errnum: INTEGER; buff: POINTER; buff_size:INTEGER) : INTEGER is
		external "C"
		end
	
	c_check_read (rights : INTEGER) : BOOLEAN is
		external "C"
		end
	
	c_check_write (rights : INTEGER) : BOOLEAN is
		external "C"
		end
	
	c_check_add (rights : INTEGER) : BOOLEAN is
		external "C"
		end
	
	c_check_delete (rights : INTEGER) : BOOLEAN is
		external "C"
		end
	
	c_check_display (rights : INTEGER) : BOOLEAN is
		external "C"
		end

	c_or_stamps (s1, s2 : INTEGER) : INTEGER is
		external "C"
		end
	
	c_and_stamps (s1, s2 : INTEGER) : INTEGER is
		external "C"
		end
	
	c_get_db_id (db_name : POINTER) : INTEGER is
		external "C"
		end
	
	c_get_db_owner (db_name: POINTER): STRING is
		external "C"
		end
	
	o_getcacheused (usedkb: POINTER) : INTEGER is
		external "C"
		end
	
	o_zapcods (count: INTEGER; objects: POINTER) : INTEGER is
		external "C"
		end

	o_setdirty (obj: INTEGER) is
		external "C"
		end

	c_codfromptr (ptr: POINTER): INTEGER is
		external "C"
		end
 
	c_ptrfromcod (cod: INTEGER): POINTER is
		external "C"
		end
	
	is_pinned (cod: INTEGER): BOOLEAN is
		external "C"
		alias "c_ispinned"
		end

	is_dirty (cod: INTEGER): BOOLEAN is
		external "C"
		alias "c_isdirty"
		end

	nbpins (cod: INTEGER): INTEGER is
		external "C"
		end
	
	c_repin_all_objects: INTEGER is
		external "C"
		end
	
	is_cached (pid: INTEGER): BOOLEAN is
		external "C"
		alias "c_iscached"
		end

	subscribe_mods (object_id: INTEGER; dbname: POINTER) is
		external "C"
		alias "c_subscribe_mods"
		end
	
	is_session_active: BOOLEAN is
		external "C"
		alias "c_is_session_active"
		end
	
	send_event_to_daemon (db_name: POINTER; event: INTEGER; 
						  definer_len: INTEGER; define_info: POINTER;
						  raiser_len: INTEGER; raiser_info: POINTER): INTEGER is
		external "C"
		alias "o_sendeventtodaemon"
		end


	c_set_was_modified (objp: POINTER) is
		external "C"
		end

	c_was_modified (objp: POINTER): BOOLEAN is
		external "C"
		end

	c_set_peif_id_and_clear_wm (objp: POINTER; eif_id: INTEGER) is
			-- set the eif_id and clear the was modified flag
		external "C"
		end

	c_get_peif_id (objp: POINTER): INTEGER is
		external "C"
		end
	
	o_isinstanceof (object_id: INTEGER; clname: POINTER;
			test_inheritance: BOOLEAN): BOOLEAN is
		external "C"
		end

	c_is_string_different (object_ptr: POINTER; offset: INTEGER;
						   str: POINTER; size: INTEGER): BOOLEAN is
		external "C"
		end

	c_is_vstr_different (object_ptr: POINTER; offset: INTEGER;
						 vstr: POINTER): BOOLEAN is
		external "C"
		end


end -- VERSANT_EXTERNALS
