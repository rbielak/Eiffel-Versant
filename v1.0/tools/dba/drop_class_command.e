-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DROP_CLASS_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	DROP_CLASS_ACTION
		undefine
			is_equal
		end
	
creation

	make

feature

	minimum_args_count : INTEGER is 1

	not_enough_args_msg : STRING is "class not specified"

	make (new_priority: INTEGER) is
		do
			help_text := "-dropclass <class name>%N"
			priority := new_priority
		end

	execute is
		do
			args.start
			set_class (args.item)
			action
		end

end  --class drop class command

