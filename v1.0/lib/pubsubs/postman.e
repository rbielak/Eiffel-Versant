-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class POSTMAN

creation {SHARED_POSTMAN}

	make

feature {SHARED_POSTMAN}

	make is
		do
			debug
				io.putstring ("POSTMAN.make%N")
			end
			!!pusubses.make
			!!last_pusubs.make_first
			!!new_pusubses.make (0, max_new_pusubs-1)
			new_pusubses_first := 0
			new_pusubses_last := max_new_pusubs-1
			!!cache_to_subscribe.make
			!!cache_to_unsubscribe.make
			publisher_on := true
		end

feature {PUBLISHER}

	publish (publisher: PUBLISHER; info: ANY) is
		require
			has_publisher: publisher /= void
		local
			pusubs: PUSUBS
		do
			debug
				io.putstring ("POSTMAN.publish (")
				io.putstring (publisher.generator)
				io.putstring (", ")
				if info = void then
					io.putstring ("void")
				else
					io.putstring (info.generator)
				end
				io.putstring (")%N")
			end
			if publisher_on then
				pusubs := find_pusubs (publisher)
				if pusubs /= void then
					pusubs.publish (info)
				end
				new_publish (publisher, info)
			end
		end

feature {PUBLISHER, SUBSCRIBER}

	unsubscribe (subscriber: SUBSCRIBER; publisher: PUBLISHER) is
		require
			has_subscriber: subscriber /= void
			has_publisher: publisher /= void
		local
			pusubs: PUSUBS
		do
			debug
				io.putstring ("POSTMAN.unsubscribe (")
				io.putstring (subscriber.generator)
				io.putstring (", ")
				io.putstring (publisher.generator)
				io.putstring (")%N")
			end
			pusubs := find_pusubs (publisher)
			if pusubs /= void then
				pusubs.remove_subscriber (subscriber)
			end
			new_unsubscribe (subscriber, publisher)
		end

	subscribe (subscriber: SUBSCRIBER; publisher: PUBLISHER) is
		require
			has_subscriber: subscriber /= void
			has_publisher: publisher /= void
		local
			new_pusubs: NON_COMPARABLE_COUPLE [SUBSCRIBER, PUBLISHER]
		do
			debug
				io.putstring ("POSTMAN.subscribe (")
				io.putstring (subscriber.generator)
				io.putstring (", ")
				io.putstring (publisher.generator)
				io.putstring (")%N")
			end
			if bufferize and then (nb_new_pusubses < max_new_pusubs-1) then
				new_subscribe (subscriber, publisher)
			else
				definite_subscribe (subscriber, publisher)
			end
		end

feature

	bufferize: BOOLEAN
			-- If `true', then subscribe won't register new objects immediatly
			-- but put them in `new_pusubses'.
			-- Items `new_pusubses' will be definitly registered later by
			-- `clean_one_by_one'.
			-- If `true', then an empty `PUSUBS' won't be unregistered from `pusubses'
			-- immediatly.
			-- `clean_one_by_one' will look for empty `PUSUBS' later.
	
	set_bufferize (new_value: like bufferize) is
			-- Change `bufferize'.
		do
			if bufferize and not new_value then
				from
					clean_one_by_one
				until
					not have_cleaned
				loop
					clean_one_by_one
				end
			end
			bufferize := new_value
		end

feature {NONE}

	find_pusubs (p: PUBLISHER): PUSUBS is
		do
			if p = last_pusubs.publisher then
				Result := last_pusubs
			elseif pusubses.count > 0 then
				from
					pusubses.start
				until
					pusubses.after or (Result /= void)
				loop
					if pusubses.item.publisher = p then
						Result := pusubses.item
						last_pusubs := Result
					end
					pusubses.forth
				end
			end
			debug
				io.putstring ("POSTMAN.find_pusubs (...) = ")
				if Result = void then
					io.putstring ("void")
				else
					io.putstring (Result.generator)
				end
				io.putstring (")%N")
			end
		end

	pusubses: FAST_LIST [PUSUBS]

	last_pusubs: PUSUBS
	
feature {PUSUBS}
	
	remove_pusubs (pusubs: PUSUBS) is
		do
			pusubses.start
			pusubses.search (pusubs)
			if not pusubses.after then
				pusubses.remove
			end			
		end

feature

	pusubses_item (i: INTEGER): PUSUBS is
		do
			Result := pusubses.i_th (i)
		end

	nb_pusubses: INTEGER is
		do
			Result := pusubses.count
		end

	nb_new_pusubses: INTEGER is
		do
			Result := 1+new_pusubses_last-new_pusubses_first
			if Result >= 0 then
				Result := Result \\ max_new_pusubs
			else
				Result := max_new_pusubs - ( (-Result) \\ max_new_pusubs)
				if Result = max_new_pusubs then
					Result := 0
				end
			end
		end

feature {NONE}

	definite_subscribe (subscriber: SUBSCRIBER; publisher: PUBLISHER) is
		require
			has_subscriber: subscriber /= void
			has_publisher: publisher /= void
		local
			pusubs: PUSUBS
		do
			pusubs := find_pusubs (publisher)
			if pusubs = void then
				!!pusubs.make (publisher)
				pusubses.extend (pusubs)
			end
			pusubs.add_subscriber (subscriber)
		end

feature {NONE}

	new_pusubses: ARRAY [NON_COMPARABLE_COUPLE [SUBSCRIBER, PUBLISHER]]

	new_pusubses_first, new_pusubses_last: INTEGER

	cache_to_subscribe, cache_to_unsubscribe: FAST_LIST [NON_COMPARABLE_COUPLE [SUBSCRIBER, PUBLISHER]]

	max_new_pusubs: INTEGER is 500

	new_subscribe (subscriber: SUBSCRIBER; publisher: PUBLISHER) is
		require
			has_subscriber: subscriber /= void
			has_publisher: publisher /= void
		local
			new_pusubs: NON_COMPARABLE_COUPLE [SUBSCRIBER, PUBLISHER]
		do
			debug
				io.putstring ("POSTMAN.new_subscribe (..., ...)%N")
			end
			!!new_pusubs.make (subscriber, publisher)
			if new_publishing > 0 then
				--io.putstring ("WARNING: subscribing during publish / ")
				--io.putstring (subscriber.generator)
				--io.putstring (" subscribe to ")
				--io.putstring (publisher.generator)
				--io.new_line
				cache_to_subscribe.extend (new_pusubs)
			else
				new_pusubses_last := (new_pusubses_last+1) \\ max_new_pusubs
				new_pusubses.put (new_pusubs, new_pusubses_last)
			end
		end

	new_unsubscribe (subscriber: SUBSCRIBER; publisher: PUBLISHER) is
		require
			has_subscriber: subscriber /= void
			has_publisher: publisher /= void
		local
			i, last_i: INTEGER
			new_pusubs: NON_COMPARABLE_COUPLE [SUBSCRIBER, PUBLISHER]
		do
			if new_publishing > 0 then
				--io.putstring ("WARNING: subscribing during publish / ")
				--io.putstring (subscriber.generator)
				--io.putstring (" subscribe to ")
				--io.putstring (publisher.generator)
				--io.new_line
				!!new_pusubs.make (subscriber, publisher)
				cache_to_unsubscribe.extend (new_pusubs)
			else
				from
					i := new_pusubses_first
					last_i := (new_pusubses_last+1) \\ max_new_pusubs
				until
					(i = last_i) or else ((new_pusubses.item (i) /= void) and then ((new_pusubses.item (i).first = subscriber) and (new_pusubses.item (i).second = publisher)))
				loop
					i := (i+1) \\ max_new_pusubs
				end
				if i /= last_i then
					new_pusubses.put (void, i)
				end
			end
		end

	new_publish (publisher: PUBLISHER; info: ANY) is
		local
			i, last_i: INTEGER
		do
			new_publishing := new_publishing+1
			from
				i := new_pusubses_first
				last_i := (new_pusubses_last+1) \\ max_new_pusubs
			until
				i = last_i
			loop
				if new_pusubses.item (i) /= void then
					if new_pusubses.item (i).second = publisher then
						new_pusubses.item (i).first.update_subscriber (publisher, info)
					end
				end
				i := (i+1) \\ max_new_pusubs
			end
			new_publishing := new_publishing-1
			if new_publishing = 0 then
				clean_cache
			end
		end

	new_publishing: INTEGER

	clean_cache is
		do
			if cache_to_subscribe.count > 0 then
				from
					cache_to_subscribe.start
				until
					cache_to_subscribe.off
				loop
					new_subscribe (cache_to_subscribe.item.first, cache_to_subscribe.item.second)
					cache_to_subscribe.forth
				end
				cache_to_subscribe.wipe_out
			end
			if cache_to_unsubscribe.count > 0 then
				from
					cache_to_unsubscribe.start
				until
					cache_to_unsubscribe.off
				loop
					new_unsubscribe (cache_to_unsubscribe.item.first, cache_to_unsubscribe.item.second)
					cache_to_unsubscribe.forth
				end
				cache_to_unsubscribe.wipe_out
			end
		end

feature

	have_cleaned: BOOLEAN

	clean_one_by_one is
		local
			stop: BOOLEAN
		do
			if nb_new_pusubses >= 1 then
				if new_pusubses.item (new_pusubses_first) /= void then
					definite_subscribe (new_pusubses.item (new_pusubses_first).first, new_pusubses.item (new_pusubses_first).second)
					new_pusubses.put (void, new_pusubses_first)
				end
				if new_publishing > 0 then
					io.putstring ("WARNING: panic in POSTMAN (see Gurvan)%N")
				end
				new_pusubses_first := (1+new_pusubses_first) \\ max_new_pusubs
				have_cleaned := true
			elseif pusubses.count > 0 then
				from
					pusubses.start
				until
					pusubses.off or stop
				loop
					if pusubses.item.count = 0 then
						pusubses.remove
						stop := true
					else
						pusubses.forth
					end
				end
				have_cleaned := stop
			else
				have_cleaned := false
			end
		end

feature

	publisher_on: BOOLEAN

	set_publisher_on_off (on: BOOLEAN) is
		do
			debug
				io.putstring ("POSTMAN.set_publisher_on_off (")
				io.putbool (on)
				io.putstring (")%N")
			end
			publisher_on := on
		end

end
