-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Received database events are store in the event queue
--
class DB_EVENT_QUEUE

inherit

	FAST_RLIST [DB_EVENT]
		rename
			extend as fast_rlist_extend
		redefine
			generator
		end

	FAST_RLIST [DB_EVENT]
		redefine
			extend, generator
		select 
			extend
		end

creation

	make

feature

	generator: STRING is "DB_EVENT_QUEUE"

	extend (ev: DB_EVENT) is
			-- Add event to the queue (if the affected object is in memory)
		do
			debug ("db_events")
				io.putstring ("db_event_queue - attempting to add an event %N")
			end
			if (ev.object /= Void) and then
				ev.version_number > ev.object.pobject_version
			 then
				-- If the object is present in this process and the 
				-- version of the published object is larger then add 
				-- to the event queue. Otherwise the event doesn't matter
				fast_rlist_extend (ev)
				-- mark the object as old
				ev.object.mark_modified
				debug ("db_events")
					io.putstring ("db_event_queue - event added %N")
				end
			end
			debug ("db_events")
				io.putstring ("db_event_queue.count=")
				io.putint (count)
				io.new_line
			end
		ensure then
			((ev.object /= Void) and 
			 then (ev.object.pobject_version < ev.version_number)) implies (has (ev))
		end


	refresh_and_wipe_out is
			-- Go through the list and refresh each object, then wipe 
			-- out the list
		local
			object_table: HASH_TABLE [INTEGER, INTEGER]
		do
			!!object_table.make (101)
			from start
			until off
			loop
				-- Only refresh if the version of the updated object 
				-- is more than version that we have. In case the 
				-- version numbers wrap around, we'll do an extra refresh
				if item.object.pobject_version < item.version_number then
					if not object_table.has (item.object.pobject_id) then
						item.object.refresh
						-- place objects in a table, so that we don't 
						-- refresh more than once
						object_table.put (0, item.object.pobject_id)
						debug ("db_events")
							io.putstring ("Refreshing object: ")
							io.putint (item.object.pobject_id)
							io.new_line
						end
					end
				end
				forth
			end
			wipe_out
			publish (Void)
		end

end -- DB_EVENT_QUEUE
