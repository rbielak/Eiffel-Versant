-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class MIGRATE_COMMAND

inherit

	ARGUMENT_CHECKER_CMD
	MIGRATE_ACTION
		undefine
			is_equal
		end

creation

	make

feature

	minimum_args_count : INTEGER is 2

	not_enough_args_msg : STRING is "not enough args entered"

	make (new_priority: INTEGER) is
		do
			help_text := "-migrate <Loid> <destination dbase>%N"
			priority := new_priority
		end

	execute is
		local
			the_id : STRING
			b: BOOLEAN
			f_db, t_db: STRING
			dbase: DATABASE
		do
			args.start
			the_id := args.item
			args.forth
			t_db := args.item
			f_db := sess.current_database.name
			!!dbase.make (t_db)
			dbase.connect
			sess.set_current_database (dbase)
			set_the_info (f_db,t_db,the_id,b)
			action
		end

end --class 

