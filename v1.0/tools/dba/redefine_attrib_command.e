-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class REDEFINE_ATTRIB_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	REDEFINE_ATTRIB_ACTION
		undefine
			is_equal
		end

creation

	make

feature

	minimum_args_count : INTEGER is 3

	not_enough_args_msg : STRING is "not enough args entered"

	make (new_priority : INTEGER) is
		do
			help_text := "-redefine <class name> <attribute name> <new type>%N"
			priority := new_priority
		end

	execute is
		do
			!!att_info
			args.start
			cls_name := args.item
			args.forth
			old_name := args.item
			args.forth
			new_attr := att_info.make_pattribute_obj (old_name,args.item)
			if set_cls then
				action
			end
		end

end --class


