-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
-- Never use this feature to handle normal Rainbow objects
-- It is usable only in cases where the basic entity we are
-- handling is the pobject_id and there is no Eiffel object involved

class LOW_LEVEL_DB_OPERATIONS

inherit

	VERSANT_EXTERNALS
 
	VERSANT_POINTER_EXTERNALS
 
	EIF_VERS_EXTERNALS
 
	DB_GLOBAL_INFO

	SHARED_ROOT_SERVER

	META_PCLASS_SERVER

	DB_INTERNAL

	DB_CONSTANTS

feature

	current_db: DATABASE is
		do
			Result := db_interface.current_database
		end

	get_pclass (object_id: INTEGER): PCLASS is
		do
			Result := db_interface.find_class_by_class_id (
					o_classobjof (object_id))
		end
 
	get_pattribute (object_id: INTEGER; attr_name: STRING): PATTRIBUTE is
		do
			Result := db_interface.find_class_by_class_id (
					o_classobjof (object_id)).attributes.item (attr_name)
		end

feature
	-- GET attribute by name.

	get_integer (object: INTEGER; attribute: STRING): INTEGER is
		do
			Result := get_db_int_o_attr (object,
					get_pattribute (object, attribute).field_offset)
		end
 
	get_double (object: INTEGER; attribute: STRING): DOUBLE is
		local
			double_value: DOUBLE
		do
			get_db_double_o_attr (object, 
					get_pattribute (object, attribute).field_offset, $double_value)
			Result := double_value
		end
 
	get_char (object: INTEGER; attribute: STRING): CHARACTER is
		do
			Result := get_db_char_o_attr (object,
					get_pattribute (object, attribute).field_offset)
		end
 
	get_bool (object: INTEGER; attribute: STRING): BOOLEAN is
		do
			Result := get_db_bool_o_attr (object,
					get_pattribute (object, attribute).field_offset)
		end
 
	get_reference (object: INTEGER; attribute: STRING): INTEGER is
		do
			Result := get_db_int_o_attr (object,
					get_pattribute (object, attribute).field_offset)
		end
 
	get_pointer (object: INTEGER; attribute: STRING): POINTER is
		do
			Result := get_db_ptr_o_attr (object,
					get_pattribute (object, attribute).field_offset)
		end
 
	get_string (object: INTEGER; attribute: STRING): STRING is
		do
			Result := get_db_string_o_attr (object,
					get_pattribute (object, attribute).field_offset)
		end
 
	get_area_vstr (plist: INTEGER; area_name: STRING): VSTR is
		local
			area: POINTER
		do
			area := get_pointer (plist, area_name)
			!!Result.make (area)
		end

	set_area_vstr (plist: INTEGER; area_name: STRING; vstr: VSTR) is
		do
			set_pointer (plist, area_name, vstr.area)
		end

feature
	-- MANS & SIMPLE QUERY

	get_root_info (root_name: STRING): INTEGER is
		require
			root_name_ok: root_name /= Void
		local
			active_databases: ACTIVE_DB_TABLE
			count, i: INTEGER
			db: DATABASE
			class_id: INTEGER
			pclass: META_PCLASS
			a_target: VSTR
			v_count, j: INTEGER
			item: INTEGER
			it_root_name: STRING
		do
			active_databases := db_interface.active_databases
			from
				count := active_databases.count
				i := 1
			until
				Result /= 0 or else i > count
			loop
				db := active_databases.i_th (i)
				class_id := db.find_class_id ("root_info")
				pclass := meta_pclass_by_pclass_id (class_id)
				db_interface.set_current_database (db)
				a_target := pclass.get_all_instances (True)
				from
					v_count := a_target.integer_count
					j := 1
				until
					Result /= 0 or else j > v_count
				loop
					item := a_target.i_th_integer (j)
					it_root_name := get_string (item, "root_name")
					if it_root_name.is_equal (root_name) then
						Result := item
					end
					j := j + 1
				end
				i := i + 1
			end
		end

	query_by_string_attribute (class_name: STRING; attr_name: STRING;
						to_seek_for: STRING): VSTR is
		local
			predicate: DB_STRING_PREDICATE
			a_query: DB_QUERY[POBJECT]
		do
			!!a_query.make (class_name)
			!!predicate.make (attr_name, to_seek_for)
			a_query.add_predicate (predicate)
			a_query.execute
			Result := a_query.last_result
		end

feature
	-- SET attribute by name.
	-- VERY DANGEROUS. DO NOT USE IF YOU ARE NOT A DB GURU !!!

	set_integer (object: INTEGER; attribute: STRING; value: INTEGER) is
		do
			set_db_int_o_attr (object,
					get_pattribute (object, attribute).field_offset, value)
		end
 
	set_double (object: INTEGER; attribute: STRING; value: DOUBLE) is
		do
			set_db_double_o_attr (object,
					get_pattribute (object, attribute).field_offset, value)
		end
 
	set_char (object: INTEGER; attribute: STRING; value: CHARACTER) is
		do
			set_db_char_o_attr (object,
					get_pattribute (object, attribute).field_offset, value)
		end
 
	set_bool (object: INTEGER; attribute: STRING; value: BOOLEAN) is
		do
			set_db_bool_o_attr (object,
					get_pattribute (object, attribute).field_offset, value)
		end
 
	set_reference (object: INTEGER; attribute: STRING; value: INTEGER) is
		do
			set_db_int_o_attr (object,
					get_pattribute (object, attribute).field_offset, value)
		end
 
	set_pointer (object: INTEGER; attribute: STRING; value: POINTER) is
		do
			set_db_ptr_o_attr (object,
					get_pattribute (object, attribute).field_offset, value)
		end
 
	set_string (object: INTEGER; attribute: STRING; value: STRING) is
		local
			pattribute: PATTRIBUTE
		do
			pattribute := get_pattribute (object, attribute)
			if value = Void then
				set_db_int_o_attr (object,
					get_pattribute (object, attribute).field_offset, 0)
			else
				set_db_vstring_o_attr (object,
					get_pattribute (object, attribute).field_offset, $(value.to_c))
			end
		end

feature
	-- STILL VERY DANGEROUS TO USE: FOR DB GURU ONLY

	create_an_object (new_class_name: STRING): INTEGER is
		local
			new_pclass: META_PCLASS
			class_id: INTEGER
		do
			class_id := current_db.find_class_id (new_class_name)
			new_pclass := meta_pclass_by_pclass_id (class_id)
			Result := new_pclass.create_instance
		end

	create_and_copy_full_object (from_object_id: INTEGER;
					new_class_name: STRING): INTEGER is
		do
			Result := create_an_object (new_class_name)
			copy_full_object (from_object_id, Result, True)
		end

	create_and_copy_object (from_object_id: INTEGER; new_class_name: STRING;
					from_attributes, to_attributes: ARRAY[STRING]): INTEGER is
		do
			Result := create_an_object (new_class_name)
			copy_object (from_object_id, Result, from_attributes, to_attributes)
		end

	copy_full_object (from_object_id, to_object_id: INTEGER; warn: BOOLEAN) is
		local
			pclass_id: INTEGER
			from_pclass, to_pclass: PCLASS
			i, j: INTEGER
			attr_names: ARRAY [STRING]
		do
			pclass_id := o_classobjof (from_object_id)
			from_pclass := db_interface.find_class_by_class_id (pclass_id)
			pclass_id := o_classobjof (to_object_id)
			to_pclass := db_interface.find_class_by_class_id (pclass_id)

			from
				i := 1
				!!attr_names.make (1, 0)
			until
				i > from_pclass.attributes_array.count
			loop
				if to_pclass.attributes.has (
							from_pclass.attributes_array.item (i).name) then
					j := j+1
					attr_names.force (
							from_pclass.attributes_array.item (i).name, j)
				elseif warn then
					io.putstring ("Warning (copy_full_object): ")
					io.putstring (to_pclass.name)
					io.putstring (" does not contain ")
					io.putstring (from_pclass.attributes_array.item (i).name)
					io.new_line
				end
				i := i+1
			end

			if warn then
				from
					i := 1
				until
					i > to_pclass.attributes_array.count
				loop
					if not from_pclass.attributes.has (
							to_pclass.attributes_array.item (i).name) then
						io.putstring ("Warning (copy_full_object): ")
						io.putstring (from_pclass.name)
						io.putstring (" does not contain ")
						io.putstring (to_pclass.attributes_array.item (i).name)
						io.new_line
					end
					i := i + 1
				end
			end

			copy_object (from_object_id, to_object_id, attr_names, attr_names)
		end

	copy_object (from_object_id, to_object_id: INTEGER;
					from_attributes, to_attributes: ARRAY[STRING]) is
		require
			same_array_size: from_attributes.count = to_attributes.count
		local
			pclass_id: INTEGER
			from_pclass, to_pclass: PCLASS
			attr_int_id: INTEGER
			attr_ptr: POINTER
			bool_value: BOOLEAN
			char_value: CHARACTER
			double_value: DOUBLE
			str_value: STRING
			from_pattr, to_pattr: PATTRIBUTE
			i, j, count, total: INTEGER
			vstr: VSTR
		do
			pclass_id := o_classobjof (from_object_id)
			from_pclass := db_interface.find_class_by_class_id (pclass_id)
			pclass_id := o_classobjof (to_object_id)
			to_pclass := db_interface.find_class_by_class_id (pclass_id)
			from
				i := 1
				count := from_attributes.count
			until
				i > count
			loop
				from_pattr := from_pclass.attributes.item (from_attributes.item (i))
				to_pattr := to_pclass.attributes.item (to_attributes.item (i))
				inspect from_pattr.eiffel_type_code
				when Eiffel_string then
					str_value := get_db_string_o_attr (
								from_object_id, from_pattr.field_offset)
					if str_value = Void then
						set_db_int_o_attr (to_object_id, to_pattr.field_offset, 0)
					else
						set_db_vstring_o_attr (to_object_id, to_pattr.field_offset,
								$(str_value.to_c))
					end
				when Eiffel_char then
					char_value := get_db_char_o_attr (
								from_object_id, from_pattr.field_offset)
					set_db_char_o_attr (to_object_id,
								to_pattr.field_offset, char_value)
				when Eiffel_boolean then
					bool_value := get_db_bool_o_attr (from_object_id,
								from_pattr.field_offset)
					set_db_bool_o_attr (to_object_id, to_pattr.field_offset,
								bool_value)
				when Eiffel_double then
					get_db_double_o_attr (from_object_id,
								from_pattr.field_offset, $double_value)
					set_db_double_o_attr (to_object_id, to_pattr.field_offset,
								double_value)
				when Eiffel_integer then
					attr_int_id := get_db_int_o_attr
								(from_object_id, from_pattr.field_offset)
					set_db_int_o_attr (to_object_id,
								to_pattr.field_offset, attr_int_id)
				when Eiffel_object then
					attr_int_id := get_db_int_o_attr
								(from_object_id, from_pattr.field_offset)
					set_db_int_o_attr (to_object_id, to_pattr.field_offset,
								attr_int_id)
				when Eiffel_pointer then
					attr_ptr := get_db_ptr_o_attr
								(from_object_id, from_pattr.field_offset)
					set_db_ptr_o_attr (to_object_id, to_pattr.field_offset, attr_ptr)
				end
				i := i + 1
			end
		end

end
