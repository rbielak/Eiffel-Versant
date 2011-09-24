-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class MARKED


feature


	mark: ANY

	set_mark (new_mark: ANY) is
			-- mark this object with a custom "mark" object
		do
			mark := new_mark
		end

end
