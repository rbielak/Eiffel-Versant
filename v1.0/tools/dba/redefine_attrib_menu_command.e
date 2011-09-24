-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class REDEFINE_ATTRIB_MENU_COMMAND

inherit

	REDEFINE_ATTRIB_ACTION
	CMD

feature

	execute is

		do
			!!att_info
			io.putstring ("-->Redefining attribute %N");
			io.putstring ("Enter class name: ");
			io.readline;
			cls_name := clone (io.laststring)
			if set_cls then
				io.putstring ("Enter old attribute name: ");
				io.readline;
				old_name := clone (io.laststring);
				io.putstring ("Enter info about new attribute %N")
				new_attr := att_info.get_one_attribute;
				action
			end
		end

end --class

