DT = {}

function DT:GENERATE_ID(LENGTH)
	if LENGTH <= 0 then return '' end
	local rand = math.random(0, 1)
	local retval = nil
	if rand == 1 then
		retval = string.char(math.random(48, 57))
	else
		local i = math.random(64, 90)
		retval = string.char((i == 64 and math.random(97, 122) or i)):upper()
	end
	return DT:GENERATE_ID(LENGTH - 1) .. retval
end

function DT:STRING_SPLIT(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
	while delim_from do
		result[#result+1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
	result[#result+1] = string.sub(str, from)
	return result
end