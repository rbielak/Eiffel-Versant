-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class TAGABLE

feature

	same (other: like Current): BOOLEAN is
		require
			has_other: other /= void
		do
			Result := other.tag.is_equal (tag)
		ensure
			trivial_case: (other = Current) implies Result
		end

	tag: STRING is
		deferred
		ensure
			has_tag: Result /= void
		end

end
