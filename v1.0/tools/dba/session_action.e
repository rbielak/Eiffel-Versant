-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SESSION_ACTION

inherit

	DBA_ACTION

feature


	error_msg: STRING is "Cannot start session%NYou must start your session (#1) before any other action%N"

	sub_action is
		do
			sess.begin (db_name)
--			sess.start_transaction
		end

	db_name: STRING 

	set_db_name (new_db: STRING) is
		require
			new_db /= Void
		do
			db_name := new_db
		end

end

