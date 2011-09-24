-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DEFINE_CLASS_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	DEFINE_CLASS_ACTION
		undefine
			is_equal
		end

creation

	make

feature

	minimum_args_count : INTEGER is 1

	not_enough_args_msg : STRING is "new class name not specified"

	make (new_priority: INTEGER) is
		do
			help_text := "-newclass <class name> [<parent name1> ..<parent name2>..] %N"
			priority := new_priority
		end

	execute is
		do
			attributes := void
			args.start
			cls_name := args.item
			!!parents.make
			args.forth
			from
			until 
				args.off
			loop
				parents.put_right (clone(args.item))
				args.forth
			end
			action
		end

end  --class