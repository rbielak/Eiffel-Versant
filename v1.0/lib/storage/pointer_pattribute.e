-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class POINTER_PATTRIBUTE

inherit
	
	PATTRIBUTE
		rename
			make as pattr_make,
			make_new as pattr_make_new
		end

	PATTRIBUTE
		redefine
			make, make_new
		select
			make, make_new
		end

creation
	
	make,
	make_new

feature

	make (new_name: STRING; new_type: STRING; new_rep: INTEGER; pid: INTEGER;
			new_field_offset: INTEGER; new_aux_info: STRING) is
		do
			pattr_make (new_name, new_type, new_rep, pid, new_field_offset, new_aux_info)
			type_is_basic := is_basic_type (type)
		end

feature {NONE}

	make_new (new_name: STRING; new_type: STRING; new_rep: INTEGER) is
		do
			pattr_make_new (new_name, new_type, new_rep)
			type_is_basic := is_basic_type (type)
		end

feature

	store_attr, store_shallow_attr (object: POBJECT; obj_ptr: POINTER) is
		local
			value: POINTER
		do
			value := extract_pointer (eiffel_offset, $object)
			set_db_ptr_o_ptr (obj_ptr, field_offset, value)
		end
	
	retrieve_attr (object: POBJECT; obj_ptr: POINTER) is
		do
			c_ptr_o_retr_ptr (obj_ptr, field_offset, eiffel_offset, object)
		end

	refresh_attr (object: POBJECT; deep: BOOLEAN; obj_ptr: POINTER) is
			-- Refresh the same as retrieve
		do
			retrieve_attr (object, obj_ptr)
		end

	is_different (object: POBJECT; obj_ptr: POINTER) : BOOLEAN is
		local
			j, total: INTEGER
			db_value, value: VSTR
		do
			-- Only Vstrs are stored as POINTERs so compare
			-- the contents of the vstr
--			!!db_value.make (get_db_ptr_o_ptr (obj_ptr, field_offset))
--			!!value.make (extract_pointer (eiffel_offset, $object))

--			Result := db_value.integer_count /= value.integer_count or else
--							not db_value.integer_is_equal (value)

			-- In order not to dispose the value from the Eiffel object !!
--			value.make (default_pointer)
--			db_value.dispose_area

			Result := c_is_vstr_different (obj_ptr, field_offset, 
										   extract_pointer (eiffel_offset, $object))
			debug ("diff_scanner")
				if Result then
					io.putstring (object.generator)
					io.putstring (":Field differs=")
					io.putstring (name)
					io.new_line
				end
			end
		end

	type_is_basic: BOOLEAN

	eiffel_type: INTEGER is
		do
			Result := Eiffel_pointer
		end

	value_to_string (object_id : INTEGER) : STRING is
		local
			p: POINTER
		do
			p := get_db_ptr_o_attr (object_id, field_offset);
			Result := p.out
		end

	value_from_id (object_id : INTEGER) : POINTER_REF is
		local
			p: POINTER
		do
			p := get_db_ptr_o_attr (object_id, field_offset);
			Result := p
		end

end -- POINTER_PATTRIBUTE
