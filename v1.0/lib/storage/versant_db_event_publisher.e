-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class VERSANT_DB_EVENT_PUBLISHER

inherit 

	DB_EVENT_PUBLISHER

	DB_GLOBAL_INFO

creation

	make

feature

	make (db: DATABASE) is
		require
			db_valid: (db /= Void) and then (db.is_connected)
		do
			database := db
			is_enabled := True
		end


	publish_event (event: DB_EVENT) is
		local
			event_str: STRING
			err: INTEGER
		do
			if is_enabled then
				event_str := event.transaction.twin
				if (event.object /= Void) and then 
					(event.object.pobject_id /= 0) 
				 then
					event.reset_version
					event_str.extend ('/')
					event_str.append (event.object.external_object_id)
					event_str.extend ('/')
					event_str.append (event.version_number.out)
				end
				err := db_interface.send_event_to_daemon ($(database.name.to_c), 42,
														  0, default_pointer,
														  event_str.count, $(event_str.to_c))
				-- Check for 112 here, else blow up
				if err = db_interface.cannot_send_event then
					io.putstring ("**** Turning event notification off **%N")
					is_enabled := False
				else
					check_error
				end
			end
			
		end

	is_enabled: BOOLEAN

feature {NONE}

	database: DATABASE
			-- database to whose server events will be sent

end
