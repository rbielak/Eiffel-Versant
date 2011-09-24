-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DEFINE_CLASS_ACTION

inherit

	DBA_TRANSACTION
	META_PCLASS_SERVER

feature
	
	last_class : META_PCLASS

	error_msg : STRING is "Can't define class";

	parents : LINKED_LIST [STRING]

	cls_name : STRING

	attributes: LINKED_LIST [PATTRIBUTE]

  

	sub_action is
		do
			cls_name.to_lower
			last_class := meta_pclass_by_name (cls_name)
			if  last_class /= Void then
				io.putstring ("Class already exists.%N")
			else
				!!last_class.make_new (cls_name, 
									   sess.current_database, parents, 
									   attributes);
				io.putstring ("Class --> ");
				cls_name.to_upper
				io.putstring (cls_name);
				io.putstring (" <-- defined. %N");
				-- database_was_modified.set_item (True);
			end
				
		end

end --class define

