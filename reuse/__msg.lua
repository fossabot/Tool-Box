_MESSAGES = {}

-- set
function _MESSAGES:INIT(NAME, DEFERRALS)

    DEFERRALS.defer()

    local tbl = {
        UPDATE = DEFERRALS.update,
        DONE = DEFERRALS.done,
        welcome = CONFIG.DEFER_STRINGS.TITLE,
        is_welcome_set = false,
        server = CONFIG.SERVER_NAME,
        client_name = NAME,
        processes = {
            messages = CONFIG.DEFER_STRINGS.PROCESSES,
            amount = #CONFIG.DEFER_STRINGS.PROCESSES,
            current = 0,
        },
        progress = {
            percentage = 0,
            per = 0,
            hash = 20,
            string = '',
        }
    }

    setmetatable(tbl, self)
    self.__index = self
    return tbl

end

-- function calculate the current progression
function _MESSAGES:PROGRESSION()

    self.processes.current = self.processes.current + 1
    self.progress.percentage = (100 / self.processes.amount) * self.processes.current

    local calc = math.ceil(self.progress.percentage / 5)
    self.progress.per = calc < 100 and calc or 100
    self.progress.hash = 20 - self.progress.per

end

-- function to create build the message
function _MESSAGES:BUILD()

    self.progress.string = ('[%s%s] '):format(
        string.rep('/', self.progress.per),
        string.rep('.', self.progress.hash)
    )..self.progress.percentage..'% '

    if not self.is_welcome_set then

        self.is_welcome_set = true

        self.welcome = self.welcome:format(
            self.client_name,
            self.server
        )..'\n'

    end

    return self.welcome..self.progress.string..self.processes.messages[self.processes.current]

end

-- function to update the the deferrals
function _MESSAGES:SEND()
    self:PROGRESSION()
    local msg = self:BUILD()
    self.UPDATE(msg)
end