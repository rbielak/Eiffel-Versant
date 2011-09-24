-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class OBJECT_PATTRIBUTE

inherit
	
	PATTRIBUTE

creation
	
	make,
	make_new

feature

	versant_class_query: VERSANT_CLASS_SELECT_QUERY is
		once
			!!Result.make ("attrid = $1")
			Result.set_class_name ("attribute")
		end

	change_type (new_type: STRING) is
		require
			new_type_valid: new_type /= Void
		local
			err, new_domain_id, domain_offset: INTEGER
			obj_ptr: POINTER
			vstr: VSTR
			attrib: INTEGER
			i, vstr_count: INTEGER
			tmp_pobject: VERSANT_QUERY_POBJECT
		do
			-- Query all attributes in DB for which attrid = pobject_id and perform
			-- the operation for all of them
			versant_class_query.set_database (db_interface.current_database) 
			!!tmp_pobject.make (pobject_id)
			versant_class_query.execute (<<tmp_pobject>>)
			vstr := versant_class_query.last_result

			type := new_type.twin
			new_domain_id := db_interface.find_class (new_type).pobject_id

			from
				i := 1
				vstr_count := vstr.integer_count
			until
				i > vstr_count
			loop
				attrib := vstr.i_th_integer (i)
				obj_ptr := o_locateobj (attrib, 0)
				check_error
				set_db_int_o_ptr (obj_ptr, 12, new_domain_id)
				err := o_unpinobj (attrib, 1)
				check_error
				i := i + 1
			end
		end

	store_attr (object: POBJECT; obj_ptr: POINTER) is
		local
			pobj: POBJECT
		do
			pobj := extract_reference (eiffel_offset, $object)
			if pobj = Void then
				-- Field is void, requires
				-- special handlings
				set_db_int_o_ptr (obj_ptr, field_offset, 0)
			else
				-- Set the attribute to the pobject_id of the object
				-- we're pointing to, but make sure it's stored first
				pobj.store_obj (db_interface.operation_context_stack.item)
				debug
					io.putstring ("Storing attribute: ")
					io.putstring (name)
					io.putstring ("  Poid=")
					io.putint (pobj.pobject_id)
					io.putstring (" offset=  ")
					io.putint (field_offset); io.new_line
				end
				set_db_int_o_ptr (obj_ptr, field_offset, pobj.pobject_id)
			end
		end

	store_shallow_attr (object: POBJECT; obj_ptr: POINTER) is
			-- Store a reference field of an object
			-- but do not follow the reference to do other stores
		local
			pobj: POBJECT
		do
			pobj := extract_reference (eiffel_offset, $object)
			if pobj = Void then
				set_db_int_o_ptr (obj_ptr, field_offset, 0)
			else
				-- Set the attribute to the pobject_id of the object
				debug
					io.putstring ("Storing attribute: ");
					io.putstring (name)
					io.putstring ("  Poid=")
					io.putint (pobj.pobject_id)
					io.putstring (" offset=  ")
					io.putint (field_offset)
					io.new_line
				end
				if pobj.pobject_id /= 0 then
					set_db_int_o_ptr (obj_ptr, field_offset, pobj.pobject_id)
				end
			end
		end

	retrieve_attr (object: POBJECT; obj_ptr: POINTER) is
		local
			object_id : INTEGER;
			pobj : POBJECT
		do
			object_id := get_db_int_o_ptr (obj_ptr, field_offset)
			if object_id /= 0 then
				pobj := db_interface.create_eiffel_object (object_id)
			end
			set_nth (eiffel_offset, $object, $pobj)
		end

	refresh_attr (object: POBJECT; deep: BOOLEAN; obj_ptr: POINTER) is
		local
			object_id : INTEGER
			pobj : POBJECT
		do
			object_id := get_db_int_o_ptr (obj_ptr, field_offset)
			if object_id /= 0 then
				-- see if we alredy have this object
				pobj := db_interface.object_table.item (object_id)
				if pobj = Void then
					-- We don't have it yet, so retrieve it
					pobj := db_interface.rebuild_eiffel_object (object_id)
				else
					if deep then
						pobj.refresh_obj (db_interface.operation_context_stack.item)
					end
				end
				check_error
			end
			set_nth (eiffel_offset, $object, $pobj)
		end

	value (object: POBJECT) : POBJECT is
			-- value of the attribute as an POBJECT
		do
			Result := extract_reference (eiffel_offset, $object);
		end

	is_different (object : POBJECT; obj_ptr: POINTER) : BOOLEAN is
		local
			db_value: INTEGER
			obj : POBJECT
		do
			obj := extract_reference (eiffel_offset, $object)
			db_value := get_db_int_o_ptr (obj_ptr, field_offset)
			if obj /= Void then
				-- We are different if object IDs different, or if
				-- the in memory object hasn't been stored yet
				Result := (db_value /= obj.pobject_id) or (obj.pobject_id = 0)
			else
				Result := db_value /= 0
			end	
			debug ("diff_scanner")
				if Result then
					io.putstring (object.generator)
					io.putstring (":Field differs=")
					io.putstring (name)
					io.new_line
				end
			end
		end

	type_is_basic: BOOLEAN is 
			-- It's a routine, so we can redefine it
		do
			Result := False
		end
	
	eiffel_type: INTEGER is
		do
			Result := Eiffel_object
		end

	value_to_string (object_id : INTEGER) : STRING is
		local
			s: STRING
			attr_value: INTEGER
		do
			attr_value := get_db_int_o_attr (object_id, field_offset)
			s := c_get_loid (attr_value)
			s.append(" (")
			if attr_value /= 0 then
				s.append((db_interface.find_class_for_object (attr_value)).name)
			else
				s.append("Void")
			end
			s.append(")")
			Result := s;
		end

	value_from_id (object_id: INTEGER): POBJECT is
		local
			lattr_id: INTEGER
		do
			lattr_id := get_db_int_o_attr (object_id, field_offset)
			if lattr_id /= 0 then
				Result := db_interface.create_eiffel_object (lattr_id)
			end
		end

end -- OBJECT_PATTRIBUTE
