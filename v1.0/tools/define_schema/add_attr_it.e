-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class ADD_ATTR_IT

inherit
	
	LINEAR_ITERATOR [SCHEMA_CLASS]
		redefine
			item_action
		end
	
	META_PCLASS_SERVER
	
	DB_CONSTANTS

creation
	
	make

feature
	
	item_action (a_class : SCHEMA_CLASS) is
			-- Define attributes
		do
			-- find PCLASS
			current_class := meta_pclass_by_name (a_class.name)
			-- Make sure that all attributes added so far
			-- show up in the PCLASS object
			--			current_class.retrieve_class;
			current_class.update_pclass
			io.putstring ("Modifying class: ");
			io.putstring (a_class.name);
			io.new_line;
			from a_class.attributes.start
			until a_class.attributes.off
			loop
				add_one_attribute (a_class.attributes.item)
				a_class.attributes.forth
			end
		end
	
	
	current_class : META_PCLASS
	
	session : DB_SESSION

	add_one_attribute (attr_desc : SCHEMA_ATTR) is
		local
			v_type : STRING;
			rep_count : INTEGER
			ti : TYPE_INFO
			attr : PATTRIBUTE
			crashed : BOOLEAN
			bad_class : PCLASS
		do
			if crashed then
				-- We crashed because an we got 6053 error
				bad_class := find_class_with_dup_attribute (attr_desc.name,
									    current_class.pclass);
				io.putstring ("** ERROR: attribute name conflict %N");
				io.putstring ("** Class=");
				io.putstring (bad_class.name);
				io.putstring (" *** Attribute=");
				io.putstring (attr_desc.name);
				io.new_line;
				except.raise ("Attribute name conflict");
				
			else
				if attr_desc.is_a_list then
					rep_count := -1;
				else
					rep_count := 1
				end
				ti := type_mapper.item (attr_desc.type);
				if ti /= Void then
					v_type := ti.versant_name;
					if rep_count = 1 then
						rep_count := ti.repeat_count
					end
				else
					v_type := attr_desc.type;
				end;
				if current_class.pclass.has_attribute (attr_desc.name) then
					-- Attribute exist, rename it
					io.putstring ("*** Redefining attribute <");
					io.putstring (attr_desc.name);
					io.putstring ("> %N");
					current_class.rename_for_redefinition (attr_desc.name)
				end
				debug
					io.putstring ("Adding attr-->");
					io.putstring (attr_desc.name);
					io.new_line;
				end
				inspect current_class.pclass.eiffel_type (v_type, rep_count)
				when Eiffel_string then
					!STRING_PATTRIBUTE!attr.make_new (attr_desc.name, 
													  v_type, rep_count)
				when Eiffel_pointer then
					!POINTER_PATTRIBUTE!attr.make_new  (attr_desc.name, 
														v_type, rep_count)
				when Eiffel_char then
					!CHARACTER_PATTRIBUTE!attr.make_new  (attr_desc.name, 
														  v_type, rep_count)
				when Eiffel_boolean then
					!BOOLEAN_PATTRIBUTE!attr.make_new  (attr_desc.name, 
														v_type, rep_count)
				when Eiffel_integer then
					!INTEGER_PATTRIBUTE!attr.make_new  (attr_desc.name, 
														v_type, rep_count)
				when Eiffel_double then
					!DOUBLE_PATTRIBUTE!attr.make_new  (attr_desc.name, 
													   v_type, rep_count)
				when Eiffel_object then
					!OBJECT_PATTRIBUTE!attr.make_new  (attr_desc.name, 
													   v_type, rep_count)
				else
					except.raise ("Unsupported type")
				end
				-- For key attributes set the aux_info
				if attr_desc.is_key_link then
					attr.set_aux_info (attr_desc.key_link_aux_info)
				end
				current_class.add_attribute (attr)
			end
		rescue
			if not crashed then
				crashed := True;
				if session.last_error = 6053 then
					-- This error means that there
					-- was a conflict in attribute
					-- names in some descendant.
					-- We have to find the right
					-- descendant, print nice
					-- error and then crash
					retry
				else
					io.putstring ("*** Crashed adding attribute: <")
					io.putstring (attr_desc.name)
					io.putstring ("> of type <")
					io.putstring (attr_desc.type)
					io.putstring ("> to class: ")
					io.putstring (current_class.name)
					io.new_line
				end;
			end;
		end
	

	
	type_mapper : TYPE_MAPPER is
		once
			!!Result.make
		end;
	
	
feature {NONE}
	
	make (new_sess : DB_SESSION) is
		do
			session := new_sess;
		end
	
	find_class_with_dup_attribute (attr_name : STRING; a_class : PCLASS) : PCLASS is
			-- Find a descendant class that has the named attribute,
			-- starting with "a_class"
		local
			one_child : PCLASS;
			i : INTEGER
		do
			a_class.retrieve_descendants;
			-- Now go thorugh the descendants to look for
			-- the attribute
			if a_class.descendants /= Void then
				from i := 1
				until (i > a_class.descendants.count) or (Result /= Void)
				loop
					one_child := session.retrieve_class (a_class.descendants @ i);
					one_child.retrieve_class;
					if one_child.has_attribute (attr_name) then
						Result := one_child
					else
						Result := find_class_with_dup_attribute (attr_name, 
											 one_child)
					end
					i := i + 1
				end
			end
		end
	

end -- ADD_ATTR_IT
