-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NEW_ATTRIB_MENU_COMMAND

inherit

	CMD
	NEW_ATTRIB_ACTION

feature

	execute is
		local
			att_info : NEW_ATTR_INFO
		do
			!!att_info
			io.putstring ("---> Adding an attribute.%N");
			io.putstring ("Enter class name: ");
			io.readline;
			cls_name := clone (io.laststring)
			attributes := att_info.get_the_attributes
			action
		end

end -- class

