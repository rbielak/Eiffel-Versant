-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- META_PCLASS is used to manipulate schema in the database
--

class META_PCLASS
	
inherit
	
	DB_GLOBAL_INFO
	META_PCLASS_SERVER

creation
	
	make_from_pclass,
	make_from_pclass_id,
	make_new
	

feature
	
	name: STRING
			-- Name of the class
	
	pclass: PCLASS
			-- PCLASS that goes with this META_PCLASS
	
	
	pclass_valid: BOOLEAN
			-- True, if PCLASS is up to date. if False,
			-- call update PCLASS.
	
	db: DATABASE
			-- database in which this class resides
	
	
feature -- query
	
	update_pclass is 
		do
			pclass.retrieve_class
			pclass.retrieve_descendants
			pclass.retrieve_redefined_attributes
			pclass_valid := True
		ensure
			pclass_valid
		end

feature -- schema operations
	
	add_attribute (attr : PATTRIBUTE) is
			-- Add a new attribute
		require
			class_exists: pclass /= Void
			attr_ok: attr /= Void
		do
			if db_interface.c_add_attr($(name.to_c), $(db.name.to_c),
									   $(attr.name.to_c), $(attr.type.to_c), 
									   attr.repetition,
									   attr.aux_ptr) /= 0
			 then
				check_error
				except.raise ("add attribute failed")
			end;
			pclass_valid := False
		ensure
			not pclass_valid
		end;
	
	remove_attribute (attr_name : STRING) is
			-- Remove an attribute
		require
			class_exists: pclass /= Void
			attr_name_ok: attr_name /= Void;
			has_attr: pclass.attr_count > 0;
		local
			l_name : STRING;
		do
			-- Schema class names are in lower case.
			-- translate it here
			l_name := clone (name);
			l_name.to_lower;
			if db_interface.o_dropattr ($(l_name.to_c), $(db.name.to_c), $(attr_name.to_c)) /= 0 
			 then
				except.raise ("Drop attribute failed");
			end;
			pclass_valid := False
		ensure
			not pclass_valid
		end; -- remove_attribute

	already_renamed: HASH_TABLE [HASH_TABLE [STRING, STRING], STRING] is
		once
			!!Result.make (100)
		end

	rename_for_redefinition (old_name: STRING) is
		require
			class_exists: pclass /= Void
			name_ok: old_name /= Void
			class_has_attribute: pclass.attributes.has (old_name)
		local
			new_name: STRING
		do
			if old_name.count > 6 and then
					old_name.substring (1,6).is_equal (old_str) then
				new_name := old_name.twin
				new_name.append ("$")
			else
				new_name := "_old__"
				new_name.append (old_name)
			end
			if pclass.attributes.has (new_name) then
				rename_for_redefinition (new_name)
			end
			rename_attribute (old_name, new_name)
		end

	rename_attribute (old_name, new_name : STRING) is
			-- Rename attribute (deeply)
		require
			class_exists: pclass /= Void
			names_ok: (old_name /= Void) and (new_name /= Void);
			class_has_attribute: pclass.attributes.has (old_name)
		local
			attr : PATTRIBUTE;
			l_name : STRING;
			a_child : META_PCLASS
			i : INTEGER
			l_new_name : STRING
			table: HASH_TABLE [STRING, STRING]
		do
			l_name := clone(name);
			l_name.to_lower;
			if db_interface.o_shallowrenameattr ($(l_name.to_c), $(db.name.to_c),
					 $(old_name.to_c), $(new_name.to_c)) /= 0 then
				if already_renamed.item (name) /= Void and then
						already_renamed.item (name).has (old_name) then
					io.putstring (old_name)
					io.putstring (" already renamed into ")
					io.putstring (already_renamed.item (name).item (old_name))
					io.putstring (" in class ")
					io.putstring (name)
					io.putstring (" and you are trying to rename it into ")
					io.putstring (new_name)
					io.new_line
				else
					except.raise ("Rename failed");
				end
			else
				if already_renamed.item (name) = Void then
					!!table.make (1)
					already_renamed.put (table, name)
				end
				already_renamed.item (name).put (new_name, old_name)
			end;
			pclass.retrieve_descendants
			if pclass.descendants /= Void then
				l_new_name := new_name.twin;
				from i := 1
				until i > pclass.descendants.count
				loop
					a_child := meta_pclass_by_name (pclass.descendants @ i)
					check
						schema_ok: a_child /= Void
					end
					a_child.rename_attribute (old_name, l_new_name);
					i := i + 1
				end;
			end
			pclass_valid := False
		ensure
			not pclass_valid
		end;
	
	
	flip_key_attribute (attr_name: STRING; key_path: STRING) is
			-- Change attribute to be a key attribute if
			-- its just a regular attribute, or flip it
			-- back to regular if it's a key attribute
		require
			pclass_valid: pclass_valid
			name_ok: attr_name /= Void
			has_attr: pclass.attributes.has (attr_name)
		local
			pattr: PATTRIBUTE
			a_child: META_PCLASS
			i: INTEGER
		do
			io.putstring ("Processing class: ")
			io.putstring (pclass.name)
			pattr := pclass.attributes.item (attr_name)
			if pattr.is_key_attribute then
				c_set_auxinfo (pattr.pobject_id, default_pointer, 0)
				io.putstring (" flipped to no key%N")
			else
				c_set_auxinfo (pattr.pobject_id, $(key_path.to_c), key_path.count+1)
				io.putstring (" flipped to key%N")
			end
			check_error
			-- Now do the same thing in the descendants
			pclass.retrieve_descendants
			if pclass.descendants /= Void then
				from i := 1
				until i > pclass.descendants.count
				loop
					a_child := meta_pclass_by_name (pclass.descendants @ i)
					if a_child.pclass_valid then
						a_child.flip_key_attribute (attr_name, key_path);
					else
						io.putstring ("-- Pclass already changed: ")
						io.putstring (a_child.pclass.name)
						io.new_line
					end
					i := i + 1
				end;
			end
			pclass_valid := False
		end

feature {NONE}

	make_new (lname: STRING; ldb: DATABASE; 
		  parents: LIST [STRING]; new_attributes: LIST [PATTRIBUTE]) is
			-- Define a class with named parents having
			-- listed attributes
		require
			valid_class_name: lname /= Void;
			database_there: (ldb /= Void) and then ldb.is_connected
		local
			parent_vstr: POINTER
			pattr: PATTRIBUTE
			pobject_id: INTEGER
		do
			db := ldb
			name := clone (lname)
			-- handle parents
			if parents /= Void then
				from parents.start
				until parents.after
				loop
					parent_vstr := db_interface.c_build_vstr (parent_vstr,
										  $(parents.item.to_c));
					parents.forth;
				end;
			end; -- parents Void
			-- Now create the class
			pobject_id := db_interface.o_defineclass ($(name.to_c), 
													  $(db.name.to_c),
													  parent_vstr, 
													  default_pointer, 0);
			check_error;
			-- delete the vstrs
			if parent_vstr /= default_pointer then
				db_interface.c_deletevstr (parent_vstr);
			end;
			if pobject_id = 0 then
				except.raise ("class definition failed");
			end;

			-- Add the attributes
			if new_attributes /= Void then
				from new_attributes.start
				until new_attributes.after
				loop
					pattr := new_attributes.item;
					if db_interface.c_add_attr($(name.to_c), 
											   $(db.name.to_c), $(pattr.name.to_c), 
											   $(pattr.type.to_c), pattr.repetition,
											   pattr.aux_ptr) /= 0 
					 then
						except.raise ("add attribute failed");
					end;
					new_attributes.forth;
				end
			end; -- new_atributes void
			!!pclass.make_by_id (pobject_id)
			update_pclass
		ensure
			exists: (pclass /= Void) and pclass_valid
		end; -- define_class
	
	
	make_from_pclass (lpclass: PCLASS) is
		require
			pclass_valid: lpclass /= Void
		do
			pclass := lpclass;
			db := pclass.db;
			name := pclass.name.twin
			update_pclass
			pclass_valid := True
		ensure
			exists: (pclass /= Void) and pclass_valid
		end
	
	make_from_pclass_id (pclass_id: INTEGER) is
		require
			pclass_id_valid: pclass_id > 0
		local
			lpclass: PCLASS
		do
			lpclass := db_interface.find_class_by_class_id (pclass_id)
			make_from_pclass (lpclass)
		ensure
			exists: (pclass /= Void) and pclass_valid
		end

feature
	
	remove is
			-- Remove the class definition from the database
		require
			class_exists : pclass /= Void
		local
			lname : STRING;
		do
			-- Schema classes are in lower case. We do
			-- clone and .to_lower here, as this rotuine
			-- will not be called very often
			lname := clone (name);
			lname.to_lower;
			if db_interface.o_dropclass ($(lname.to_c), $(db.name.to_c)) /= 0 then
				except.raise ("dropclass failed");
			end;
			-- Remove the class from the class hash_table
			if db_interface.pclass_table.has (pclass.pobject_id) then
				db_interface.pclass_table.remove (pclass.pobject_id);
			end
			pclass := Void
			pclass_valid := False
		ensure
			pclass = Void
		end; -- remove

	
	get_all_instances (include_descendants: BOOLEAN): VSTR is
		obsolete "Use 'all_instances' form PCLASS"
		require
			name_ok: name /= Void
			db_ok: db /= Void
		local
			c_vstr: POINTER
			l_name: STRING
		do
			l_name := clone (name)
			l_name.to_lower
			c_vstr := db_interface.c_db_select ($(l_name.to_c), $(db.name.to_c),
												include_descendants, 0, default_pointer)
			check_error
			!!Result.make (c_vstr)
		end

	create_instance: INTEGER is
		require
			persistent: pclass /= Void
		do
			Result := db_interface.o_makeobj (pclass.pobject_id, 
							  default_pointer, False)
			db_interface.set_db_int_attr (Result, $(("pobject_version").to_c), 1)
		end

	get_ref_or_int_attribute (instance: INTEGER; attr_name: STRING): INTEGER is
		require
			persistent_instance: instance /= 0
			attr_name_ok: attr_name /= Void and pclass.attributes.has (attr_name)
		do
			Result := db_interface.get_db_int_attr (instance, $(attr_name.to_c))
			check_error
		end

	set_ref_or_int_attribute (instance: INTEGER; attr_name: STRING; value: INTEGER) is
		require
			persistent_instance: instance /= 0
			attr_name_ok: attr_name /= Void and pclass.attributes.has (attr_name)
		do
			db_interface.set_db_int_attr (instance, $(attr_name.to_c), value)
			check_error
		end
	
	
	old_str : STRING is "_old__";

	
feature {NONE}
	
	c_set_auxinfo (attr_id: INTEGER; value: POINTER; len: INTEGER) is
		external "C"
		end

invariant	
	
	db_defined: db /= Void
	pclass_retrieved: pclass_valid implies (pclass /= Void)
	name_defined: name /= Void

end -- META_PCLASS
