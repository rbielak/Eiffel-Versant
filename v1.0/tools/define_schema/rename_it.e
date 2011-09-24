-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class RENAME_IT

inherit
	
	LINEAR_ITERATOR [SCHEMA_CLASS]
		redefine
			item_action
		end
	
	META_PCLASS_SERVER
	
creation
	
	make

feature
	
	session : DB_SESSION

	current_class : META_PCLASS;

	item_action (a_class : SCHEMA_CLASS) is
		local
			rename_desc : SCHEMA_RENAME
		do
			current_class := meta_pclass_by_name (a_class.name)
			-- current_class.retrieve_class
			if a_class.renames.count > 0 then
				io.putstring ("Renaming in class: ");
				io.putstring (a_class.name);
				io.new_line;
			end
			from a_class.renames.start
			until a_class.renames.off
			loop
				rename_desc := a_class.renames.item
				current_class.rename_attribute (rename_desc.old_name, rename_desc.new_name)
				a_class.renames.forth;
			end
		end
	
feature {NONE}
	
	make (new_sess : DB_SESSION) is
		do
			session := new_sess
		end

end -- RENAME_IT
