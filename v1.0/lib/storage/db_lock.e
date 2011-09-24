-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- DB_LOCK - class to manage locks on POBJECTs
--

class DB_LOCK [T -> POBJECT]

inherit
	
	DB_GLOBAL_INFO

creation
	
	make

feature
	
	
	object : T
			-- Object being locked
	
	write_lock is
			-- Get a write lock (Noop, if we have write
			-- lock already)
		require
			object_persistent: object.pobject_id /= 0;
		do
			if not has_write_lock then
				db_interface.lock_object (object.pobject_id, 
							  db_interface.db_write_lock);
				if not has_read_lock then
					-- Add this lock to a global structure
					-- of locks that have to be reset at commit
					db_interface.locks.put (Current) 
				end
				has_write_lock := True;
				-- Refresh the object from db cache
				refresh_eiffel_object
			end
		ensure
			has_write_lock
		end
	
	has_write_lock : BOOLEAN 
			-- We have a write lock
	
	read_lock is
			-- Get a read lock (no-op if we have read lock already)
		require
			not_write_locked: not has_write_lock
		do
			if not has_read_lock then
				db_interface.lock_object (object.pobject_id, 
							  db_interface.db_read_lock);
				db_interface.locks.put (Current)
				has_read_lock := True;
				-- Refresh the object from db cache
				refresh_eiffel_object
			end
		ensure
			has_read_lock
		end
	
	has_read_lock : BOOLEAN
			-- We have a read lock
	
feature {DB_INTERFACE_INFO}
	
	reset_lock_flags is
			-- Reset flags after after commit
		do
			has_read_lock := False;
			has_write_lock := False;
		end
	
	refresh_eiffel_object is
			-- Routine to refresh Eiffel attributes from
			-- database cache after locking
		do
			object.refresh
		end

feature {NONE}	
	
	
	make (my_object : T) is
		require
			my_object /= Void
		do
			object := my_object
		end

end -- DB_LOCK
