-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class RENAME_CLASS_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	RENAME_CLASS_ACTION
		undefine
			is_equal
		end

creation
	
	make

feature

	minimum_args_count : INTEGER is 2

	not_enough_args_msg : STRING is "not enough args entered"

	make (new_priority : INTEGER) is
		do
			help_text := "-renameclass <old name> <new name>%N"
			priority := new_priority
		end
			
	execute is
		local
			st: STRING
		do
			args.start
			st := args.item
			args.forth
			set_names (st, args.item)
			action
		end

end -- class