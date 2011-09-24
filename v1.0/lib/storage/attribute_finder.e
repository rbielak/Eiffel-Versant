-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class ATTRIBUTE_FINDER

inherit
	
	ATTRIBUTE_EXTRACTOR

feature

	attribute_values (pobject_id: INTEGER; attribute_names: ARRAY[STRING]) is
		require
			is_persistent: pobject_id /= 0
			attr_names_ok: attribute_names /= Void and attribute_names.count > 0
		local
			pclass: PCLASS
		do
			pclass := db_interface.find_class_for_object (pobject_id)

			if (last_tuple = Void) or else (attribute_names.count /= last_tuple.count) then
				!!last_tuple.make (1, attribute_names.count)
			end

			-- Create array of paths
			build_paths (attribute_names)

			-- Create field extractors
			build_extractors (pclass.name, attribute_names)

			-- Create the output tuple
			extract_values (pobject_id)
		ensure
			last_tuple.count = attribute_names.count
		end

end -- ATTRIBUTE_FINDER
