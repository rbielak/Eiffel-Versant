-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SHARED_INTERNAL_INFOS

inherit

	INTERNAL

feature

	class_of (current_object: ANY): HASH_TABLE [INTEGER, STRING] is
		require
			has_object: current_object /= void
		local
			cur_obj_generator: STRING
			attr_count, attr_index: INTEGER
		do
			cur_obj_generator := current_object.generator
			Result := classes.item (cur_obj_generator)
			if Result = void then
				attr_count := field_count (current_object)
				!!Result.make (attr_count)
				from
					attr_index := 1
				until
					attr_index > attr_count
				loop
					Result.put (attr_index, field_name (attr_index, current_object))
					attr_index := attr_index+1
				end
				classes.put (Result, cur_obj_generator)
			end
		end

	attribute_index_of (current_object: ANY; attribute_name: STRING): INTEGER is
		require
			has_object: current_object /= void
			has_attribute: attribute_name /= void
		do
			Result := class_of (current_object).item (attribute_name)
		end

	classes: HASH_TABLE [HASH_TABLE [INTEGER, STRING], STRING] is
			-- Attributes indexes
			-- Retrive with `classes.item (class_name).item (attribute_name)'.
		once
			!!Result.make (100)
		end

end -- class ID_I
