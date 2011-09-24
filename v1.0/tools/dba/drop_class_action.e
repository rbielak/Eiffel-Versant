-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DROP_CLASS_ACTION

inherit
	
	DBA_TRANSACTION
	META_PCLASS_SERVER

feature

	error_msg: STRING is "Can't drop class";

	cls: META_PCLASS
	cls_name: STRING

	set_class (new_class:STRING) is
		do
			cls_name := new_class
			cls := meta_pclass_by_name (new_class)
		end

	sub_action is
		do
			if cls = Void then
				io.putstring ("No such class in database.%N");
			else
				cls.remove;
--				database_was_modified.set_item (True);
				io.putstring ("Class> ")
				io.putstring (cls_name)
				io.putstring (" was removed.%N")
			end;
		end

end

