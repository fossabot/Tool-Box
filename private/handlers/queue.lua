local a = 1000

SetTimeout(50, function()
    a = a + 1000
end)

print(a)
