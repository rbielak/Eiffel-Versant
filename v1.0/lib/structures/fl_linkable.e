-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class	FL_LINKABLE [G] inherit

	BI_LINKABLE [G]
		export {ANY}
			put_right, put_left, forget_right, forget_left,
			simple_put_right, simple_put_left,
			simple_forget_right, simple_forget_left,
			put
		end

end -- class Fl_LINKABLE
