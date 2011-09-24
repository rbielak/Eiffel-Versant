-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DROP_ATTRIB_COMMAND

inherit

	DROP_ATTRIB_ACTION
		undefine
			is_equal
		end
	ARGUMENT_CHECKER_CMD

creation

	make

feature

	minimum_args_count : INTEGER is 2

	not_enough_args_msg : STRING is "Not enough args entered"

	make (new_priority: INTEGER) is
		do
			help_text := "-dropattr <class name> <attr name>%N"
			priority:= new_priority
		end

	execute is
		do 
			args.start
			cls_name := args.item
			args.forth
			attr_name := args.item
			action
		end

end  --class


