-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RENAME_ATTRIB_MENU_COMMAND

inherit

	RENAME_ATTRIB_ACTION
	CMD

feature

	execute is
		do
			io.putstring ("-->Renaming attribute %N");
			io.putstring ("Enter class name: ");
			io.readline;
			cls_name := clone (io.laststring)
			if set_cls then
				io.putstring ("Enter old attribute name: ");
				io.readline;
				old_name := clone (io.laststring);
				io.putstring ("Enter new attribute name: ");
				io.readline;
				new_name := clone (io.laststring);
				action
			end
		end

end --class
