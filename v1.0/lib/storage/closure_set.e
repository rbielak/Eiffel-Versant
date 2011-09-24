-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "This class can be used to compute a closure of a %
                 %set of persistent objects"

class CLOSURE_SET

inherit
	
	DB_GLOBAL_INFO

creation
	
	make_all,
	make_in_one_database,
	make_in_one_root
	

feature
	
	make_all (pobject_id: INTEGER) is
			-- compute closure of "pobject_id" in all
			-- connected databases
		do
			scanning_option := all_databases
			internal_make (pobject_id)
		end
	
	make_in_one_database (pobject_id: INTEGER) is
			-- compute closure in the same database as the
			-- root object
		do
			scanning_option := one_database
			internal_make (pobject_id)
		end
	
	make_in_one_root (pobject_id: INTEGER) is
			-- closure from "pobject_id" in the same root
		do
			scanning_option := one_root
			internal_make (pobject_id)
		end
	

	closure: VSTR
			-- computed closure
	
	unreachables: INTEGER
			-- count of objects that couldn't be reached
			-- 'cause they were not in a connected database
	
	has (pobject_id: INTEGER): BOOLEAN is
		do
			Result := closure_set_table.has (pobject_id)
		end
	
feature {NONE}
	
	
	root_id: INTEGER
			-- root_id of the starting objects
	
	root_database: DATABASE
			-- database of the starting object
	
	internal_make (pobject_id: INTEGER) is
			-- make a VSTR of object ids that are
			-- reachable from the object in the argument
		require
			valid_pobject_id: pobject_id /= 0
		local
			vp: POINTER
			pclass: PCLASS
		do
			root_id := db_interface.get_db_int_o_attr (pobject_id, 4)
			pclass := db_interface.find_class_for_object (pobject_id)
			root_database := pclass.db
			!!closure.make (db_interface.o_newvstr ($vp, 4, $pobject_id))
			position := 1
			!!closure_set_table.make (10_000)
			compute_closure
		end
	
	position: INTEGER
			-- current position in the closure VSTR
	

	compute_closure is
		local
			done: BOOLEAN
		do
			from
			until done
			loop
				scan_one_object (closure.i_th_integer (position))
				position := position + 1
				if (position \\ 1000) = 0 then
					io.putstring ("..closure: scanned -> ")
					io.putint (position)
					io.new_line
				end
				done := position > closure.integer_count
			end
		end
	
	scan_one_object (pobject_id: INTEGER) is
		local
			pclass: PCLASS
			pattr: PATTRIBUTE
			obj_ptr: POINTER
			err, i, ref_id: INTEGER
		do
--			obj_ptr := db_interface.c_ptrfromcod (pobject_id)
			-- pin the object
			obj_ptr := db_interface.o_locateobj (pobject_id, 0)
			
			pclass := db_interface.find_class_for_object (pobject_id)
			-- First process reference attributes
			if pclass.reference_attributes /= Void then
				from i := 1
				until i > pclass.reference_attributes.count
				loop
					pattr := pclass.reference_attributes @ i
					ref_id := db_interface.get_db_int_o_ptr (obj_ptr, pattr.field_offset)
					if (ref_id /= 0) and then not closure_set_table.has (ref_id) then
						add_to_closure (ref_id)
					end
					i := i + 1
				end
			end
			-- Next deal with VSTR attributes
			if pclass.vstr_attributes /= Void then
				from i := 1
				until i > pclass.vstr_attributes.count
				loop
					pattr := pclass.vstr_attributes @ i
					scan_vstr_attr (pobject_id, pattr)
					i := i + 1
				end
			end
			-- unpin
			err := db_interface.o_unpinobj (pobject_id, 0)
		end
	
	
	scan_vstr_attr (pobject_id: INTEGER; pattr: PATTRIBUTE) is
		local
			v: VSTR
			i: INTEGER
			ref_id: INTEGER
		do
			!!v.make (db_interface.get_db_ptr_o_attr (pobject_id, pattr.field_offset))
			from i := 1
			until i > v.integer_count
			loop
				ref_id := v.i_th_integer (i)
				if (ref_id /= 0) and then not closure_set_table.has (ref_id) then
					-- add to closure
					add_to_closure (ref_id)
				end
				i := i + 1
			end
		end
	
	add_to_closure (pobject_id: INTEGER) is
		local
			l_root_id: INTEGER
			add: BOOLEAN
			l_pclass: PCLASS
			err: INTEGER
		do
			l_root_id :=  db_interface.get_db_int_o_attr (pobject_id, 4)
			inspect scanning_option 
			when all_databases then
				add := True
			when one_database then
				if l_root_id /= 0 then
					add := root_database.database_id = l_root_id // db_interface.max_roots_per_db
				else
					-- If root_id is 0, as it maybe for some
					-- special objects, check actual database
					l_pclass := db_interface.find_class_for_object (pobject_id)
					add := l_pclass.db = root_database
				end
			when one_root then
				add := l_root_id = root_id
			end
			-- If object exists, then add it to closure
			if add then
				closure_set_table.put (pobject_id)
				closure.extend_integer (pobject_id)
			else
				unreachables := unreachables + 1
			end
		end
	
feature {NONE}
	
	closure_set_table: HASH_INTEGER_SET
			-- keeps track what is in closure so far
	
	scanning_option: INTEGER
			-- what sort of scan are we doing
	
	all_databases, one_database, one_root: INTEGER is unique 
	

end -- CLOSURE_SET
