-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class NEW_ATTRIB_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	NEW_ATTRIB_ACTION
		undefine
			is_equal
		end

creation

	make

feature

	minimum_args_count : INTEGER is 3
	
	not_enough_args_msg : STRING is "not enough args entered" 

	attr_info : NEW_ATTR_INFO

	make (new_priority : INTEGER) is
		do
			help_text := "-newattr  <class name> <attribute name> <type>%N"
			priority:= new_priority
		end

	execute is
		local 
			pattr : PATTRIBUTE
			attr_name : STRING
		do
			!!attr_info
			args.start
			cls_name := args.item
			args.forth
			attr_name := args.item
			args.forth
			pattr := attr_info.make_pattribute_obj (attr_name, args.item)
			!!attributes.make
			attributes.put_right (pattr)
			action 		    			
		end

end --class