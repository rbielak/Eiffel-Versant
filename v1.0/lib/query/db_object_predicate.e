-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing
	description: "predicate for object fields";
	database: "Versant"

class DB_OBJECT_PREDICATE

inherit

	DB_QUERY_PREDICATE [POBJECT]
		redefine
			value_conforms,
			is_true
		end

creation
 
	make, make_empty, make_with_feature_access
 
feature
 
	make (attribute: STRING; new_value : POBJECT) is
		require
			name_ok: attribute /= Void
		local
			feat_access: FEATURE_ACCESS
		do
			!!feat_access.make_simple_attribute (attribute)
			make_with_feature_access (feat_access, new_value)
		end
  
	make_with_feature_access (lattribute_access: FEATURE_ACCESS;
				new_value : POBJECT) is
		require
			attribute_ok: lattribute_access /= Void
		do
			set_attribute_access (lattribute_access)
			value := new_value
			operation := db_equal
		end

feature
	
	value_conforms (new_value: POBJECT): BOOLEAN is
		local
			pobj: POBJECT
		do
			if new_value /= Void then
				pobj ?= new_value
				Result := pobj /= Void
			else
				Result := True
			end
		end
	
	is_true (pobject_id: INTEGER): BOOLEAN is
			-- See if Current predicate is true for this object ID.
			-- This routine is an optimized version of the general
			-- "is_true". It does NOT retrieve the Eiffel object
			-- to see if the prodicate holds.
		local
			area_vstr: VSTR
			other_object_id, plist_object_id: INTEGER
			void_in_path: BOOLEAN
		do
			if (attribute_access.next /= Void) then
				-- Path attribute
				other_object_id := attribute_access.get_db_id (pobject_id)
				if other_object_id /= 0 then
					other_object_id := get_db_int_attr (other_object_id, $(last_name.to_c))
				else
					void_in_path := True
				end
			else
				-- no paths or weak links
				other_object_id := get_db_int_attr (pobject_id, $(last_name.to_c))
			end
			if other_object_id /= 0 then
				if last_subscript /= -1 then
					plist_object_id := other_object_id
					!!area_vstr.make (get_db_ptr_attr (plist_object_id, $(area_str.to_c)))
					if area_vstr.exists then
						other_object_id := area_vstr.i_th_integer (last_subscript + 1)
					else
						other_object_id := 0
					end
					area_vstr := Void
				end
			end
			if void_in_path then
				Result := False
			else
				if value /= Void then
					Result := test_pobject_ids (value.pobject_id, other_object_id)
				else
					Result := test_pobject_ids (0, other_object_id)
				end
			end
		end

feature {NONE}
	
	value_size: INTEGER is 4
			 -- pobject_ids are integers
	
	value_address: POINTER is
		require else
			True
		do
			if value /= Void then
				value_pobject_id := value.pobject_id
			else
				value_pobject_id := 0
			end;
			Result := c_to_address ($value_pobject_id)
		end

	value_pobject_id: INTEGER
	
	key_type : INTEGER is
		once
			Result := db_key_type_object
		end

	make_empty is
		do
		end

	extract_i_th_vstr_value (vstr: VSTR; index: INTEGER): POBJECT is
			-- Extract i-th entry of a vstr
		local
			local_object_id: INTEGER
		do
			local_object_id := vstr.i_th_integer (index + 1)
			if local_object_id /= 0 then
				Result := db_interface.rebuild_eiffel_object (local_object_id)
			end
			check_error
		end

	extract_db_value (pobject_id : INTEGER; l_attr_name : STRING) : POBJECT is
			-- Extract the actual value of approriate type
			-- from the database
		local
			local_object_id: INTEGER
		do
			local_object_id := get_db_int_attr (pobject_id, $(l_attr_name.to_c))
			if local_object_id /= 0 then
				Result := db_interface.rebuild_eiffel_object (local_object_id)
			end
			check_error
		end
	
	test_pobject_ids (pobject_id, other_pobject_id: INTEGER) : BOOLEAN is
		local
			area: VSTR
		do
			inspect operation
			when db_equal then
				Result := pobject_id = other_pobject_id
			when db_not_equal then
				Result := pobject_id /= other_pobject_id
			when db_in_list then
				-- second object is a list
				!!area.make (get_db_ptr_attr (other_pobject_id, $(area_str.to_c)))
				if not area.exists then
					!!area.make (get_db_ptr_attr (other_pobject_id, $(db_area_str.to_c)))
				end
				if area.exists then
					Result := area.has_integer (pobject_id)
				else
					except.raise ("Cannot find area%N")
				end
			else
				except.raise ("Can't compare pobjects like this")
			end
		end

	test_values (db_value, pred_value: POBJECT): BOOLEAN is
		local
			db_list: PLIST[POBJECT]
			db_array: ARRAY[POBJECT]
		do
			inspect operation
			when db_equal then
				if (pred_value /= Void) and (db_value /= Void) then
					Result := pred_value.pobject_id = db_value.pobject_id
				else
					-- True if both are Void
					Result := pred_value = db_value
				end
			when db_not_equal then
				if (pred_value /= Void) and (db_value /= Void) then
					Result := pred_value.pobject_id /= db_value.pobject_id
				else
					Result := pred_value /= db_value
				end
			when db_in_list then
				db_list ?= db_value
				db_array ?= db_value
				if (pred_value /= Void) and (db_list /= Void) then
					Result := db_list.has (value)
				elseif (pred_value /= Void) and (db_array /= Void) then
					Result := db_array.has (value)
				else
					except.raise ("Cannot evaluate in%N")
				end
			else
				except.raise ("Can't compare pobjects like this")
			end
		end

end -- DB_OBJECT_PREDICATE
