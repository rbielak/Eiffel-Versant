-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
--  Take schema from a Versant database and write out text
--  that can be used by "build_schema"

class DUMP_SCHEMA

inherit 
	
	ENVIRONMENT_VARIABLES
	MEMORY

creation
	
	make

feature
	
	args : ARGUMENTS is
		once
			!!Result
		end
	
	session : DB_SESSION is
		once
			!!Result
		end
	
	typer : SCHEMA_TYPE_MAPPER is
		once
			!!Result
		end
	
	root_class : PCLASS;

	classes : INDEXED_LIST [CLASS_INFO, STRING];
			-- List of classes index by their name
	
	renames_list : LINKED_LIST [PCLASS];
			-- List of classes that have renamed attributes

	make is
		local
			root_class_name : STRING;
			class_info : CLASS_INFO;
			current_db_name : STRING;
			goforit : BOOLEAN;
		do
			-- expect either two or four parameters
			-- dump_schema  -d <db_name> <root_class_name>
			-- dump_schema  <root_class_name>
			if args.argument_count = 1 then
				current_db_name := get ("O_DBNAME");
				root_class_name := clone (args.argument(1));
				goforit := current_db_name /= Void;
			elseif args.argument_count = 3 then
				if (args.argument(1).is_equal ("-d") or 
				   args.argument(1).is_equal ("-D")) then
					current_db_name := clone (args.argument(2));
					root_class_name := clone (args.argument(3));
					goforit := true;
				else
					goforit := false;
				end;
			else goforit := false;
			end;
			if not goforit then
				io.error.putstring ("Usage: dump_schema -d <db_name> <root_class_name>%N");
				io.error.putstring ("       dump_schema <root_class_name>%N");
			else
				io.error.putstring ("Connecting to database -> ");
				io.error.putstring (current_db_name);
				io.error.new_line;
				session.begin (current_db_name);
				io.error.putstring ("--> Getting schema for root class: ");
				io.error.putstring (root_class_name); 
				io.error.new_line;
				root_class := retrieve_class (root_class_name); 
				if root_class = Void then
					io.error.putstring ("**** Error: class <");
					io.error.putstring (root_class_name);
					io.error.putstring ("> not in the schema.  %N");
				else
					!!renames_list.make;
					!!classes.make (200);
					!!class_info.make (root_class);
					io.error.putstring ("--> Retrieving classes%N");
					classes.put_key (class_info, root_class.name);
					retrieve_class_info (root_class);
					generate_simplified_schema
				end;
				session.finish;
			end;
		end; -- make
	
	retrieve_class_info (one_class : PCLASS) is
		require
			one_class /= Void
		local
			a_name : STRING;
			a_class : PCLASS;
			class_info : CLASS_INFO;
			i : INTEGER;
		do
			-- Collection off 'cause of ISE bug
			collection_off
			-- Get all the descendants first
			if one_class.descendants /= Void then
				-- First retrieve all the classes
				from  i := 1
				until i > one_class.descendants.count
				loop
					a_name := one_class.descendants.item (i);
					if not classes.has_key (a_name) then
						-- Retrieve the class
						a_class := retrieve_class (a_name);
						check
							consistent_schema: a_class /= Void
						end;
						!!class_info.make (a_class);
						classes.put_key (class_info, a_name);
					end;
					i := i + 1
				end; -- loop
				-- Then recursively deal with their descendants
				from  i := 1
				until i > one_class.descendants.count
				loop
					a_name := one_class.descendants.item (i); 
					class_info := classes.item_by_key (a_name);
					retrieve_class_info (class_info.the_class);
					i := i + 1
				end;
			end;
			collection_on
		end;
	
	retrieve_class (name : STRING) : PCLASS is
		require
			name /= Void
		do
			Result := session.retrieve_class (name);
			if Result /= Void then
				Result.retrieve_descendants;
			end;
		end;
	
	
	generate_simplified_schema is
		do
			io.putstring ("-- Dump of schema from <");
			io.putstring (session.default_db.name);
			io.putstring ("> database. %N--%N");
			io.error.putstring ("--> Generating schema %N");
			from classes.start
			until classes.off
			loop
				generate_one_class (classes.item.the_class)
				classes.forth;
			end
		end
	
	
	generate_one_class (the_class : PCLASS) is
		local
			cls_name : STRING;
		do
			-- First generate class header
			io.putstring ("CLASS ");
			cls_name := the_class.name.twin;
			cls_name.to_lower;
			io.putstring (cls_name);
			io.new_line;
			-- Generate inheritance clauses
			generate_class_inheritance (the_class);
			-- generate reanames
			generate_class_renames (the_class);			
			-- generate attributes
			generate_class_attributes (the_class);
			io.putstring ("END%N");
		end
	

	
	generate_class_attributes (the_class : PCLASS) is
		local
			attr_array : ARRAY[ PATTRIBUTE];
			one_attr : PATTRIBUTE;
--			key_attr: KEY_PATTRIBUTE
			i : INTEGER;
			header_generated : BOOLEAN;
			parent_info : CLASS_INFO;
			class_name : STRING
		do
			-- first deal with the ancestors
			attr_array := the_class.attributes_array
			sort_attr_by_field_offset (attr_array)
			from 
				i := 1;
			until i > attr_array.count
			loop
				one_attr := attr_array @ i;
				-- Generate only attributes defined in
				-- this class
				if one_attr.class_id = the_class.pobject_id then
					io.putstring ("%TATTRIBUTE ");
					io.putstring (one_attr.name);
					io.putstring (" ")
					io.putstring (typer.schema_type (one_attr))
					io.new_line;
				end;
				i := i + 1;
			end;
		end;
	
	generate_renames is
		do
			from classes.start
			until classes.off
			loop
				generate_class_renames (classes.item.the_class);
				classes.forth;
			end;
		end;

	
	generate_class_renames (one_class : PCLASS) is
		require
			class_ok : one_class /= Void
		local
			attr_array : ARRAY[PATTRIBUTE];
			parent : PCLASS;
			one_attr : PATTRIBUTE;
			i, j : INTEGER;		
			header_generated, skip : BOOLEAN;
			original_name : STRING;
			class_name : STRING;
		do
			-- YOu need ancestors to have renames
			if one_class.ancestors /= Void then
				from 
					i := 1;
					attr_array := one_class.attributes.array_representation;
				until i > attr_array.count
				loop
					one_attr := attr_array @ i;
					if one_attr.original_name /= Void then
						-- Check for "_old__" names which should
						-- be ignored
						skip := (one_attr.name.count > 6) and then
						         one_attr.name.substring (1,6).is_equal ("_old__");
						if not skip and then original_from_parent (one_class,
											   one_attr) 
						 then
							-- Only generate the rename
							-- if the original attribute
							-- comes from a direct parent
							io.putstring ("   RENAME ");
							io.putstring (one_attr.original_name);
							io.putstring (" ");
							io.putstring (one_attr.name);
							io.new_line;
						end;
					end;
					i := i + 1
				end; -- loop
			end
		end
	
	original_from_parent (a_class : PCLASS; an_attr : PATTRIBUTE) : BOOLEAN is
		require
			class_ok: (a_class /= Void);
			attr_was_renamed: (an_attr /= Void) and then (an_attr.original_name /= Void);
		local
			a_parent : PCLASS;
			i : INTEGER
		do
			from i := 1
			until (i > a_class.ancestors.count) or Result
			loop
				a_parent := classes.item_by_key(a_class.ancestors @ i).the_class;
				Result := a_parent.has_attribute (an_attr.original_name);
				i := i + 1
			end
		end
	

	generate_inheritance is
		local
			class_info : CLASS_INFO;
		do
			from classes.start
			until classes.off
			loop
				class_info := classes.item;
				if not class_info.generated then
					generate_class_inheritance (class_info.the_class);
					class_info.mark_generated;
				end;
				classes.forth;
			end;
		end;
	
	generate_class_inheritance (a_class : PCLASS) is
		require
			a_class /= Void
		local
			i : INTEGER;
			parent_info : CLASS_INFO;
			class_name : STRING;
		do
			if a_class.ancestors /= Void then
				from i := 1
				until i > a_class.ancestors.count
				loop
					io.putstring ("%TINHERIT ");
					io.putstring (a_class.ancestors.item(i));
					io.new_line;
					i := i + 1
				end;
			end;
		end;
	
	sort_attr_by_field_offset (attr: ARRAY [PATTRIBUTE]) is
		local
			tmp: PATTRIBUTE
			i, j: INTEGER
		do
			from i := 1
			until i > attr.count
			loop
				from j := i + 1
				until j > attr.count
				loop
					if attr.item (i).field_offset > attr.item (j).field_offset then
						-- swap
						tmp := attr.item (i)
						attr.put (attr.item (j), i)
						attr.put (tmp, j)
					end
					j := j + 1
				end
				i := i + 1
			end
		end

end -- DUMP_SCHEMA
