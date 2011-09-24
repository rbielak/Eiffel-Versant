-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Sort a list of classes by using the inheritance relationship
--

class CLASS_SORTER

creation
	
	make

feature
	
	sorted_classes : INDEXED_LIST [SCHEMA_CLASS, STRING]
			-- Sorted classes
	
	sort_list (class_list :INDEXED_LIST [SCHEMA_CLASS, STRING]) is
		require
			(class_list /= Void) and then (class_list.count > 0)
		do
			to_be_sorted := class_list
			from class_list.start
			until class_list.off
			loop
				handle_one_class (class_list.item);
				class_list.forth
			end
		end
	

	dump_list is
		do
			from sorted_classes.start
			until sorted_classes.off
			loop
				sorted_classes.item.dump
				sorted_classes.forth
			end
		end
	
	missing_parents: BOOLEAN

feature {NONE}
	
	to_be_sorted : INDEXED_LIST [SCHEMA_CLASS, STRING];

	handle_one_class (a_class : SCHEMA_CLASS) is
		require
			a_class /= Void
		local
			a_parent : SCHEMA_CLASS
			parent_name : STRING
		do
			-- If the class is not already in the final
			-- list look at the parents
			if not sorted_classes.has_key (a_class.name) then
				-- Make sure all the parents are in
				-- the sorted list fist
				from a_class.parents.start
				until a_class.parents.off
				loop
					parent_name := a_class.parents.item
					-- If parent isn't here yet,
					-- process the parent first
					if not sorted_classes.has_key (parent_name) then
						a_parent := to_be_sorted.item_by_key (parent_name);
						if a_parent /= Void then
							handle_one_class (a_parent);
						else
							io.putstring ("*** Warning class:")
							io.putstring (parent_name)
							io.putstring (" not in file, but referenced in schema. %N")
							missing_parents := True
						end
					end
					a_class.parents.forth
				end
				sorted_classes.put_key (a_class, a_class.name);
			end
		end
	
	make is
		do
			!!sorted_classes.make (200);
		end

invariant

end -- CLASS_SORTER
