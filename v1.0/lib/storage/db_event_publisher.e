-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "This class is a template for objects that can send %
                 %out database events";
    date: "1/20/98"

deferred class DB_EVENT_PUBLISHER

feature {DB_INTERFACE_INFO}

	publish_event (event: DB_EVENT) is
		require
			event_valid: event /= Void
		deferred
		end

feature

	is_enabled: BOOLEAN is
		deferred
		end

end
