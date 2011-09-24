-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DISPLAY_INSTANCE_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	DISPLAY_INSTANCE_ACTION
		undefine
			is_equal
		end
	
creation
	
	make

feature

	minimum_args_count : INTEGER is 1

	not_enough_args_msg : STRING is "no loid specified"

	make (new_priority: INTEGER) is
		do
			help_text := "-L <Loid>%N"
			priority := new_priority
		end

	execute is
		do
			args.start
			io.putstring("Retrieving object : ")
			io.putstring(args.item)
			io.new_line
			--
			set_id (args.item)
		    action
		end

end
