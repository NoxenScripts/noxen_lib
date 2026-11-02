Mappers = {}

---@param job table
---@return NoxenJob
function Mappers.esxJob(job)
    return {
        name = job.name,
        label = job.label,
        grade = job.grade,
        gradeName = job.grade_name,
        gradeLabel = job.grade_label,
        salary = job.grade_salary,
        onDuty = job.onDuty ~= false,
        isBoss = job.grade_name == 'boss',
        type = job.type,
    }
end

---@param job table
---@return NoxenJob
function Mappers.qbJob(job)
    local grade = job.grade or {}

    return {
        name = job.name,
        label = job.label,
        grade = grade.level or 0,
        gradeName = grade.name or '',
        gradeLabel = grade.name or '',
        salary = job.payment or grade.payment or 0,
        onDuty = job.onduty == true,
        isBoss = job.isboss == true or grade.isboss == true,
        type = job.type,
    }
end

---@param gang? table
---@return NoxenGang?
function Mappers.qbGang(gang)
    if not gang then
        return nil
    end

    local grade = gang.grade or {}

    return {
        name = gang.name,
        label = gang.label,
        grade = grade.level or 0,
        gradeName = grade.name or '',
        isBoss = gang.isboss == true or grade.isboss == true,
    }
end

---@param accounts table[]
---@return table<string, number>
function Mappers.esxMoney(accounts)
    local balances = {}

    for neutral, native in pairs(Config.Accounts.esx) do
        for _, account in pairs(accounts) do
            if account.name == native then
                balances[neutral] = account.money
            end
        end
    end

    return balances
end

---@param framework 'qb'|'qbx'
---@param money table<string, number>
---@return table<string, number>
function Mappers.qbMoney(framework, money)
    local balances = {}

    for neutral, native in pairs(Config.Accounts[framework]) do
        balances[neutral] = money[native]
    end

    return balances
end

---@param framework 'qb'|'qbx'
---@param data table
---@return NoxenPlayer
function Mappers.qbPlayer(framework, data)
    local charinfo = data.charinfo or {}

    return {
        source = data.source,
        identifier = data.citizenid,
        license = data.license,
        name = ('%s %s'):format(charinfo.firstname or '', charinfo.lastname or ''),
        firstName = charinfo.firstname or '',
        lastName = charinfo.lastname or '',
        job = Mappers.qbJob(data.job),
        gang = Mappers.qbGang(data.gang),
        money = Mappers.qbMoney(framework, data.money),
    }
end

---@param job? NoxenJob
---@param jobs string|string[]
---@param minGrade? integer
---@return boolean
function Mappers.matchesJob(job, jobs, minGrade)
    if not job then
        return false
    end

    if minGrade and job.grade < minGrade then
        return false
    end

    if type(jobs) == 'string' then
        return job.name == jobs
    end

    for _, name in pairs(jobs) do
        if job.name == name then
            return true
        end
    end

    return false
end
