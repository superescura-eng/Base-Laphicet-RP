Locale = {}
Locale.__index = Locale

function Locale:new(name, data)
    local self = setmetatable({}, Locale)

    if type(name) == "table" then
        local config = name
        self.name = config.name or "Unknown"
        self.phrases = config.phrases or {}
        self.warnOnMissing = config.warnOnMissing or false
    else
        self.name = name
        self.phrases = data
        self.warnOnMissing = false
    end

    return self
end

function Locale:extend(name, data)
    for k, v in pairs(data) do
        self.phrases[k] = v
    end
end

function Locale:t(key, subs)
    local phrase = self.phrases[key]
    if not phrase then
        return "Locale [" .. self.name .. "] Key [" .. key .. "] does not exist"
    end

    if subs then
        for k, v in pairs(subs) do
            phrase = phrase:gsub("%%{" .. k .. "}", tostring(v))
        end
    end

    return phrase
end

function Locale:has(key)
    return self.phrases[key] ~= nil
end

function Locale:delete(key)
    self.phrases[key] = nil
end
