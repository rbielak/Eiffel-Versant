-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class SAFE_EXCEPTIONS

inherit

	EXCEPTIONS

feature

	safe_class_name: STRING is
		local
			retried: BOOLEAN
		do
retried := true
			if not retried then
				Result := class_name
			else
				Result := "???"
			end
		rescue
			retried := true
			retry
		end

	safe_recipient_name: STRING is
		local
			retried: BOOLEAN
		do
retried := true
			if not retried then
				--Result := recipient_name
				Result := "???"
			else
				Result := "???"
			end
		rescue
			retried := true
			retry
		end

	safe_meaning: STRING is
		local
			retried: BOOLEAN
		do
retried := true
			if not retried then
				Result := meaning (exception)
			else
				Result := "???"
			end
		rescue
			retried := true
			retry
		end

	safe_tag_name: STRING is
		local
			retried: BOOLEAN
		do
retried := true
			if not retried then
				--Result := tag_name
				Result := "???"
			else
				Result := "???"
			end
		rescue
			retried := true
			retry
		end

	safe_developer_exception_name: STRING is
		local
			retried: BOOLEAN
		do
retried := true
			if not retried then
				Result := developer_exception_name
			else
				Result := "???"
			end
		rescue
			retried := true
			retry
		end

end
