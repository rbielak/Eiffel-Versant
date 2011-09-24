-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Extract value of an attribute specfied by a path (eg.  "foo.bar.junk")
--
deferred class ATTR_VALUE

inherit

	DB_GLOBAL_INFO
	DB_CONSTANTS
	VERSANT_EXTERNALS
	EIFFEL_EXTERNALS

feature
	
	standard_extraction: BOOLEAN is
			-- If False, only the DB persistent object will be considered,
			-- not the Eiffel object. This is useful when we do a tuple
			-- extraction and the extractor type is forced (eg: one wants to
			-- return an object_id, not the Eiffel object, using OBJECT_ID_EXTRACTOR)
		do
			Result := True
		end

	value_of_attr (object_id : INTEGER; path : ATTR_PATH) : ANY is
		require
			id_ok : object_id /= 0;
			path_ok: path /= Void;
		local
			current_object_id : INTEGER;
			i : INTEGER;
			object: POBJECT
		do
			current_object_id := object_id
			object := db_interface.object_table.item (current_object_id)
			if object /= Void and standard_extraction then
				-- Object is in memory
				Result := value_of_attr_from_object (object, path)
			else
				from
					i := 1
				until
					(i > path.count) or (current_object_id = 0)
				loop
					if i = path.count then
						-- Got to the last one, extract the value
						Result := extract_db_value (current_object_id, path.i_th (i));
					else
						current_object_id := get_db_int_attr (current_object_id, 
															  $(path.i_th (i).to_c));
					end
					i := i + 1
				end
			end
		end
	
	value_of_attr_from_object (object: POBJECT; path: ATTR_PATH): ANY is
		require
			object_there: object /= Void
		local
			current_object: POBJECT
			current_pclass: PCLASS
			pattribute: PATTRIBUTE
			i: INTEGER
		do
			from
				i := 1
				current_object := object
			until 
				(i > path.count) or (current_object = Void)
			loop
				current_pclass := current_object.pobject_class
				if current_pclass = Void then
					-- This code assumes that the schema is the same
					-- in all databases
					current_pclass := db_interface.find_class (
						db_interface.view_table.versant_class (current_object.generator))
					if not current_pclass.initialized then
						current_pclass.init_offsets (object)
					end
				end
				pattribute := current_pclass.attributes.item (path.i_th (i))
				
				if i = path.count then
					inspect pattribute.eiffel_type_code
					when Eiffel_boolean then
						Result := extract_boolean (pattribute.eiffel_offset, $current_object)
					when Eiffel_char then
						Result := extract_character (pattribute.eiffel_offset, $current_object)
					when Eiffel_double then
						Result := extract_double (pattribute.eiffel_offset, $current_object)
					when Eiffel_integer then
						Result := extract_integer (pattribute.eiffel_offset, $current_object)
					when Eiffel_string then
						Result := extract_string (pattribute.eiffel_offset, $current_object)
					when Eiffel_object, Eiffel_object_key then
						Result := extract_reference (pattribute.eiffel_offset, $current_object)
					end
				else
					-- Follow the path
					current_object := extract_reference (pattribute.eiffel_offset, $current_object)
				end
				i := i + 1
			end

		end

feature {NONE}
	
	
	extract_db_value (object_id : INTEGER; attr_name : STRING) : ANY is
			-- This code is type specific
		deferred
		end;

end -- ATTR_VALUE
