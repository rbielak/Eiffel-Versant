-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DROP_ATTRIB_MENU_COMMAND

inherit

	DROP_ATTRIB_ACTION
	CMD

feature

	execute is
		do
			io.putstring ("---> Dropping an attribute. %N")
			io.putstring ("Enter class name: ")
			io.readline
			cls_name := clone (io.laststring)
			io.putstring ("Enter attribute to drop: ")
			io.readline
			attr_name := clone (io.laststring)
			action
		end

end --class

