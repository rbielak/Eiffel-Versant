-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Table of databases we are currently connected to
--

class ACTIVE_DB_TABLE
	
creation
	
	make

feature
	
	
	max_active_databases : INTEGER is 10;
			-- In Versant 3 this is the max number of DBs
			-- you can connect to at once
	
			
	add (db : DATABASE) is
		require
			db_connected: (db /= Void) and then db.is_connected;
			max_not_reached: count < max_active_databases
			not_yet_active: not has (db)
		do
			table.put_key (db, db.name)
			index_by_name_without_server.put (db, db.name_without_server)
		ensure
			count = old count + 1;
			has (db)
		end
	
	remove (db : DATABASE) is
		require
			db_ok: db /= Void and has (db)
		do
			table.remove_by_key (db.name)
			index_by_name_without_server.remove (db.name_without_server) 
		ensure
			count = old count - 1;
			not has(db)
		end
	
	count : INTEGER is
			-- Number of databases already active
		do
			Result := table.count
		end
	
	has (db : DATABASE) : BOOLEAN is
			-- True if the database is active
		require
			db_ok: db /= Void
		do
			Result := table.has_key (db.name);
		end;
	
	start is
			-- Start iteration
		do
			table.start;
		end
	
	item_by_key (key : STRING) : DATABASE is
			-- Find connected database by name 
		do
			Result := table.item_by_key (key)
			if Result = Void then
				Result := index_by_name_without_server.item (key)
			end
		end
	
	item : DATABASE is
			-- Item at current position during iteration
		do
			Result := table.item
		end
	
	forth is
			-- Move cursor to the next database
		do
			table.forth
		end
	
	off : BOOLEAN is
			-- True when we are at the end of iteration
		do
			Result := table.off
		end
	
	i_th (i : INTEGER) : DATABASE is
			-- I-th database in the list
		do
			Result := table.i_th(i)
		end


feature {NONE}
	
	table : INDEXED_LIST [DATABASE, STRING]
			-- table of active databases
	
	
	index_by_name_without_server: HASH_TABLE [DATABASE, STRING]
			-- index by partial name

	make is
		do
			!!table.make (max_active_databases)
			!!index_by_name_without_server.make (max_active_databases)
		end;

invariant
	
	count <= max_active_databases
	-- Only active databases are in the table

end -- ACTIVE_DB_TABLE
