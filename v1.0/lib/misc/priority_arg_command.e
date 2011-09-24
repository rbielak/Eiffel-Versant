-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class PRIORITY_ARG_COMMAND

inherit

	ARGUMENT_COMMAND
		redefine
			is_equal
		end

	COMPARABLE
		undefine
			is_equal
		end

feature

	validate is
		do
		end

	priority: INTEGER
			-- priority of this command, lower priority
			-- gets executed first

	infix "<" (other: like Current): BOOLEAN is
		do
			Result := priority < other.priority
		end

	is_equal (other: like Current): BOOLEAN is
		do
			Result := priority = other.priority
		end

end
