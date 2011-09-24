-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- A private database
--

class PRIVATE_DATABASE

inherit
	
	DATABASE
		rename
			connect as database_connect,
			disconnect as database_disconnect
		end
	
	DATABASE
		redefine
			connect, disconnect
		select
			connect, disconnect
		end
	
	SHARED_PRIVATE_DATABASE

creation
	
	make

feature
	
	connect is
			-- Connect to a private database, disconnect
			-- current private db if there
		do
			if current_private_db /= Void then
				current_private_db.disconnect
			end
			private_database.put (Current)
			database_connect
		ensure then
			set: current_private_db /= Void
		end
	
	
	disconnect is
		do
			private_database.put (Void)
			database_disconnect
		end

invariant
	
	consistent_state: is_connected implies (current_private_db = Current)

end -- PRIVATE_DATABASE
