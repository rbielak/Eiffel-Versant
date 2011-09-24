-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- 
--

class DEFINE_CLASS_IT

inherit
	
	LINEAR_ITERATOR [SCHEMA_CLASS]
		redefine
			item_action
		end
	
creation
	
	make

feature
	
	current_class : META_PCLASS;
			-- current class we're working on
	
	session : DB_SESSION;

	item_action (a_class : SCHEMA_CLASS) is
		do
			io.putstring ("Defining class: ");
			io.putstring (a_class.name);
			io.new_line;
			!!current_class.make_new (a_class.name, session.default_db,
						  a_class.parents, Void);
--			if not current_class.exists then
--				current_class.define_class (a_class.parents, Void);
--			else
--				except.raise ("Class already exists");
--			end
		end
	
feature {NONE}
	
	except : expanded EXCEPTIONS;
	
	make (new_session : DB_SESSION) is
		require
			new_session /= Void
		do
			session := new_session
		end


invariant

end -- DEFINE_CLASS_IT
