-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class AMBROSIA_DB_EVENT_PUBLISHER

inherit

	DB_EVENT_PUBLISHER

	EIF_PLUG_IN
	
	SHARED_EIF_COM_SERVER

creation

	make

feature 

	make is
		local
			sess: EIF_COM_SESSION
		do
			sess := shared_server.item.session_by_name ("DB_EVENTS")
			sess.add_plug_in (Current)
			is_enabled := True
			io.putstring ("AMBROSIA Publisher ready%N")
		end

feature -- from EIF_PLUG_IN

	plug_in_code: STRING is "DB_EVENT"

	process (command: STRING) is
			-- we don't expect to receive anything
		do
		end

feature -- from DB_EVENT_PUBLISHER

	is_enabled: BOOLEAN

	publish_event (event: DB_EVENT) is
		local
			event_str: STRING
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

				debug ("db_events")
					print ("Publishing with abmrosia:")
					print (event_str)
					print ("%N")
				end

				send_new_line (event_str)
			end
		rescue
			io.putstring ("*** Failed to send event - disabling %
                          %notification %N")
			if is_enabled then
				is_enabled := False
				retry
			end
		end

end
