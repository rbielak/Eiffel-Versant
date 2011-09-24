-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "Descendant of MANAGEABLE with automatic name and tag";
	date: "$Date: $";
	revision: "$Revision: $"

deferred class NAMED_MANAGEABLE

inherit

	MANAGEABLE

feature

	name: STRING
			-- Name of object

	set_name (new_name: STRING) is
			-- Change object name.
			-- Warning: the string is shared.
		require
			has_name: new_name /= void
		do
			name := new_name
		ensure
			name_changed: name = new_name
		end

	tag: STRING is
			-- from MANAGEABLE
		do
			if name = void then
				Result := default_tag
			else
				Result := name
			end
		end

	default_tag: STRING is "<no tag>"

end
