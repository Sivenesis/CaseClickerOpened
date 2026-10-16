MissionManager = {
	missions = {
		{newMission = true},
		{
			locked = true,
			rank = 12,
			cost = 2500
		},
		{
			locked = true,
			rank = 18,
			cost = 10000
		}
	}
}
local missions = require("data.missions")
function MissionManager.reset()
	MissionManager.missions = {
		{newMission = true},
		{
			locked = true,
			rank = 12,
			cost = 2500
		},
		{
			locked = true,
			rank = 18,
			cost = 10000
		}
	}
	MissionManager.refreshMissions()
end
function MissionManager.init()
	MissionManager.refreshMissions()
end
function MissionManager.refreshMissions()
	for i, mission in ipairs(MissionManager.missions) do
		if not mission.id and not mission.locked then
			local id, subId
			while true do
				id = math.random(1, #missions)
				local canAdd = true
				if missions[id].canStart and not missions[id].canStart() then
					canAdd = false
				end
				if canAdd then
					if missions[id].getSubId then
						subId = missions[id].getSubId()
					else
						subId = nil
					end
					for j, mission in ipairs(MissionManager.missions) do
						if mission and mission.id == id and mission.subId == subId then
							canAdd = false
						end
					end
				end
				if canAdd then
					break
				end
			end
			MissionManager.missions[i] = {
				id = id,
				subId = subId,
				endValue = missions[id].getValue(subId) + missions[id].getEndValue(subId),
				startValue = missions[id].getValue(subId),
				newMission = true
			}
		end
	end
end
function MissionManager.load(loadTable)
	for i, mission in ipairs(loadTable.missions) do
		MissionManager.missions[i].id = mission.id
		MissionManager.missions[i].subId = mission.subId
		MissionManager.missions[i].locked = mission.locked
		MissionManager.missions[i].startValue = mission.startValue
		MissionManager.missions[i].endValue = mission.endValue
		MissionManager.missions[i].completed = mission.completed
		MissionManager.missions[i].newMission = mission.newMission
	end
end
function MissionManager.save(saveTable)
	saveTable.missions = {}
	for i, mission in ipairs(MissionManager.missions) do
		saveTable.missions[i] = {}
		saveTable.missions[i].id = mission.id
		saveTable.missions[i].subId = mission.subId
		saveTable.missions[i].locked = mission.locked
		saveTable.missions[i].startValue = mission.startValue
		saveTable.missions[i].completed = mission.completed
		saveTable.missions[i].endValue = mission.endValue
		saveTable.missions[i].newMission = mission.newMission
	end
end
function MissionManager.skipMission(missionId)
	local missionId2 = MissionManager.missions[missionId].id
	repeat
		MissionManager.missions[missionId] = {}
		MissionManager.refreshMissions()
	until MissionManager.missions[missionId].id ~= missionId2
end
function MissionManager.skipRandomMission()
	local missions = {}
	for i = 1, #MissionManager.missions do
		if not MissionManager.missions[i].locked then
			table.insert(missions, i)
		end
	end
	local missionId = choose(missions)
	MissionManager.skipMission(missionId)
end
function MissionManager.getMission(missionId)
	return MissionManager.missions[missionId]
end
function MissionManager.completeMission(missionId)
	MissionManager.receiveReward()
	StatisticManager.addStatistic("completedMissions")
	MissionManager.missions[missionId] = {}
	MissionManager.refreshMissions()
end
function MissionManager.getRewards()
	return {
		experience = 500,
		money = 2 + 0.25 * Game.expRank + 10 * Game.others.expResets
	}
end
function MissionManager.receiveReward()
	GUI.showInfoBox("Mission completed", "500 exp awarded", InfoBoxType.experience)
	local rewards = MissionManager.getRewards()
	Game.addExperience(rewards.experience)
	local moneyToAdd = GUI.showInfoBox("Mission completed", "$" .. formatPrice(rewards.money) .. " completion bonus", InfoBoxType.coin)
	Game.addMoney(rewards.money, "Other", "Mission", true)
	Menu.addAlert("Missions")
end
function MissionManager.checkMissionsForCompletion()
	for id, mission in ipairs(MissionManager.missions) do
		if not mission.locked and not mission.completed and missions[mission.id].getValue(mission.subId) >= mission.endValue then
			local missionInfo = MissionManager.getMissionInfo(id)
			GUI.showInfoBox("Mission Completed:", missionInfo.firstText, nil, {
				image = missionInfo.image.path,
				imageWidth = missionInfo.image.width,
				imageHeight = missionInfo.image.height
			})
			MissionManager.missions[id].completed = true
			Menu.addAlert("Missions")
		end
	end
end
function MissionManager.getMissionInfo(missionId)
	local mission = MissionManager.getMission(missionId)
	local value = mission.endValue - mission.startValue
	local image = missions[mission.id].image
	image = image or missions[mission.id].getImage(mission.subId)
	return {
		firstText = missions[mission.id].getDescription(value, mission.subId),
		secondText = missions[mission.id].secondText,
		image = image,
		startValue = mission.startValue,
		endValue = mission.endValue,
		noProgressBar = missions[mission.id].noProgressBar,
		formatValueAsPrice = missions[mission.id].formatValueAsPrice,
		actualValue = missions[mission.id].getValue(mission.subId)
	}
end
function MissionManager.unlockSlot(slotId)
	MissionManager.missions[slotId].locked = nil
	MissionManager.refreshMissions()
end
return MissionManager
