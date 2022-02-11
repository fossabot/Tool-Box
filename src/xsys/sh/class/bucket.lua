function NewBucket(name)
    return setmetatable({
        name = name,
        bucket = {},
    },{
        __index = function(self, key)
            if self.bucket[key] == nil then
                print('BUCKET:INFO | tried fetching non-existent data from the '..self.name..' bucket')
            else
                print('BUCKET:INFO | fetched data from the '..self.name..' bucket')
                return self.bucket[key]
            end
        end,
        __newindex = function(self, key, value)
            if self.bucket[key] == nil then
                print('BUCKET:INFO | someone added something to the '..self.name..' bucket (key: '..key..', key: '..value..')')
            else
                print('BUCKET:INFO | someone changed somethin in the '..self.name..' bucket (key: '..key..', key: '..value..')')
            end
        end,
        __call = function(self, data)
            if (self.bucket[data.temp] and self.bucket[data.src]) == nil then
                self.bucket[data.temp] = data
            elseif self.pool[data.temp] ~= nil and self.bucket[data.src] == nil then
                self.bucket[data.temp] = nil
                self.bucket[data.src] = data
            elseif (self.bucket[data.temp] and self.bucket[data.src]) ~= nil then
                self.bucket[data.src] = data
            else
                print('BUCKET:ERROR | something went wrong while adding data to the '..self.name..' bucket')
            end
        end,
        __len = FullTableLength,
        __tostring = ToStringDebugger,
        __metatable = nil
    })
end