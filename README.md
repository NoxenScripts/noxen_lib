# noxen_lib

Bridge et outillage des scripts Noxen, en une seule ressource. Supporte ESX Legacy, QBCore et Qbox.

| Framework | Inventaires | Targets |
|---|---|---|
| ESX | inventaire ESX, ox_inventory | ox_target, qb-target |
| QBCore | qb-inventory | ox_target, qb-target |
| Qbox | ox_inventory | ox_target |

Aucune dépendance hors framework. `noxen_lib` démarre après le framework dans `server.cfg`.

## Utilisation

```lua
shared_script '@noxen_lib/imports.lua'
dependency 'noxen_lib'
```

Le script ne charge que les modules qu'il utilise. L'état du bridge et des callbacks vit une seule fois dans `noxen_lib`.

## Bridge serveur

```lua
local player = nox.bridge:GetPlayer(source)

player:GetIdentifier()
player:GetJob()
player:GetJob2()
player:HasPermission('admin')
player:GetAccountMoney('bank')
player:AddAccountMoney('money', 100, 'reason')
player:RemoveAccountMoney('bank', 50, 'reason')
player:GetInventory()
player:HasItem('bread', 2)
player:CanCarryItem('bread', 2)
player:AddItem('bread', 2, 'reason')
player:RemoveItem('bread', 2, 'reason')
player:ShowNotification('Message', 'success')
```

Comptes : `money`, `bank`, `black_money` (`crypto` sur QBCore et Qbox).

## Bridge client

```lua
local player = nox.bridge.player

player:GetJob()
player:GetAccountMoney('money')
player:HasItem('bread')
player:ShowNotification('Message', 'info')
player:ShowHelpNotification('Message', true)
```

## Callbacks

```lua
nox.events.on.callback('my:name', function(source, reply, value)
    reply(value * 2)
end)

local result = nox.events.emit.callback.await('my:name', 21)
```

## Targets

```lua
local id = nox.target.add_sphere_zone({ coords = coords, radius = 1.5 }, {
    { label = 'Ouvrir', job = 'police', minGrade = 1, onSelect = function(entity) end },
})

nox.target.remove(id)
```

Disponible aussi : `add_box_zone`, `add_entity`, `add_model`, `add_global_vehicle`, `add_global_ped`.

## Règles métier

- Montants et quantités : nombre fini, arrondi à l'entier inférieur, au moins 1. Sinon `false`.
- `RemoveAccountMoney` refuse tout découvert. `AddItem` vérifie la capacité, `RemoveItem` le stock.
- Une réponse de callback n'est acceptée que du joueur interrogé. Les appels sont limités par joueur et par nom.
- Usable items, callbacks et targets sont libérés à l'arrêt de la ressource qui les a créés.
- La metadata d'item est ignorée par l'inventaire ESX.
