-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Defines schema in a database
--

class SCHEMA_BUILDER

creation
	
	make

feature
	
	session : DB_SESSION is
		once
			!!Result
		end
	
	db_name : STRING;
			-- database name
	
	start_session is
		do
			session.begin (db_name)
			session.start_transaction
			io.putstring ("---> Connecting to database: ");
			io.putstring (db_name);
			io.new_line;
		end
	
	end_session is
		do
			io.putstring ("Commting all changes...%N");
			session.end_transaction
			session.finish
			io.putstring ("---> Done...%N");
		end

	
	build_partial_schema (classes : INDEXED_LIST [SCHEMA_CLASS, STRING]) is
			-- Here some classes are already defined in the DB
		require
			session.active
		do
			define_classes (classes);
			add_attributes (classes)
			do_renames (classes)
		rescue
			if session.active then
				io.putstring ("** Crashed...%N");
				io.putstring ("** Last error=");
				io.putint (session.last_error);
				io.new_line;
				session.abort_transaction
				session.finish
			end
		end
	

	build_full_schema (classes : INDEXED_LIST [SCHEMA_CLASS, STRING]) is
		require
			(classes /= Void) and then (classes.count > 0)
			session.active
		local
			first_class: INDEXED_LIST [SCHEMA_CLASS, STRING]
			first: SCHEMA_CLASS
		do
			-- Hack to work around a Versant bug
			-- Define the first class completely
			!!first_class.make (3)
			classes.start
			first := classes.item
			classes.remove_by_key (first.name)
			first_class.put_key (first, first.name)
			define_classes (first_class)
			add_attributes (first_class)
			-- Now do the rest
			build_partial_schema (classes)
		rescue
			if session.active then
				io.putstring ("** Crashed...%N");
				io.putstring ("** Last error=");
				io.putint (session.last_error);
				io.new_line;
				session.abort_transaction
				session.finish
			end
		end

	define_classes (classes : INDEXED_LIST [SCHEMA_CLASS, STRING]) is
		local
			new_class_it : DEFINE_CLASS_IT;
		do
			!!new_class_it.make (session);
			new_class_it.set (classes);
			new_class_it.do_all;
		end
	
	add_attributes (classes : INDEXED_LIST [SCHEMA_CLASS, STRING]) is
		local
			add_attr_it : ADD_ATTR_IT
		do
			!!add_attr_it.make (session);
			add_attr_it.set (classes);
			add_attr_it.do_all;
		end
	
	do_renames (classes : INDEXED_LIST [SCHEMA_CLASS, STRING]) is
		local
			rename_it : RENAME_IT
		do
			!!rename_it.make (session);
			rename_it.set (classes);
			rename_it.do_all
		end
	

feature {NONE}
	
	make (new_db_name : STRING) is
		require
			new_db_name /= Void
		do
			db_name := new_db_name
		end

end -- SCHEMA_BUILDER
