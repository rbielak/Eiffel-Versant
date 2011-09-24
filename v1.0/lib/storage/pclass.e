-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Information about persistent classes
--

class PCLASS

inherit

	VERSANT_EXTERNALS
	INTERNAL
	DB_GLOBAL_INFO
	DB_CONSTANTS

creation

	make_by_name,
	make_by_id


feature

	pobject_id: INTEGER
			-- Object ID of the class object

	name: STRING
			-- Name of the class (Versant Name)

	eiffel_name: STRING
			-- Name of the matching Eiffel class (View in the current system)

	attr_count: INTEGER
			-- Number of Versant (persistent) attributes

	attributes: ARRAYED_H_TABLE [PATTRIBUTE, STRING]
			-- Attributes of the class, for access by name.

	attributes_array: ARRAY [PATTRIBUTE]
			-- Redundant attributes information for fast access
			-- when traversing
	
	reference_attributes : ARRAY [OBJECT_PATTRIBUTE]
			-- attributes that are references to other POBJECTs

	vstr_attributes : ARRAY [PATTRIBUTE]
			-- attributes that are references to Versant Vstr (i.e. list)
	
	key_attributes: ARRAY [PATTRIBUTE]
			-- attributes that can be used to form a unique query

	ancestors: ARRAY [STRING]
			-- Names of direct parents

	descendants: ARRAY [STRING]
			-- Names of direct descendants

	my_manager: MAN [MANAGEABLE]
			-- Manager for this class (could be void)
	
	db : DATABASE
			-- Database from which this class came from

feature -- retrieval of existing classes

	exists: BOOLEAN
			-- True, if class found

	initialized: BOOLEAN
			-- True if the Eiffel Offset have been defined when processing
			-- the first Object instance of this PCLASS.


	retrieve_class is
			-- Retrieve class information from the database
		require
			name_specified: name /= Void;
		local
			attr_vstr: POINTER
			attr_oid: INTEGER
			attr_type_oid: INTEGER
			attr_name: STRING
			attr_type: STRING
			attr_aux_info: STRING
			attr: PATTRIBUTE
			rep_factor: INTEGER
			offset: INTEGER
			i: INTEGER
			schema_attr_count : INTEGER;
		do
			debug ("pclass")
				io.putstring ("Retrieving a class=")
				io.putstring (name)
				io.new_line
			end

			attr_count := 0
			attributes.clear_all

			debug("pclass")
				io.putstring ("Class oid=")
				io.putint (pobject_id)
				io.putstring (" Error=")
				io.putint (c_get_error)
				io.new_line
			end

			if pobject_id /= 0 then
				exists := TRUE
				initialized := FALSE

					-- Now get all the attribute info
				schema_attr_count := get_db_int_attr (pobject_id, $(("numattrs").to_c));
				check_error
				attr_vstr := c_get_db_class_attrs (pobject_id);
				check_error;

				debug("pclass")
					io.putstring ("Class attr_count=");
					io.putint (schema_attr_count);
					io.new_line;
				end;

				from
					i := 1
				until
					i > schema_attr_count
				loop
					attr_oid := c_get_entry (attr_vstr, i - 1)
					attr_type_oid := get_db_int_attr (attr_oid, $(domain_str.to_c))
					check_error
					rep_factor := get_db_int_attr (attr_oid, $(repfactor_str.to_c))
					check_error
					attr_name := get_db_string_attr (attr_oid, $(name_str.to_c))
					check_error
					-- Only add attributes that were not redefined and
					-- renamed away
					if ((attr_name.count < 6) or else
						not attr_name.substring (1,6).is_equal (old_str)) and
						not (attr_name.is_equal ("auxobj") and name.is_equal ("CLASS")) and
						not (attr_name.is_equal ("auxobj") and name.is_equal ("ATTRIBUTE"))
					 then 
						attr_type := get_db_string_attr (attr_type_oid, $(name_str.to_c))
						check_error
						attr_aux_info := get_db_string_attr (attr_oid, $(aux_info_str.to_c))
						check_error
						offset := c_get_attr_offset (pobject_id, $(attr_name.to_c))
						inspect eiffel_type (attr_type, rep_factor)
						when Eiffel_string then
							!STRING_PATTRIBUTE!attr.make (attr_name, 
										      attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						when Eiffel_pointer then
							!POINTER_PATTRIBUTE!attr.make (attr_name, 
										      attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						when Eiffel_char then
							!CHARACTER_PATTRIBUTE!attr.make (attr_name, 
										      attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						when Eiffel_boolean then
							!BOOLEAN_PATTRIBUTE!attr.make (attr_name, 
										      attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						when Eiffel_integer then
							!INTEGER_PATTRIBUTE!attr.make (attr_name, 
										       attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						when Eiffel_double then
							!DOUBLE_PATTRIBUTE!attr.make (attr_name, 
										       attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						when Eiffel_object then
							!OBJECT_PATTRIBUTE!attr.make (attr_name, 
										      attr_type, 
										      rep_factor, 
										      attr_oid, offset,
										      attr_aux_info) 
						else
							except.raise ("Unsupported type")
						end
						attributes.put (attr, attr_name)
					end

					debug("pclass")
						io.putstring ("Attr name=")
						io.putstring (attr_name)
						io.putstring (" type=")
						io.putstring (attr_type)
						io.new_line
					end
					i := i + 1
				end
				attr_count := attributes.count;
				if attr_vstr /= default_pointer then
					c_deletevstr (attr_vstr)
					check_error
				end
				if attr_count > 0 then
					attributes_array := attributes.array_representation
					create_ref_attr_array
				end
				retrieve_ancestors
			end
		ensure
			consistent_result: exists implies pobject_id /= 0
		end -- retrieve_class
	
	
	retrieve_redefined_attributes is
			-- Must be called after "retrieve_class"
		require
			pobject_id /= 0
		local
			attr_vstr: POINTER
			attr_oid: INTEGER
			attr_type_oid: INTEGER
			attr_name: STRING
			attr_type: STRING
			attr_aux_info: STRING
			attr: PATTRIBUTE
			rep_factor: INTEGER
			offset: INTEGER
			i: INTEGER
			schema_attr_count : INTEGER;
		do
			-- Now get all the attribute info
			schema_attr_count := get_db_int_attr (pobject_id, $(("numattrs").to_c));
			check_error
			attr_vstr := c_get_db_class_attrs (pobject_id);
			check_error;
			from
				i := 1
			until
				i > schema_attr_count
			loop
				attr_oid := c_get_entry (attr_vstr, i - 1)
				attr_type_oid := get_db_int_attr (attr_oid, $(domain_str.to_c))
				check_error
				rep_factor := get_db_int_attr (attr_oid, $(repfactor_str.to_c))
				check_error
				attr_name := get_db_string_attr (attr_oid, $(name_str.to_c))
				check_error
				-- Only get attributes that start with "_old__"
				if (attr_name.count > 6) and attr_name.substring (1,6).is_equal (old_str) then 
					attr_type := get_db_string_attr (attr_type_oid, $(name_str.to_c))
					check_error
					attr_aux_info := get_db_string_attr (attr_oid, $(aux_info_str.to_c))
					check_error

					offset := c_get_attr_offset (pobject_id, $(attr_name.to_c))
					inspect eiffel_type (attr_type, rep_factor)
					when Eiffel_string then
						!STRING_PATTRIBUTE!attr.make (attr_name, 
													  attr_type, 
													  rep_factor, 
													  attr_oid, offset,
													  attr_aux_info) 
					when Eiffel_pointer then
						!POINTER_PATTRIBUTE!attr.make (attr_name, 
													   attr_type, 
													   rep_factor, 
													   attr_oid, offset,
													   attr_aux_info) 
					when Eiffel_char then
						!CHARACTER_PATTRIBUTE!attr.make (attr_name, 
														 attr_type, 
														 rep_factor, 
														 attr_oid, offset,
														 attr_aux_info) 
					when Eiffel_boolean then
						!BOOLEAN_PATTRIBUTE!attr.make (attr_name, 
													   attr_type, 
													   rep_factor, 
													   attr_oid, offset,
													   attr_aux_info) 
					when Eiffel_integer then
						!INTEGER_PATTRIBUTE!attr.make (attr_name, 
													   attr_type, 
													   rep_factor, 
													   attr_oid, offset,
													   attr_aux_info) 
					when Eiffel_double then
						!DOUBLE_PATTRIBUTE!attr.make (attr_name, 
													  attr_type, 
													  rep_factor, 
													  attr_oid, offset,
													  attr_aux_info) 
					when Eiffel_object then
						!OBJECT_PATTRIBUTE!attr.make (attr_name, 
													  attr_type, 
													  rep_factor, 
													  attr_oid, offset,
													  attr_aux_info) 
					else
						except.raise ("Unsupported type")
					end
					-- add to attribute table
					attributes.put (attr, attr_name)
				end
				i := i + 1
			end -- loop
			-- Now update internal tables
			attr_count := attributes.count;
			if attr_vstr /= default_pointer then
				c_deletevstr (attr_vstr)
				check_error
			end
			if attr_count > 0 then
				attributes_array := attributes.array_representation
				create_ref_attr_array
			end
		end
	
	pclass_of_generic: PCLASS is
			-- the PCLASS of the generic parameter, Void if this
			-- class is not generic
		local
			generic_name: STRING
			pos: INTEGER
			class_id: INTEGER
		do
			pos := eiffel_name.index_of ('[', 1)
			if (pos > 0) then
				generic_name := eiffel_name.substring (pos+1, name.count-1)
				generic_name.to_lower
				class_id := db.find_class_id (generic_name)
				Result := db_interface.find_class_by_class_id (class_id)
			end
		end

feature {NONE}

	retrieve_ancestors is
		require
			class_exists: exists
		local
			class_oid, i: INTEGER
			lclass_name: STRING
			super_classes_vstr: POINTER
			super_classes_count: INTEGER
		do
			super_classes_vstr := get_db_ptr_attr (pobject_id, $(("supclses").to_c));
			if super_classes_vstr /= default_pointer then
				super_classes_count := c_sizeofvstr (super_classes_vstr) // 4;
				if super_classes_count > 0 then
					!!ancestors.make (1, super_classes_count);
					from
						i := 1
					until
						i > super_classes_count
					loop
						class_oid := c_get_entry (super_classes_vstr, i - 1);
						lclass_name := get_db_string_attr (class_oid, $(name_str.to_c));
						ancestors.put (lclass_name, i);
						i := i + 1
					end
				end
				c_deletevstr (super_classes_vstr)
			end
		end
	
feature -- retrieve descendants

	retrieve_descendants is
		require
			class_exists: exists
		local
			class_oid, i: INTEGER
			lclass_name: STRING
			sub_classes_vstr: POINTER
			sub_classes_count: INTEGER
		do
			sub_classes_vstr := get_db_ptr_attr (pobject_id, $(("subclses").to_c));
			if sub_classes_vstr /= default_pointer then
				sub_classes_count := c_sizeofvstr (sub_classes_vstr) // 4;
				if sub_classes_count > 0 then
					!!descendants.make (1, sub_classes_count);
					from i := 1
					until i > sub_classes_count
					loop
						class_oid := c_get_entry (sub_classes_vstr, i - 1);
						lclass_name := get_db_string_attr (class_oid, $(name_str.to_c));
						descendants.put (lclass_name, i);
						i := i + 1
					end
				end
				c_deletevstr (sub_classes_vstr)
			end
		end

feature -- schema operations

	has_attribute (attr_name: STRING): BOOLEAN is
		require
			attr_ok: attr_name /= Void
		do
			Result := attributes.has (attr_name)
		end




feature {PCLASS, POBJECT, DB_INTERFACE_INFO, ATTR_VALUE}
	-- Internal features for the database interface

	init_offsets (object: POBJECT) is
			-- Init the Pattribute Eiffel's offset.
		require
			not_void: object /= Void
			not_initialised: not initialized
		local
			count, i, ftype: INTEGER
			pattr: PATTRIBUTE
			type_error: BOOLEAN
		do
			count := field_count (object);
			from
				i := 1
			until
				i > count
			loop
				pattr := attributes.item (field_name(i, object))
				if pattr /= void then
					pattr.set_eiffel_offset (field_offset (i, object))
					debug ("pclass_type_check")
						-- verify types of attributes
						ftype := field_type (i, object)
						inspect ftype 
						when reference_type then
							type_error := (pattr.eiffel_type /= Eiffel_string) and pattr.type_is_basic
						when character_type then
							type_error := pattr.eiffel_type /= Eiffel_char
						when boolean_type then
							type_error := pattr.eiffel_type /= Eiffel_boolean
						when integer_type then
							type_error := pattr.eiffel_type /= Eiffel_integer
						when double_type then
							type_error := pattr.eiffel_type /= Eiffel_double
						when pointer_type then
							type_error := pattr.eiffel_type /= Eiffel_pointer
						else
							io.putstring ("Unsupported persistent type error%N")
							type_error := True
						end
						if type_error then
							io.putstring ("*** ERROR: Class: ")
							io.putstring (name)
							io.putstring (" Attribute: ")
							io.putstring (pattr.name)
							io.new_line
							except.raise ("Type mismatch between Eiffel and the schema")
						end
					end -- debug
				end
				i := i + 1
			end
			initialized := TRUE
			check_schema
		end

	peif_id_str: STRING is "peif_id"

	check_schema is
		local
			i: INTEGER
			pattr: PATTRIBUTE
			modified: BOOLEAN
		do
			from
				i := 1
			until
				i > attr_count
			loop
				pattr := attributes_array.item (i)
				if pattr.eiffel_offset = -1 then
					if pattr.name.is_equal (peif_id_str) then
						if pattr.field_offset /= 8 then
							except.raise ("peif_id offset /= 8 !")
						end
					elseif eiffel_name = name then
						io.putstring ("SCHEMA ERROR: attribute <")
						io.putstring (pattr.name)
						io.putstring ("> in schema but not in Eiffel class: ")
						io.putstring (name)
						io.new_line
					end
					attributes.remove (pattr.name)
					modified := True
				end
				i := i + 1
			end
			if modified then
				attributes_array := attributes.array_representation
				attr_count := attributes.count
				create_ref_attr_array
			end
		end


feature {NONE}

	make_by_name (new_name : STRING; new_db : DATABASE) is
		require
			name_ok: new_name /= Void;
			db_ok: new_db /= Void
		do
			!!attributes.make (17)
			name := clone (new_name)
			eiffel_name := db_interface.view_table.eiffel_view (name)
			-- Find our manager
			my_manager := db_interface.restricted_managers.item (name)
			-- Find out our ID
			pobject_id := new_db.find_class_id (name);
			db := new_db
		ensure
			name_ok: name /= Void;
			persistent: pobject_id /= 0
			db_ok : db /= Void
		end -- make
	
	
	make_by_id (class_id : INTEGER) is
		require
			valid_class_id : class_id /= 0
		do
			!!attributes.make (17)			
			pobject_id := class_id;
			-- Retrieve class name
			name := get_db_string_attr (pobject_id, $(name_str.to_c));
			check_error;
			name.to_upper
			eiffel_name := db_interface.view_table.eiffel_view (name)
			-- Find our manager
			my_manager := db_interface.restricted_managers.item (name)
			-- Find our database
			if db_interface.active_databases.count = 1 then
				-- Small optimization if there is only
				-- one database
				db := db_interface.current_database
			else
				from db_interface.active_databases.start
				until db_interface.active_databases.off or db /= Void
				loop
					if db_interface.active_databases.item.has_class (pobject_id,name) 
					 then
						db := db_interface.active_databases.item
					end
					db_interface.active_databases.forth
				end; -- loop
			end
		ensure
			name_ok: name /= Void
			persistent: pobject_id /= 0
			db_ok : db /= Void		
		end

	
	create_ref_attr_array is
			-- Create an array of ref-only attributes and an array of
			-- vstr only attributes
		require
			attributes_defined: attributes_array /= Void
		local 
			i : INTEGER
			count_ref, count_vstr, count_key: INTEGER
			ref_attr : ARRAY [OBJECT_PATTRIBUTE]
			vstr_attr : ARRAY [PATTRIBUTE]
			key_attr: ARRAY [PATTRIBUTE]
			one_attr : PATTRIBUTE
			obj_attr: OBJECT_PATTRIBUTE
		do
			-- Copy ref attributes to a local array
			!!ref_attr.make (1, attr_count)
			!!vstr_attr.make (1, attr_count)
			!!key_attr.make (1, attr_count)
			from i := 1
			until i > attr_count
			loop
				one_attr := attributes_array @ i
				if (one_attr.eiffel_type_code = Eiffel_object) or
					(one_attr.eiffel_type_code = Eiffel_object_key) 
				 then
					count_ref := count_ref + 1
					obj_attr ?= one_attr
					ref_attr.put (obj_attr, count_ref)
				elseif one_attr.eiffel_type_code = Eiffel_pointer and
						not one_attr.type.is_equal ("o_double") and
						not one_attr.type.is_equal ("o_4b") and
						not one_attr.type.is_equal ("o_u1b") then
					count_vstr := count_vstr + 1
					vstr_attr.put (one_attr, count_vstr)
				end
				if one_attr.is_key_attribute then
					count_key := count_key + 1
					key_attr.put (one_attr, count_key)
				end
				i := i + 1
			end
			if count_ref > 0 then
				!!reference_attributes.make (1, count_ref)
				from i := 1
				until i > count_ref
				loop
					reference_attributes.put (ref_attr @ i, i)
					i := i + 1
				end
			else
				reference_attributes := Void
			end
			if count_vstr > 0 then
				!!vstr_attributes.make (1, count_vstr)
				from i := 1
				until i > count_vstr
				loop
					vstr_attributes.put (vstr_attr @ i, i)
					i := i + 1
				end
			else
				vstr_attributes := Void
			end
			if count_key > 0 then
				!!key_attributes.make (1, count_key) 
				from i := 1
				until i > count_key
				loop
					key_attributes.put (key_attr @ i, i)
					i := i + 1
				end
			else
				key_attributes := Void
			end
		end
	
	domain_str: STRING is "domain";
	
	repfactor_str: STRING is "repfactor";
	
	name_str: STRING is "name";
	
	old_str: STRING is "_old__";
	
	aux_info_str: STRING is "auxinfo"
	

feature

	eiffel_type (type: STRING; repetition: INTEGER) : INTEGER is
			-- translate from Versant to Eiffel type
		do
			if equal (type, "char") and (repetition = -1) then
				Result := Eiffel_string
			elseif repetition = -1 then
				Result := Eiffel_pointer
			elseif equal (type,"char") and (repetition = 1)  then
				Result := Eiffel_char;
			elseif equal (type, "o_u1b") then
				Result := Eiffel_boolean
			elseif equal (type, "o_4b") then
				Result := Eiffel_integer
			elseif equal (type, "o_double") and (repetition = 1)  then
				Result := Eiffel_double
			elseif equal (type, "o_ptr") then
				-- Patch for peif_id
				Result := Eiffel_integer
			else
				Result := Eiffel_object
			end;
		end

	
	set_db (ldb: like db) is
		do
			db := ldb
		end

feature -- instance retrieval

	all_instances (include_descendants: BOOLEAN): VSTR is
		require
			valid_database: db /= Void
		local
			c_vstr: POINTER
			l_name: STRING
		do
			l_name := clone (name)
			l_name.to_lower
			c_vstr := db_interface.c_db_select ($(l_name.to_c), $(db.name.to_c),
												include_descendants, 0, default_pointer)
			check_error
			if c_vstr /= default_pointer then
				!!Result.make (c_vstr)
			end
		end

	is_subclass_of (parent_name: STRING): BOOLEAN is
		require
			valid_database: db /= Void
			parent_class_name_is_valid: parent_name /= Void
		local
			i: INTEGER
			tmp_parent_pclass: PCLASS
		do
			from 
				i := 1
				ancestors.compare_objects
			until
				Result or i > ancestors.count
			loop
				Result := name.is_equal (parent_name) or else ancestors.has (parent_name)
				if not Result then
					tmp_parent_pclass := db_interface.find_class (ancestors.item (i))
					if tmp_parent_pclass.ancestors /= Void then
						Result := tmp_parent_pclass.is_subclass_of (parent_name)
					end
				end
				i := i+1
			end
		end


invariant

	valid_attr_count: attr_count >= 0
	valid_name: name /= Void

end -- PCLASS
