Clients = {
    {
        name = "Users",
        event = "userdata",
        dataset = {}
    },
    {
        name = "Characters",
        event = "chardata",
        dataset = {}
    }
}

for i = 1, #Clients, 1 do

    Clients[i].dataset = NewBucket(Clients[i].name)

end

RegisterNetEvent('xsys:bucket:data', function(bucket, data)

    for i = 1, #Clients, 1 do

        local current = Clients[i]

        if current.name:lower() == bucket:lower() then

            Clients[i].dataset(data)

        end

    end

end)