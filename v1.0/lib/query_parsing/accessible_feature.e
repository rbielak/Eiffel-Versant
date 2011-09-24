-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class ACCESSIBLE_FEATURE

inherit

   SHARED_BYTE_CODE_AS
      undefine
         out
      end

feature

	attribute_name: STRING is
		deferred
		end

	is_subscripted: BOOLEAN is
		deferred
		end

	subscript: INTEGER is
		deferred
		end

	is_dynamic_subscript: BOOLEAN is
		deferred
		end

	build_feature_access: FEATURE_ACCESS is
		do
			if is_subscripted then
				!!Result.make_subscripted_attribute (attribute_name, subscript,
							is_dynamic_subscript)
			else
				!!Result.make_simple_attribute (attribute_name)
			end
		end

end -- ACCESSIBLE_FEATURE
