local oxmysql = exports.oxmysql
ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('ny8-recel:sellItem')
AddEventHandler('ny8-recel:sellItem', function(item, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local itemData = Config.ItemsToSell[item]
    if not itemData then return end

    local inventoryItem = xPlayer.getInventoryItem(item)
    if inventoryItem.count < count then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = "Tu n'as pas assez de cet objet"
        })
    end

    xPlayer.removeInventoryItem(item, count)
    local totalPrice = itemData.price * count

    if count >= 100 then
        totalPrice = totalPrice + math.floor(totalPrice * 0.10)
    end

    if itemData.dirty then
        xPlayer.addAccountMoney('black_money', totalPrice)
    else
        xPlayer.addMoney(totalPrice)
    end

    -- mise à jour de la réputation en base
    local identifier = xPlayer.getIdentifier()
    oxmysql:execute('UPDATE users SET reputation = reputation + ? WHERE identifier = ?', { count, identifier })

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ("Tu as vendu %sx %s pour %s$%s"):format(count, item, totalPrice, count >= 100 and " 🎁 Bonus inclus" or "")
    })
end)

ESX.RegisterServerCallback("ny8-recel:getReputation", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(0) end

    local identifier = xPlayer.getIdentifier()
    oxmysql:scalar('SELECT reputation FROM users WHERE identifier = ?', { identifier }, function(rep)
        cb(rep or 0)
    end)
end)