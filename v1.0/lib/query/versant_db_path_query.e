-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Class for querying the database using "o_pathselect"
-- Result is a simple VSTR

deferred class VERSANT_DB_PATH_QUERY

inherit

	VERSANT_EXTERNALS
	DB_GLOBAL_INFO
	MEMORY

feature

	execute is
			-- Execute the query
		require
			false
		deferred
		ensure
			(last_result /= Void) implies (last_result.integer_count > 0)
		end

	last_result: VSTR
			-- Result of the query

	database: DATABASE
			-- database to query - if Void query all
			-- active databases

	set_database (db : DATABASE) is
			-- if database is Void all databases will be queried
		require
			db_ok: (db /= Void) implies  db.is_connected
		do
			database := db
		end

	set_predicate_block (new_predicate: DB_QUERY_PREDICATE_BLOCK) is
		do
			predicate_block := new_predicate
		end

feature {NONE}

	predicate_block: DB_QUERY_PREDICATE_BLOCK
			-- structure representing the predicate tree

	predicate_block_ptr : POINTER
			-- C structure corresponding to the predicate structure

end -- VERSANT_DB_PATH_QUERY
