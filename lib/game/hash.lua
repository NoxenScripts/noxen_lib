local hashTable <const> = {};

---@param value string | number
---@return number
return function(value)
    if (hashTable[value]) then
        return hashTable[value];
    end
    if (type(value) == 'string') then
        hashTable[value] = joaat(value);
    end
    if (type(value) == 'number') then
        return value;
    end

    return hashTable[value] and hashTable[value] or -1;
end
