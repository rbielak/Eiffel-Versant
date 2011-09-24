-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--
indexing

	description: "Predicate for db queries";
	database: "Versant"

deferred class DB_QUERY_PREDICATE [T]

inherit 

	DB_CONSTANTS
	DB_GLOBAL_INFO
	VERSANT_EXTERNALS
	MEMORY
		redefine
			dispose
		end

feature


	attribute_access: FEATURE_ACCESS
			-- Structure describing the attribute to consider

	last_name: STRING

	path_name: STRING
			-- the entire name of this attribute: like "name.foo.bar"

	last_subscript: INTEGER

	set_attribute_access (lattribute_access: FEATURE_ACCESS) is

		do
			attribute_access := lattribute_access
			reset_path_name
		end -- set_attribute_access
	
	reset_path_name is 
		local
			current_fa: FEATURE_ACCESS			
		do
			last_name := attribute_access.get_last_name
			-- Make the attribute name.Names in a path are
			-- separated by tabs, so "foo.bar" in Eiffel
			-- becomes "foo%Tbar" for Versant
			from
				path_name := attribute_access.attribute_name.twin
				current_fa := attribute_access.next
			until
				current_fa = Void
			loop
				path_name.append ("%T") 
				path_name.append (current_fa.attribute_name)
				current_fa := current_fa.next
			end
			last_subscript := attribute_access.get_last_subscript
		end

	operation: INTEGER
			-- What comparison to make (see DB_CONSTANTS
			-- for possible values)

	set_operation (new_operation: INTEGER) is
		do
			operation := new_operation
		end -- set_operation

	value: T

	value_conforms (new_value: T): BOOLEAN is
			-- To be redefined in subclasses if needed
		do
			Result := True
		end -- value_conforms

	set_value (new_value: T) is
			-- Set value to compare against
		require
			conforms: value_conforms (new_value)
		do
			value := new_value
		end -- set_value
	
	is_special: BOOLEAN is
		do
			Result := (operation = db_in_list) or 
				(attribute_access.subscript /= -1)    or
				-- This last condition forces path queries with two 
				-- dots to be done in the client (i.e. "a.b.c = $1")
				(attribute_access.next /= Void) 
		end

feature {DB_QUERY, SELECT_QUERY, DB_QUERY_PREDICATE_BLOCK}

	is_true (pobject_id: INTEGER): BOOLEAN is
			-- See if this predicate is true for a particular object
		require
			pid_ok: pobject_id /= 0
		local
			db_value: like value
			attribute_object_id: INTEGER
			area_vstr: VSTR
		do
			attribute_object_id := pobject_id
			if (attribute_access.next /= Void) then
				attribute_object_id := attribute_access.get_db_id (pobject_id)
			end
			if attribute_object_id /= 0 then
				if last_subscript = -1 then
					db_value := extract_db_value (attribute_object_id, last_name)
				else
					-- Get the id of the PLIST and then extract the element
					attribute_object_id := get_db_int_attr (pobject_id, $(last_name.to_c))
					!!area_vstr.make (get_db_ptr_attr (attribute_object_id, $(area_str.to_c)))
					if area_vstr.exists then
						db_value := extract_i_th_vstr_value (area_vstr, last_subscript)
					end
				end
				Result := test_values (db_value, value)
			end
		end

	to_pointer: POINTER is
			-- Return a pointer to the predicate
			-- decriptor. Always re-initialize the buffers
			-- because Eiffel can move objects on us and
			-- make the addresses wrong
		do
			make_new_buff_desc
			make_new_pred_desc
			debug
				io.putstring ("DB_QUERY_PREDICATE: Predicate ptr=")
				io.putstring (pred_desc.out)
				io.new_line
			end
			Result := pred_desc
		end

	pred_desc: POINTER
			-- Area or predicate descriptor

	value_desc: POINTER
			-- Area for value descriptor


feature {NONE}

	extract_i_th_vstr_value (vstr: VSTR; index: INTEGER): T is
			-- Extract i-th entry of a vstr
		require
			vstr_ok: vstr /= Void
			index_ok: index >= 0
		deferred
		end

	extract_db_value  (pobject_id: INTEGER; l_attr_name: STRING): T is
			-- Return the actual value of this attribute
			-- from the database
		require
			id_ok: pobject_id /= 0
			name_ok: l_attr_name /= Void
		deferred
		end

	test_values (pred_value, db_value: T): BOOLEAN is
			-- See if the values satisfy the predicates comparison
		deferred
		end

	make_new_pred_desc is
		do
			if pred_desc = default_pointer then
				pred_desc := c_alloc_pred
			end
			c_fill_pred_struct (pred_desc, $(path_name.to_c),
								value_desc, operation, key_type)
		end
	
	key_type : INTEGER is
			-- type of key - redefined in descendant
		deferred
		end

	make_new_buff_desc is
		do
			if value_desc /= default_pointer then
				c_free_buff_desc (value_desc)
			end
			if value_address = default_pointer then
				value_desc := default_pointer
			else
				value_desc := c_make_buff_desc (value_address, value_size)
			end
		end

	value_address: POINTER is
		require
			false
		deferred
		end

	value_size: INTEGER is
		require
			false
		deferred
		end

	dispose is
		do
			-- Free predicate structures
			c_free_pred_struct(pred_desc)
			c_free_buff_desc (value_desc)
		end -- dispose
	
	area_str : STRING is "area";
	db_area_str : STRING is "db_area";

end -- DB_QUERY_PREDICATE
