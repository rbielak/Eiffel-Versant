-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class SUBSCRIBER

inherit

	SHARED_POSTMAN

feature

	unsubscribe (publisher: PUBLISHER) is
		require
			has_publisher: publisher /= void
		do
			publisher.remove_subscriber (Current)
		end

	subscribe (publisher: PUBLISHER) is
		require
			has_publisher: publisher /= void
		do
			publisher.add_subscriber (Current)
		end

feature {POSTMAN, PUSUBS}

	update_subscriber (publisher: PUBLISHER; info: ANY) is
		require
			has_publisher: publisher /= void
		deferred
		end

end
