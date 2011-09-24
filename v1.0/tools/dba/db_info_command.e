-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DB_INFO_COMMAND

inherit
	
	PRIORITY_ARG_COMMAND
	DB_INFO_ACTION
		undefine
			is_equal
		end

creation

	make

feature

	make (new_priority: INTEGER) is
		do
			help_text := "-free : db free space%N"
			priority := new_priority
		end

	execute is
		do
			action
		end

end


	

	